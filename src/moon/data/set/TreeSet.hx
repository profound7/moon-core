package moon.data.set;

import moon.core.Pair;
import moon.core.Seq;
import moon.data.map.OrderedMap;

/**
 * // uses Reflect.compare
 * var set:Set<Fruit> = new TreeSet<Fruit>();
 * 
 * // custom compare function
 * var set:Set<Fruit> = new TreeSet<Fruit>(Compare.by(function(x:Fruit) return x.name.length));
 * 
 * @author Munir Hussin
 */
class TreeSet<T> implements ISet<T>
{
    public var length(get, never):Int;
    private var map:OrderedMap<T,T>;
    private var cmp:T->T->Int;
    
    public function new(?cmp:T->T->Int)
    {
        this.cmp = cmp;
        map = new OrderedMap<T,T>(cmp);
    }
    
    private inline function get_length():Int
    {
        return map.length;
    }
    
    /*==================================================
        IMap
    ==================================================*/
    
    public function exists(v:T):Bool
    {
        return map.exists(v);
    }
    
    public function remove(v:T):Bool
    {
        return map.remove(v);
    }
    
    public function iterator():Iterator<T>
    {
        return map.keys();
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
        map.set(v, v);
        return vExists;
    }
    
    public function addMany(seq:Seq<T>):Void
    {
        for (v in seq) add(v);
    }
    
    public function clear():Void
    {
        map = new OrderedMap<T,T>(cmp);
    }
    
    public function clone():TreeSet<T>
    {
        var set = new TreeSet<T>(cmp);
        set.addMany(this);
        return set;
    }
    
    /*==================================================
        Set Operations
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
        var s = new TreeSet<T>(cmp);
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
        var s = new TreeSet<T>(cmp);
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
        var s = new TreeSet<T>(cmp);
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
        var s = new TreeSet<T>(cmp);
        for (x in this) if (!other.exists(x)) s.add(x);
        for (x in other) if (!this.exists(x)) s.add(x);
        return s;
    }
    
    /**
     * Return a new set by performing a cartesian product on `other`.
     */
    public function cartesianProduct<U>(other:Set<U>):Set<Pair<T,U>>
    {
        var s = new TreeSet<Pair<T,U>>();
        for (a in this)
            for (b in other)
                s.add(Pair.of(a, b));
        return s;
    }
}