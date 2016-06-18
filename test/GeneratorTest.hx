package;

import moon.core.Types.Generator;


/**
 * ...
 * @author Munir Hussin
 */
@:build(moon.macros.async.AsyncMacro.build())
class Baz
{
    public static function main()
    {
        trace("testaaa");
        
        var x:Float = 1.23;
        var yo = { qqq: { www: 0 } };
        var i = 1;
        
        // declaring variables currently don't work
        @flatten function yoyo(a:Int, b:Int):Float
        {
            var q = 5;
            trace(q);
            return a + b;
        }
        
        var i = 1;
        
        function hihi(a:Int, b:Int):Float
        {
            var q = 5;
            trace(q);
            return a + b;
        }
        
        trace("yoyo:");
        yoyo(5, 1);
        
        trace("hihi:");
        hihi(5, 1);
        
    }
    
    public static function add(a:Int, b:Int):Int
    {
        trace('$a + $b');
        return a + b;
    }
}
