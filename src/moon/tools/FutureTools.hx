package moon.tools;

import moon.core.Callback;
import moon.core.Future;

/**
 * ...
 * @author Munir Hussin
 */
@:deprecated("Use CallbackTools")
class FutureTools
{
    /**
     * Converting from continuation passing style to futures:
     *  - Create a Future object, eg: var f = new Future<Something>();
     *  - Wherever a callback is expected as an argument,
     *    put f.callback() instead
     * 
     * The error is expected to be the first argument of the callback,
     * in order to trigger failure.
     * 
     * Example. Instead of:
     *      fetchPage("index.html", "GET", function(err:Dynamic, val:String)
     *      {
     *          doSomething(val);
     *      });
     *   
     * Do this instead:
     *      var f:Future<String> = new Future<String>();
     *      fetchPage("index.html", "GET", f.callback());
     *      
     *      f.onComplete(function(val:String)
     *      {
     *          doSomething(val);
     *      });
     */
    public static inline function callback<T>(fut:Future<T>):Callback<T>
    {
        return function(err:Dynamic, val:T):Void
        {
            if (err != null) fut.fail(err);
            else fut.complete(val);
        }
    }
    
}