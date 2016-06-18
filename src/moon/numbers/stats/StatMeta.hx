package moon.numbers.stats;

/**
 * Used for calculating stats of stats.
 * @author Munir Hussin
 */
class StatMeta<T>
{
    public var data:T;
    public var val:Float;
    
    public function new(data:T, val:Float)
    {
        this.data = data;
        this.val = val;
    }
    
    public static inline function value<S>(meta:StatMeta<S>):Float
    {
        return meta.val;
    }
}