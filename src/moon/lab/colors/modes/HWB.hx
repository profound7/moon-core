package moon.lab.colors.modes;

using moon.tools.FloatTools;

/**
 * hue, whiteness, blackness
 * @author Munir Hussin
 */
class HWB implements IColorMode
{
    public var hasAlpha(get, never):Bool;
    public var alpha(get, set):Float;
    
    public var h:Float;
    public var w:Float;
    public var b:Float;
    
    /**
     * Values are normalized between 0 and 1.
     */
    public function new(h:Float, w:Float, b:Float)
    {
        this.h = h;
        this.w = w;
        this.b = b;
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
        Methods
    ==================================================*/
    
    public function toHSV():HSV
    {
        return new HSV(h, 1.0 - (w / (1.0 - b)), 1.0 - b);
    }
    
    /*==================================================
        Implements
    ==================================================*/
    
    public function getRGB():RGB
    {
        return toHSV().getRGB();
    }
    
    public function setRGB(rgb:RGB):Void
    {
        var hsv = new HSV(0, 0, 0);
        hsv.setRGB(rgb);
        
        h = hsv.h;
        w = (1.0 - hsv.s) * hsv.v;
        b = 1.0 - hsv.v;
    }
    
    public function toString():String
    {
        var h = Math.round(h * 360.0) % 360;
        var w = Math.round(w * 100.0);
        var b = Math.round(b * 100.0);
        return 'hwb($h, $w%, $b%)';
    }
}

class HWBA extends HWB
{
    public var a:Float;
    
    public function new(h:Float, w:Float, b:Float, a:Float)
    {
        super(h, w, b);
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
        var w = Math.round(w * 100.0);
        var b = Math.round(b * 100.0);
        var a = a.round(2);
        return 'hwba($h, $w%, $b%, $a)';
    }
}