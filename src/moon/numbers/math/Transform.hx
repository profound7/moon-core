package moon.numbers.math;

/**
 * ...
 * @author Munir Hussin
 */
class Transform
{
    public static inline function identity(x:Float):Float
    {
        return x;
    }
    
    public static inline function absolute(x:Float):Float
    {
        return Math.abs(x);
    }
    
    public static inline function squared(x:Float):Float
    {
        return x * x;
    }
}