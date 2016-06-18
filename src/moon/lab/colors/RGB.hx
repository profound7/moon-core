package moon.lab.colors;

import moon.numbers.geom.Vec4;

using moon.tools.FloatTools;

/**
 * ...
 * @author Munir Hussin
 */
abstract RGB(Vec4) to Vec4 from Vec4
{
    public var r(get, set):Float;
    public var g(get, set):Float;
    public var b(get, set):Float;
    public var a(get, set):Float;
    
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
            (max == rgb.r) ? (60 * (rgb.g - rgb.b) / sub + 360) % 360 :
            (max == rgb.g) ? 60 * (rgb.b - rgb.r) / sub + 120 :
            60 * (rgb.r - rgb.g) / sub + 240;
        
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
            (max == min) ? 0 :
            (max == rgb.r) ? (60 * (rgb.g - rgb.b) / sub + 360) % 360 :
            (max == rgb.g) ? 60 * (rgb.b - rgb.r) / sub + 120 :
            60 * (rgb.r - rgb.g) / sub + 240;
        
        var s:Float =
            (max == 0) ? 0 :
            1 - min / max;
        
        var v:Float = max;
        
        return new HSV(h, s, v, a);
    }
    
    @:to public inline function toString():String
    {
        return "rgba" + this.toString();
    }
    
    public inline function toHTML():String
    {
        // FIXME: proper formatting is rgba(255, 128, 64, 0.2)
        // with each color in 0-255 and alpha in 0-1
        
        var r = Math.round(r);
        var g = Math.round(g);
        var b = Math.round(b);
        var a = a.round(2);
        return 'rgba($r, $g, $b, $a)';
    }
}
