package moon.tools;

/**
 * import moon.strings.HashCode.*;
 * using moon.tools.HashCodeTools;
 * 
 * trace(djb2.hash("test"));
 * 
 * @author Munir Hussin
 */
class HashCodeTools
{
    
    public static inline function hash(f:String->Int, s:Dynamic):Int
    {
        return f(Std.string(s));
    }
    
}