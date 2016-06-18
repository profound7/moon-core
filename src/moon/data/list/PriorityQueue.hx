package moon.data.list;

import moon.data.iterators.IterableIterator;
import moon.data.map.OrderedMap;

using moon.tools.IteratorTools;

/**
 * PriorityQueue, implemented using haxe.ds.BalancedTree.
 * (Well, moon.data.map.OrderedMap is built upon haxe.ds.BalancedTree)
 * 
 * @author Munir Hussin
 */
class PriorityQueue<T>
{
    public var length(default, null):Int;
    private var map:OrderedMap<T, List<T>>;
    private var cmp:T->T->Int;
    
    public function new(?cmp:T->T->Int) 
    {
        this.cmp = cmp;
        clear();
    }
    
    public function clear():Void
    {
        map = new OrderedMap(cmp);
        length = 0;
    }
    
    /**
     * Adds an element into the PriorityQueue
     */
    public function add(v:T):Void
    {
        if (map.exists(v))
        {
            map.get(v).push(v);
        }
        else
        {
            var list = new List<T>();
            list.push(v);
            map.set(v, list);
        }
        
        ++length;
    }
    
    /**
     * Return a list of elements that are tied at the front of the queue.
     * All elements in this list are considered equal according to the comparator,
     * even if they have different references.
     */
    private function front():List<T>
    {
        return map.iterator().next();
    }
    
    /**
     * Returns the element that is at the front of the queue.
     * This operation does not modify the priority queue.
     */
    public function peek():Null<T>
    {
        var list = front();
        return list != null ? list.first() : null;
    }
    
    /**
     * Removes the element that is at the front of the queue.
     */
    public function remove():Null<T>
    {
        return delete(peek());
    }
    
    /**
     * Removes an element from anywhere in the queue.
     * 
     * The element is matched using the compare function, and the first
     * element that matches will be removed.
     * 
     * If `strictRef` is true, then the reference must also match.
     */
    public function delete(v:T, strictRef:Bool=false):Null<T>
    {
        var list = map.get(v);
        var val:T = null;
        
        if (list != null)
        {
            if (strictRef)
            {
                if (list.remove(v))
                {
                    val = v;
                    --length;
                }
            }
            else if (list.length > 0)
            {
                val = list.pop();
                --length;
            }
            
            if (list.length == 0)
            {
                map.remove(val);
            }
        }
        
        return val;
    }
    
    public function iterator():Iterator<T>
    {
        return new IterableIterator<T>(map.iterator());
    }
    
    public function toString():String
    {
        return "[" + iterator().join(", ") + "]";
    }
}