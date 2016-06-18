package moon.core;

/**
 * Lazy is a function that returns a value.
 * 
 * Retrieving the value will call the function and cache the value.
 * Subsequent calls will use the cached value;
 * 
 * @author Munir Hussin
 */
abstract Lazy<T>(Void->T)
{
    public var value(get, never):T;
    
    public function new(fn:Void->T)
    {
        this = wrap(fn);
    }
    
    private static inline function wrap<T>(fn:Void->T):Void->T
    {
        var cache:T = null;
        
        return function():T
        {
            if (fn != null)
            {
                cache = fn();
                //trace('yo! $cache');
                fn = null;
            }
            
            return cache;
        }
    }
    
    public inline function flatMap<U>(fn:T->Lazy<U>):Lazy<U>
    {
        return new Lazy<U>(function() return fn(value).value);
    }
    
    public inline function map<U>(fn:T->U):Lazy<U>
    {
        return new Lazy<U>(function() return fn(value));
    }
    
    @:to private inline function get_value():T
    {
        return this();
    }
    
    @:from public static inline function fromFunction<T>(fn:Void->T):Lazy<T>
    {
        return new Lazy<T>(fn);
    }
    
    @:from public static inline function fromValue<T>(val:T):Lazy<T>
    {
        return new Lazy<T>(function() return val);
    }
}
