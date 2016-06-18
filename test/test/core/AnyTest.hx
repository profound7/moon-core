package test.core;

import moon.core.Any;
import moon.core.Future;
import moon.core.Range;
import moon.core.Struct;
import moon.test.TestCase;
import moon.test.TestRunner;

/**
 * ...
 * @author Munir Hussin
 */
class AnyTest extends TestCase
{
    public static function main() 
    {
        var r = new TestRunner();
        r.add(new AnyTest());
        r.run();
    }
    
    
    public function testDeepEqualsCircular01()
    {
        var a:Struct = { foo: "bar" };
        var b:Struct = { foo: "bar" };
        
        a["baz"] = a;
        b["baz"] = b;
        
        assert.isTrue(Any.deepEquals(a, b));
    }
    
    public function testDeepEqualsCircular02()
    {
        var a:Struct = { foo: "bar" };
        var b:Struct = { foo: "bar" };
        
        a["baz"] = b;
        b["baz"] = a;
        
        assert.isTrue(Any.deepEquals(a, b));
    }
}