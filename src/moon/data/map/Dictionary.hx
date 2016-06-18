package moon.data.map;

import moon.core.Compare;
import moon.core.Pair;
import haxe.Constraints.IMap;

using moon.tools.ArrayTools;

/**
 * In this implementation, Dictionary is like a StringMap,
 * but the order of keys is maintained in insertion order.
 * Alternatively, the keys can be sorted.
 * 
 * You can use array access with either Int or String, and it'll
 * use the underlying getByIndex or getByKey respectively.
 *
 * Usage:
 *      var d:Dictionary<String> = new Dictionary<String>();
 *      d["b"] = "bbb";
 *      d["d"] = "ddd";
 *      d["a"] = "aaa";
 *      d["c"] = "ccc";
 *      
 *      // appears in insertion order
 *      trace(d);
 *      
 *      // these 2 lines modify the same entry
 *      d[2] = "zzz";
 *      d["a"] = "yyy";
 * 
 * @author Munir Hussin
 */
@:forward abstract Dictionary<V>(DictionaryType<V>) to DictionaryType<V> from DictionaryType<V>
{
    /**
     * Usage: Std.is(anymap, AnyMap.type);
     */
    public static var type(default, null) = DictionaryType;
    
    public function new()
    {
        this = new DictionaryType<V>();
    }
    
    @:arrayAccess public inline function getByIndex(i:Int):V
    {
        return this.getByIndex(i);
    }
    
    @:arrayAccess public inline function get(s:String):V
    {
        return this.get(s);
    }
    
    @:arrayAccess public inline function setByIndex(i:Int, value:V):V
    {
        this.setByIndex(i, value);
        return value;
    }
    
    @:arrayAccess public inline function set(s:String, value:V):V
    {
        this.set(s, value);
        return value;
    }
    
    @:to public inline function toString():String
    {
        return this.toString();
    }
}


private class DictionaryType<V> implements IMap<String,V>
{
    public var length(get, never):Int;
    private var arr:Array<String>;
    private var map:Map<String,V>;
    
    /*==================================================
        Constructor
    ==================================================*/
    
    public function new()
    {
        arr = [];
        map = new Map<String,V>();
    }
    
    /*public function fromMap(map:Map<String,V>):Void
    {
        this.map = map;
        refreshKeys();
    }*/
    
    /*==================================================
        Properties
    ==================================================*/
    
    private inline function get_length():Int
    {
        return arr.length;
    }
    
    /*==================================================
        Methods
    ==================================================*/
        
    /**
     * When keys are refreshed, the original sorting
     * sequence is lost.
     */
    /*public function refreshKeys():Void
    {
        arr.clear();
        for (k in map.keys())
            arr.push(k);
    }*/
    
    /**
     * Sort the entries. If `cmp` is not given, the entries are sorted
     * alphabetically.
     */
    public function sort(?cmp:Pair<String,V>->Pair<String,V>->Int):Void
    {
        // if no sorter function is specified, then dictionary
        // entries are sorted alphabetically in ascending order
        
        var fn:String->String->Int = cmp == null ?
            Compare.string(Asc, CaseSensitive, false):
            function(a, b) return cmp(Pair.of(a, get(a)), Pair.of(b, get(b)));
        
        arr.sort(fn);
    }
    
    public inline function get(key:String):V
    {
        return map.get(key);
    }
    
    public function set(key:String, value:V):Void
    {
        // if it's a new key, add it to the ordered keys
        if (!map.exists(key))
            arr.push(key);
        map.set(key, value);
    }
    
    public inline function getByIndex(i:Int):V
    {
        return map.get(arr[i]);
    }
    
    public function setByIndex(i:Int, value:V):Void
    {
        if (i < 0 || i >= arr.length)
            throw "Index out of bounds exception.";
        map.set(arr[i], value);
    }
    
    public function remove(key:String):Bool
    {
        if (map.exists(key))
        {
            arr.remove(key);
            return map.remove(key);
        }
        
        return false;
    }
    
    public inline function exists(key:String):Bool
    {
        return map.exists(key);
    }
    
    public function iterator():Iterator<V>
    {
        return new DictionaryIterator<V>(this);
    }
    
    public inline function keys():Iterator<String>
    {
        return arr.iterator();
    }
    
    public inline function values():Iterator<V>
    {
        return iterator();
    }
    
    public inline function pairs():Iterator<Pair<String,V>>
    {
        return new DictionaryPairIterator<V>(this);
    }
    
    public function toString():String
    {
        return "{" + [for (p in pairs()) p.join(" => ")].join(", ") + "}";
    }
}


private class DictionaryIterator<V>
{
    public var obj:Dictionary<V>;
    public var it:Iterator<String>;
    
    public inline function new(obj:Dictionary<V>)
    {
        this.obj = obj;
        this.it = obj.keys();
    }
    
    public inline function hasNext():Bool
    {
        return it.hasNext();
    }
    
    public inline function next():V
    {
        return obj.get(it.next());
    }
}


private class DictionaryPairIterator<V>
{
    public var obj:Dictionary<V>;
    public var it:Iterator<String>;
    
    public inline function new(obj:Dictionary<V>)
    {
        this.obj = obj;
        this.it = obj.keys();
    }
    
    public inline function hasNext():Bool
    {
        return it.hasNext();
    }
    
    public inline function next():Pair<String,V>
    {
        var k:String = it.next();
        return Pair.of(k, obj.get(k));
    }
}

