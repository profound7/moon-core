package moon.data.map;

import haxe.Constraints.IMap;
import moon.data.list.DoubleLinkedList;
import moon.core.Signal;

/**
 * Least Recently Used (LRU) Cache
 * 
 * LruCache<T> works like a Map<String, T> except that it
 * has limited `capacity`. When you add an item and the cache
 * is full, the cache will remove an item from the back of
 * the queue, to make room for a new item.
 * 
 * Each time you access an item, that item will be moved
 * to the front of the queue.
 * 
 * @author Munir Hussin
 */
class LruCache<T> implements IMap<String, T>
{
    private var map:Map<String, DoubleLinkedNode<CacheInfo<T>>>;
    private var list:DoubleLinkedList<CacheInfo<T>>;
    
    public var evicted:Signal<String, T>;
    //public var missing:Signal<String, Ref<T>>;
    public var onMiss:String->T;
    
    public var capacity(default, set):Int;
    public var length(get, never):Int;
    public var evictionCount(default, null):Int;
    public var hitCount(default, null):Int;
    public var missCount(default, null):Int;
    
    public function new(capacity:Int=-1, ?onMiss:String->T) 
    {
        evictionCount = 0;
        hitCount = 0;
        missCount = 0;
        
        map = new Map<String, DoubleLinkedNode<CacheInfo<T>>>();
        list = new DoubleLinkedList<CacheInfo<T>>();
        evicted = new Signal<String, T>();
        //missing = new Signal<String, Ref<T>>();
        
        this.capacity = capacity;
        this.onMiss = onMiss;
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private inline function get_length():Int
    {
        return list.length;
    }
    
    private inline function set_capacity(v:Int):Int
    {
        capacity = v;
        trim();
        return v;
    }
    
    /*==================================================
        Methods
    ==================================================*/
    
    /**
     * Removes excess entries to satisfy capacity requirements.
     */
    private inline function trim():Void
    {
        if (capacity >= 0)
            while (length >= capacity)
                evict();
    }
    
    /**
     * Clears the cache.
     */
    public inline function clear():Void
    {
        while (length > 0) remove(list.first.key);
    }
    
    /**
     * Remove the oldest item that was accessed
     */
    public function evict():Null<T>
    {
        if (length > 0)
        {
            var info = list.shift();
            map.remove(info.key);
            ++evictionCount;
            evicted.dispatch(info.key, info.value);
            return info.value;
        }
        else
        {
            return null;
        }
    }
    
    public function set(key:String, value:T):Void
    {
        var node = map.get(key);
        
        // already exist. no length change. just update
        if (node != null)
        {
            DoubleLinkedList.removeNode(list, node);
            DoubleLinkedList.insertLast(list, node);
            node.data.value = value;
        }
        // does not exist. need to add
        else
        {
            // if cache is full, make room
            trim();
            
            // add it in
            var info = new CacheInfo<T>(key, value);
            list.push(info);
            map.set(key, DoubleLinkedList.lastNode(list));
        }
    }
    
    public function get(key:String):Null<T>
    {
        var node = map.get(key);
        
        // node exist
        if (node != null)
        {
            ++hitCount;
            DoubleLinkedList.removeNode(list, node);
            DoubleLinkedList.insertLast(list, node);
            return node.data.value;
        }
        // node does not exist
        else
        {
            ++missCount;
            
            var value:T = null;
            
            if (onMiss != null)
            {
                value = onMiss(key);
                set(key, value);
            }
            
            return value;
            
            // create a reference variable, and trigger missing signal
            //var ref = new Ref<T>();
            //missing.dispatch(key, ref);
            
            // if reference now has a value (set by one of the listeners)
            // then use that value
            //if (ref.value != null)
            //    set(key, ref.value);
            
            //return ref.value;
        }
    }
    
    public inline function exists(key:String):Bool
    {
        return map.exists(key);
    }
    
    public function remove(key:String):Bool
    {
        var node = map.get(key);
        
        if (node != null)
        {
            DoubleLinkedList.removeNode(list, node);
            map.remove(key);
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public inline function keys():Iterator<String>
    {
        return map.keys();
    }
    
    public inline function iterator():Iterator<T>
    {
        return new CacheIterator<T>(list);
    }
    
    public function toString():String
    {
        var arr:Array<String> = [];
        for (info in list.iterator())
            arr.push('${info.key} => ${info.value}');
        return "{ " + arr.join(", ") + " }";
    }
}

private class CacheInfo<T>
{
    public var key:String;
    public var value:T;
    
    public function new(key:String, value:T)
    {
        this.key = key;
        this.value = value;
    }
}

private class CacheIterator<T>
{
    public var it:Iterator<CacheInfo<T>>;
    
    public inline function new(list:DoubleLinkedList<CacheInfo<T>>)
    {
        it = list.iterator();
    }
    
    public inline function hasNext():Bool
    {
        return it.hasNext();
    }
    
    public inline function next():T
    {
        return it.next().value;
    }
}