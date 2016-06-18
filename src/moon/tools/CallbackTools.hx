package moon.tools;

import haxe.Constraints.Function;
import moon.core.Callback;
import moon.core.Future;

using moon.tools.FutureTools;

/**
 * Callback<T> = Callback2<Error, T> = Error->T->Void;
 * @author Munir Hussin
 */
class CallbackTools
{
    /**
     * Calls the function that expects a callback (Error->T->Void) as
     * the last argument, and returns a Future instead.
     * 
     * You should not pass in a callback function as the last argument,
     * as that will be automatically done to create the Future.
     * 
     * The arguments are dynamic and can handle any number of arguments.
     * For the typed version, use fn.future()
     * 
     * Usage:
     *      Let's say there's a
     *      function foo(aaa:Int, bbb:Float, cb:Callback<Float>):Void
     *      
     *      Then instead of calling like so:
     *      foo(2, 3.4, function(x) { ... });
     *      
     *      You call like so to get a Future instead:
     *      var f:Future<Float> = foo.asyncCall([2, 3.4]);
     *      
     *      Alternatively, but with type checking:
     *      var f = foo.future(2, 3.4);
     */
    public static function asyncCall<Z>(fn:Function, args:Array<Dynamic>):Future<Z>
    {
        var fut = new Future<Z>();
        try Reflect.callMethod(null, fn, args.concat([fut.callback()]))
        catch (ex:Dynamic) fut.fail(ex);
        return fut;
    }
}

class Callback0Tools
{
    public static function future<Z>(fn:Callback<Z>->Void):Future<Z>
    {
        var fut = new Future<Z>();
        try fn(fut.callback())
        catch (ex:Dynamic) fut.fail(ex);
        return fut;
    }
}

class Callback1Tools
{
    public static function future<A,Z>(fn:A->Callback<Z>->Void, a:A):Future<Z>
    {
        var fut = new Future<Z>();
        try fn(a, fut.callback())
        catch (ex:Dynamic) fut.fail(ex);
        return fut;
    }
}

class Callback2Tools
{
    public static function future<A,B,Z>(fn:A->B->Callback<Z>->Void, a:A, b:B):Future<Z>
    {
        var fut = new Future<Z>();
        try fn(a, b, fut.callback())
        catch (ex:Dynamic) fut.fail(ex);
        return fut;
    }
}

class Callback3Tools
{
    public static function future<A,B,C,Z>(fn:A->B->C->Callback<Z>->Void, a:A, b:B, c:C):Future<Z>
    {
        var fut = new Future<Z>();
        try fn(a, b, c, fut.callback())
        catch (ex:Dynamic) fut.fail(ex);
        return fut;
    }
}

class Callback4Tools
{
    public static function future<A,B,C,D,Z>(fn:A->B->C->D->Callback<Z>->Void, a:A, b:B, c:C, d:D):Future<Z>
    {
        var fut = new Future<Z>();
        try fn(a, b, c, d, fut.callback())
        catch (ex:Dynamic) fut.fail(ex);
        return fut;
    }
}

class Callback5Tools
{
    public static function future<A,B,C,D,E,Z>(fn:A->B->C->D->E->Callback<Z>->Void, a:A, b:B, c:C, d:D, e:E):Future<Z>
    {
        var fut = new Future<Z>();
        try fn(a, b, c, d, e, fut.callback())
        catch (ex:Dynamic) fut.fail(ex);
        return fut;
    }
}
