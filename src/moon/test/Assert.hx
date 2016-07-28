package moon.test;

import haxe.PosInfos;
import moon.core.Any;
import moon.core.Future;
import moon.core.Invoke;
import moon.test.TestStatus;
import moon.tools.FloatTools;

/**
 * ...
 * @author Munir Hussin
 */
@:allow(moon.test.TestRunner)
class Assert
{
    private static var currentTest:TestStatus;
    
    public function new() 
    {
    }
    
    
    /*==================================================
        Asserts
    ==================================================*/
    
    private function is(actual:Dynamic, expected:Dynamic, eq:Dynamic->Dynamic->Bool, info:String, ?pos:PosInfos):Void
    {
        if (eq(actual, expected))
            currentTest.ok();
        else
            currentTest.fail(info, actual, expected, pos);
    }
    
    public function isEqual(actual:Dynamic, expected:Dynamic, ?pos:PosInfos):Void
    {
        is(actual, expected, Any.equals, "isEqual", pos);
    }
    
    public function isNotEqual(actual:Dynamic, expected:Dynamic, ?pos:PosInfos):Void
    {
        is(actual, expected, Any.notEquals, "isNotEqual", pos);
    }
    
    public function isDeepEqual(actual:Dynamic, expected:Dynamic, ?pos:PosInfos):Void
    {
        is(actual, expected, Any.deepEquals, "isDeepEqual", pos);
    }
    
    public function isNotDeepEqual(actual:Dynamic, expected:Dynamic, ?pos:PosInfos):Void
    {
        is(actual, expected, Any.notDeepEquals, "isNotDeepEqual", pos);
    }
    
    public function isTrue(value:Dynamic, ?pos:PosInfos):Void
    {
        is(value, true, Any.equals, "isTrue", pos);
    }
    
    public function isFalse(value:Dynamic, ?pos:PosInfos):Void
    {
        is(value, false, Any.equals, "isFalse", pos);
    }
    
    public function isNull(value:Dynamic, ?pos:PosInfos):Void
    {
        is(value, null, Any.equals, "isNull", pos);
    }
    
    public function isNotNull(value:Dynamic, ?pos:PosInfos):Void
    {
        is(value, null, Any.notEquals, "isNotNull", pos);
    }
    
    public function isNear(actual:Dynamic, expected:Dynamic, epsilon:Float, ?pos:PosInfos):Void
    {
        is(Math.abs(expected - actual) <= Math.abs(epsilon), true, Any.equals, "isNear", pos);
    }
    
    public function isNotNear(actual:Dynamic, expected:Dynamic, epsilon:Float, ?pos:PosInfos):Void
    {
        is(Math.abs(expected - actual) <= Math.abs(epsilon), false, Any.equals, "isNotNear", pos);
    }
    
    public function isType(value:Dynamic, type:Dynamic, ?pos:PosInfos):Void
    {
        var actual = Type.getClassName(Type.getClass(value));
        var expected = Type.getClassName(type);
        
        is(actual, expected, Any.equals, "isType", pos);
    }
    
    
    private function are(actual:Array<Dynamic>, expected:Array<Dynamic>, eq:Dynamic->Dynamic->Bool, info:String, ?pos:PosInfos):Void
    {
        if (actual == null)
            currentTest.fail(info + " (actual is NULL)", actual, expected, pos);
        else if (expected == null)
            currentTest.fail(info + " (expected is NULL)", actual, expected, pos);
        else if (actual.length != expected.length)
            currentTest.fail(info + " (length different)", actual, expected, pos);
        else
        {
            for (i in 0...actual.length)
            {
                if (!eq(actual[i], expected[i]))
                {
                    currentTest.fail(info, actual, expected, pos);
                    return;
                }
            }
            
            currentTest.ok();
        }
    }
    
    public function areEqual(actual:Array<Dynamic>, expected:Array<Dynamic>, ?pos:PosInfos):Void
    {
        are(actual, expected, Any.equals, "areNear", pos);
    }
    
    public function areNear(actual:Array<Dynamic>, expected:Array<Dynamic>, epsilon:Float, ?pos:PosInfos):Void
    {
        var fn = function(a, b) return FloatTools.isNear(a, b, epsilon);
        are(actual, expected, fn, "areNear", pos);
    }
    
    public function throws(fn:Void->Dynamic, ?pos:PosInfos):Void
    {
        try
        {
            fn();
            currentTest.fail("throws", "No error", "Error", pos, false);
        }
        catch (ex:Dynamic)
        {
            currentTest.ok();
        }
    }
    
    public function noThrows(fn:Void->Dynamic, ?pos:PosInfos):Void
    {
        try
        {
            fn();
            currentTest.ok();
        }
        catch (ex:Dynamic)
        {
            currentTest.fail("noThrows", "Error", "No error", pos, false);
        }
    }
    
    public function returns(fn:Void->Dynamic, value:Dynamic, ?pos:PosInfos):Void
    {
        try
        {
            var x = fn();
            
            if (Any.deepEquals(x, value))
            {
                //trace("equal!");
                currentTest.ok();
            }
            else
            {
                //trace("not equal!");
                currentTest.fail("returns", x, value, pos, false);
            }
        }
        catch (ex:Dynamic)
        {
            //trace("ERROR!");
            currentTest.fail("returns", "Error", "No error", pos, false);
        }
    }
    
    /*==================================================
        Async Asserts
    ==================================================*/
    
    private function will(actual:Future<Dynamic>, expected:Dynamic, eq:Dynamic->Dynamic->Bool, info:String, ?timeout_ms:Int, ?pos:PosInfos):Void
    {
        (function(currentTest:TestStatus):Void
        {
            var outcome = currentTest.pending();
            
            // if timeout is given, fail the Future when timeout expires
            if (timeout_ms != null)
            {
                var timeF:Future<Bool> = new Future<Bool>();
                //Async.delay(function() { timeF.complete(true); }, timeout_ms);
                Invoke.later(function() { timeF.complete(true); }, timeout_ms);
                
                timeF.onComplete(function(v:Bool):Void
                {
                    if (!actual.isDone)
                        actual.fail("Timeout expired");
                });
            }
            
            actual.onComplete(function(value:Dynamic):Void
            {
                if (eq(value, expected))
                    outcome.ok();
                else
                    outcome.fail(info, value, expected, pos);
            });
            
            actual.onFail(function(err:Dynamic):Void
            {
                outcome.err("Error: " + Std.string(err), pos);
            });
            
        })(currentTest);
    } 
    
    public function willBeEqual(actual:Future<Dynamic>, expected:Dynamic, ?timeout_ms:Int, ?pos:PosInfos):Void
    {
        will(actual, expected, Any.equals, "willBeEqual", timeout_ms, pos);
    }
    
    public function willBeNotEqual(actual:Future<Dynamic>, expected:Dynamic, ?timeout_ms:Int, ?pos:PosInfos):Void
    {
        will(actual, expected, Any.notEquals, "willBeNotEqual", timeout_ms, pos);
    }
    
    public function willBeDeepEqual(actual:Future<Dynamic>, expected:Dynamic, ?timeout_ms:Int, ?pos:PosInfos):Void
    {
        will(actual, expected, Any.deepEquals, "willBeDeepEqual", timeout_ms, pos);
    }
    
    public function willBeNotDeepEqual(actual:Future<Dynamic>, expected:Dynamic, ?timeout_ms:Int, ?pos:PosInfos):Void
    {
        will(actual, expected, Any.notDeepEquals, "willBeNotDeepEqual", timeout_ms, pos);
    }
    
    public function willBeTrue(value:Future<Dynamic>, ?timeout_ms:Int, ?pos:PosInfos):Void
    {
        will(value, true, Any.equals, "willBeTrue", timeout_ms, pos);
    }
    
    public function willBeFalse(value:Future<Dynamic>, ?timeout_ms:Int, ?pos:PosInfos):Void
    {
        will(value, false, Any.equals, "willBeFalse", timeout_ms, pos);
    }
    
    public function willBeNull(value:Future<Dynamic>, ?timeout_ms:Int, ?pos:PosInfos):Void
    {
        will(value, null, Any.equals, "willBeNull", timeout_ms, pos);
    }
    
    public function willBeNotNull(value:Future<Dynamic>, ?timeout_ms:Int, ?pos:PosInfos):Void
    {
        will(value, null, Any.notEquals, "willBeNotNull", timeout_ms, pos);
    }
    
    public function willBeNear(actual:Future<Dynamic>, expected:Dynamic, epsilon:Float, ?timeout_ms:Int, ?pos:PosInfos):Void
    {
        var val:Future<Bool> = new Future<Bool>();
        
        actual.onComplete(function(value:Dynamic):Void
        {
            val.complete(Math.abs(expected - value) <= Math.abs(epsilon));
        });
        
        will(actual, true, Any.equals, "willBeNear", timeout_ms, pos);
    }
    
    public function willBeNotNear(actual:Future<Dynamic>, expected:Dynamic, epsilon:Float, ?timeout_ms:Int, ?pos:PosInfos):Void
    {
        var val:Future<Bool> = new Future<Bool>();
        
        actual.onComplete(function(value:Dynamic):Void
        {
            val.complete(Math.abs(expected - value) <= Math.abs(epsilon));
        });
        
        will(actual, false, Any.equals, "willBeNotNear", timeout_ms, pos);
    }
    
    public function willBeType(value:Future<Dynamic>, type:Dynamic, ?timeout_ms:Int, ?pos:PosInfos):Void
    {
        var actual:Future<String> = new Future<String>();
        var expected:String = Type.getClassName(type);
        
        actual.onComplete(function(value:Dynamic):Void
        {
            actual.complete(Type.getClassName(Type.getClass(value)));
        });
        
        will(actual, expected, Any.equals, "willBeType", timeout_ms, pos);
    }
    
}