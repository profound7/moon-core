package moon.lab.colors;

import moon.numbers.geom.Vec4;

using moon.tools.FloatTools;

/**
 * red:     0.0 - 1.0
 * green:   0.0 - 1.0
 * blue:    0.0 - 1.0
 * alpha:   0.0 - 1.0
 * 
 * @author Munir Hussin
 */
abstract RGB(Vec4) to Vec4 from Vec4
{
    private static inline var DEG_60 = 60.0 / 360.0;
    private static inline var DEG_120 = 120.0 / 360.0;
    private static inline var DEG_240 = 240.0 / 360.0;
    private static inline var DEG_360 = 1.0;
    
    
    public var r(get, set):Float;
    public var g(get, set):Float;
    public var b(get, set):Float;
    public var a(get, set):Float;
    
    /**
     * Values r, g, b, a are normalized between 0 and 1.
     */
    public function new(r:Float=0.0, g:Float=0.0, b:Float=0.0, a:Float=1.0) 
    {
        this = new Vec4(r, g, b, a);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private inline function get_r():Float return this[0];
    private inline function get_g():Float return this[1];
    private inline function get_b():Float return this[2];
    private inline function get_a():Float return this[3];
    private inline function set_r(value:Float):Float return this[0] = value;
    private inline function set_g(value:Float):Float return this[1] = value;
    private inline function set_b(value:Float):Float return this[2] = value;
    private inline function set_a(value:Float):Float return this[3] = value;
    
    /*==================================================
        Methods
    ==================================================*/
    
    private static inline function maxRGB(rgb:RGB):Float
    {
        return Math.max(rgb.r, Math.max(rgb.g, rgb.b));
    }
    
    private static inline function minRGB(rgb:RGB):Float
    {
        return Math.min(rgb.r, Math.min(rgb.g, rgb.b));
    }
    
    /*==================================================
        Conversions
    ==================================================*/
    
    @:to public function toColor():Color
    {
        return Color.fromRGB(r, g, b, a);
    }
    
    @:to public function toHSL():HSL
    {
        var rgb:RGB = this;
        var max:Float = maxRGB(rgb);
        var min:Float = minRGB(rgb);
        var add:Float = max + min;
        var sub:Float = max - min;
        
        var h:Float =
            (max == min) ? 0 :
            (max == rgb.r) ? (DEG_60 * (rgb.g - rgb.b) / sub + DEG_360) % DEG_360:
            (max == rgb.g) ? DEG_60 * (rgb.b - rgb.r) / sub + DEG_120:
            DEG_60 * (rgb.r - rgb.g) / sub + DEG_240;
        
        var l:Float = add / 2;
        
        var s:Float =
            (max == min) ? 0 :
            (l <= 1 / 2) ? sub / add :
            sub / (2 - add);
        
        return new HSL(h, s, l, a);
    }
    
    @:to public function toHSV():HSV
    {
        var rgb:RGB = this;
        var max:Float = maxRGB(rgb);
        var min:Float = minRGB(rgb);
        var add:Float = max + min;
        var sub:Float = max - min;
        
        var h:Float =
            (max == min) ? 0.0 :
            (max == rgb.r) ? (DEG_60 * (rgb.g - rgb.b) / sub + DEG_360) % DEG_360:
            (max == rgb.g) ? DEG_60 * (rgb.b - rgb.r) / sub + DEG_120:
            DEG_60 * (rgb.r - rgb.g) / sub + DEG_240;
        
        var s:Float =
            (max == 0) ? 0 :
            1.0 - min / max;
        
        var v:Float = max;
        
        return new HSV(h, s, v, a);
    }
    
    @:to public inline function toString():String
    {
        var r = Math.round(r * 255.0);
        var g = Math.round(g * 255.0);
        var b = Math.round(b * 255.0);
        var a = a.round(2);
        return 'rgba($r, $g, $b, $a)';
    }
    
    public inline function toHTML():String
    {
        return toString();
    }
}
