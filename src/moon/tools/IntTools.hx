package moon.tools;

/**
 * ...
 * @author Munir Hussin
 */
class IntTools
{
    
    public static inline function clamp(v:Int, lo:Int, hi:Int):Int
    {
        return
            if (v <= lo)
                lo;
            else if (v >= hi)
                hi;
            else
                v;
    }
    
}