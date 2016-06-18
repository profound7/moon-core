package moon.macros.signal;

import haxe.Constraints.Function;

/**
 * ...
 * @author Munir Hussin
 */
abstract SlotList<T:Function>(Array<Slot<T>>) to Array<Slot<T>> from Array<Slot<T>>
{
    public var length(get, never):Int;
    
    /*==================================================
        Constructor
    ==================================================*/
    
    public function new()
    {
        this = [];
    }
    
    private static function compare<T:Function>(a:Slot<T>, b:Slot<T>):Int
    {
        return a.priority - b.priority;
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private inline function get_length():Int
    {
        return this.length;
    }
    
    /*==================================================
        Methods
    ==================================================*/
    
    /**
     * Adds a listener to this slot list.
     */
    public function add(listener:T, limit:Int=-1, priority:Int=1):Slot<T>
    {
        var slot:Slot<T> = new Slot<T>(listener, limit, priority, true);
        this.push(slot);
        this.sort(compare);
        return slot;
    }
    
    /**
     * Finds a listener in this slot list and returns its position.
     */
    public function indexOf(listener:T, start:Int=0):Int
    {
        for (i in start...this.length)
            if (this[i].listener == listener)
                return i;
        return -1;
    }
    
    /**
     * Checks to see if this slot list contains a particular listener.
     */
    public inline function contains(listener:T):Bool
    {
        return indexOf(listener) != -1;
    }
    
    /**
     * Empties the slot list.
     */
    public inline function clear():Void
    {
        this.splice(0, this.length);
    }
    
    /**
     * Removes a specific slot.
     */
    public inline function removeSlot(slot:Slot<T>):Bool
    {
        return this.remove(slot);
    }
    
    /**
     * Removes a specific listener.
     * Use negative limit to remove all matching listeners.
     */
    public function remove(listener:T, limit:Int=-1):Array<Slot<T>>
    {
        // remove those that are already 0 priority
        cleanup();
        
        // set those we want to remove to have priority 0
        for (s in this)
        {
            if (limit != 0 && s.listener == listener)
            {
                s.priority = 0;
                
                if (limit > 0)
                    --limit;
            }
            
            if (limit == 0)
                break;
        }
        
        // remove those with priority 0
        return cleanup();
    }
    
    /**
     * Needed by dispatch to loop through all slots.
     */
    public inline function iterator():Iterator<Slot<T>>
    {
        return this.iterator();
    }
    
    /**
     * Ensures the slots are ordered by priority, and
     * removes all slots with priority less than 1.
     */
    public function cleanup():Array<Slot<T>>
    {
        // sort by priority
        this.sort(compare);
        
        // don't need to do anything
        if (length == 0 || this[0].priority > 0)
            return [];
        
        // one item and priority is less than 1
        if (length == 1)
        {
            return [this.pop()];
        }
        
        // more than 1 item so need to find and
        // remove all those with priority less than 1.
        // this[0] case already handled above. so start from 1
        for (i in 1...this.length)
        {
            if (this[i].priority > 0)
            {
                return this.splice(0, i - 1);
                
                // don't need to compare other slots
                // since it's sorted by priority
            }
        }
        
        // shouldn't reach here
        throw "oops!";
        //return [];
    }
}