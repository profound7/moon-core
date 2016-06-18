package moon.tools;

using StringTools;

/**
 * ...
 * @author Munir Hussin
 */
class FloatTools
{
    /**
     * Rounds off a number to `d` decimal places.
     */
    public static inline function round(v:Float, d:Int=0):Float
    {
        var shift = Math.pow(10, d);
        return Math.fround(v * shift) / shift;
    }
    
    /**
     * Truncates a number to `d` decimal places..
     */
    public static inline function trunc(v:Float, d:Int=0):Float
    {
        var shift = Math.pow(10, d);
        return Std.int(v * shift) / shift;
    }
    
    /**
     * Clamps the value `v` to be between `lo` and `hi`
     */
    public static inline function clamp(v:Float, lo:Float, hi:Float):Float
    {
        return
            if (v <= lo)
                lo;
            else if (v >= hi)
                hi;
            else
                v;
    }
    
    /**
     * If truncate is false, round() will be called on the value, otherwise trunc()
     * is called instead.
     */
    public static function format(v:Float, sf:Int=0, truncate:Bool=false):String
    {
        var fnum = Std.string(truncate ? trunc(v, sf) : round(v, sf));
        var fpos = fnum.indexOf(".");
        var fdec = "";
        
        if (fpos != -1)
        {
            fdec = fnum.substr(fpos + 1, sf);
            fnum = fnum.substr(0, fpos);
        }
        
        //return fnum + "." + Text.of(fdec).rpad("0", sf);
        return fnum + "." + fdec.rpad("0", sf);
    }
    
    /**
     * Linear interpolation between numbers `a` and `b`
     * https://en.wikipedia.org/wiki/Linear_interpolation
     * 
     * lerp(a, b, t) == interpolate(t, 0, 1, a, b)
     * a.lerp(b, t)  == t.interpolate(0, 1, a, b)
     * 
     * Usage:
     * var x1 = 5.0;
     * var x2 = x1.lerp(8.0, 0.5); // x2 is halfway between 5.0 and 8.0
     */
    public static inline function lerp(a:Float, b:Float, t:Float):Float
    {
        return (1-t) * a + t * b;
    }
    
    /**
     * Given a number `v`, which is in the range from `aLo` to `aHi`, interpolate `v`
     * to be in the range of `bLo` to `bHi`.
     * 
     * Lerp interpolates between any 2 numbers using a parameter that's normalized to
     * 0 and 1, where 0 is the first number and 1 is the second number.
     * 
     * This method generalizes that, so instead of 0 and 1, you can specify any
     * numbers.
     * 
     * interpolate(t, 0, 1, a, b) == lerp(a, b, t)
     * 
     * Usage:
     * var progress = bytesDownloaded;
     * var x = progress.interpolate(0, bytesTotal, 50, 100);
     * // progress is between 0 and bytesTotal
     * // interpolate progress such that x is between 50 and 100
     */
    public static function interpolate(v:Float, aLo:Float, aHi:Float, bLo:Float, bHi:Float):Float
    {
        /*var aRange = aHi - aLo;
        var bRange = bHi - bLo;
        var ratio = (v - aLo) / aRange;
        return bRange * ratio + bLo;*/
        
        return (bHi - bLo) * (v - aLo) / (aHi - aLo) + bLo;
    }
    
    /**
     * Returns the index of the bin the value `v` belongs to.
     * @param v     a normalized value between 0 and 1
     * @param len   the number of bins
     * @return
     */
    public static inline function bin(v:Float, len:Int, lo:Float=0, hi:Float=1):Int
    {
        return IntTools.clamp(Math.floor(interpolate(v, lo, hi, 0, len)), 0, len - 1);
    }
    
    /**
     * Checks if a floating point number is near another floating point number
     * by a margin of `epsilon`.
     */
    public static inline function isNear(a:Float, b:Float, epsilon:Float):Bool
    {
        return Math.abs(b - a) <= Math.abs(epsilon);
    }
}
