package moon.test;
import haxe.PosInfos;
import moon.core.Future;

/**
 * ...
 * @author Munir Hussin
 */
class TestStatus
{
    public var status:Status;
    public var async:Future<Bool>;
    
    public var error:String;
    public var method:String;
    public var className:String;
    public var posInfos:PosInfos;
    public var backtrace:String;
    
    public function new()
    {
        status = NotStarted;
        async = new Future<Bool>();
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
        status = Success;
        async.complete(true);
    }
    
    public function err(msg:String, pos:PosInfos, throwError:Bool=true):Void
    {
        status = Failed;
        error = msg;
        posInfos = pos;
        async.complete(false);
        if (throwError) throw this;
    }
    
    public function fail(info:String, actual:Dynamic, expected:Dynamic, pos:PosInfos, throwError:Bool=true):Void
    {
        err(msg(info, actual, expected), pos, throwError);
    }
}

enum Status
{
    NotStarted;
    Success;
    Failed;
    Pending;
}
