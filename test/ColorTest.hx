package;

import moon.lab.colors.Hue;
import moon.lab.colors.formats.*;
import moon.lab.colors.modes.*;
import moon.lab.colors.modes.RGB;
import moon.lab.colors.modes.HSL;
import moon.lab.colors.modes.HSV;

using moon.lab.colors.Color;

/**
 * ...
 * @author Munir Hussin
 */
class ColorTest
{
    
    public static function main()
    {
        var a:Color = new RGB(0, 0, 0);
        var b:Color = new RGB(1, 1, 1);
        
        trace(a);
        trace(b);
        trace(a.contrast(b));
        trace(a.isLight());
        trace(b.isLight());
        
        
    }
    
}