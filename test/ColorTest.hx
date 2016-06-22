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
        var a:Color = new RGB888(0xaabbcc);
        
        trace(a);
        
        a.lighten(0.1);
        
        
        trace(a);
        trace(a.toHTML());
        
        var x = Hue.magenta(0);
        trace(x * 360);
    }
    
}