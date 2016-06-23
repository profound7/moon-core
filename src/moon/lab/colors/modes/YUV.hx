package moon.lab.colors.modes;

using moon.tools.FloatTools;

/**
 * @author Munir Hussin
 */
class YUV implements IColorMode
{
    public static var wr = 0.299;
    public static var wg = 1 - wr - wb;       // 1 - wr - wb == 0.587
    public static var wb = 0.114;
    public static var umax = 0.436;
    public static var vmax = 0.615;
        
    public var hasAlpha(get, never):Bool;
    public var alpha(get, set):Float;
    
    public var y:Float;
    public var u:Float;
    public var v:Float;
    
    /**
     * Values are normalized between 0 and 1.
     */
    public function new(y:Float, u:Float, v:Float)
    {
        this.y = y;
        this.u = u;
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
        var r = y + v * (1 - wr) / vmax;
        var g = y - u * (wb - wb * wb) / (umax * wg) - v * (wr - wr * wr) / (vmax * wg);
        var b = y + u * (1 - wb) / umax;
        return new RGB(r, g, b);
    }
    
    public function setRGB(rgb:RGB):Void
    {
        y = wr * rgb.r + wg * rgb.g + wb * rgb.b;
        u = umax * (rgb.b - y) / (1 - wb);
        v = vmax * (rgb.r - y) / (1 - wr);
    }
    
    public function toString():String
    {
        var y = Math.round(y * 100.0);
        var u = Math.round(u * 100.0);
        var v = Math.round(v * 100.0);
        return 'Y\'UV($y%, $u%, $v%)';
    }
}
