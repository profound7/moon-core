package moon.core;

import haxe.CallStack;
import haxe.PosInfos;

using StringTools;

/**
 * Error abstract. Underlying type is Dynamic, so it can
 * be used in place of Dynamic in catch.
 * 
 * @author Munir Hussin
 */
abstract Error(Dynamic) to Dynamic from Dynamic
{
    public function new(?message:String, ?pos:PosInfos)
    {
        this = new Exception(message, pos);
    }
    
    @:to public function toString():String
    {
        return Std.string(this);
    }
    
    public function getStackTrace():String
    {
        var stack = CallStack.exceptionStack();
        stack.reverse();
        return CallStack.toString(stack);
    }
    
    public function printStackTrace():Void
    {
        Console.println(getStackTrace());
        Console.println("Caught exception - " + toString());
    }
    
    public function throwSelf():Void
    {
        rethrow(this);
    }
    
    public static inline function rethrow(ex:Dynamic):Void
    {
        #if neko
            neko.Lib.rethrow(ex);
        #elseif cpp
            cpp.Lib.rethrow(ex);
        #elseif php
            php.Lib.rethrow(ex);
        #elseif cs
            cs.Lib.rethrow(ex);
        #else
            throw ex;
        #end
    }
}


class Exception
{
    public var message(default, null):String;
    public var name(default, null):String;
    
    public function new(?message:String, ?pos:PosInfos)
    {
        this.message = message;
    }
    
    public static inline function rethrow(ex:Dynamic):Void
    {
        Error.rethrow(ex);
    }
}

