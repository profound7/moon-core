package moon.tools;

import haxe.Constraints.Function;
import haxe.Serializer;
import haxe.ds.ObjectMap;
import moon.core.Types.Resolver;
import moon.data.resolvers.IndexedResolver;
import moon.data.map.LruCache;


/**
 * Unlike some other memoize implementations out there, this implementation
 * makes use of Least-Recently-Used (LRU) cache for better performance.
 * 
 * For functions up to 5 arguments, type-hinted versions will
 * be used instead when used with `using moon.tools.FunctionTools`.
 * 
 * @author Munir Hussin
 */
class FunctionTools
{
    public static inline var CAPACITY = 128;
    
    /**
     * 
     */
    public static inline function call<T>(fn:Function, args:Array<Dynamic>):T
    {
        return Reflect.callMethod(null, fn, args);
    }
    
    /**
     * Returns a function, that when called, will use the cached
     * results (based on the arguments give) when available.
     * 
     * @param capacity Capacity is maximum number of results the
     * LRU Cache can store. When the cache is full, the
     * Least-Recently-Used entry gets evicted from the cache,
     * before adding another entry.
     * 
     * @param resolver A function that takes in any number of arguments,
     * and returns a String key that is used to identify unique
     * argument values. @see Resolver.serialize, Resolver.join
     */
    public static function memoize(fn:Function, capacity:Int=CAPACITY, ?resolver:Resolver):Function
    {
        var cache:LruCache<Dynamic> = new LruCache<Dynamic>(capacity);
        //cache.evicted.add(function(k, v) trace('evicted: $k = $v'));
        
        if (resolver == null) resolver = new IndexedResolver();
        
        var memoized = function(args:Dynamic):Dynamic
        {
            var key:String = resolver.resolve(args);
            
            if (cache.exists(key))
            {
                //trace("exist! " + key);
                return cache.get(key);
            }
            else
            {
                var result:Dynamic = call(fn, args);
                cache.set(key, result);
                return result;
            }
        };
        
        return Reflect.makeVarArgs(memoized);
    }
}




class Function0Tools
{
    /*public static function memoize<R>(fn:Void->R):Void->R
    {
        var value:Maybe<R> = None;
        
        return function():R
        {
            return switch (value)
            {
                case None:
                    var v = fn();
                    value = Some(v);
                    v;
                    
                case Some(v):
                    v;
            }
        }
    }*/
    
    
    // in this one, if fn is null, no error.
    // in the above one, if fn is null, error occurs when calling the fn.
    
    /**
     * Returns a function, that when called, will use the cached
     * results (based on the arguments give) when available.
     */
    public static function memoize<R>(fn:Void->R):Void->R
    {
        var value:R = null;
        var called:Bool = false;
        
        return function():R
        {
            if (called)
            {
                return value;
            }
            else
            {
                called = true;
                value = fn();
                fn = null;
                return value;
            }
        }
    }
}

class Function1Tools
{
    /**
     * Returns a function, that when called, will use the cached
     * results (based on the arguments give) when available.
     * 
     * @param capacity Capacity is maximum number of results the
     * LRU Cache can store. When the cache is full, the
     * Least-Recently-Used entry gets evicted from the cache,
     * before adding another entry.
     * 
     * @param resolver A function that takes in any number of arguments,
     * and returns a String key that is used to identify unique
     * argument values. @see Resolver.serialize, Resolver.join
     */
    public static function memoize<A,Z>(fn:A->Z, capacity:Int=FunctionTools.CAPACITY, ?resolver:Resolver):A->Z
    {
        return cast FunctionTools.memoize(fn, capacity, resolver);
    }
}

class Function2Tools
{
    /**
     * Returns a function, that when called, will use the cached
     * results (based on the arguments give) when available.
     * 
     * @param capacity Capacity is maximum number of results the
     * LRU Cache can store. When the cache is full, the
     * Least-Recently-Used entry gets evicted from the cache,
     * before adding another entry.
     * 
     * @param resolver A function that takes in any number of arguments,
     * and returns a String key that is used to identify unique
     * argument values. @see Resolver.serialize, Resolver.join
     */
    public static function memoize<A,B,Z>(fn:A->B->Z, capacity:Int=FunctionTools.CAPACITY, ?resolver:Resolver):A->B->Z
    {
        return cast FunctionTools.memoize(fn, capacity, resolver);
    }
}

class Function3Tools
{
    /**
     * Returns a function, that when called, will use the cached
     * results (based on the arguments give) when available.
     * 
     * @param capacity Capacity is maximum number of results the
     * LRU Cache can store. When the cache is full, the
     * Least-Recently-Used entry gets evicted from the cache,
     * before adding another entry.
     * 
     * @param resolver A function that takes in any number of arguments,
     * and returns a String key that is used to identify unique
     * argument values. @see Resolver.serialize, Resolver.join
     */
    public static function memoize<A,B,C,Z>(fn:A->B->C->Z, capacity:Int=FunctionTools.CAPACITY, ?resolver:Resolver):A->B->C->Z
    {
        return cast FunctionTools.memoize(fn, capacity, resolver);
    }
}

class Function4Tools
{
    /**
     * Returns a function, that when called, will use the cached
     * results (based on the arguments give) when available.
     * 
     * @param capacity Capacity is maximum number of results the
     * LRU Cache can store. When the cache is full, the
     * Least-Recently-Used entry gets evicted from the cache,
     * before adding another entry.
     * 
     * @param resolver A function that takes in any number of arguments,
     * and returns a String key that is used to identify unique
     * argument values. @see Resolver.serialize, Resolver.join
     */
    public static function memoize<A,B,C,D,Z>(fn:A->B->C->D->Z, capacity:Int=FunctionTools.CAPACITY, ?resolver:Resolver):A->B->C->D->Z
    {
        return cast FunctionTools.memoize(fn, capacity, resolver);
    }
}

class Function5Tools
{
    /**
     * Returns a function, that when called, will use the cached
     * results (based on the arguments give) when available.
     * 
     * @param capacity Capacity is maximum number of results the
     * LRU Cache can store. When the cache is full, the
     * Least-Recently-Used entry gets evicted from the cache,
     * before adding another entry.
     * 
     * @param resolver A function that takes in any number of arguments,
     * and returns a String key that is used to identify unique
     * argument values. @see Resolver.serialize, Resolver.join
     */
    public static function memoize<A,B,C,D,E,Z>(fn:A->B->C->D->E->Z, capacity:Int=FunctionTools.CAPACITY, ?resolver:Resolver):A->B->C->D->E->Z
    {
        return cast FunctionTools.memoize(fn, capacity, resolver);
    }
}