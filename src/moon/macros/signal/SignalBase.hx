package moon.macros.signal;

import haxe.Constraints.Function;
import moon.core.Future;

/**
 * ...
 * @author Munir Hussin
 */
class SignalBase<T:Function>
{
    public var slots(default, null):SlotList<T>;
    
    #if (haxe_ver >= 3.3)
    private var futures:Array<Future<Array<Dynamic>>>;
    #end
    
    public function new() 
    {
        slots = new SlotList<T>();
        
        #if (haxe_ver >= 3.3)
        futures = [];
        #end
    }
    
    /**
     * Adds a listener to the slot list.
     * `limit` is the maximum number of times the listener can trigger.
     *      set to -1 for unlimited.
     * `priority` is the order the listeners are triggered.
     *      slots with priority 0 are removed
     */
    public inline function add(limit:Int=-1, priority:Int=1, listener:T):Slot<T>
    {
        return slots.add(listener, limit, priority);
    }
    
    /**
     * Checks to see if the slot list contains a particular listener.
     */
    public inline function contains(listener:T):Bool
    {
        return slots.contains(listener);
    }
    
    /**
     * Removes all listeners
     */
    public inline function clear():Void
    {
        return slots.clear();
    }
    
    /**
     * Removes specific listerners from the slots.
     * Negative `limit` will remove all matching listeners,
     * while positive `limit` will remove `limit` occurances.
     */
    public inline function remove(listener:T, limit:Int=-1):Array<Slot<T>>
    {
        return slots.remove(listener, limit);
    }
    
    /**
     * Sends the values to all listeners.
     */
    public function dynamicDispatch(values:Array<Dynamic>):Void
    {
        #if (haxe_ver >= 3.3)
        for (f in futures)
        {
            f.complete(values);
        }
        futures = [];
        #end
        
        for (s in slots)
        {
            s.execute(values);
            
            if (s.limit == 0)
            {
                s.priority = 0;
            }
        }
        
        slots.cleanup();
    }
    
    #if (haxe_ver >= 3.3)
    /**
     * Return a Future that will trigger the next time this
     * Signal is triggered.
     */
    public function dynamicNext():Future<Array<Dynamic>>
    {
        var f:Future<Array<Dynamic>> = new Future<Array<Dynamic>>();
        futures.push(f);
        return f;
    }
    #end
}