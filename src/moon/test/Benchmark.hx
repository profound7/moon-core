package moon.test;

import haxe.PosInfos;
import haxe.Timer;

/**
 * ...
 * @author Munir Hussin
 */
class Benchmark
{
    /**
     * Returns a timestamp, in seconds with fractions.
     * The value itself might differ depending on platforms, only differences
     * between two values make sense.
     */
    public static inline function stamp():Float
    {
        return Timer.stamp();
    }
    
    public static inline function measure<T>(fn:Void->T, ?pos:PosInfos):T
    {
        return Timer.measure(fn, pos);
    }
    
    public static function repeat<T>(iterations:Int, fn:Void->T):Float
    {
        var sum:Float = 0.0;
        var t0:Float = 0.0;
        
        for (i in 0...iterations)
        {
            t0 = stamp();
            fn();
            sum += stamp() - t0;
        }
        
        return sum / iterations;
    }
    
}