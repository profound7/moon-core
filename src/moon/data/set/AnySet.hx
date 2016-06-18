package moon.data.set;

import haxe.Constraints.Function;
import haxe.Serializer;
import moon.core.Pair;
import moon.core.Seq;
import moon.data.map.AnyMap.AnySerializer;
import moon.data.map.Dictionary;

/**
 * This set works based on serialization.
 * 
 * If two objects serializes to the same string, they are considered equal.
 * If it is a set of functions, then two functions are equal if they have
 * the same reference.
 * 
 * You can add
 *      @:keep private function hxSerialize(s:Serializer) ...
 * to your classes to implement custom serialization result.
 * 
 * @author Munir Hussin
 */
class AnySet<T> implements ISet<T>
{
    public var length(get, never):Int;
    private var map:Dictionary<T>;
    private var toKey:T->String;
    
    public function new(?toKey:T->String)
    {
        this.map = new Dictionary<T>();
        this.toKey = toKey == null ? AnySerializer.any() : toKey;
    }
    
    private inline function get_length():Int
    {
        return map.length;
    }
    
    /*==================================================
        IMap
    ==================================================*/
    
    public function exists(k:T):Bool
    {
        return map.exists(toKey(k));
    }
    
    public function remove(k:T):Bool
    {
        return map.remove(toKey(k));
    }
    
    public function iterator():Iterator<T>
    {
        return map.iterator();
    }
    
    public function toString():String
    {
        return "{" + [for (x in this) x].join(", ") + "}";
    }
    
    public function toArray():Array<T>
    {
        return [for (v in this) v];
    }
    
    /*==================================================
        Set
    ==================================================*/
    
    public function add(v:T):Bool
    {
        var vExists = exists(v);
        map.set(toKey(v), v);
        return vExists;
    }
    
    public function addMany(seq:Seq<T>):Void
    {
        for (v in seq) add(v);
    }
    
    public function clear():Void
    {
        map = new Dictionary<T>();
    }
    
    public function clone():AnySet<T>
    {
        var set = new AnySet<T>(toKey);
        set.addMany(this);
        return set;
    }
    
    /*==================================================
        Operations
    ==================================================*/
    
    /**
     * Returns true if all elements in `this` is also in `other`.
     * a <= b
     */
    public function subset(other:Set<T>):Bool
    {
        //return intersect(other).length == length;
        for (x in this)
            if (!other.exists(x))
                return false;
        return true;
    }
    
    /**
     * Returns true if all elements in `this` is also in `other`
     * and `other` has more elements than `this`.
     * a < b
     */
    public inline function properSubset(other:Set<T>):Bool
    {
        return length < other.length && subset(other);
    }
    
    /**
     * Returns true if `this` and `other` have the exact
     * same elements.
     * a == b
     */
    public inline function equals(other:Set<T>):Bool
    {
        return length == other.length && subset(other);
    }
    
    /**
     * Returns true if `this` and `other` has no common elements.
     */
    public function disjoint(other:Set<T>):Bool
    {
        for (x in this)
            if (other.exists(x))
                return false;
        return true;
    }
    
    /**
     * Compare with another set by its cardinality.
     */
    public inline function compareTo(other:Set<T>):Int
    {
        return this.length - other.length;
    }
    
    /**
     * Returns a new set containing all elements from `this`
     * as well as elements from `other`.
     * 
     * Operator: this | other
     * Venn: (###(###)###)
     */
    public function union(other:Set<T>):Set<T>
    {
        var s = new AnySet<T>(toKey);
        for (x in this) s.add(x);
        for (x in other) s.add(x);
        return s;
    }
    
    /**
     * Returns a new set containing common elements that
     * appears in both sets.
     * 
     * Operator: this & other
     * Venn: (   (###)   )
     */
    public function intersect(other:Set<T>):Set<T>
    {
        var s = new AnySet<T>(toKey);
        for (x in this) if (other.exists(x)) s.add(x);
        return s;
    }
    
    /**
     * Returns a new set containing elements that appears in
     * `this` that does not appear in `other`.
     * 
     * Operator: this - other
     * Venn: (###(   )   )
     */
    public function difference(other:Set<T>):Set<T>
    {
        var s = new AnySet<T>(toKey);
        for (x in this) if (!other.exists(x)) s.add(x);
        return s;
    }
    
    /**
     * Returns a new set containing elements that appears in
     * either `this` or `other`, but not both.
     * 
     * Operator: this ^ other
     * Venn: (###(   )###)
     */
    public function exclude(other:Set<T>):Set<T>
    {
        var s = new AnySet<T>(toKey);
        for (x in this) if (!other.exists(x)) s.add(x);
        for (x in other) if (!this.exists(x)) s.add(x);
        return s;
    }
    
    /**
     * Return a new set by performing a cartesian product on `other`.
     */
    public function cartesianProduct<U>(other:Set<U>):Set<Pair<T,U>>
    {
        var s = new AnySet<Pair<T,U>>();
        for (a in this)
            for (b in other)
                s.add(Pair.of(a, b));
        return s;
    }
}