package moon.lab.colors;

/**
 * ...
 * @author Munir Hussin
 */
class ColorUtil
{
    public static inline var DEG_60 = 60.0 / 360.0;
    public static inline var DEG_120 = 120.0 / 360.0;
    public static inline var DEG_240 = 240.0 / 360.0;
    public static inline var DEG_360 = 1.0;
    
    public static inline function max3(a:Float, b:Float, c:Float):Float
    {
        return Math.max(a, Math.max(b, c));
    }
    
    public static inline function min3(a:Float, b:Float, c:Float):Float
    {
        return Math.min(a, Math.min(b, c));
    }
    
}