package moon.lab.colors;

/**
 * 32bit int as color.
 * 
 * Compared to RGB, HSL and HSV, Color uses the smallest memory -- a single Int (4 bytes) as
 * opposed to four Floats (32 bytes).
 * However, it has the smallest precision.
 * 
 * For calculations where interpolation or calculations between colors are needed,
 * use RGB, HSL or HSV for smoother results.
 * 
 * @author Munir Hussin
 */
abstract Color(Int) to Int from Int
{
    public var r(get, set):Int;
    public var g(get, set):Int;
    public var b(get, set):Int;
    public var a(get, set):Int;
    
    public inline function new(c:Color=0)
    {
        this = c;
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private inline function get_r():Int return (this >> 16) & 255;
    private inline function get_g():Int return (this >> 8) & 255;
    private inline function get_b():Int return (this & 255);
    private inline function get_a():Int return (this >> 24) & 255;
    private inline function set_r(v:Int):Int { this = fromBytes(v, g, b, a); return v; };
    private inline function set_g(v:Int):Int { this = fromBytes(r, v, b, a); return v; };
    private inline function set_b(v:Int):Int { this = fromBytes(r, g, v, a); return v; };
    private inline function set_a(v:Int):Int { this = fromBytes(r, g, b, v); return v; };
    
    /*==================================================
        Conversions
    ==================================================*/
    
    /**
     * All arguments are between 0 to 255 inclusive
     */
    public static inline function fromBytes(r:Int, g:Int, b:Int, a:Int=255):Color
    {
        return
            (a << 24) |
            (r << 16) |
            (g <<  8) |
            (b);
    }
    
    /**
     * All arguments are normalized between 0 to 1
     */
    public static inline function fromRGB(r:Float, g:Float, b:Float, a:Float=1.0):Color
    {
        return fromBytes(
            Math.round(r * 255),
            Math.round(g * 255),
            Math.round(b * 255),
            Math.round(a * 255));
    }
    
    /**
     * All arguments are normalized between 0 to 1
     */
    public static inline function fromHSV(h:Float, s:Float, v:Float, a:Float=1.0):Color
    {
        return new HSV(h, s, v, a).toRGB().toColor();
    }
    
    /**
     * All arguments are normalized between 0 to 1
     */
    public static inline function fromHSL(h:Float, s:Float, l:Float, a:Float=1.0):Color
    {
        return new HSL(h, s, l, a).toRGB().toColor();
    }
    
    @:to public function toBytes():Array<Int>
    {
        return [r, g, b, a];
    }
    
    @:to public inline function toRGB():RGB
    {
        return new RGB(r / 255, g / 255, b / 255, a / 255);
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

