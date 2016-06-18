package moon.macros.proxy;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import moon.core.Pair;

using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
using haxe.macro.TypedExprTools;
using haxe.macro.ExprTools;
using moon.tools.EnumTools;

/**
 * ...
 * @author Munir Hussin
 */
class FutureProxyMacro
{
    public static var cache = new Map<String, Bool>();
    
    public static function build():Type
    {
        //trace("BUILD FutureProxy----------------");
        return switch (Context.getLocalType())
        {
            case TInst(_.get() => { name: "FutureProxy" }, [param]):
                createProxyType(param, Context.currentPos()).toType();
                
            case t:
                Context.error('Invalid type $t', Context.currentPos());
        }
    }
    
    public static function createProxyType(type:Type, pos:Position):ComplexType
    {
        return switch (type)
        {
            case TInst(_.get() => t, _):
                defineProxyType(t, pos);
                
            case _:
                Context.error('Invalid type $type', pos);
        }
    }
    
    public static function defineProxyType(classType:ClassType, pos:Position):ComplexType
    {
        // FieldKind (cf): FVar | FMethod
        // FieldType (f):  FVar | FFun | FProp
        // MethodKind: MethNormal | MethInline | MethDynamic | MethMacro
        
        var paramName = classType.name;
        var className = 'FutureProxy_$paramName';
        
        var localClass = Context.getLocalClass().get();
        var pack = localClass.pack;
        var module = pack.concat([localClass.name]);
        
        var selfType = { pack: pack, name: className };
        
        
        if (!cache.exists(className))
        {
            var classFields = classType.fields.get();
            var fields:Array<Field> = Context.getBuildFields();
            var unitType:ComplexType = macro:moon.core.Types.Unit;
            
            // pick all public methods of the param type
            for (cf in classFields)
            {
                switch (cf)
                {
                    case { isPublic: true, kind: FMethod(_) }:
                        
                        var field:Field = toField(cf);
                        
                        
                        switch (field.kind)
                        {
                            case FFun({ args: args, ret: ret, expr: _, params: params }):
                                
                                // change Void to Unit
                                switch (ret)
                                {
                                    case macro:StdTypes.Void:
                                        ret = unitType;
                                        
                                    case _:
                                }
                                
                                var fut = wrapFutureType(ret);
                                var expr:Expr = generateCode(ret, fut, cf.name, args, pos);
                                field.kind = FFun({ args: args, ret: fut, expr: expr, params: params });
                                
                            case _:
                                throw 'Unexpected field type';
                        }
                        
                        fields.push(field);
                        
                    case _:
                        // ignore other field types
                }
            }
            
            
            Context.defineType(
            {
                pack: pack,
                name: className,
                pos: pos,
                params: [],
                kind: TDClass(),
                fields: fields
            });
            
            //trace('created $pack.$className ');
            //trace("fields: " + [for (f in fields) f.name]);
            cache[className] = true;
        }
        
        
        return TPath(selfType);
    }
    
    
    public static function toTypeParamDecl(type:Type):TypeParamDecl
    {
        return switch (type)
        {
            case TInst(_.get() => { kind: KTypeParameter(constraints), name: name }, params):
                {
                    name: name,
                    constraints: [for (c in constraints) c.toComplexType()],
                    params: [for (p in params) toTypeParamDecl(p)],
                }
                
            case _:
                throw 'Not a type parameter $type';
        }
    }
    
    /**
     * T => Future<T>
     */
    public static inline function wrapFutureType(t:ComplexType):ComplexType
    {
        return TPath({ pack: ["moon", "core"], name: "Future", params: [TPType(t)] });
    }
    
    public static inline function toTypePath(ct:ComplexType):TypePath
    {
        return switch (ct)
        {
            case TPath(p): p;
            case _: throw 'Not a TypePath';
        }
    }
    
    public static function generateCode(valType:ComplexType, futType:ComplexType, method:String, args:Array<FunctionArg>, pos:Position):Expr
    {
        var futPath = toTypePath(futType);
        var vals = [for (a in args) macro $i{a.name}];
        
        return macro
        {
            var __fut = new $futPath();
            
            try
            {
                var __method = __cnx.resolve($v{method});
                __method.setErrorHandler(function(ex) __fut.fail(ex));
                __method.call($a{vals}, function(ret:$valType) __fut.complete(ret));
            }
            catch (ex:Dynamic)
            {
                __fut.error(ex);
            }
            
            return __fut;
        }
    }
    
    
    public static function toField(cf:ClassField):Field
    {
        return
        {
            name: cf.name,
            doc: cf.doc,
            access: cf.isPublic ? [APublic] : [APrivate],
            kind: switch ([cf.kind, cf.type])
            {
                case [FMethod(_), retType]:
                    
                    var args;
                    var ret;
                    
                    switch (retType)
                    {
                        case TFun(a, r):
                            args = a;
                            ret = r;
                            
                        case TLazy(_() => TFun(a, r)):
                            args = a;
                            ret = r;
                            
                        case _:
                            throw 'Unexpected return type $retType';
                    }
                    
                    FFun(
                    {
                        args: [for (a in args) { name: a.name, opt: a.opt, type: a.t.toComplexType() }],
                        ret: ret.toComplexType(),
                        expr: null,
                        params: [for (p in cf.params) toTypeParamDecl(p.t)]
                    });
                    
                case [k, t]:
                    
                    throw 'Unexpected field type $k, $t';
            },
            pos: cf.pos,
            meta: cf.meta.get(),
        }
    }
}


/**
    class ApiProxy extends AsyncProxy<Api> { }
    ==>
    class ApiImpl
    {
        var __cnx : haxe.remoting.AsyncConnection;
        
        function new(c)
        {
            __cnx = c;
        }
        
        public function foo(x:Int, y:Int, __callb:Int->Void)
        {
            __cnx.foo.call([x, y], __callb);
        }
    }
    
    class ApiProxy extends ApiImpl {}
**/
    
/**
    class ApiProxy extends FutureProxy<Api> { }
    ==>
    class ApiImpl
    {
        var __cnx : haxe.remoting.AsyncConnection;
        
        function new(c)
        {
            __cnx = c;
        }
        
        public function foo(x:Int, y:Int):Future<Int>
        {
            var fut = new Future<Int>();
            try
            {
                // don't cache the method, so that every call to foo
                // will have its own error handler
                
                var method = __cnx.resolve("foo");
                method.setErrorHandler(function(ex) fut.fail(ex));
                method.call([x, y], function(ret:Int) fut.complete(ret));
            }
            catch (ex:Dynamic)
            {
                fut.fail(ex);
            }
            return fut;
        }
    }
    
    class ApiProxy extends ApiImpl {}
    
    
    public function foo(x:Int, y:Int):Float             ==>     public function foo(x:Int, y:Int):Future<Float>
    
    do a similar thing for sys classes? eg.
    
    class FileSystem
    {
        public static function exists(name:String):Bool { ... }
    }
    
    // we want a future version..
    class FutureFileSystem implements FutureInterface<FileSystem> // checks that FutureFileSystem has all fields of FileSystem
    {
        public static function exists(name:String):Future<Bool> { ... }
    }
**/