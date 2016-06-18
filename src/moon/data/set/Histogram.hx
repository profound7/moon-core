package moon.data.set;

import haxe.Constraints.IMap;
import haxe.Serializer;
import moon.core.Pair;
import moon.core.Seq;
import moon.data.iterators.MapIterator;
import moon.data.map.OrderedMap;

/**
 * Histogram<T> is a Map<T,Int> where Int is the count of T.
 * It also has Set<T> methods, but doesn't implements ISet<T>.
 * 
 * @author Munir Hussin
 */
@:forward abstract Histogram<T>(HistogramType<T>) to HistogramType<T> from HistogramType<T>
{
    /**
     * Usage: Std.is(set, Histogram.type);
     */
    public static var type(default, null) = HistogramType;
    
    public function new(?cmp:T->T->Int)
    {
        this = new HistogramType<T>(cmp);
    }
    
    /**
     * Return a new set by performing a cartesian product on `other`.
     */
    @:op(A * B) private inline function mul<U>(other:Histogram<U>):Histogram<Pair<T,U>>
    {
        return this.cartesianProduct(other);
    }
    
    @:op(a <= b) private inline function lte(other:Histogram<T>):Bool
    {
        return this.subset(other);
    }
    
    @:op(a < b) private inline function lt(other:Histogram<T>):Bool
    {
        return this.properSubset(other);
    }
    
    @:op(a >= b) private inline function gte(other:Histogram<T>):Bool
    {
        return other.subset(this);
    }
    
    @:op(a > b) private inline function ge(other:Histogram<T>):Bool
    {
        return other.properSubset(this);
    }
    
    @:op(a == b) private inline function eq(other:Histogram<T>):Bool
    {
        return this.equals(other);
    }
    
    @:op(a != b) private inline function neq(other:Histogram<T>):Bool
    {
        return !this.equals(other);
    }
    
    /**
     * Returns a new set containing all elements from `this`
     * as well as elements from `other`.
     * 
     * Operator: this | other
     * Venn: (###(###)###)
     */
    @:op(A | B) private inline function or(other:Histogram<T>):Histogram<T>
    {
        return this.union(other);
    }
    
    /**
     * Returns a new set containing common elements that
     * appears in both sets.
     * 
     * Operator: this & other
     * Venn: (   (###)   )
     */
    @:op(A & B) private inline function and(other:Histogram<T>):Histogram<T>
    {
        return this.intersect(other);
    }
    
    /**
     * Returns a new set containing elements that appears in
     * `this` that does not appear in `other`.
     * 
     * Operator: this - other
     * Venn: (###(   )   )
     */
    @:op(A - B) private inline function sub(other:Histogram<T>):Histogram<T>
    {
        return this.difference(other);
    }
    
    /**
     * Returns a new set containing elements that appears in
     * either `this` or `other`, but not both.
     * 
     * Operator: this ^ other
     * Venn: (###(   )###)
     */
    @:op(A ^ B) private inline function xor(other:Histogram<T>):Histogram<T>
    {
        return this.exclude(other);
    }
    
    /*==================================================
        Conversions
    ==================================================*/
    
    @:from public static function of<T>(seq:Seq<T>):Histogram<T>
    {
        var set = new Histogram<T>();
        set.addMany(seq);
        return set;
    }
    
    @:to public inline function toSortedPairs():Array<Pair<T,Int>>
    {
        return this.toSortedPairs();
    }
    
    @:to public inline function toString():String
    {
        return this.toString();
    }
}

/**
 * ...
 * @author Munir Hussin
 */
class HistogramType<T> implements IMap<T,Int>
{
    public var length(get, never):Int;
    private var map:OrderedMap<T,Int>;
    private var cmp:T->T->Int;
    
    public function new(?cmp:T->T->Int)
    {
        this.cmp = cmp;
        map = new OrderedMap<T,Int>(cmp);
    }
    
    private inline function get_length():Int
    {
        return map.length;
    }
    
    /*==================================================
        IMap
    ==================================================*/
    
    public function get(k:T):Null<Int>
    {
        return map.get(k);
    }
    
    public function set(k:T, v:Int):Void
    {
        map.set(k, v);
    }
    
    public function exists(k:T):Bool
    {
        return map.exists(k);
    }
    
    public function remove(k:T):Bool
    {
        return map.remove(k);
    }
    
    public function keys():Iterator<T>
    {
        return map.keys();
    }
    
    public function iterator():Iterator<Int>
    {
        return map.iterator();
    }
    
    public function toString():String
    {
        return map.toString();
    }
    
    /*==================================================
        Histogram
    ==================================================*/
    
    public function inc(v:T, count:Int, defval:Int=1):Bool
    {
        var keyExists = exists(v);
        set(v, keyExists ? get(v) + count : defval);
        return keyExists;
    }
    
    public function toSortedPairs():Array<Pair<T,Int>>
    {
        var arr = toPairs();
        arr.sort(function(a, b) return a.tail - b.tail);
        return arr;
    }
    
    public function toPairs():Array<Pair<T,Int>>
    {
        return [for (p in pairs()) p];
    }
    
    public function toArray():Array<T>
    {
        return [for (p in pairs()) for (_ in 0...p.tail) p.head];
    }
    
    public inline function pairs():Iterator<Pair<T,Int>>
    {
        return new MapIterator<T,Int>(this);
    }
    
    public function mergeAdd(other:Histogram<T>):Histogram<T>
    {
        for (x in other.pairs())
            inc(x.head, x.tail);
        return this;
    }
    
    public function mergeSub(other:Histogram<T>):Histogram<T>
    {
        for (x in other.pairs())
            inc(x.head, -x.tail, -1);
        return this;
    }
    
    /*==================================================
        Set
    ==================================================*/
    
    public function add(v:T):Bool
    {
        return inc(v, 1);
    }
    
    public function addMany(seq:Seq<T>):Void
    {
        for (v in seq) add(v);
    }
    
    public function clear():Void
    {
        map = new OrderedMap<T,Int>(cmp);
    }
    
    public function clone():Histogram<T>
    {
        var hist = new Histogram<T>(cmp);
        for (p in pairs())
            hist.set(p.head, p.tail);
        return hist;
    }
    
    /*==================================================
        Set Operations
    ==================================================*/
    
    /**
     * Returns true if all elements in `this` is also in `other`.
     * a <= b
     */
    public function subset(other:Histogram<T>):Bool
    {
        for (x in this.keys())
            if (!other.exists(x))
                return false;
        return true;
    }
    
    /**
     * Returns true if all elements in `this` is also in `other`
     * and `other` has more elements than `this`.
     * a < b
     */
    public inline function properSubset(other:Histogram<T>):Bool
    {
        return length < other.length && subset(other);
    }
    
    /**
     * Returns true if `this` and `other` have the exact
     * same elements.
     * a == b
     */
    public inline function equals(other:Histogram<T>):Bool
    {
        return length == other.length && subset(other);
    }
    
    /**
     * Returns true if `this` and `other` has no common elements.
     */
    public function disjoint(other:Histogram<T>):Bool
    {
        for (x in this.keys())
            if (other.exists(x))
                return false;
        return true;
    }
    
    /**
     * Compare with another set by its cardinality.
     */
    public inline function compareTo(other:Histogram<T>):Int
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
    public function union(other:Histogram<T>):Histogram<T>
    {
        var s = new Histogram<T>(cmp);
        for (x in this.keys()) s.set(x, this.get(x));
        for (x in other.keys()) s.inc(x, other.get(x));
        return s;
    }
    
    /**
     * Returns a new set containing common elements that
     * appears in both sets.
     * 
     * Operator: this & other
     * Venn: (   (###)   )
     */
    public function intersect(other:Histogram<T>):Histogram<T>
    {
        var s = new Histogram<T>(cmp);
        for (x in this.keys()) if (other.exists(x)) s.set(x, this.get(x) + other.get(x));
        return s;
    }
    
    /**
     * Returns a new set containing elements that appears in
     * `this` that does not appear in `other`.
     * 
     * Operator: this - other
     * Venn: (###(   )   )
     */
    public function difference(other:Histogram<T>):Histogram<T>
    {
        var s = new Histogram<T>(cmp);
        for (x in this.keys()) if (!other.exists(x)) s.set(x, this.get(x));
        return s;
    }
    
    /**
     * Returns a new set containing elements that appears in
     * either `this` or `other`, but not both.
     * 
     * Operator: this ^ other
     * Venn: (###(   )###)
     */
    public function exclude(other:Histogram<T>):Histogram<T>
    {
        var s = new Histogram<T>(cmp);
        for (x in this.keys()) if (!other.exists(x)) s.set(x, this.get(x));
        for (x in other.keys()) if (!this.exists(x)) s.set(x, other.get(x));
        return s;
    }
    
    /**
     * Return a new set by performing a cartesian product on `other`.
     */
    public function cartesianProduct<U>(other:Histogram<U>):Histogram<Pair<T,U>>
    {
        var s = new Histogram<Pair<T,U>>();
        for (a in this.keys())
            for (b in other.keys())
                s.add(Pair.of(a, b));
        return s;
    }
}
