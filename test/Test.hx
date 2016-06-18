package;

import test.core.CompareTest;
import test.core.FutureTest;
import test.core.RangeTest;
import test.numbers.RandomTest;
import test.numbers.StatsTest;
import test.numbers.UnitsTest;
import test.signals.SignalsTest;
import test.strings.InflectTest;
import moon.crypto.Message;
import moon.numbers.big.BigBits;
import moon.test.TestCase;
import moon.test.TestRunner;

/**
 * ...
 * @author Munir Hussin
 */
class Test
{

    public static function main()
    {
        var modules:Array<Class<TestCase>> =
        [
            // core
            CompareTest,
            FutureTest,
            RangeTest,
            
            // numbers
            RandomTest,
            StatsTest,
            UnitsTest,
            
            // signals
            SignalsTest,
            
            // strings
            InflectTest,
        ];
        
        
        var r = new TestRunner();
        for (m in modules)
            r.add(Type.createInstance(m, []));
        r.run();
        
        
        /*var s0:String = "bla bla lorum ipsum haha foo bar yoyo bye";
        var m0:Message = s0;
        var b0:BigBits = m0;
        
        trace(b0);
        
        var m1:Message = Message.fromBigBits(b0);
        var s1:String = m1;
        
        trace(s1);
        
        var a:Int = 0xAABBCCDD;
        var hi:Int = a >>> 16;
        var lo:Int = a << 16 >>> 16;
        trace(StringTools.hex(hi));
        trace(StringTools.hex(lo));*/
        
    }
    
    
}