package moon.core;

import haxe.macro.Context;
import haxe.macro.Expr;
import moon.macros.async.AsyncTransformer;

using haxe.macro.Tools;

/**
 * function(...):Iterator<T>        generator       default if no type given
 * function(...):Iterable<T>        generator
 * function(...):Seq<T>             generator
 * function(...):Generator<T,U>     generator
 * function(...):Fiber<T>           fiber
 * function(...):Future<T>          fiber
 * function(...):Signal<T>          fiber
 * function(...):Observable<T>      fiber
 * 
 * @author Munir Hussin
 */
class Async
{
    
    /**
     * Create a generator from the function given.
     * Function return type can be:
     *      Generator<T,V>
     *      Iterator<T>
     *      Iterable<T>
     * 
     * Usage:
     *  var gen = Async.gen(function(...):Generator<String, Float>
     *  {
     *      var x:Float = @yield "hello";
     *      var y:Float = @yield "world";
     *  });
     */
    public static macro function async(expr:Expr):Expr
    {
        //trace("-----"); trace("-----");
        
        return switch (expr.expr)
        {
            case EFunction(name, fn):
                
                var ab = new AsyncTransformer(name, fn, expr.pos);
                fn.expr = ab.build();
                return expr;
                
            case _:
                throw Context.error("Expected function", expr.pos);
        }
    }
    
    
}

enum AsyncException
{
    InvalidState(state:Int);
    FunctionEnded;
}
