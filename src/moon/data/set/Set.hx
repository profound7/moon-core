package moon.data.set;

import haxe.Constraints.Function;
import haxe.Serializer;
import moon.core.Pair;
import moon.core.Seq;
import moon.data.iterators.MapIterator;
import moon.data.map.Dictionary;

/**
 * This Set abstract provides operator overloading for the
 * various set types. You can assign any class that implements
 * ISet to Set.
 * 
 * Usage:
 *      var a:Set<T> = new AnySet<T>();
 *      var b:Set<T> = new TreeSet<T>();
 *      var c:Set<T> = a & b;   // intersection of a and b
 *      trace(Type.typeof(c));  // AnySet. LHS type is used in operations
 *      
 * 
 * @author Munir Hussin
 */
@:forward abstract Set<T>(ISet<T>) to ISet<T> from ISet<T>
{
    
    public function new()
    {
        this = new TreeSet<T>();
    }
    
    /**
     * Return a new set by performing a cartesian product on `other`.
     */
    @:op(A * B) private inline function mul<U>(other:Set<U>):Set<Pair<T,U>>
    {
        return this.cartesianProduct(other);
    }
    
    @:op(a <= b) private inline function lte(other:Set<T>):Bool
    {
        return this.subset(other);
    }
    
    @:op(a < b) private inline function lt(other:Set<T>):Bool
    {
        return this.properSubset(other);
    }
    
    @:op(a >= b) private inline function gte(other:Set<T>):Bool
    {
        return other.subset(this);
    }
    
    @:op(a > b) private inline function ge(other:Set<T>):Bool
    {
        return other.properSubset(this);
    }
    
    @:op(a == b) private inline function eq(other:Set<T>):Bool
    {
        return this.equals(other);
    }
    
    @:op(a != b) private inline function neq(other:Set<T>):Bool
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
    @:op(A | B) private inline function or(other:Set<T>):Set<T>
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
    @:op(A & B) private inline function and(other:Set<T>):Set<T>
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
    @:op(A - B) private inline function sub(other:Set<T>):Set<T>
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
    @:op(A ^ B) private inline function xor(other:Set<T>):Set<T>
    {
        return this.exclude(other);
    }
    
    /*==================================================
        Conversions
    ==================================================*/
    
    /**
     * var set:Set<String> = Set.create(AnySet);
     */
    public static function create<T>(setClass:Class<ISet<T>>):Set<T>
    {
        return setClass != null ? Type.createInstance(setClass, []) : new Set<T>();
    }
    
    @:from public static function fromISet<T>(set:ISet<T>):Set<T>
    {
        //trace("FROM ISET");
        return set;
    }
    
    @:from public static function of<T>(seq:Seq<T>):Set<T>
    {
        //trace("FROM SEQ");
        var set = new Set<T>();
        set.addMany(seq);
        return set;
    }
    
    @:to public inline function toArray():Array<T>
    {
        return this.toArray();
    }
    
    @:to public inline function toString():String
    {
        return this.toString();
    }
}
