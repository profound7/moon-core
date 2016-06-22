package moon.lab.colors.modes;

using moon.tools.FloatTools;

/**
 * @author Munir Hussin
 */
class HSV implements IColorMode
{
    public var hasAlpha(get, never):Bool;
    public var alpha(get, set):Float;
    
    public var h:Float;
    public var s:Float;
    public var v:Float;
    
    /**
     * Values are normalized between 0 and 1.
     */
    public function new(h:Float, s:Float, v:Float)
    {
        this.h = h;
        this.s = s;
        this.v = v;
    }
    
    private function get_hasAlpha():Bool
    {
        return false;
    }
    
    private function get_alpha():Float
    {
        return 1.0;
    }
    
    private function set_alpha(value:Float):Float
    {
        throw "Cannot modify alpha";
    }
    
    /*==================================================
        Implements
    ==================================================*/
    
    public function getRGB():RGB
    {
        var hsv:HSV = this;
        
        var d:Float = (hsv.h % ColorUtil.DEG_360) / ColorUtil.DEG_60;
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
            case 0: new RGB(v, t, p);
            case 1: new RGB(q, v, p);
            case 2: new RGB(p, v, t);
            case 3: new RGB(p, q, v);
            case 4: new RGB(t, p, v);
            case 5: new RGB(v, p, q);
            default: throw "Unexpected error";
        }
    }
    
    public function setRGB(rgb:RGB):Void
    {
        var max:Float = ColorUtil.max3(rgb.r, rgb.g, rgb.b);
        var min:Float = ColorUtil.min3(rgb.r, rgb.g, rgb.b);
        var add:Float = max + min;
        var sub:Float = max - min;
        
        h =
            (max == min) ? 0.0 :
            (max == rgb.r) ? (ColorUtil.DEG_60 * (rgb.g - rgb.b) / sub + ColorUtil.DEG_360) % ColorUtil.DEG_360:
            (max == rgb.g) ? ColorUtil.DEG_60 * (rgb.b - rgb.r) / sub + ColorUtil.DEG_120:
            ColorUtil.DEG_60 * (rgb.r - rgb.g) / sub + ColorUtil.DEG_240;
        
        s =
            (max == 0) ? 0 :
            1.0 - min / max;
        
        v = max;
    }
    
    public function toString():String
    {
        var h = Math.round(h * 360.0) % 360;
        var s = Math.round(s * 100.0);
        var v = Math.round(v * 100.0);
        return 'hsv($h, $s%, $v%)';
    }
}

class HSVA extends HSV
{
    public var a:Float;
    
    public function new(h:Float, s:Float, v:Float, a:Float)
    {
        super(h, s, v);
        this.a = a;
    }
    
    private override function get_hasAlpha():Bool
    {
        return true;
    }
    
    private override function get_alpha():Float
    {
        return a;
    }
    
    private override function set_alpha(value:Float):Float
    {
        return a = value;
    }
    
    public override function toString():String
    {
        var h = Math.round(h * 360.0) % 360;
        var s = Math.round(s * 100.0);
        var v = Math.round(v * 100.0);
        var a = a.round(2);
        return 'hsva($h, $s%, $v%, $a)';
    }
}