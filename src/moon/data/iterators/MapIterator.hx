package moon.data.iterators;

import haxe.Constraints.IMap;
import moon.core.Pair;

/**
 * Iterate through the key/value pairs in a map
 * 
 * @author Munir Hussin
 */
class MapIterator<K,V>
{
    private var m:IMap<K,V>;
    private var it:Iterator<K>;
    
    public inline function new(m:IMap<K,V>)
    {
        this.m = m;
        this.it = m.keys();
    }
    
    public inline function hasNext():Bool
    {
        return it.hasNext();
    }
    
    public inline function next():Pair<K,V>
    {
        var k = it.next();
        return Pair.of(k, m.get(k));
    }
}