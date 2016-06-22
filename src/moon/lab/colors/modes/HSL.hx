package moon.lab.colors.modes;

using moon.tools.FloatTools;

/**
 * @author Munir Hussin
 */
class HSL implements IColorMode
{
    public var hasAlpha(get, never):Bool;
    public var alpha(get, set):Float;
    
    public var h:Float;
    public var s:Float;
    public var l:Float;
    
    /**
     * Values are normalized between 0 and 1.
     */
    public function new(h:Float, s:Float, l:Float)
    {
        this.h = h;
        this.s = s;
        this.l = l;
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
        var hsl:HSL = this;
        var q:Float =
            (hsl.l < 1 / 2) ? hsl.l * (1 + hsl.s) :
            hsl.l + hsl.s - (hsl.l * hsl.s);
        
        var p:Float = 2 * hsl.l - q;
        
        var hk:Float = (hsl.h % ColorUtil.DEG_360) / ColorUtil.DEG_360;
        
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
        
        return new RGB(tc[0], tc[1], tc[2]);
    }
    
    public function setRGB(rgb:RGB):Void
    {
        var max:Float = ColorUtil.max3(rgb.r, rgb.g, rgb.b);
        var min:Float = ColorUtil.min3(rgb.r, rgb.g, rgb.b);
        var add:Float = max + min;
        var sub:Float = max - min;
        
        //var h:Float =
        h =
            (max == min) ? 0 :
            (max == rgb.r) ? (ColorUtil.DEG_60 * (rgb.g - rgb.b) / sub + ColorUtil.DEG_360) % ColorUtil.DEG_360:
            (max == rgb.g) ? ColorUtil.DEG_60 * (rgb.b - rgb.r) / sub + ColorUtil.DEG_120:
            ColorUtil.DEG_60 * (rgb.r - rgb.g) / sub + ColorUtil.DEG_240;
        
        //var l:Float = add / 2;
        l = add / 2;
        
        //var s:Float =
        s =
            (max == min) ? 0 :
            (l <= 1 / 2) ? sub / add :
            sub / (2 - add);
        
        //return new HSL(h, s, l);
    }
    
    public function toString():String
    {
        var h = Math.round(h * 360.0) % 360;
        var s = Math.round(s * 100.0);
        var l = Math.round(l * 100.0);
        return 'hsl($h, $s%, $l%)';
    }
}


class HSLA extends HSL
{
    public var a:Float;
    
    public function new(h:Float, s:Float, l:Float, a:Float)
    {
        super(h, s, l);
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
        var l = Math.round(l * 100.0);
        var a = a.round(2);
        return 'hsla($h, $s%, $l%, $a)';
    }
}