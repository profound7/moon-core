package moon.lab.colors;

import moon.lab.colors.formats.RGB888;
import moon.lab.colors.modes.HSL;
import moon.lab.colors.modes.RGB;
import moon.lab.colors.modes.YUV;

using moon.tools.FloatTools;

/**
 * @author Munir Hussin
 */
@:forward abstract Color(ColorInternal) to ColorInternal from ColorInternal
{
    public static inline var Red = 0xFFFF0000;
    public static inline var Green = 0xFF00FF00;
    public static inline var Blue = 0xFF0000FF;
    
    /**
     * using moon.lab.colors.Color;
     * ...
     * var cmyk:CMYK = new CMYK(0.1, 0.2, 0.3, 0.4);
     * var hsl:HSL = cmyk.convert(HSL);
     */
    public static function convert<T:IColorMode, U:IColorMode>(color:T, mode:Class<U>):U
    {
        var out:U = Type.createEmptyInstance(mode);
        
        out.setRGB(color.getRGB());
        
        if (out.hasAlpha)
            out.alpha = color.alpha;
            
        return out;
    }
    
    @:from public static function fromColorMode(mode:IColorMode):Color
    {
        return new ColorInternal(mode);
    }
}


/**
 * http://stackoverflow.com/a/596241/3761791
 * approximation of luminance
 * 
 * Y = 0.2126 R + 0.7152 G + 0.0722 B
 * 
 * Y = (R+R+B+G+G+G)/6
 * or
 * Y = (R+R+R+B+G+G+G+G)>>3
 * 
 * 00000000 00000000 00000000 00000000
 * RRRRRRRG GGGGGGGG GGGGGGGG GGGGGGBB      R7G23B2
 * 
 * 00000000 00000000 00000000
 * RRRRRGGG GGGGGGGG GGGGGGBB               R5G17B2
 * 
 * 00000000
 * RRRGGGBB
 */
private class ColorInternal
{
    public var color(get, set):IColorMode;
    public var alpha(get, set):Float;
    //public var luminosity(get, set):Float;
    
    private var original:IColorMode;
    private var tmp:IColorMode;
    
    
    public function new(color:IColorMode)
    {
        this.color = color;
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private function get_color():IColorMode
    {
        changeMode(Type.getClass(original));
        
        if (tmp.hasAlpha)
            tmp.alpha = original.alpha;
            
        return tmp;
    }
    
    private function set_color(color:IColorMode):IColorMode
    {
        return original = tmp = color;
    }
    
    private function get_alpha():Float
    {
        return original.alpha;
    }
    
    private function set_alpha(value:Float):Float
    {
        return original.alpha = value;
    }
    
    /*private function get_luminosity():Float
    {
        var yuv:YUV = changeMode(YUV);
        return yuv.y;
    }
    
    private function set_luminosity(value:Float):Float
    {
        var yuv:YUV = changeMode(YUV);
        return yuv.y = value;
    }*/
    
    /*==================================================
        Methods
    ==================================================*/
    
    private function changeMode<T:IColorMode>(mode:Class<IColorMode>):T
    {
        if (!Std.is(tmp, mode))
        {
            //trace("changed mode");
            tmp = Color.convert(tmp, mode);
        }
        return cast tmp;
    }
    
    public function rotate(turn:Float):Color
    {
        var hsl:HSL = changeMode(HSL);
        hsl.h = (hsl.h + turn) % 1.0;
        tmp = hsl;
        return this;
    }
    
    public function lighten(ratio:Float):Color
    {
        var hsl:HSL = changeMode(HSL);
        hsl.l = (hsl.l + hsl.l * ratio).clamp(0.0, 1.0);
        tmp = hsl;
        return this;
    }
    
    public function darken(ratio:Float):Color
    {
        var hsl:HSL = changeMode(HSL);
        hsl.l = (hsl.l - hsl.l * ratio).clamp(0.0, 1.0);
        tmp = hsl;
        return this;
    }
    
    public function saturate(ratio:Float):Color
    {
        var hsl:HSL = changeMode(HSL);
        hsl.s = (hsl.s + hsl.s * ratio).clamp(0.0, 1.0);
        tmp = hsl;
        return this;
    }
    
    public function desaturate(ratio:Float):Color
    {
        var hsl:HSL = changeMode(HSL);
        hsl.s = (hsl.s - hsl.s * ratio).clamp(0.0, 1.0);
        tmp = hsl;
        return this;
    }
    
    public function opaquer(ratio:Float):Color
    {
        original.alpha = (original.alpha + (original.alpha * ratio)).clamp(0.0, 1.0);
        return this;
    }
    
    public function clearer(ratio:Float):Color
    {
        original.alpha = (original.alpha - (original.alpha * ratio)).clamp(0.0, 1.0);
        return this;
    }
    
    /**
     * relative luminance
     * https://www.w3.org/TR/WCAG20/#relativeluminancedef
     */
    public function luminance():Float
    {
        var rgb:RGB = changeMode(RGB);
        var r = (rgb.r <= 0.03928) ? rgb.r / 12.92 : Math.pow((rgb.r + 0.055) / 1.055, 2.4);
        var g = (rgb.g <= 0.03928) ? rgb.g / 12.92 : Math.pow((rgb.g + 0.055) / 1.055, 2.4);
        var b = (rgb.b <= 0.03928) ? rgb.b / 12.92 : Math.pow((rgb.b + 0.055) / 1.055, 2.4);
        return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }
    
    /**
     * contrast ratio with another color.
     * contrast ratio ranges from 1 (same color) to 21 (black and white)
     * https://www.w3.org/TR/WCAG20/#contrast-ratiodef
     */
    public function contrast(other:Color):Float
    {
        var y1 = this.luminance();
        var y2 = other.luminance();
        return y1 > y2 ? (y1 + 0.05) / (y2 + 0.05) : (y2 + 0.05) / (y1 + 0.05);
    }
    
    public inline function isLight():Bool
    {
        return luminance() > 0.5;
    }
    
    public inline function isDark():Bool
    {
        return !isLight();
    }
    
    public function toString():String
    {
        return color.toString();
    }
    
    public function toHTML():String
    {
        var c = color;
        return switch (Type.getClass(c))
        {
            case RGB | HSL | RGBA | HSLA | RGB888:
                c.toString();
                
            case _:
                c.hasAlpha ?
                    Color.convert(c, RGBA).toString():
                    Color.convert(c, RGB).toString();
        }
    }
}