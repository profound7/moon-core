package moon.lab.colors.modes;

using moon.tools.FloatTools;

/**
 * @author Munir Hussin
 */
class RGB implements IColorMode
{
    public var hasAlpha(get, never):Bool;
    public var alpha(get, set):Float;
    
    public var r:Float;
    public var g:Float;
    public var b:Float;
    
    /**
     * Values are normalized between 0 and 1.
     */
    public function new(r:Float, g:Float, b:Float)
    {
        this.r = r;
        this.g = g;
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
        Implements
    ==================================================*/
    
    public function getRGB():RGB
    {
        return this;
    }
    
    public function setRGB(rgb:RGB):Void
    {
        this.r = rgb.r;
        this.g = rgb.g;
        this.b = rgb.b;
    }
    
    public function toString():String
    {
        var r = Math.round(r * 255.0);
        var g = Math.round(g * 255.0);
        var b = Math.round(b * 255.0);
        return 'rgb($r, $g, $b)';
    }
}

class RGBA extends RGB
{
    public var a:Float;
    
    public function new(r:Float, g:Float, b:Float, a:Float)
    {
        super(r, g, b);
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
        var r = Math.round(r * 255.0);
        var g = Math.round(g * 255.0);
        var b = Math.round(b * 255.0);
        var a = a.round(2);
        return 'rgba($r, $g, $b, $a)';
    }
}