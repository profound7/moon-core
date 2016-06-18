package moon.numbers.math;

/**
 * ...
 * @author Munir Hussin
 */
class Predicate
{
    public static inline function lesserThan(a:Float, b:Float):Bool
    {
        return a < b;
    }
    
    public static inline function greaterThan(a:Float, b:Float):Bool
    {
        return a > b;
    }
    
    public static inline function lesserThanOrEqualsTo(a:Float, b:Float):Bool
    {
        return a <= b;
    }
    
    public static inline function greaterThanOrEqualsTo(a:Float, b:Float):Bool
    {
        return a >= b;
    }
    
    public static inline function equalsTo(a:Float, b:Float):Bool
    {
        return a == b;
    }
    
    public static inline function notEqualsTo(a:Float, b:Float):Bool
    {
        return a != b;
    }
    
    public static inline function nearTo(a:Float, b:Float, epsilon:Float):Bool
    {
        return Math.abs(a - b) <= Math.abs(epsilon);
    }
    
    public static inline function notNearTo(a:Float, b:Float, epsilon:Float):Bool
    {
        return Math.abs(a - b) > Math.abs(epsilon);
    }
}