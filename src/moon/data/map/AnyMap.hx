package moon.data.map;

import haxe.Constraints.Function;
import haxe.Constraints.IMap;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.ds.StringMap;
import moon.core.Pair;
import moon.data.iterators.MapIterator;

/**
 * This map works by serializing the key into a String.
 * So any 2 keys that serializes into the same String
 * are considered to be the same key.
 * 
 * If you don't like the serialization method, you can
 * provide your own K->String function to turn your key
 * into a String.
 * 
 * NOTE: When working with objects/arrays as keys, as
 * long as they serialize to the same String, they're
 * considered equal, even if they have different
 * references!
 * 
 * @author Munir Hussin
 */
@:forward abstract AnyMap<K,V>(AnyMapType<K,V>) to AnyMapType<K,V> from AnyMapType<K,V>
{
    /**
     * Usage: Std.is(anymap, AnyMap.type);
     */
    public static var type(default, null) = AnyMapType;
    
    public function new(?to:K->String)
    {
        this = new AnyMapType<K,V>(to);
    }
    
    @:arrayAccess public inline function get(k:K):Null<V>
    {
        return this.get(k);
    }
    
    @:arrayAccess public inline function set(k:K, v:V):Void
    {
        return this.set(k, v);
    }
    
    @:to public inline function toString():String
    {
        return this.toString();
    }
}


private class AnyMapType<K, V> implements IMap<K,V>
{
    private var mapV:StringMap<V>;
    private var mapK:StringMap<K>;
    private var toKey:K->String;
    
    public function new(?toKey:K->String)
    {
        this.mapV = new StringMap<V>();
        this.mapK = new StringMap<K>();
        this.toKey = toKey == null ? AnySerializer.any() : toKey;
    }
    
    public function get(k:K):Null<V>
    {
        return mapV.get(toKey(k));
    }
    
    public function set(k:K, v:V):Void
    {
        var strK = toKey(k);
        mapK.set(strK, k);
        mapV.set(strK, v);
    }
    
    public function exists(k:K):Bool
    {
        return mapV.exists(toKey(k));
    }
    
    public function remove(k:K):Bool
    {
        var strK = toKey(k);
        mapK.remove(strK);
        return mapV.remove(strK);
    }
    
    public function keys():Iterator<K>
    {
        return mapK.iterator();
    }
    
    public function iterator():Iterator<V>
    {
        return mapV.iterator();
    }
    
    public function toString():String
    {
        return "{" + [for (k in mapV.keys()) mapK.get(k) + " => " + mapV.get(k)].join(", ") + "}";
    }
    
    /*==================================================
        Extra
    ==================================================*/
    
    public function pairs():Iterator<Pair<K,V>>
    {
        return new MapIterator<K,V>(this);
    }
}


class AnySerializer
{
    /**
     * The serializer
     */
    public static function serialize<K>(k:K):String
    {
        var s = new Serializer();
        s.useCache = true;
        s.useEnumIndex = true;
        s.serialize(k);
        return s.toString();
    }
    
    /**
     * Special case to handle functions as keys.
     * Functions can't be serialized, nor can it be compared (so BalancedTree wouldn't work).
     * So we have to iterate through the function array to find a match.
     */
    public static function any<K>():K->String
    {
        var fns:Array<Function> = [];
        
        return function(k:K):String
        {
            if (Reflect.isFunction(k))
            {
                var f:Function = cast k;
                var i:Int = fns.indexOf(f);
                
                if (i == -1)
                {
                    i = fns.length;
                    fns.push(f);
                }
                
                return 'F$i';
            }
            else
            {
                return serialize(k);
            }
        }
    }
}