package moon.test;

import moon.core.Future;
import moon.core.Console;
import moon.test.TestStatus;

using StringTools;

/**
 * This is based on haxe's default unit testing framework,
 * but modified to allow async test cases using Futures.
 * 
 * @author Munir Hussin
 */
class TestRunner
{
    private var cases:Array<TestCase>;
    
    
    public function new() 
    {
        cases = new Array<TestCase>();
    }
    
    private inline function print(v:Dynamic)
    {
        Console.print(v);
    }
    
    public function add(c:TestCase):Void
    {
        cases.push(c);
    }
    
    public function run():Future<TestResult>
    {
        var ret:Future<TestResult> = new Future<TestResult>();
        var result:TestResult = new TestResult();
        
        // parallel mode
        /*
        var results:Array<Future<Bool>> = [];
        
        for (c in cases)
        {
            results.push(runCase(c, result));
        }
        
        Future.array(results).onComplete(function(v):Void
        {
            print(result.toString());
            ret.complete(result);
        });
        */
        
        // sequential mode
        var c = cases.copy();
        c.reverse();
        
        function next(v:Bool):Void
        {
            if (c.length == 0)
            {
                print(result.toString());
                ret.complete(result);
            }
            else
            {
                runCase(c.pop(), result).onComplete(next);
            }
        }
        
        next(false);
        return ret;
    }
    
    private function runCase(c:TestCase, result:TestResult):Future<Bool>
    {
        var ret:Future<Bool> = new Future<Bool>();
        var cl = Type.getClass(c);
        var fields:Array<String> = Type.getInstanceFields(cl);
        var results:Array<Future<TestStatus>> = [];
        
        print("Class: " + Type.getClassName(cl) + " ");
        
        // run setup
        if (fields.indexOf("setup") != -1)
            Reflect.callMethod(c, Reflect.field(c, "setup"), []);
        
        // run all the test methods. if there are async methods,
        // then they are run in parallel.
        for (f in fields)
        {
            results.push(runMethod(c, f));
        }
        
        Future.array(results).onComplete(function(statuses:Array<TestStatus>):Void
        {
            for (s in statuses)
                if (s != null)
                    result.add(s);
                    
            print("\n");
            ret.complete(true);
        });
        
        return ret;
    }
    
    private function runMethod(c:TestCase, fn:String):Future<TestStatus>
    {
        var ret:Future<TestStatus> = new Future<TestStatus>();
        var cl = Type.getClass(c);
        
        var status:TestStatus = new TestStatus();
        var field = Reflect.field(c, fn);
        
        if (fn.startsWith("test") && Reflect.isFunction(field))
        {
            var currentTest = new TestStatus();
            currentTest.className = Type.getClassName(cl);
            currentTest.method = fn;
            
            try
            {
                Assert.currentTest = currentTest;
                Reflect.callMethod(c, field, []);
                
                switch (currentTest.status)
                {
                    case NotStarted:
                        print("W");
                        currentTest.error = "(warning) no assert";
                        ret.complete(currentTest);
                        
                    case Success:
                        print(".");
                        ret.complete(currentTest);
                        
                    case Failed:
                        print("F");
                        ret.complete(currentTest);
                        
                    case Pending:
                        //print("?");
                        currentTest.async.onComplete(function(success:Bool):Void
                        {
                            if (success)
                            {
                                print(".");
                            }
                            else
                            {
                                print("F");
                                currentTest.backtrace = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
                            }
                                
                            ret.complete(currentTest);
                        });
                }
            }
            catch (e:TestStatus)
            {
                print("F");
                currentTest.backtrace = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
                ret.complete(currentTest);
            }
            catch (e:Dynamic)
            {
                print("E");
                currentTest.error = e;
                currentTest.backtrace = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
                ret.complete(currentTest);
            }
        }
        else
        {
            // not a test case. ignore.
            ret.complete(null);
        }
        
        return ret;
    }
}
