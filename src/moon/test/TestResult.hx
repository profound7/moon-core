package moon.test;

import moon.test.TestStatus;

/**
 * ...
 * @author Munir Hussin
 */
class TestResult
{
    private var m_tests:List<TestStatus>;
    public var success(default, null):Bool;

    public function new()
    {
        m_tests = new List();
        success = true;
    }

    public function add(t:TestStatus):Void
    {
        m_tests.add(t);
        if (t.status != Success)
            success = false;
    }

    public function toString():String
    {
        var buf = new StringBuf();
        var failures = 0;
        
        buf.add("\n");
        
        for (test in m_tests)
        {
            if (test.status != Success)
            {
                buf.add("* ");
                buf.add(test.className);
                buf.add("::");
                buf.add(test.method);
                buf.add("()");
                buf.add("\n");
                
                buf.add("ERR: ");
                
                if (test.posInfos != null)
                {
                    buf.add(test.posInfos.fileName);
                    buf.add(":");
                    buf.add(test.posInfos.lineNumber);
                    buf.add("(");
                    buf.add(test.posInfos.className);
                    buf.add(".");
                    buf.add(test.posInfos.methodName);
                    buf.add(") - \n");
                }
                
                buf.add(test.error);
                buf.add("\n");
                
                if (test.backtrace != null && test.backtrace.length > 0)
                {
                    buf.add(test.backtrace);
                    buf.add("\n");
                }
                
                buf.add("\n");
                failures++;
            }
        }
        
        buf.add("\n");
        
        if (failures == 0)
            buf.add("OK ");
        else
            buf.add("FAILED ");
            
        buf.add(m_tests.length);
        buf.add(" tests, ");
        buf.add(failures);
        buf.add(" failed, ");
        buf.add((m_tests.length - failures));
        buf.add(" success");
        buf.add("\n");
        
        return buf.toString();
    }
}
