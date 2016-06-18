package moon.lab.colors;

/**
 * 32bit int as color.
 * Compared to RGB, HSL and HSV, Color uses the smallest memory (a single Int as
 * opposed to four Floats -- 256bits on many targets!).
 * However, it has the smallest precision.
 * 
 * For calculations where interpolation or calculations between colors are needed,
 * use RGB, HSL or HSV for smoother results.
 * 
 * @author Munir Hussin
 */
abstract Color(Int) to Int from Int
{
    
    public inline function new(c:Color=0)
    {
        this = c;
    }
    
    public static inline function fromRGB(r:Float, g:Float, b:Float, a:Float=1.0):Color
    {
        return
            (Math.round(a * 255) << 24) |
            (Math.round(r * 255) << 16) |
            (Math.round(g * 255) <<  8) |
            (Math.round(b * 255));
    }
    
    public static inline function fromHSV(h:Float, s:Float, v:Float, a:Float=1.0):Color
    {
        return new HSV(h, s, v, a).toRGB().toColor();
    }
    
    public static inline function fromHSL(h:Float, s:Float, l:Float, a:Float=1.0):Color
    {
        return new HSL(h, s, l, a).toRGB().toColor();
    }
    
    /*==================================================
        Conversions
    ==================================================*/
    
    @:to public inline function toRGB():RGB
    {
        return new RGB(
            ((this >> 16) & 255) / 255,
            ((this >> 8) & 255) / 255,
            (this & 255) / 255,
            ((this >> 24) & 255) / 255
        );
    }
    
    @:to public inline function toHSL():HSL
    {
        return toRGB().toHSL();
    }
    
    @:to public inline function toHSV():HSV
    {
        return toRGB().toHSV();
    }
    
    @:to public inline function toString():String
    {
        return "#" + toHex();
    }
    
    public inline function toHex(withAlpha:Bool=true):String
    {
        return withAlpha ? StringTools.hex(this, 8) : StringTools.hex(this, 8).substr(2);
    }
    
    public inline function toHTML():String
    {
        return "#" + toHex(false);
    }
    
    public inline function toLiteral(withAlpha:Bool=true):String
    {
        return "0x" + toHex(withAlpha);
    }
}

