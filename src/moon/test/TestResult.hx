package moon.test;

import moon.test.TestStatus;

/**
 * ...
 * @author Munir Hussin
 */
class TestResult
{
    private var tests:List<TestStatus>;
    public var success(default, null):Bool;

    public function new()
    {
        tests = new List();
        success = true;
    }

    public function add(t:TestStatus):Void
    {
        tests.add(t);
        if (success == true)
            for (outcome in t.outcomes)
                if (outcome.status != Success)
                    { success = false; break; }
    }

    public function toString():String
    {
        var buf = new StringBuf();
        
        var failures = 0;
        var success = 0;
        
        buf.add("\n");
        
        for (test in tests)
        {
            for (outcome in test.outcomes)
            {
                if (outcome.status != Success)
                {
                    buf.add("* ");
                    buf.add(test.className);
                    buf.add("::");
                    buf.add(test.method);
                    buf.add("()");
                    buf.add("\n");
                    
                    buf.add("ERR: ");
                    
                    if (outcome.posInfos != null)
                    {
                        buf.add(outcome.posInfos.fileName);
                        buf.add(":");
                        buf.add(outcome.posInfos.lineNumber);
                        buf.add("(");
                        buf.add(outcome.posInfos.className);
                        buf.add(".");
                        buf.add(outcome.posInfos.methodName);
                        buf.add(") - \n");
                    }
                    
                    buf.add(outcome.error);
                    buf.add("\n");
                    
                    if (outcome.backtrace != null && outcome.backtrace.length > 0)
                    {
                        buf.add(outcome.backtrace);
                        buf.add("\n");
                    }
                    
                    buf.add("\n");
                    ++failures;
                }
                else
                {
                    ++success;
                }
            }
        }
        
        buf.add("\n");
        
        if (failures == 0)
            buf.add("OK ");
        else
            buf.add("FAILED ");
            
        buf.add(tests.length);
        buf.add(" tests, ");
        buf.add(success + failures);
        buf.add(" asserts, ");
        buf.add(failures);
        buf.add(" failed, ");
        buf.add(success);
        buf.add(" success");
        buf.add("\n");
        
        return buf.toString();
    }
}
