package;

import moon.core.Fiber;
import moon.core.Fiber.Processor;

/**
 * ...
 * @author Munir Hussin
 */
class FiberTest
{

    public static function main()
    {
        var a = new Fiber<Int>(1, 5...20);
        var b = new Fiber<Int>(1, 100...115);
        
        a.onComplete(function(v) trace('A:: Completed with value: $v'));
        a.onFail(function(e) trace('A:: Failed: $e'));
        b.onComplete(function(v) trace('B:: Completed with value: $v'));
        b.onFail(function(e) trace('B:: Failed: $e'));
        
        Processor.main.add(a);
        Processor.main.add(b);
        
        for (i in 0...10)
        {
            trace("---- " + i);
            if (i == 2) a.kill();
            
            Processor.main.run(3);
        }
    }
    
}