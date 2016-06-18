package moon.tools;

import haxe.Constraints.IMap;
import haxe.ds.Vector;
import moon.core.Compare;
import moon.core.Types.Comparable;
import moon.data.iterators.IterableIterator;
import moon.data.map.AnyMap;

/**
 * There's no IterableTools because we don't want to pollute and fill Iterables with
 * so many methods. Use Seq instead.
 * 
 * @author Munir Hussin
 */
class IteratorTools
{
    
    /*==================================================
        Lambda
    ==================================================*/
    
    public static function map<T,U>(it:Iterator<T>, f:T->U):List<U>
    {
        var l = new List<U>();
        for (x in it)
            l.add(f(x));
        return l;
    }
    
    public static function mapi<T,U>(it:Iterator<T>, f:Int->T->U):List<U>
    {
        var l = new List<U>();
        var i = 0;
        for (x in it)
            l.add(f(i++,x));
        return l;
    }
    
    public static function has<T>(it:Iterator<T>, v:T):Bool
    {
        for (x in it)
            if (x == v)
                return true;
        return false;
    }
    
    public static function exists<T>(it:Iterator<T>, f:T->Bool):Bool
    {
        for (x in it)
            if (f(x))
                return true;
        return false;
    }
    
    public static function foreach<T>(it:Iterator<T>, f:T->Bool):Bool
    {
        for (x in it)
            if (!f(x))
                return false;
        return true;
    }
    
    public static function iter<T>(it:Iterator<T>, f:T->Void)
    {
        for (x in it)
            f(x);
    }
    
    public static function filter<T>(it:Iterator<T>, f:T->Bool):List<T>
    {
        var l = new List<T>();
        for (x in it)
            if (f(x))
                l.add(x);
        return l;
    }
    
    public static inline function isEmpty<T>(it:Iterator<T>):Bool
    {
        return !it.hasNext();
    }
    
    public static function indexOf<T>(it:Iterator<T>, v:T):Int
    {
        var i = 0;
        for (x in it)
        {
            if (x == v)
                return i;
            i++;
        }
        return -1;
    }
    
    public static function find<T>(it:Iterator<T>, f:T->Bool):Null<T>
    {
        for (v in it)
            if (f(v)) return v;
        return null;
    }
    
    public static function concat<T>(a:Iterator<T>, b:Iterator<T>):List<T>
    {
        var l = new List();
        for (x in a) l.add(x);
        for (x in b) l.add(x);
        return l;
    }
    
    /*==================================================
        New stuff not from Lambda 
    ==================================================*/
    
    public static function flatMap<T,U>(it:Iterator<T>, fn:T->Iterable<U>):List<U>
    {
        var l = new List<U>();
        for (x in it)
        {
            var subList = fn(x);
            if (subList != null)
                for (s in subList)
                    l.add(s);
        }
        return l;
    }
    
    public static function flatMapi<T,U>(it:Iterator<T>, fn:Int->T->Iterable<U>):List<U>
    {
        var l = new List<U>();
        var i = 0;
        for (x in it)
        {
            var subList = fn(i++, x);
            if (subList != null)
                for (s in subList)
                    l.add(s);
        }
        return l;
    }
    
    public static function equals<T>(a:Iterator<T>, b:Iterator<T>, ?cmp:T->T->Int):Bool
    {
        if (cmp == null) cmp = Compare.any(Asc);
        
        while (a.hasNext() && b.hasNext())
        {
            if (cmp(a.next(), b.next()) != 0)
                return false;
        }
        
        return !(a.hasNext() || b.hasNext());
    }
    
    /**
     * Checks if this sequence contains a value using a
     * comparison function `cmp`.
     * 
     * By using a comparison function, you can make use of
     * the Compare module.
     */
    public static function contains<T>(it:Iterator<T>, v:T, ?cmp:T->T->Int):Bool
    {
        if (cmp == null) return has(it, v);
        
        for (x in it)
            if (cmp(x, v) == 0)
                return true;
        return false;
    }
    
    public static function distinct<T>(it:Iterator<T>, ?cmp:T->T->Int):Array<T>
    {
        if (cmp == null) cmp = Compare.any(Asc);
        var unq = new Array<T>();
        
        for (x in it)
            if (!contains(unq.iterator(), x, cmp))
                unq.push(x);
        
        return unq;
    }
    
    public static function jump<T>(it:Iterator<T>, count:Int):Iterator<T>
    {
        while (it.hasNext() && count-->0)
            it.next();
        return it;
    }
    
    public static function skip<T>(it:Iterator<T>, count:Int):List<T>
    {
        var l = new List<T>();
        it = jump(it, count);
        for (x in it)
            l.add(x);
        return l;
    }
    
    public static function skipWhile<T>(it:Iterator<T>, pred:T->Bool):List<T>
    {
        var l = new List<T>();
        
        while (it.hasNext())
        {
            var x = it.next();
            
            if (!pred(x))
            {
                l.add(x);
                while (it.hasNext())
                    l.add(it.next());
            }
        }
        
        return l;
    }
    
    public static function take<T>(it:Iterator<T>, count:Int):List<T>
    {
        var l = new List<T>();
        while (count-->0 && it.hasNext())
            l.add(it.next());
        return l;
    }
    
    public static function takeWhile<T>(it:Iterator<T>, pred:T->Bool):List<T>
    {
        var l = new List<T>();
        for (x in it)
            if (pred(x))
                l.add(x);
            else
                break;
        return l;
    }
    
    public static function single<T>(it:Iterator<T>):T
    {
        if (!it.hasNext()) throw "There are no elements";
        var val = it.next();
        if (it.hasNext()) throw "There are more than 1 element";
        return val;
    }
    
    public static function singleOrDefault<T>(it:Iterator<T>, defaultValue:T):T
    {
        var val = it.hasNext() ? it.next() : defaultValue;
        if (it.hasNext()) throw "There are more than 1 element";
        return val;
    }
    
    public static function first<T>(it:Iterator<T>):T
    {
        if (!it.hasNext()) throw "There are no elements";
        return it.next();
    }
    
    public static function firstOrDefault<T>(it:Iterator<T>, defaultValue:T):T
    {
        return it.hasNext() ? it.next() : defaultValue;
    }
    
    public static function last<T>(it:Iterator<T>):T
    {
        if (!it.hasNext()) throw "There are no elements";
        var val:T = it.next();
        while (it.hasNext()) val = it.next();
        return val;
    }
    
    public static function lastOrDefault<T>(it:Iterator<T>, defaultValue:T):T
    {
        var val:T = defaultValue;
        while (it.hasNext()) val = it.next();
        return val;
    }
    
    public static function get<T>(it:Iterator<T>, i:Int):T
    {
        it = jump(it, i);
        if (!it.hasNext()) throw "Index out of bounds";
        return it.next();
    }
    
    public static function getOrDefault<T>(it:Iterator<T>, i:Int, defaultValue:T):T
    {
        it = jump(it, i);
        return it.hasNext() ? it.next() : defaultValue;
    }
    
    /**
     * Returns a new List with this sequence reversed.
     * This is an O(n) operation.
     */
    public static function reverse<T>(it:Iterator<T>):List<T>
    {
        var l = new List<T>();
        for (x in it) l.push(x);
        return l;
    }
    
    public static function join<T>(it:Iterator<T>, sep:String):String
    {
        var s = new StringBuf();
        
        if (it.hasNext())
        {
            s.add(Std.string(it.next()));
            
            while (it.hasNext())
            {
                s.add(sep);
                s.add(Std.string(it.next()));
            }
        }
        
        return s.toString();
    }
    
    /*==================================================
        Sorting operations
    ==================================================*/
    
    public static function sortBy<T>(it:Iterator<T>, cmp:T->T->Int):Array<T>
    {
        // using array because arrays have a native sorting method
        // which is usually faster in most platforms compared to custom
        // sorting algorithms
        var a = toArray(it);
        a.sort(cmp);
        return a;
    }
    
    public static inline function sortByValue<T,U>(it:Iterator<T>, ?fn:T->U, order:Order=Asc):Array<T>
    {
        return fn == null ?
            sortBy(it, Compare.any(order)):
            sortBy(it, Compare.map(fn, Compare.any(order)));
    }
    
    public static inline function sortByComparable<T,U:Comparable<U>>(it:Iterator<T>, fn:T->U, order:Order=Asc):Array<T>
    {
        return sortBy(it, Compare.map(fn, Compare.obj(order)));
    }
    
    public static inline function sortByOwnComparable<T:Comparable<T>>(it:Iterator<T>, order:Order=Asc):Array<T>
    {
        return sortBy(it, Compare.obj(order));
    }
    
    public static function groupBy<T,K,V>(it:Iterator<T>, fnKey:T->K, fnVal:K->T->V):IMap<K, Array<V>>
    {
        var map = new AnyMap<K, Array<V>>();
        
        for (x in it)
        {
            var key:K = fnKey(x);
            var val:V = fnVal(key, x);
            var arr:Array<V>;
            
            if (map.exists(key))
            {
                arr = map.get(key);
            }
            else
            {
                arr = [];
                map.set(key, arr);
            }
            
            arr.push(val);
        }
        
        return map;
    }
    
    public static function groupByValue<T,K,V>(it:Iterator<T>, ?fnKey:T->Dynamic, ?fnVal:Dynamic->T->Dynamic):IMap<Dynamic, Array<T>>
    {
        if (fnKey == null) fnKey = function(t) return t;
        if (fnVal == null) fnVal = function(k, t) return t;
        return groupBy(it, fnKey, fnVal);
    }
    
    public static function orderBy<T>(it:Iterator<T>, cmp:T->T->Int):Array<Array<T>>
    {
        var a = toArray(it);
        
        switch (a.length)
        {
            case 0:
                return [[]];
                
            case 1:
                return [[a[0]]];
                
            case _:
                // first we sort the array
                a.sort(cmp);
                //trace(a);
                
                // then we make another pass to group the results
                var groups:Array<Array<T>> = [];
                var it = a.iterator();
                var prev = it.next();
                var grp:Array<T> = [prev];
                
                for (curr in it)
                {
                    // prev and curr are equal, thus in same group
                    if (cmp(prev, curr) == 0)
                    {
                        grp.push(curr);
                    }
                    // different group
                    else
                    {
                        groups.push(grp);
                        grp = [curr];
                        prev = curr;
                    }
                }
                
                groups.push(grp);
                return groups;
        }
    }
    
    public static inline function orderByValue<T,U>(it:Iterator<T>, ?fn:T->U, order:Order=Asc):Array<Array<T>>
    {
        return fn == null ?
            orderBy(it, Compare.any(order)):
            orderBy(it, Compare.map(fn, Compare.any(order)));
    }
    
    public static inline function orderByComparable<T,U:Comparable<U>>(it:Iterator<T>, fn:T->U, order:Order=Asc):Array<Array<T>>
    {
        return orderBy(it, Compare.map(fn, Compare.obj(order)));
    }
    
    public static inline function orderByOwnComparable<T:Comparable<T>>(it:Iterator<T>, order:Order=Asc):Array<Array<T>>
    {
        return orderBy(it, Compare.obj(order));
    }
    
    /**
     * Sort each sub-sequence.
     * 
     * Usage:
     * var fruits = "grape passionfruit banana mango orange raspberry apple blueberry";
     * var seq:Seq<String> = fruits.split(" ");
     * 
     * var y = x1
     *     .orderBy(function(a, b) return a.length - b.length)
     *     .thenBy(function(a, b) return a == b ? 0 : a < b ? -1 : 1);
     * 
     * trace(y); // {apple, grape, mango, banana, orange, blueberry, raspberry, passionfruit}
     */
    public static function thenBy<T>(it:Iterator<Iterable<T>>, cmp:T->T->Int):List<Array<T>>
    {
        return flatMap(it, function(grp) return orderBy(grp.iterator(), cmp));
    }
    
    public static inline function thenByValue<T,U>(it:Iterator<Iterable<T>>, ?fn:T->U, order:Order=Asc):List<Array<T>>
    {
        return fn == null ?
            thenBy(it, Compare.any(order)):
            thenBy(it, Compare.map(fn, Compare.any(order)));
    }
    
    public static inline function thenByComparable<T,U:Comparable<U>>(it:Iterator<Iterable<T>>, fn:T->U, order:Order=Asc):List<Array<T>>
    {
        return thenBy(it, Compare.map(fn, Compare.obj(order)));
    }
    
    public static inline function thenByOwnComparable<T:Comparable<T>>(it:Iterator<Iterable<T>>, order:Order=Asc):List<Array<T>>
    {
        return thenBy(it, Compare.obj(order));
    }
    
    /*==================================================
        Aggregate operations
    ==================================================*/
    
    public static function foldLeft<T,U>(it:Iterator<T>, fn:U->T->U, init:U):U
    {
        for (x in it)
            init = fn(init, x);
        return init;
    }
    
    public static inline function foldRight<T,U>(it:Iterator<T>, fn:U->T->U, init:U):U
    {
        return foldLeft(reverse(it).iterator(), fn, init);
    }
    
    public static inline function reduceLeft<T>(it:Iterator<T>, fn:T->T->T):Null<T>
    {
        return it.hasNext() ? foldLeft(it, fn, it.next()) : null;
    }
    
    public static inline function reduceRight<T>(it:Iterator<T>, fn:T->T->T):Null<T>
    {
        return reduceLeft(reverse(it).iterator(), fn);
    }
    
    public static function count<T>(it:Iterator<T>, ?pred:T->Bool):Int
    {
        var n = 0;
        if (pred == null)
            for (_ in it)
                n++;
        else
            for (x in it)
                if (pred(x))
                    n++;
        return n;
    }
    
    public static function sum<T>(it:Iterator<T>, fn:T->Float):Float
    {
        var total:Float = 0.0;
        for (x in it)
            total += fn(x);
        return total;
    }
    
    public static function average<T>(it:Iterator<T>, fn:T->Float):Float
    {
        var total:Float = 0.0;
        var count:Int = 0;
        
        for (x in it)
        {
            total += fn(x);
            ++count;
        }
        
        return total / count;
    }
    
    public static function max<T,U:Float>(it:Iterator<T>, fn:T->U):U
    {
        var best:U = fn(it.next());
        
        for (x in it)
        {
            var curr:U = fn(x);
            if (curr > best)
                best = curr;
        }
        
        return best;
    }
    
    public static function min<T,U:Float>(it:Iterator<T>, fn:T->U):U
    {
        var best:U = fn(it.next());
        
        for (x in it)
        {
            var curr:U = fn(x);
            if (curr < best)
                best = curr;
        }
        
        return best;
    }
    
    /*==================================================
        Set operations
    ==================================================*/
    
    /**
     * Return a sequence of unique elements from both `this` and `other`.
     * 
     * (###(###)###)
     */
    public static function union<T>(ai:Iterator<T>, bi:Iterator<T>, ?cmp:T->T->Int):Array<T>
    {
        if (cmp == null) cmp = Compare.any(Asc);
        
        var a = distinct(ai, cmp);
        var b = distinct(bi, cmp);
        for (x in b) if (!contains(a.iterator(), x, cmp)) a.push(x);
        return a;
    }
    
    /**
     * Return a sequence of unique elements that appear in
     * both `this` and `other`, but not elements that only appear
     * in one of them.
     * 
     * (   (###)   )
     */
    public static function intersect<T>(ai:Iterator<T>, bi:Iterator<T>, ?cmp:T->T->Int):Array<T>
    {
        if (cmp == null) cmp = Compare.any(Asc);
        
        var a = distinct(ai, cmp);
        var b = distinct(bi, cmp);
        var r:Array<T> = [];
        for (x in a) if (contains(b.iterator(), x, cmp)) r.push(x);
        return r;
    }
    
    /**
     * Return a sequence of unique elements that appear only in
     * `this` but take away elements from `other` that appears
     * in `this`.
     * 
     * (###(   )   )
     */
    public static function difference<T>(ai:Iterator<T>, bi:Iterator<T>, ?cmp:T->T->Int):Array<T>
    {
        if (cmp == null) cmp = Compare.any(Asc);
        
        var a = distinct(ai, cmp);
        var b = distinct(bi, cmp);
        var r:Array<T> = [];
        for (x in a) if (!contains(b.iterator(), x, cmp)) r.push(x);
        return r;
    }
    
    /**
     * Return a sequence of unique elements that appear only in
     * either `this` or `other`, but not both of them.
     * 
     * (###(   )###)
     */
    public static function exclude<T>(ai:Iterator<T>, bi:Iterator<T>, ?cmp:T->T->Int):Array<T>
    {
        if (cmp == null) cmp = Compare.any(Asc);
        
        var a = distinct(ai, cmp);
        var b = distinct(bi, cmp);
        var r:Array<T> = [];
        for (x in a) if (!contains(b.iterator(), x, cmp)) r.push(x);
        for (x in b) if (!contains(a.iterator(), x, cmp)) r.push(x);
        return r;
    }
    
    /*==================================================
        Conversions
    ==================================================*/
    
    public static function toArray<T>(it:Iterator<T>):Array<T>
    {
        var x = new Array<T>();
        for (v in it) x.push(v);
        return x;
    }
    
    public static function toList<T>(it:Iterator<T>):List<T>
    {
        var x = new List<T>();
        for (v in it) x.add(v);
        return x;
    }
    
    public static inline function toVector<T>(it:Iterator<T>):Vector<T>
    {
        return Vector.fromArrayCopy(toArray(it));
    }
    
    public static function toMap<T>(it:Iterator<T>):Map<Int, T>
    {
        var x = new Map<Int, T>();
        var i:Int = 0;
        for (v in it) x.set(i++, v);
        return x;
    }
    
    public static inline function toString<T>(it:Iterator<T>):String
    {
        return toList(it).toString();
    }
    
    /*==================================================
        Nested
    ==================================================*/
    
    /**
     * Flatten a 2-layer sequence into a 1-layer sequence.
     */
    public static inline function flatten<T>(self:Iterator<Iterable<T>>):Iterator<T>
    {
        return new IterableIterator(self);
    }
    
    public static function toArrayOfArray<T>(self:Iterator<Iterable<T>>):Array<Array<T>>
    {
        var x = new Array<Array<T>>();
        for (g in self) x.push(toArray(g.iterator()));
        return x;
    }
    
    public static function toArrayOfVector<T>(self:Iterator<Iterable<T>>):Array<Vector<T>>
    {
        var x = new Array<Vector<T>>();
        for (g in self) x.push(toVector(g.iterator()));
        return x;
    }
    
    public static function toListOfList<T>(self:Iterator<Iterable<T>>):List<List<T>>
    {
        var x = new List<List<T>>();
        for (g in self) x.add(toList(g.iterator()));
        return x;
    }
    
    public static inline function toVectorOfVector<T>(self:Iterator<Iterable<T>>):Vector<Vector<T>>
    {
        return Vector.fromArrayCopy(toArrayOfVector(self));
    }
    
    public static function toMapOfMap<T>(self:Iterator<Iterable<T>>):Map<Int, Map<Int, T>>
    {
        var x = new Map<Int, Map<Int, T>>();
        var i:Int = 0;
        for (g in self) x.set(i++, toMap(g.iterator()));
        return x;
    }
}
