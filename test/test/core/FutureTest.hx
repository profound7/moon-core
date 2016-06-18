package test.core;

import moon.core.Tuple;
import moon.core.Future;
import moon.test.TestCase;
import moon.test.TestRunner;

/**
 * ...
 * @author Munir Hussin
 */
class FutureTest extends TestCase
{
    public static function main() 
    {
        var r = new TestRunner();
        r.add(new FutureTest());
        r.run();
        //Async.exit();
    }
    
    
    public function testUnit1()
    {
        var fut:Future<Int> = Future.unitValue(5);
        assert.willBeEqual(fut, 5);
    }
    
    public function testUnit2()
    {
        var fut:Future<String> = Future.unitValue("hi");
        assert.willBeEqual(fut, "hi");
    }
    
    public function testAnd1()
    {
        var a:Future<String> = Future.unitValue("aaa");
        var b:Future<Int> = Future.unitValue(3);
        var c:Future<Float> = Future.unitValue(1.23);
        
        var fut = a.and(b).and(c);
        assert.willBeDeepEqual(fut, [["aaa", 3], 1.23]);
        //assert.willBeDeepEqual(fut, Tuple.of(Tuple.of("aaa", 3), 1.23));
    }
    
    /*public function testAnd2()
    {
        var a:FutureValue<String> = Future.unitValue("aaa");
        var b:FutureValue<Int> = Future.unitValue(3);
        var c:FutureValue<Float> = Future.unitValue(1.23);
        
        var fut = a && b && c;
        assert.willBeDeepEqual(fut, Tuple.of("aaa", 3, 1.23));
    }
    
    public function testAnd3()
    {
        var a:FutureValue<String> = Future.unitValue("aaa");
        var b:FutureValue<Int> = Future.unitValue(3);
        var c:FutureValue<Float> = Future.unitValue(1.23);
        
        var fut = a && b && c;
        
        fut.onComplete(function(arr)
        {
            var a_val:String = a;
            var b_val:Int = b;
            var c_val:Float = c;
            
            assert.isEqual(a_val, "aaa");
            assert.isEqual(b_val, 3);
            assert.isEqual(c_val, 1.23);
        });
    }*/
    
    public function testArray()
    {
        var a:Future<String> = Future.unitValue("aaa");
        var b:Future<Int> = Future.unitValue(3);
        var c:Future<Float> = Future.unitValue(1.23);
        var arr:Array<Future<Dynamic>> = [a, b, c];
        var fut:Future<Array<Dynamic>> = Future.array(arr);
        assert.willBeDeepEqual(fut, ["aaa", 3, 1.23]);
    }
    
}

