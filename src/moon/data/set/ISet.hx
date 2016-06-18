package moon.data.set;

import moon.core.Pair;
import moon.core.Seq;

/**
 * ...
 * @author Munir Hussin
 */
interface ISet<T>
{
    public var length(get, null):Int;
    
    public function exists(k:T):Bool;
    public function remove(k:T):Bool;
    public function iterator():Iterator<T>;
    public function toString():String;
    public function toArray():Array<T>;
    
    public function add(v:T):Bool;
    public function addMany(seq:Seq<T>):Void;
    public function clear():Void;
    public function clone():Set<T>;
    
    
    public function subset(other:Set<T>):Bool;
    public function properSubset(other:Set<T>):Bool;
    public function equals(other:Set<T>):Bool;
    public function disjoint(other:Set<T>):Bool;
    public function compareTo(other:Set<T>):Int;
    
    public function union(other:Set<T>):Set<T>;
    public function intersect(other:Set<T>):Set<T>;
    public function difference(other:Set<T>):Set<T>;
    public function exclude(other:Set<T>):Set<T>;
    
    public function cartesianProduct<U>(other:Set<U>):Set<Pair<T,U>>;
}

