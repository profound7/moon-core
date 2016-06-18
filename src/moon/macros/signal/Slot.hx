package moon.macros.signal;

import haxe.Constraints.Function;

/**
 * ...
 * @author Munir Hussin
 */
class Slot<T:Function>
{
    public var listener:T;
    public var limit:Int;
    public var priority:Int;
    public var enabled:Bool;
    
    public function new(listener:T, limit:Int=-1, priority:Int=1, enabled:Bool=true) 
    {
        this.listener = listener;
        this.limit = limit;
        this.priority = priority;
        this.enabled = enabled;
    }
    
    public inline function canExecute():Bool
    {
        return enabled && limit != 0 && priority > 0;
    }
    
    public inline function execute(values:Array<Dynamic>):Void
    {
        if (canExecute())
        {
            // negative limit means can execute forever
            // positive limit means can execute
            // zero limit means cannot execute
            
            if (limit > 0) --limit;
            Reflect.callMethod(null, listener, values);
        }
    }
}
