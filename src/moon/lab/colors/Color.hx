package moon.lab.colors;

import moon.lab.colors.formats.RGB888;
import moon.lab.colors.modes.HSL;
import moon.lab.colors.modes.RGB;

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



private class ColorInternal
{
    public var color(get, set):IColorMode;
    public var alpha(get, set):Float;
    
    private var original:IColorMode;
    private var tmp:IColorMode;
    
    
    public function new(color:IColorMode)
    {
        this.color = color;
    }
    
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
    
    private function set_alpha(alpha:Float):Float
    {
        return original.alpha = alpha;
    }
    
    
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