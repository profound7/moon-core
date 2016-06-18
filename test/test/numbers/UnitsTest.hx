package test.numbers;

import moon.numbers.units.base.Length;
import moon.test.TestCase;
import moon.test.TestRunner;

/**
 * TODO: Add more tests
 * @author Munir Hussin
 */
class UnitsTest extends TestCase
{
    public static function main() 
    {
        var r = new TestRunner();
        r.add(new UnitsTest());
        r.run();
    }
    
    public function testUnits()
    {
        var m1:Meter = 1200;
        var km1:Kilometer = m1;
        
        var km2:Kilometer = 2.4;
        var m2:Meter = km2;
        
        assert.isEqual(km1, 1.2);
        assert.isEqual(m2, 2400);
    }
    
}

