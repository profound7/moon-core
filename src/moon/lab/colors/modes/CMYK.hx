package moon.lab.colors.modes;

using moon.tools.FloatTools;

/**
 * @author Munir Hussin
 */
package moon.lab.colors;

using moon.tools.FloatTools;

/**
 * @author Munir Hussin
 */
class CMY implements IColorMode
{
    public var hasAlpha(get, never):Bool;
    public var alpha(get, set):Float;
    
    public var c:Float;
    public var m:Float;
    public var y:Float;
    
    /**
     * Values are normalized between 0 and 1.
     */
    public function new(c:Float, m:Float, y:Float)
    {
        this.c = c;
        this.m = m;
        this.y = y;
    }
    
    private inline function get_hasAlpha():Bool
    {
        return false;
    }
    
    private inline function get_alpha():Float
    {
        return 1.0;
    }
    
    private inline function set_alpha(value:Float):Float
    {
        throw "Cannot modify alpha";
    }
    
    /*==================================================
        Color Typedef Methods
    ==================================================*/
    
    public function getRGB():RGB
    {
        var d:Float = 1.0 - k;
        var r:Float = (1.0 - c) * d;
        var g:Float = (1.0 - m) * d;
        var b:Float = (1.0 - y) * d;
        return new RGB(r, g, b);
    }
    
    public function setRGB(rgb:RGB):Void
    {
        k = 1.0 - ColorUtil.max3(rgb.r, rgb.g, rgb.b);
        var d:Float = 1.0 / (1.0 - k);
        c = (1.0 - rgb.r - k) * d;
        m = (1.0 - rgb.g - k) * d;
        y = (1.0 - rgb.b - k) * d;
    }
    
    public function toString():String
    {
        var c = Math.round(c * 255.0);
        var m = Math.round(m * 255.0);
        var y = Math.round(y * 255.0);
        var k = Math.round(k * 255.0);
        return 'cmyk($c, $m, $y, $k)';
    }
}
