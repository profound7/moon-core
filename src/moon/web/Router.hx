package moon.web;

import haxe.Constraints.Function;
import moon.core.Tuple;
import moon.core.Signal;

#if macro
    import haxe.macro.Context;
    import haxe.macro.Expr;
    import haxe.macro.Type;
    import haxe.macro.TypeTools;
    
    using haxe.macro.ExprTools;
#end

// this does not work due to genericBuild not allowed in macro context
// and router.metaMap uses macros...
//typedef RouterDefines = Map<String, Tuple<String, String->Dynamic>>;

/**
 * A very simple router that uses regular expression and triggers
 * a callback function. Arguments can be typed, with automated
 * run-time conversions.
 * 
 * This router has no concept of paths. It just does a straight
 * regular expression matching, in the order the map() function
 * was called. This router also have no concept of request type
 * (like GET, POST, PUT etc...)
 * 
 * So you can have urls like:
 *      /foo/bar/baz
 * 
 * Or if you prefer it to look like files:
 *      foo-bar-baz.html
 * 
 * This router can do type conversions before triggering the callback.
 * Int and String are pre-defined. For more types, use the define() method.
 * You can also override the Int and String types if you wish
 * to have a different implementation.
 * 
 * For String type, the string value will be url-decoded, since that's
 * the most common use case. If you want the string not url-decoded,
 * use RawString instead, since that's the special case.
 * 
 * Usage:
 *      // Capture 2 digits, and convert those to Int.
 *      router.map("foo/{(\d\d):Int}/bar", function(x:Int){ ... });
 *      
 *      // Captures 1 or more digits, and convert to Int
 *      router.map("foo/{:Int}/bar", function(x:Int){ ... });
 *      
 *      // Captures 1 digit. No conversions, so it defaults to String.
 *      router.map("foo/{(\d)}/baz", function(x:String){ ... });
 *      
 *      // triggers the 2nd map above. `3` is converted to Int.
 *      router.route("foo/3/bar");
 *      
 * @author Munir Hussin
 */
class Router
{
    private static var matcher:EReg = ~/\{((?!:).+?)?(:[A-Za-z][A-Za-z0-9]*)?\}/g;
    
    // Tuple uses genericBuild, which has problems in macro context
    #if !macro
    
    public var routes:Array<RouteEntry>;
    public var defines:Map<String, Tuple<String, String->Dynamic>>;
    public var failed:Signal<RouterException>;
    public var path:String;
    
    public function new(initDefaultDefines:Bool=true)
    {
        routes = [];
        failed = new Signal<RouterException>();
        defines = new Map<String, Tuple<String, String->Dynamic>>();
        
        if (initDefaultDefines)
            defaultDefines();
    }
    
    private function defaultDefines():Void
    {
        // matches digits
        define("Int", "(\\d+)", function(value:String):Dynamic
        {
            return Std.parseInt(value);
        });
        
        // matches any strings excluding slash. decodes url encodings.
        // this is the most common use-case
        define("String", "([^/]+?)", function(value:String):Dynamic
        {
            return StringTools.urlDecode(value);
        });
        
        // matches any string, including slashes
        // rename this? since Path is also an existing abstract in moon lib
        define("Path", "(.*?)", function(value:String):Dynamic
        {
            return value;
        });
        
        // matches any strings excluding slash. does not decode url encodings
        define("RawString", "([^/]+?)", function(value:String):Dynamic
        {
            return value;
        });
    }
    
    private function getRegex(type:String):String
    {
        var regex = defines.get(type).v0;
        if (regex == null)
            throw "Unsupported type";
        return regex;
    }
    
    private function getConvert(type:String):String->Dynamic
    {
        var fn = defines.get(type).v1;
        if (fn == null)
            throw "Unsupported type";
        return fn;
    }
    
    /**
     * Defines a type and map it to a regex and a conversion function.
     * Regex is used when your pattern looks like {:Type}.
     * Conversion function is used when a route matches, and a {*:Type}
     * matched string needs to be converted to the actual type.
     * 
     * Usage:
     *      
     *      router.define("User", "(\\d+)", function(value:String):Dynamic
     *      {
     *          return User.manager.select($id == Std.parseInt(value));
     *      });
     *      
     *      // the callback now supports the User type now that it's defined above
     *      router.map("foo/{:User}/bar", function(user:User)
     *      {
     *          trace("user: " + user.username);
     *      });
     *      
     *      router.route("foo/3/bar"); // triggers the map above
     */
    public inline function define(type:String, regex:String, convert:String->Dynamic):Void
    {
        defines.set(type, new Tuple<String, String->Dynamic>(regex, convert));
    }
    
    /**
     * Maps a pattern to a callback function.
     * Pattern is any valid regular expression.
     * For variable matching, use {regex:Type} where `regex` and `:Type`
     * are optional (provide both or either one).
     * 
     * Example:
     *      // Capture 2 digits, and convert those to Int.
     *      router.map("foo/{(\d\d):Int}/bar", function(x:Int){ ... });
     *      
     *      // Captures 1 or more digits, and convert to Int
     *      router.map("foo/{:Int}/bar", function(x:Int){ ... });
     *      
     *      // Captures 1 digit. No conversions, so it defaults to String.
     *      router.map("foo/{(\d)}/bar", function(x:String){ ... });
     */
    public function map(pattern:String, fn:haxe.Constraints.Function):Void
    {
        var next = pattern;
        var regex = "";
        var types:Array<String> = [];
        
        while (matcher.match(next))
        {
            var r = matcher.matched(1);     // the regex part
            var t = matcher.matched(2);     // the type part
            
            // remove colon, so we just get the type
            if (t != null)
            {
                t = t.substr(1);
            }
            
            // regex not given, only type
            // abc{:Int}def
            if (r == null && t != null)
            {
                r = getRegex(t);
            }
            // type not given, only regex -- type defaults to String
            // abc{(\d+)}def
            else if (r != null && t == null)
            {
                t = "String";
            }
            // both regex and type are specified -- ok
            else if (r != null && t != null)
            {
                // ok
            }
            else
            {
                //trace('wtf?: $r === $t');
                throw "Invalid";
            }
            
            
            //trace('matched: $r === $t');
            
            types.push(t);
            regex += matcher.matchedLeft() + r;
            next = matcher.matchedRight();
        }
        
        // add the remaining leftover pattern
        regex += next;
        
        var rx = new EReg("^" + regex + "$", "g");
        routes.push(new RouteEntry(pattern, regex, rx, types, fn));
    }
    
    
    /**
     * Routes a path and triggers the function of the first matched pattern.
     * When no pattern matches, the failed signal is dispatched.
     */
    public function route(path:String):Bool
    {
        var matchFound:Bool = false;
        var errors:Array<RouterException> = [];
        
        for (entry in routes)
        {
            // a match is found!
            if (entry.rx.match(path))
            {
                matchFound = true;
                
                //trace("matched!!!");
                var types:Array<String> = entry.types;
                var args:Array<Dynamic> = [];
                var val:Dynamic = null;
                var str:String = null;
                
                // convert all the types
                for (i in 0...types.length)
                {
                    str = entry.rx.matched(i + 1);
                    
                    try
                    {
                        var convert = getConvert(types[i]);
                        val = convert(str);
                        args.push(val);
                    }
                    catch (ex:Dynamic)
                    {
                        errors.push(ConversionFailed(path, entry, types[i], str));
                    }
                }
                
                // trigger handler
                try
                {
                    Reflect.callMethod(null, entry.callback, args);
                    return true;
                }
                catch (ex:Dynamic)
                {
                    errors.push(HandlerFailed(path, entry));
                }
            }
        }
        
        if (matchFound == false)
            errors.push(MatchNotFound(path));
        
        if (errors.length > 1)
            failed.dispatch(MultipleErrors(errors));
        else
            failed.dispatch(errors.pop());
        
        return false;
    }
    
    #else // macro
    
    private static function getClassFields(type:Type):Array<ClassField>
    {
        return switch (type)
        {
            // obj ref (instance fields)
            case TInst(ct, _):
                ct.get().fields.get();
                
            // class ref (static fields)
            case TAnonymous(a):
                a.get().fields;
                
            case TDynamic(_):
                throw "Cannot use automap on Dynamic type. Fields must be known at compile-time.";
                
            case _:
                throw "Invalid type: " + type;
        }
    }
    
    private static function parsePatternForTypes(pattern:String):Array<String>
    {
        var next = pattern;
        var regex = "";
        var types:Array<String> = [];
        
        while (matcher.match(next))
        {
            var r = matcher.matched(1);
            var t = matcher.matched(2);
            
            // remove colon
            if (t != null)
                t = t.substr(1);
            
            // abc{:Int}def
            if (r == null && t != null)
            {
                //r = getRegex(t);
            }
            // abc{(\d+)}def
            else if (r != null && t == null)
            {
                t = "String";
            }
            else if (r != null && t != null)
            {
                // ok
            }
            else
            {
                //trace('wtf?: $r === $t');
                throw "Invalid";
            }
            
            //trace('matched: $r === $t');
            
            types.push(t);
            regex += matcher.matchedLeft() + r;
            next = matcher.matchedRight();
        }
        
        return types;
    }
    
    #end
    // both macro and not macro
    
    /**
     * Macro to map paths by @:route meta to its attached method.
     * Usage:
     * router.metaMap(this);    // maps instance fields that has @:route meta
     * router.metaMap(MyClass); // maps static fields that has @:route meta
     * src/moon/web/Router.hx:363: { expr => #function:0, kind => FMethod(MethNormal), meta => { extract => #function:1, add => #function:3, get => #function:0, has => #function:1, remove => #function:1 }, name => test, type => TLazy(#abstract), params => [], doc => null, pos => #pos(test/Foo.hx:34: lines 34-37), isPublic => true }
     */
    public macro function metaMap(ethis:Expr, obj:ExprOf<Dynamic>, doTypeChecking:Bool=true):ExprOf<Void>
    {
        var type = TypeTools.follow(Context.typeof(obj));
        var fields = getClassFields(type);
        
        //var cl = TypeTools.getClass(type);
        //var fields = cl.fields.get();
        //var fields = Context.getLocalClass().get().fields.get();
        
        var exprs:Array<Expr> = [];
        
        for (f in fields)
        {
            if (f.meta.has(":route"))
            {
                var metaEntries = f.meta.extract(":route");
                
                for (metaEntry in metaEntries)
                {
                    var metaParam = metaEntry.params[0];
                    
                    switch (metaParam.expr)
                    {
                        case EConst(CString(pattern)):
                            var fname:String = f.name;
                            var patternTypes = parsePatternForTypes(pattern);
                            var fnType = Context.follow(f.type);
                            
                            switch (fnType)
                            {
                                case TFun(args, ret):
                                    //trace('$path => $fname');
                                    //trace('$pattern => $fname, $patternTypes');
                                    
                                    if (patternTypes.length != args.length)
                                        Context.error('Function requires ${patternTypes.length} args for route $pattern. Given ${args.length}.', f.pos);
                                    
                                    if (doTypeChecking)
                                    {
                                        // type checking
                                        for (i in 0...args.length)
                                        {
                                            var fnArg = args[i].t;
                                            var rtArg = Context.getType(patternTypes[i]);
                                            
                                            if (!Context.unify(rtArg, fnArg))
                                            {
                                                var rtArgType = TypeTools.toString(rtArg);
                                                var fnArgType = TypeTools.toString(fnArg);
                                                var fnArgName = args[i].name;
                                                Context.error('Expected $rtArgType got $fnArgType for argument $fnArgName', f.pos);
                                            }
                                        }
                                    }
                                        
                                    exprs.push(macro { $ethis.map($v { pattern }, $obj.$fname); });
                                    
                                case _:
                                    Context.error( "@:route meta can only be used on methods", metaEntry.pos);
                            }
                            
                            
                        case EConst(CIdent("error")):
                            var fname:String = f.name;
                            exprs.push(macro { $ethis.failed.add($obj.$fname); });
                            
                        case _:
                            Context.error("Invalid route: " + metaParam.toString(), metaParam.pos);
                    }
                }
            }
        }
        
        var m = macro $b{exprs};
        //trace(m.toString().split("\n").join("|"));
        return m;
    }
    
    
}


class RouteEntry
{
    public var pattern:String;
    public var regex:String;
    public var rx:EReg;
    public var types:Array<String>;
    public var callback:haxe.Constraints.Function;
    
    public function new(pattern:String, regex:String, rx:EReg, types:Array<String>,
        callback:haxe.Constraints.Function)
    {
        this.pattern = pattern;
        this.regex = regex;
        this.rx = rx;
        this.types = types;
        this.callback = callback;
    }
}

enum RouterException
{
    MatchNotFound(path:String);
    ConversionFailed(path:String, entry:RouteEntry, type:String, value:String);
    HandlerFailed(path:String, entry:RouteEntry);
    MultipleErrors(errors:Array<RouterException>);
}