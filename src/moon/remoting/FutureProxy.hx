package moon.remoting;

/**
 * Like haxe.remoting.AsyncProxy, FutureProxy works similarly,
 * except that instead of using a callback T->Void, a Future<T>
 * is returned instead.
 * 
 * Unlike haxe.remoting.AsyncProxy, you do not need to extend
 * this class to use it.
 * 
 * Usage:
 * var foo = new FooProxy<Foo>(ctx);
 * 
 * foo.bar(1, 2).onComplete(function(x) trace(x));
 * 
 * foo.bar(1, 2)
 *  .onComplete(function(x) trace(x))
 *  .onFail(function(e) trace(e));
 * 
 * @author Munir Hussin
 */
@:genericBuild(moon.macros.proxy.FutureProxyMacro.build())
class FutureProxy<T>
{
    var __cnx:haxe.remoting.AsyncConnection;
    
    public function new(c:haxe.remoting.AsyncConnection)
    {
        __cnx = c;
    }
}
