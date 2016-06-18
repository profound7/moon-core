package moon.numbers.math;

/**
 * http://lab.polygonal.de/?p=81
 * http://mudcu.be/journal/2011/11/bitwise-gems-and-other-optimizations/
 * http://graphics.stanford.edu/~seander/bithacks.html#IntegerLog10
 * 
 * These aren't benchmarked yet. No idea how well they
 * do on the different targets. Just adding them here for reference.
 * 
 * @author Munir Hussin
 */
class FastMath
{
    public static inline var PI:Float = 3.14159265358979323846;
    public static inline var PI2:Float = PI * PI;
    public static inline var PI3:Float = PI2 * PI;
    public static inline var HALF_PI:Float = 0.5 * PI;
    public static inline var TWO_PI:Float = 2.0 * PI;
    public static inline var TWO_PI_INV:Float = 1.0 / TWO_PI;
    
    
    public static inline function abs(x:Int):Int
    {
        return x < 0 ? -x : x;
    }
    
    public static inline function round(x:Float):Int
    {
        return x + (x < 0 ? -0.5 : 0.5) >> 0;
    }
    
    public static inline function ceil(x:Float):Int
    {
        return x + (x < 0 ? 0 : 1) >> 0;
    }
    
    public static inline function floor(x:Float):Int
    {
        return x + (x < 0 ? -1 : 0) >> 0;
    }
    
    public static inline function max(x:Int, y:Int):Int
    {
        return x > y ? x : y;
    }
    
    public static inline function min(x:Int, y:Int):Int
    {
        return x < y ? x : y;
    }
    
    // x must be 32 bit int
    public static inline function log10(x:Int):Int
    {
        return
            (v >= 1000000000) ? 9 :
            (v >= 100000000) ? 8 :
            (v >= 10000000) ? 7 : 
            (v >= 1000000) ? 6 :
            (v >= 100000) ? 5 :
            (v >= 10000) ? 4 : 
            (v >= 1000) ? 3 :
            (v >= 100) ? 2 :
            (v >= 10) ? 1 : 0;
    }
    
    
    public static inline function isEven(x:Int):Bool
    {
        return (x & 1) == 0;
    }
    
    public static inline function isOdd(x:Int):Bool
    {
        return (x & 1) != 0;
    }
    
    public static inline function hasSameSign(x:Int, y:Int):Bool
    {
        return x ^ y >= 0;
    }
    
    // http://allenchou.net/2014/02/game-math-faster-sine-cosine-with-polynomial-curves/
    // a piece of the sine curve
    public static inline function hill(x:Float):Float
    {
        var a0:Float = 1.0;
        var a2:Float = 2.0 / PI - 12.0 / PI2;
        var a3:Float = 16.0 / PI3 - 4.0 / PI2;
        var xx:Float = x * x;
        var xxx:Float = xx * x;
        return a0 + a2 * xx + a3 * xxx;
    }
    
    public static function sin(x:Float):Float
    {
        var a:Float = x * TWO_PI_INV;
        x -= a * TWO_PI;
        if (x < 0.0)
            x += TWO_PI;
        
        if (x < HALF_PI)
            return hill(HALF_PI - x);
        else if (x < PI)
            return hill(x - HALF_PI);
        else if (x < 3.0 * HALF_PI)
            return -hill(3.0 * HALF_PI - x);
        else
            return -hill(x - 3.0 * HALF_PI);
    }
    
    public static inline function cos(x:Float):Float
    {
        return sin(x + HALF_PI);
    }
    
    public static inline function tan(x:Float):Float
    {
        return sin(x) / cos(x);
    }
}
