package moon.core;

/**
 * Wraps a value in an Array object, so you can have functions that have
 * an *out* argument.
 * 
 * function addTwo(r:Ref<Int>):Void
 * {
 *     r.value += 2;
 * }
 * 
 * var x:Ref<Int> = 5;      // auto wrap
 * addTwo(x);
 * trace(x.value);          // 7
 * 
 * var y:Int = x;           // auto unwrap
 * trace(y);                // (you can pass a Ref<Int> anywhere an Int is expected)
 * 
 * @author Munir Hussin
 */
abstract Ref<T>(Array<T>)
{
    public var value(get, set):T;
    
    public inline function new(x:T=null)
    {
        this = [x];
    }
    
    @:from public static inline function of<T>(x:T):Ref<T>
    {
        return new Ref<T>(x);
    }
    
    @:to private inline function get_value():T
    {
        return this[0];
    }
    
    private inline function set_value(x:T):T
    {
        return this[0] = x;
    }
    
    @:to public function toString():String
    {
        return '<$value>';
    }
}