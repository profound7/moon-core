package moon.core;

import haxe.ds.Either;
import moon.core.Tuple;
import moon.core.Signal;

/**
 * A Future has 3 possible states:
 * 
 * - Awaiting: Unresolved. Initial state. It's waiting for an outcome.
 * - Success: Resolved. Future completed, and holds a value.
 * - Failure: Resolved. Future failed and holds an error.
 */
enum FutureState<T>
{
    Awaiting;
    Success(v:T);
    Failure(e:Dynamic);
}


/**
 * A Future is a value that may exist some time later in the future.
 * When that time comes, all listeners will receive a callback.
 * If that future fails, a different callback will be triggered.
 * 
 * Register callbacks with onComplete or onFail (or onDone which
 * combines both).
 * 
 * To resolve the future, use complete(value) or fail(error).
 * 
 * Future<Void> doesn't work. Use Future<Unit> instead.
 * 
 * http://tech.pro/blog/6742/callback-to-future-functor-applicative-monad
 * https://web.archive.org/web/20150405010543/http://tech.pro/blog/6742/callback-to-future-functor-applicative-monad
 * https://gist.github.com/yelouafi/40aeb2a70a368acb6e45
 * 
 * @author Munir Hussin
 */
class Future<T>
{
    public var state(default, null):FutureState<T>;     // holds the value
    
    public var isDone(get, never):Bool;
    public var value(get, never):T;
    public var error(get, never):Dynamic;
    
    private var succeeded:Signal<T>;                    // on complete
    private var failed:Signal<Dynamic>;                 // on failed
    private var resolved:Signal<Dynamic, T>;            // on complete/failed
    
    
    public function new() 
    {
        state = Awaiting;
        
        succeeded = new Signal<T>();
        failed = new Signal<Dynamic>();
        resolved = new Signal<Dynamic, T>();
    }
    
    /*==================================================
        Static methods
    ==================================================*/
    
    /**
     * Returns a Future that completes to a `value` after `time_ms` milliseconds.
     */
    public static function delay<S>(value:S, time_ms:Int):Future<S>
    {
        var f:Future<S> = new Future<S>();
        Invoke.later(function() { f.complete(value); }, time_ms);
        return f;
    }
    
    /**
     * Turn a regular value into a Future value.
     */
    public static function unitValue<S>(val:S):Future<S>
    {
        var f:Future<S> = new Future<S>();
        f.complete(val);
        return f;
    }
    
    /**
     * Returns a Future that has failed.
     */
    public static function unitError<S>(err:Dynamic):Future<S>
    {
        var f:Future<S> = new Future<S>();
        f.fail(err);
        return f; 
    }
    
    /**
     * Transform a 2-layer future into a simple future.
     * ie:
     *      Future<Future<S>> ==> Future<S>
     */ 
    public static function flatten<S>(f1:Future<Future<S>>):Future<S>
    {
        var f:Future<S> = new Future<S>();
        
        f1.onFail(function(err:Dynamic):Void
        {
            f.fail(err);
        });
        
        f1.onComplete(function(f2:Future<S>):Void
        {
            f2.onFail(function(err:Dynamic):Void
            {
                f.fail(err);
            });
            
            f2.onComplete(function(val:S):Void
            {
                f.complete(val);
            });
        });
        
        return f;
    }
    
    /**
     * Takes in a function that works on values, and
     * turns it into a function that works on Futures.
     * ie:
     *      Array<Int>->Float
     * becomes:
     *      Array<Future<Int>>->Future<Float>
     * 
     * So for example,
     *      function foo(args:Array<String>):Int
     *      {
     *          var total = 0;
     *          for (x in args) total += x.length;
     *          return total;
     *      }
     * 
     * But I have
     *      var futNames:Array<Future<String>> =
     *      [
     *          fetchUsernameById(2),
     *          fetchUsernameById(7),
     *          fetchUsernameById(8),
     *      ]
     * 
     * So instead of calling foo which expects
     * immediate values, I do this:
     *      var bar = Future.lift(foo);
     *      var futResult:Future<Int> = bar(futNames);
     */
    public static function lift<P,Q>(fn:Array<P>->Q):Array<Future<P>>->Future<Q>
    {
        return function(fArgs:Array<Future<P>>):Future<Q>
        {
            function bindArgs(index:Int, vArgs:Array<P>):Future<Q>
            {
                return fArgs[index].flatMap(function(val:P)
                {
                    //vArgs = vArgs.concat(val);
                    vArgs.push(val);
                    
                    return (index < fArgs.length - 1) ?
                        bindArgs(index + 1, vArgs) :
                        Future.unitValue(fn(vArgs));
                });
            };
            
            return bindArgs(0, []);
        }
    }
    
    
    
    /**
     * Convert an array of Futures into a Future array.
     * The Future array will be completed when all the
     * Futures in the array has completed.
     * ie:
     *      Array<Future<S>> ==> Future<Array<S>>
     */
    public static function array<S>(arr:Array<Future<S>>):Future<Array<S>>
    {
        var f:Future<Array<S>> = new Future<Array<S>>();
        
        var results:Array<S> = [];
        var errors:Array<Dynamic> = [];
        
        var numOk:Int = 0;
        var numErr:Int = 0;
        
        for (i in 0...arr.length)
        {
            arr[i].onComplete(function(x:S):Void
            {
                results[i] = x;
                numOk++;
                
                // when everything completed, trigger the callback
                if (numOk == arr.length)
                {
                    f.complete(results);
                }
                else if (numOk + numErr == arr.length)
                {
                    f.fail(errors);
                }
            });
            
            arr[i].onFail(function(e:Dynamic):Void
            {
                errors[i] = e;
                numErr++;
               
                if (numOk + numErr == arr.length)
                {
                    f.fail(errors);
                }
            });
        }
        
        return f;
    }
    
    /**
     * Wraps a function that might throw an error into the Future form.
     */
    public static inline function wrap<S>(fn:Void->S):Future<S>
    {
        var ret:Future<S> = new Future<S>();
        try ret.complete(fn())
        catch (ex:Dynamic) ret.fail(ex);
        return ret;
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    // not inlining because it causes compiler to go crazy sometimes.
    // see the or function for more details.
    private inline function get_isDone():Bool
    {
        return state != Awaiting;
    }
    
    private inline function get_value():T
    {
        return switch(state)
        {
            case Success(v): v;
            case _: throw "No value";
        }
    }
    
    private inline function get_error():Dynamic
    {
        return switch(state)
        {
            case Failure(e): e;
            case _: throw "No error";
        }
    }
    
    /*==================================================
        Methods
    ==================================================*/
    
    /**
     * Register callback that triggers when Future has completed.
     * Returns this Future, for method chaining.
     */
    public function onComplete(slot:T->Void):Future<T>
    {
        switch (state)
        {
            case Awaiting:
                succeeded.add(slot);
                
            case Success(v):
                slot(v);
                
            case _:
        }
        
        return this;
    }
    
    /**
     * Register callback that triggers when Future has failed.
     * Returns this Future, for method chaining.
     */
    public function onFail(slot:Dynamic->Void):Future<T>
    {
        switch (state)
        {
            case Awaiting:
                failed.add(slot);
                
            case Failure(e):
                slot(e);
                
            case _:
        }
        
        return this;
    }
    
    /**
     * Register callback that triggers when Future has either
     * completed or failed.
     * Returns this Future, for method chaining.
     */
    public function onDone(slot:Dynamic->T->Void):Future<T>
    {
        switch (state)
        {
            case Awaiting:
                resolved.add(slot);
                
            case Success(v):
                slot(null, v);
                
            case Failure(e):
                slot(e, null);
        }
        
        return this;
    }
    
    
    /**
     * Completes this Future, and trigger all registered callbacks.
     */
    public function complete(value:T, noThrow:Bool=true):Void
    {
        switch (state)
        {
            case Awaiting:
                // yay
                state = Success(value);
                succeeded.dispatch(value);
                resolved.dispatch(null, value);
                
            case _:
                if (noThrow)
                    return;
                else
                    throw "Cannot complete an already settled future!";
        }
    }
    
    /**
     * Fails this Future, and trigger all registered callbacks.
     */
    public function fail(error:Dynamic, noThrow:Bool=true):Void
    {
        switch (state)
        {
            case Awaiting:
                // nay
                state = Failure(error);
                failed.dispatch(error);
                resolved.dispatch(error, null);
                
            case _:
                if (noThrow)
                    return;
                else
                    throw "Cannot fail an already settled future!";
        }
    }
    
    /**
     * Handy function that outputs the value of this Future
     * when it has completed or failed.
     */
    public function log(prefix:String=""):Future<T>
    {
        //onComplete(function(val:T):Void trace(val));
        onComplete(function(x:T):Void trace("COMPLETE: " + prefix + x));
        onFail(function(x:T):Void trace("FAIL: " + prefix + x));
        return this;
    }
    
    
    /**
     * Create new Future that is chained by this Future.
     * The new Future will receive a transformed value
     * from this Future.
     */
    public function map<U>(fn:T->U):Future<U>
    {
        var f:Future<U> = new Future<U>();
        
        onComplete(function(val:T):Void
        {
            try
            {
                f.complete(fn(val));
            }
            catch (err:Dynamic)
            {
                f.fail(err);
            }
        });
        
        //onFail(function(err:Dynamic):Void f.fail(err));
        chainError(f);
        
        return f;
    }
    
    /**
     * Create new Future, such that if this Future fails,
     * the new Future can still complete through the
     * mapped function.
     */
    public function mapError(fn:Dynamic->T):Future<T>
    {
        var f:Future<T> = new Future<T>();
        
        onComplete(function(val:T):Void
        {
            f.complete(val);
        });
        
        onFail(function(err:Dynamic):Void
        {
            try
            {
                f.complete(fn(err));
            }
            catch (err1:Dynamic)
            {
                f.fail(err1);
            }
        });
        
        return f;
    }
    
    /**
     * Like map, but the value is transformed into another Future.
     * This is useful for passing the value to a function that
     * returns a Future.
     * 
     * The result is flattened, so you don't get nested Futures.
     * 
     *      var dirF:Future<Array<String>> = readDirF("blah");
     *      dirF.fmap(function(files:Array<String>):Future<Int>
     *      {
     *          return readFileLenF(files[0]);
     *      });
     */ 
    public inline function flatMap<U>(fn:T->Future<U>):Future<U>
    {
        return Future.flatten(map(fn));
    }
    
    /**
     * Same as flatMap, but maps the errors instead.
     */
    public inline function flatMapError(fn:Dynamic->Future<T>):Future<T>
    {
        // NOTICE: did i get this right with my types? and how its mapped?
        //return Future.flatten(mapError(fn));
        
        var f:Future<T> = new Future<T>();
        
        onComplete(function(val:T):Void
        {
            f.complete(val);
        });
        
        onFail(function(err:Dynamic):Void
        {
            try
            {
                fn(err).chain(f);
            }
            catch (err1:Dynamic)
            {
                f.fail(err1);
            }
        });
        
        return f;
    }
    
    
    /**
     * When this Future is completed or failed, trigger the completion of
     * the next Future. The value from this future is transformed and
     * passed to the next Future.
     */
    public function chainMap<U>(next:Future<U>, fn:T->U):Future<T>
    {
        onComplete(function(value:T):Void
        {
            try
            {
                next.complete(fn(value));
            }
            catch (err:Dynamic)
            {
                next.fail(err);
            }
        });
        
        chainError(next);
        return this;
    }
    
    /**
     * If the current Future succeeds, make the next Future succeed.
     */
    public function chainValue(next:Future<T>):Future<T>
    {
        onComplete(function(value:T):Void
        {
            //if (!next.isDone) // is this check necessary?
                next.complete(value);
        });
        return this;
    }
    
    /**
     * If the current Future fails, make the next Future fail.
     */
    public function chainError<U>(next:Future<U>):Future<T>
    {
        onFail(function(err:Dynamic):Void
        {
            //if (!next.isDone) // is this check necessary?
                next.fail(err);
        });
        return this;
    }
    
    /**
     * If the current Future succeeds, make the next Future succeed.
     * If the current Future fails, make the next Future fail.
     * 
     * Chaining multiple
     * f1.chain(f2).chain(f3).chain(f4);
     */
    public function chain(next:Future<T>):Future<T>
    {
        chainValue(next);
        chainError(next);
        return this;
    }
    
    /**
     * This is chain, but in the other direction.
     * Make this Future succeed when the other Future succeed.
     * Make this Future fail when the other Future fail.
     * 
     * This is only for readability. In some situations, it might be
     * more natural to read this way.
     * 
     * fut.completeWhen(fetchName() && fetchAddress() && fetchItems());
     * vs
     * (fetchName() && fetchAddress() && fetchItems()).chain(fut);
     */
    public function completeWhen(other:Future<T>):Future<T>
    {
        other.chain(this);
        return this;
    }
    
    /**
     * Return a Future that will trigger when both this Future
     * and the other Future has completed.
     * 
     * The returned Future will hold a pair of both values.
     * 
     * var f = f1.and(f2).and(f3).and(f4);
     */
    public function and<U>(other:Future<U>):Future<Tuple<T, U>>
    {
        var ret = new Future<Tuple<T, U>>();
        
        // when both succeeds, then final outcome succeeds
        this.onComplete(function(t:T)
        {
            other.onComplete(function(u:U)
            {
                ret.complete(new Tuple<T,U>(t, u));
            });
        });
        
        this.chainError(ret);
        other.chainError(ret);
        return ret;
    }
    
    /**
     * Return a Future that will trigger when either this Future
     * or the other Future has completed, whichever is first.
     * 
     * The returned Future will hold a pair containing the
     * completed value in it's called position, and null in the other.
     */
    public function or<U>(other:Future<U>):Future<Either<T, U>>
    {
        var ret:Future<Either<T, U>> = new Future<Either<T, U>>();
        
        this.onComplete(function(t:T)
        {
            // WTF: !ret.isDone causes compiler to go crazy...
            // but only when isDone property is inlined
            
            //if (!ret.isDone)          // uncomment this and comment next line
            if (ret.state == Awaiting)  // to see what I mean...
            {
                ret.complete(Left(t));
            }
        });
        
        other.onComplete(function(u:U)
        {
            //if (!ret.isDone)
            if (ret.state == Awaiting)
            {
                ret.complete(Right(u));
            }
        });
        
        // when both fails, then fail final outcome
        this.onFail(function(t:Dynamic)
        {
            other.onFail(function(u:Dynamic)
            {
                ret.fail(new Tuple<T,U>(t, u));
            });
        });
        
        return ret;
    }
    
    /*==================================================
        Conversions
    ==================================================*/
        
    public function toString():String
    {
        return '<$state>';
    }
}
