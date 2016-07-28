package moon.test;

import haxe.PosInfos;
import moon.core.Future;

/**
 * ...
 * @author Munir Hussin
 */
class TestStatus
{
    public var outcomes:Array<TestOutcome>;
    
    //public var status:Status;
    //public var async:Future<Bool>;
    
    //public var error:String;
    public var method:String;
    public var className:String;
    //public var posInfos:PosInfos;
    //public var backtrace:String;
    
    public function new()
    {
        outcomes = [];
        //status = NotStarted;
        //async = new Future<Bool>();
    }
    
    public function msg(info:String, actual:Dynamic, expected:Dynamic):String
    {
        return
        [
            "Info:     " + info,
            "Expected: " + Std.string(expected),
            "Actual:   " + Std.string(actual),
            
        ].join("\n");
    }
    
    public function ok():Void
    {
        var out = new TestOutcome();
        out.ok();
        outcomes.push(out);
    }
    
    public function err(msg:String, pos:PosInfos, throwError:Bool=true):Void
    {
        var out = new TestOutcome();
        out.err(msg, pos);
        outcomes.push(out);
        if (throwError) throw this;
    }
    
    public function fail(info:String, actual:Dynamic, expected:Dynamic, pos:PosInfos, throwError:Bool=true):Void
    {
        var out = new TestOutcome();
        out.fail(info, actual, expected, pos);
        outcomes.push(out);
        if (throwError) throw this;
    }
    
    public function pending():TestOutcome
    {
        var out = new TestOutcome();
        outcomes.push(out);
        return out;
    }
}

