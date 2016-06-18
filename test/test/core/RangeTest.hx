package test.core;

import moon.core.Future;
import moon.core.Range;
import moon.test.TestCase;
import moon.test.TestRunner;

/**
 * ...
 * @author Munir Hussin
 */
class RangeTest extends TestCase
{
    public static function main() 
    {
        var r = new TestRunner();
        r.add(new RangeTest());
        r.run();
    }
    
    
    public function testCount()
    {
        var arr1:Array<Int> = [];
        var arr2:Array<Int> = [];
        var arr3:Array<Int> = [];
        
        for (i in Range.count(4))
            arr1.push(i);
            
        for (i in Range.count(6, 2))
            arr2.push(i);
            
        for (i in Range.count(4, -1))
            arr3.push(i);
        
        assert.isDeepEqual([arr1, arr2, arr3],
        [
            [0, 1, 2, 3],
            [0, 2, 4],
            [4, 3, 2, 1],
        ]);
    }
    
    public function testZeroTo()
    {
        var arr1:Array<Int> = [];
        var arr2:Array<Int> = [];
        var arr3:Array<Int> = [];
        
        for (i in Range.zeroTo(4))
            arr1.push(i);
            
        for (i in Range.zeroTo(6, 2))
            arr2.push(i);
            
        for (i in Range.zeroTo(4, -1))
            arr3.push(i);
        
        assert.isDeepEqual([arr1, arr2, arr3],
        [
            [0, 1, 2, 3, 4],
            [0, 2, 4, 6],
            [4, 3, 2, 1, 0],
        ]);
    }
    
    public function testFrom()
    {
        var arr1:Array<Int> = [];
        var arr2:Array<Int> = [];
        var arr3:Array<Int> = [];
        var arr4:Array<Int> = [];
        var arr5:Array<Int> = [];
        
        for (i in Range.from(3, 9, 1))
            arr1.push(i);
            
        for (i in Range.from(3, 9, 2))
            arr2.push(i);
            
        for (i in Range.from(9, 3, -1))
            arr3.push(i);
            
        for (i in Range.from(9, 3, -2))
            arr4.push(i);
            
        for (i in Range.from(9, 3))
            arr5.push(i);
        
        assert.isDeepEqual([arr1, arr2, arr3, arr4, arr5],
        [
            [3, 4, 5, 6, 7, 8],
            [3, 5, 7],
            [9, 8, 7, 6, 5, 4],
            [9, 7, 5],
            [],
        ]);
    }
    
    public function testArray()
    {
        var arr1:Array<Int> = Range.count(6, 2).toArray();
        var arr2:Array<Int> = Range.zeroTo(4).toArray();
        var arr3:Array<Int> = Range.from(3, 9, 1).toArray();
        
        assert.isDeepEqual([arr1, arr2, arr3],
        [
            [0, 2, 4],
            [0, 1, 2, 3, 4],
            [3, 4, 5, 6, 7, 8],
        ]);
    }
    
    
}

