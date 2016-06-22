package moon.lab.colors.formats;

import moon.lab.colors.modes.RGB;

/**
 * @author Munir Hussin
 */
class RGB888 implements IColorMode
{
    public var hasAlpha(get, never):Bool;
    public var alpha(get, set):Float;
    
    public var color:Int;
    public var r(get, set):Int;
    public var g(get, set):Int;
    public var b(get, set):Int;
    
    public inline function new(color:Int=0)
    {
        this.color = color;
    }
    
    private inline function get_hasAlpha():Bool
    {
        return false;
    }
    
    private inline function get_alpha():Float
    {
        return 1.0;
    }
    
    private inline function set_alpha(value:Float):Float
    {
        throw "Cannot modify alpha";
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private inline function get_r():Int return (color >> 16) & 255;
    private inline function get_g():Int return (color >> 8) & 255;
    private inline function get_b():Int return (color & 255);
    
    private inline function set_r(v:Int):Int { setValues(v, g, b); return v; };
    private inline function set_g(v:Int):Int { setValues(r, v, b); return v; };
    private inline function set_b(v:Int):Int { setValues(r, g, v); return v; };
    
    /*==================================================
        Conversions
    ==================================================*/
    
    /**
     * All arguments are between 0 to 255 inclusive
     */
    public inline function setValues(r:Int, g:Int, b:Int):Void
    {
        color = (r << 16) | (g <<  8) | (b);
    }
    
    public inline function toHex():String
    {
        return StringTools.hex(color, 6);
    }
    
    /*==================================================
        Implements
    ==================================================*/
    
    public function getRGB():RGB
    {
        return new RGB(r / 255.0, g / 255.0, b / 255.0);
    }
    
    public function setRGB(rgb:RGB):Void
    {
        color =
            (Math.round(rgb.r * 255.0) << 16) |
            (Math.round(rgb.g * 255.0) <<  8) |
            (Math.round(rgb.b * 255.0));
    }
    
    public inline function toString():String
    {
        return "#" + toHex();
    }
}
