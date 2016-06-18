package moon.lab.colors;

import moon.numbers.geom.Vec4;

/**
 * hue:         0-360
 * saturation:  0.0-1.0
 * value:       0-255
 * @author Munir Hussin
 */
abstract HSV(Vec4) to Vec4 from Vec4
{
    public var h(get, set):Float;
    public var s(get, set):Float;
    public var v(get, set):Float;
    public var a(get, set):Float;
    
    public function new(h:Float=0.0, s:Float=0.0, v:Float=0.0, a:Float=1.0) 
    {
        this = new Vec4(h, s, v, a);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private inline function get_h():Float return this[0];
    private inline function get_s():Float return this[1];
    private inline function get_v():Float return this[2];
    private inline function get_a():Float return this[3];
    private inline function set_h(value:Float):Float return this[0] = value;
    private inline function set_s(value:Float):Float return this[1] = value;
    private inline function set_v(value:Float):Float return this[2] = value;
    private inline function set_a(value:Float):Float return this[3] = value;
    
    /*==================================================
        Conversions
    ==================================================*/
    
    @:to public function toColor():Color
    {
        return Color.fromHSV(h, s, v, a);
    }
    
    @:to public function toRGB():RGB
    {
        var hsv:HSV = this;
        var d:Float = (hsv.h % 360) / 60;
        if (d < 0) d += 6;
        var hf:Int = Math.floor(d);
        var hi:Int = hf % 6;
        var f:Float = d - hf;
        
        var v:Float = hsv.v;
        var p:Float = hsv.v * (1 - hsv.s);
        var q:Float = hsv.v * (1 - f * hsv.s);
        var t:Float = hsv.v * (1 - (1 - f) * hsv.s);
        
        return switch(hi)
        {
            case 0: new RGB( v, t, p, a );
            case 1: new RGB( q, v, p, a );
            case 2: new RGB( p, v, t, a );
            case 3: new RGB( p, q, v, a );
            case 4: new RGB( t, p, v, a );
            case 5: new RGB( v, p, q, a );
            default: throw "Unexpected error";
        }
    }
    
    @:to public function toHSL():HSL
    {
        return toRGB().toHSL();
    }
    
    @:to public inline function toString():String
    {
        return "hsva" + this.toString();
    }
    
    public inline function toHTML():String
    {
        // html has HSL but not HSV.
        return toRGB().toHTML();
    }
}
