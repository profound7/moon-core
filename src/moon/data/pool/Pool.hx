package moon.data.pool;

import haxe.ds.Vector;
import moon.data.iterators.IteratorIterator;
import moon.data.iterators.VectorIterator;

using moon.tools.VectorTools;

/**
 * A Pool<T> is a collection of reusable T objects.
 * A Pool avoids creating new instances whenever possible.
 * 
 * When an instance is requested, the Pool will revive
 * a dead instance for reuse. If there's no dead instances,
 * then the Pool will create a new one.
 * 
 * However, if the capacity is full, then the Pool will decide
 * on what to do next depending on the PoolPolicy.
 * 
 * @author Munir Hussin
 */
class Pool<T>
{
    public var length(default, null):Int;
    public var capacity(get, never):Int;
    
    public var items:Vector<T>;
    public var policy:PoolPolicy;
    public var constructor:Void->T;
    public var destructor:T->Void;
    
    // linked list for increasing capacity
    private var next:Pool<T>;
    
    
    public function new(capacity:Int, policy:PoolPolicy, constructor:Void->T, destructor:T->Void)
    {
        this.policy = policy;
        this.constructor = constructor;
        this.destructor = destructor;
        
        this.items = new Vector<T>(capacity);
        this.length = 0;
    }
    
    private inline function get_capacity():Int
    {
        return items.length;
    }
    
    public function create():T
    {
        if (length < capacity)
        {
            if (items[length] == null)
            {
                // create a new one
                return items[length++] = constructor();
            }
            else
            {
                // revive a dead one
                var item = items[length++];
                return item;
            }
        }
        else if (next != null)
        {
            return next.create();
        }
        else
        {
            return applyPolicy(policy);
        }
    }
    
    private function applyPolicy(p:PoolPolicy):T
    {
        switch (p)
        {
            case CreateError:
                throw "Pool is full";
                
            case KillInactive:
                throw "not implemented";
                
            case KillOldest:
                throw "not implemented";
                
            case IncreaseSize(n):
                next = new Pool<T>(n, policy, constructor, destructor);
                return next.create();
                
            case MultiPolicy(arr):
                
                // try a series of policies and if it works, return immediately
                for (a in arr)
                {
                    try
                    {
                        var ret = applyPolicy(a);
                        return ret;
                    }
                    catch (ex:Dynamic)
                    {
                        if (ex == "Pool is full")
                            throw ex;
                    }
                }
                
                throw "No policy worked";
        }
    }
    
    public function destroy(item:T):Void
    {
        var i = items.indexOf(item);
        
        if (i != -1)
        {
            if (destructor != null)
                destructor(items[i]);
            
            // swap i with length-1
            //                               length
            // live0 live1 live2 live3 live4 dead5 dead6 null
            // destroy(live1)
            //                         length
            // live0 live4 live2 live3 dead1 dead5 dead6 null
            
            var tmp = items[i];
            items[i] = items[length - 1];
            items[length - 1] = tmp;
            
            --length;
        }
        else if (next != null)
        {
            next.destroy(item);
            if (next.length == 0)
                next = next.next;
        }
    }
    
    public function iterator():Iterator<T>
    {
        if (next == null)
        {
            return new VectorIterator<T>(items, length);
        }
        else
        {
            var arr:Array<Iterator<T>> = [];
            var curr = this;
            
            while (curr != null)
            {
                arr.push(new VectorIterator<T>(curr.items, curr.length));
                curr = curr.next;
            }
            
            return new IteratorIterator<T>(arr.iterator());
        }
    }
    
    public function toString():String
    {
        return Std.string(items) + (next == null ? "" : "->" + next.toString());
    }
}



enum PoolPolicy
{
    CreateError;
    KillInactive;
    KillOldest;
    IncreaseSize(by:Int);
    MultiPolicy(a:Array<PoolPolicy>);
}