package moon.macros.async;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;
using moon.macros.async.AsyncMacroTools;

/**
 * 
 * The current yield implementation is designed to behave more like
 * the js/python generators. Use @yield expr to return the value of
 * expr when next() is called. Note that @yield is not a statement,
 * but an expression, and @yield can have a value itself, which is
 * retrieved from the argument in next(arg);
 * 
 * A Generator<T,V> has 3 methods, hasNext:Bool, next:Void->T
 * and send:V->T, which is kinda like iterators.
 * 
 * You can retrieve the next value using next(), and you can also
 * pass a value back into the generator and receive the next value
 * by using send(valToSend)
 * 
 * References:
 * http://stackoverflow.com/questions/131871/algorithm-for-implementing-c-sharp-yield-statement
 * https://blogs.msdn.microsoft.com/oldnewthing/20080812-00/?p=21273
 * 
 * js generator api
 * https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Generator
 * 
 * python
 * http://pythoncentral.io/python-generators-and-yield-keyword/
 * 
 * @author Munir Hussin
 */
class AsyncBuilder
{
    
    public static function build(?fields:Array<Field>):Array<Field>
    {
        //trace("------------"); trace("------------");
        if (fields == null) fields = Context.getBuildFields();
        
        // look for generators, fibers, and green threads
        
        for (f in fields)
        {
            switch (f.kind)
            {
                case FFun(fn):
                    //trace(f.name, isGenerator(fn));
                    var isAsync:Bool = false;
                    
                    for (m in f.meta)
                    {
                        switch (m.name)
                        {
                            case "async":
                                isAsync = true;
                                
                            case _:
                                // ignore other metas
                        }
                    }
                    
                    if (isAsync || fn.isGenerator())
                    {
                        // create the async function
                        f.kind = FFun(make(f.name, fn, f.pos));
                    }
                    else
                    {
                        // look for nested async functions
                        fn.expr = transform(fn.expr);
                    }
                    
                case _:
            }
        }
        
        return fields;
    }
    
    
    
    /**
     * Look for generator function expressions and transform those
     */
    public static function transform(e:Expr):Expr
    {
        return switch (e.expr)
        {
            case EMeta({ name: "async", params: params }, { expr: EFunction(name, fn), pos: pos }):
                
                //{ expr: EFunction(name, make(name, fn, pos)), pos: pos };
                
                // inner one first
                fn.expr = transform(fn.expr);
                var expr = { expr: EFunction(name, fn), pos: e.pos };
                return macro moon.core.Async.async($expr);
                
            // no meta, but contains @yield, so imply its a generator also
            case EFunction(name, fn) if (fn.isGenerator()):
                
                //{ expr: EFunction(name, make(name, fn, e.pos)), pos: e.pos };
                // function name() { expr } ==> moon.core.Async.async(function name() { expr });
                
                // inner one first
                fn.expr = transform(fn.expr);
                var expr = { expr: EFunction(name, fn), pos: e.pos };
                return macro moon.core.Async.async($expr);
                
            case _:
                e.map(transform);
        }
    }
    
    public static function make(name:String, fn:Function, pos:Position):Function
    {
        // nested functions? handle the inner ones first.
        fn.expr = transform(fn.expr);
        //trace(fn.ret);
        
        // build the generator
        var ab = new AsyncTransformer(name, fn, pos);
        fn.expr = ab.build();
        
        // return the transformed function
        return fn;
    }
    
}