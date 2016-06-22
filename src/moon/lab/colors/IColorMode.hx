package moon.lab.colors;

import moon.lab.colors.modes.RGB;

/**
 * ...
 * @author Munir Hussin
 */
interface IColorMode
{
    public var hasAlpha(get, never):Bool;
    public var alpha(get, set):Float;
    
    public function getRGB():RGB;
    public function setRGB(rgb:RGB):Void;
    
    public function toString():String;
}