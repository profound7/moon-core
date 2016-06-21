package moon.lab.colors;

import moon.numbers.geom.Vec4;

using moon.tools.FloatTools;

/**
 * hue:         0.0 - 1.0       where 1.0 = 360deg
 * saturation:  0.0 - 1.0
 * lightness:   0.0 - 1.0
 * 
 * @author Munir Hussin
 */
abstract HSL(Vec4) to Vec4 from Vec4
{
    private static inline var DEG_60 = 60.0 / 360.0;
    private static inline var DEG_360 = 1.0;
    
    public var h(get, set):Float;
    public var s(get, set):Float;
    public var l(get, set):Float;
    public var a(get, set):Float;
    
    /**
     * Values h, s, l, a are normalized between 0 and 1.
     */
    public function new(h:Float=0.0, s:Float=0.0, l:Float=0.0, a:Float=1.0) 
    {
        this = new Vec4(h, s, l, a);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private inline function get_h():Float return this[0];
    private inline function get_s():Float return this[1];
    private inline function get_l():Float return this[2];
    private inline function get_a():Float return this[3];
    private inline function set_h(value:Float):Float return this[0] = value;
    private inline function set_s(value:Float):Float return this[1] = value;
    private inline function set_l(value:Float):Float return this[2] = value;
    private inline function set_a(value:Float):Float return this[3] = value;
    
    /*==================================================
        Conversions
    ==================================================*/
    
    @:to public function toColor():Color
    {
        return Color.fromHSL(h, s, l, a);
    }
    
    @:to public function toRGB():RGB
    {
        var hsl:HSL = this;
        var q:Float =
            (hsl.l < 1 / 2) ? hsl.l * (1 + hsl.s) :
            hsl.l + hsl.s - (hsl.l * hsl.s);
        
        var p:Float = 2 * hsl.l - q;
        
        var hk:Float = (hsl.h % DEG_360) / DEG_360;
        
        var tr:Float = hk + 1 / 3;
        var tg:Float = hk;
        var tb:Float = hk - 1 / 3;
        
        var tc:Array<Float> = [tr, tg, tb];
        
        for (n in 0...tc.length)
        {
            var t:Float = tc[n];
            
            if (t < 0) t += 1;
            if (t > 1) t -= 1;
            
            tc[n] =
                (t < 1 / 6) ? p + ((q - p) * 6 * t) :
                (t < 1 / 2) ? q :
                (t < 2 / 3) ? p + ((q - p) * 6 * (2 / 3 - t)) :
                p;
        }
        
        return new RGB(tc[0], tc[1], tc[2], a);
    }
    
    @:to public function toHSV():HSV
    {
        return toRGB().toHSV();
    }
    
    @:to public inline function toString():String
    {
        var h = Math.round(h * 360.0);
        var s = Math.round(s * 100.0);
        var l = Math.round(l * 100.0);
        var a = a.round(2);
        return 'hsla($h, $s%, $l%, $a)';
    }
    
    public inline function toHTML():String
    {
        return toString();
    }
}
