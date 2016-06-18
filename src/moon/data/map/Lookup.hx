package moon.data.map;

import haxe.Constraints.IMap;
import moon.data.iterators.IterableIterator;

/**
 * Lookup<K,V> is Map<K, Array<V>>
 * Values in the array are not guaranteed to be unique.
 * 
 * If the constructor argument `map` is not provided, AnyMap
 * is used.
 * 
 * @author Munir Hussin
 */
class Lookup<K,V> implements IMap<K, Array<V>>
{
    private var map:IMap<K, Array<V>>;
    
    public function new(?map:IMap<K, Array<V>>)
    {
        this.map = map == null ? new AnyMap<K, Array<V>>() : map;
    }
    
    public inline function get(k:K):Null<Array<V>>
    {
        return map.get(k);
    }
    
    public inline function set(k:K, av:Array<V>):Void
    {
        map.set(k, av);
    }
    
    /**
     * Returns true when the key exist AND the array has at
     * least 1 element.
     */
    public inline function exists(k:K):Bool
    {
        return map.exists(k) && map.get(k).length > 0;
    }
    
    public inline function remove(k:K):Bool
    {
        return map.remove(k);
    }
    
    public inline function keys():Iterator<K>
    {
        return map.keys();
    }
    
    public inline function iterator():Iterator<Array<V>>
    {
        return map.iterator();
    }
    
    public inline function toString():String
    {
        return map.toString();
    }
    
    /*==================================================
        Array methods
    ==================================================*/
    
    public inline function values():Iterator<V>
    {
        return new IterableIterator(map.iterator());
    }
    
    /**
     * Get the array from key `k` or create one if it
     * does not exist.
     */
    public function getOrCreate(k:K):Array<V>
    {
        var arr:Array<V> = map.get(k);
        
        if (arr == null)
        {
            arr = [];
            map.set(k, arr);
        }
        
        return arr;
    }
}