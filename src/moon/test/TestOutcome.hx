package moon.test;

import haxe.PosInfos;
import moon.core.Future;

/**
 * ...
 * @author Munir Hussin
 */
class TestOutcome
{
    public var status:TestState;
    public var async:Future<Bool>;
    public var error:String;
    public var posInfos:PosInfos;
    public var backtrace:String;
    
    public function new() 
    {
        status = NotStarted;
        async = new Future<Bool>();
    }
    
    public static function msg(info:String, actual:Dynamic, expected:Dynamic):String
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
    
    public function err(msg:String, pos:PosInfos):Void
    {
        status = Failed;
        error = msg;
        posInfos = pos;
        async.complete(false);
    }
    
    public function fail(info:String, actual:Dynamic, expected:Dynamic, pos:PosInfos):Void
    {
        err(msg(info, actual, expected), pos);
    }
}