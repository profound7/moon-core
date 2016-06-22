package moon.lab.colors;

using moon.tools.FloatTools;

/**
 * Hue reference points for a more intuitive way
 * of setting hues based on percentage offset
 * from primary/secondary colors.
 * 
 * Usage:
 * var color:HSV = ...;
 * color.h = Hue.red(0.75); // 75% between red and yellow (orange)
 * 
 * @author Munir Hussin
 */
class Hue
{
    public static inline var R:Float =   0.0;
    public static inline var Y:Float =  60.0 / 360.0;
    public static inline var G:Float = 120.0 / 360.0;
    public static inline var C:Float = 180.0 / 360.0;
    public static inline var B:Float = 240.0 / 360.0;
    public static inline var M:Float = 300.0 / 360.0;
    
    public static function red(x:Float):Float
    {
        return (R + Y * x) % 1.0;
    }
    
    public static function yellow(x:Float):Float
    {
        return (Y + Y * x) % 1.0;
    }
    
    public static function green(x:Float):Float
    {
        return (G + Y * x) % 1.0;
    }
    
    public static function cyan(x:Float):Float
    {
        return (C + Y * x) % 1.0;
    }
    
    public static function blue(x:Float):Float
    {
        return (B + Y * x) % 1.0;
    }
    
    public static function magenta(x:Float):Float
    {
        return (M + Y * x) % 1.0;
    }
}