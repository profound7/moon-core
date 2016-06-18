package moon.core;

import haxe.ds.Vector;
import moon.core.Compare.Order;
import moon.core.Seq.Sequence;
import moon.core.Types.Comparable;
import moon.data.iterators.CustomIterator;
import moon.data.iterators.IterableIterator;
import moon.data.iterators.StringIterator;
import moon.tools.VectorTools;

using moon.tools.IteratorTools;

/**
 * Seq is an abstract Iterable.
 * 
 * You can assign Iterable, Iterator, Vector, String to a Seq,
 * after which you can make use of any of the Lambda methods as well
 * as some methods that work similarly to .NET's Enumerable methods.
 * 
 * If you assign an Iterator to an Seq, a new Iterable is created,
 * so that it'll work properly with the Lambda methods.
 * 
 * It is recommended that you use `using` instead of `import`
 * for this module. When you use `using`, the sequence() method
 * will be available to all Iterables, which you can then use
 * to do your query.
 * 
 * Usage:
 *      using moon.core.Seq;
 *      ...
 *      var it:Seq<Foo> = bar.myCustomIterator();
 *      var it:Seq<Foo> = function() return bar.myCustomIterator();
 *      var it:Seq<Int> = [3, 5, 3, 7];
 *      var it:Seq<String> = "hello";
 *      
 *      for (x in it) trace(x);
 *      ...
 *      var fruits = "grape passionfruit banana mango orange raspberry apple blueberry";
 *      var result = fruits.split(" ").sequence()
 *          .orderBy(Compare.map(function(x) return x.length, CompareFloat.asc))
 *          .thenBy(Compare.string(Asc, CaseInsensitive))
 *          .flatten();
 * 
 * IMPORTANT: Methods returning Seq are deferred! The immediate return
 * value is a function that has the information necessary to perform the
 * action. Those methods will not be executed until the sequence is
 * iterated either by calling iterator() or by using the sequence in a
 * for loop. This is similar to .NET's Enumerable methods. For example:
 * 
 *    var arr:Array<Int> = [1,2,3];
 *    var seq:Seq<Int> = arr;
 *    
 *    // although you modify arr AFTER map has been called, foo changes too!
 *    
 *    var foo = seq.map(function(x) return x * 10);
 *    
 *    arr.push(4);
 *    trace(foo);   // {10,20,30,40}
 *    
 *    arr.push(5);
 *    trace(foo);   // {10,20,30,40,50}
 *    
 *    
 *    // if you don't want foo to change, you should "solidify" it
 *    // by turning it back into a list or array, or call solidify
 *    // to return a new sequence.
 *    var foo = seq.map(function(x) return x * 10).solidify();
 *    
 *    arr.push(4);
 *    trace(foo);   // {10,20,30}
 *    
 *    arr.push(5);
 *    trace(foo);   // {10,20,30}
 *    
 *    Due to this, most operations that returns a Seq are O(1), not O(n)
 *    as the methods does not iterate through the sequence. The O(n) part
 *    does not disappear completely, it's just deferred to iterator().
 * 
 * TODO:
 *  function groupJoin<T,U,K,V>(inner:Seq<U>, okey:T->K, ikey:U->K, res:T->Seq<U>->V):Seq<V>
 *  function join<T,U,K,V>(inner:Seq<U>, okey:T->K, ikey:U->K, res:T->U->V):Seq<V>
 *  function ofType<T,U>(type:Class<U>):Seq<V>
 * 
 * Enumerable.Range: Use moon.core.Range
 * 
 * @author Munir Hussin
 */
 abstract Seq<T>(Iterable<T>) to Iterable<T> from Iterable<T>
{
    // Technically, to Iterable<T> should not be allowed, but it causes compilation
    // errors to some methods below. TODO: figure out the proper way to do this
    
    // Although from Iterable<T> is defined below, it somehow causes errors
    // if I leave it out above.
    
    private var all(get, never):Iterator<T>; // for convenience
    
    public function new(it:Iterable<T>)
    {
        this = it;
    }
    
    private inline function get_all():Iterator<T>
    {
        return iterator();
    }
    
    /**
     * Returns an iterator for this sequence.
     */
    public inline function iterator():Iterator<T>
    {
        return this.iterator();
    }
    
    /*==================================================
        Factory methods
    ==================================================*/
    
    /**
     * Create an empty sequence.
     * 
     * .NET: Enumerable.Empty
     */
    @:noUsing public static inline function empty<T>():Seq<T>
    {
        return [];
    }
    
    /**
     * Create a sequence consisting of a single value.
     */
    @:noUsing public static inline function singleton<T>(value:T):Seq<T>
    {
        return [value];
    }
    
    /**
     * Create a repeating sequence `count` times.
     * 
     * Usage:
     *      Seq.repeat("a", 3); // [a, a, a]
     * 
     * .NET: Enumerable.Repeat
     */
    @:noUsing public static function repeat<T>(v:T, count:Int):Seq<T>
    {
        function make(v:T, count:Int)
        {
            return new CustomIterator<T>(
                function() return count > 0,
                function() { --count; trace(count); return v; });
        }
        
        return new Sequence(function() return make(v, count));
    }
    
    /**
     * Create a sequence from the function `fn`.
     * 
     * Usage:
     *     Seq.loop(function(i) return i, 3); // [0, 1, 2]
     */
    @:noUsing public static function loop<T>(fn:Int->T, count:Int):Seq<T>
    {
        function make(count:Int)
        {
            var i = 0;
            return new CustomIterator<T>(
                function() return i < count,
                function() return fn(i++));
        }
        
        return new Sequence(function() return make(count));
    }
    
    /*==================================================
        Modifications
    ==================================================*/
    
    /**
     * Concatenates this sequence with an array of other sequences.
     * 
     * .NET equivalent: Enumerable.Concat
     */
    public inline function concat(other:Seq<T>):Seq<T>
    {
        return function():Seq<T> return IterableIterator.of([this, other]);
    }
    
    /**
     * Add an element to the beginning of this sequence. O(1)
     */
    public inline function unshift(value:T):Seq<T>
    {
        return function():Seq<T> return IterableIterator.of([[value], this]);
    }
    
    /**
     * Add an element to the end of this sequence. O(1)
     */
    public inline function push(value:T):Seq<T>
    {
        return function():Seq<T> return IterableIterator.of([this, [value]]);
    }
    
    /*==================================================
        Lambda
    ==================================================*/
    
    /**
     * Creates a new sequence by applying function `fn` to
     * each element of this sequence.
     * 
     * .NET: Enumerable.Select
     */
    public inline function map<U>(fn:T->U):Seq<U>
    {
        return function():Seq<U> return all.map(fn);
    }
    
    /**
     * Creates a new sequence by applying function `fn` to
     * each element of this sequence. The index is passed to
     * the function as well.
     * 
     * .NET: Enumerable.Select
     */
    public inline function mapi<U>(fn:Int->T->U):Seq<U>
    {
        return function():Seq<U> return all.mapi(fn);
    }
    
    /**
     * Checks if this sequence contains `item`.
     * This is checked using == operator. This function returns
     * true as soon as a match is found.
     * 
     * .NET: Enumerable.Contains
     */
    public inline function has(item:T):Bool
    {
        return all.has(item);
    }
    
    /**
     * Checks if this sequence contains an element for
     * which `fn` is true. This function returns true as soon
     * as `fn` is true.
     * 
     * .NET equivalent: Enumerable.Any(fn)
     */
    public inline function exists(fn:T->Bool):Bool
    {
        return all.exists(fn);
    }
    
    /**
     * Checks if `fn` is true for all values in this sequence.
     * This function returns false as soon as `fn` is false.
     * 
     * .NET equivalent: Enumerable.All(fn)
     */
    public inline function foreach(fn:T->Bool):Bool
    {
        return all.foreach(fn);
    }
    
    /**
     * Calls `fn` on all elements in this sequence.
     */
    public inline function iter(fn:T->Void):Void
    {
        all.iter(fn);
    }
    
    /**
     * Returns a sub-sequence of this sequence where
     * `fn` is true.
     */
    public inline function filter(fn:T->Bool):Seq<T>
    {
        return function():Seq<T> return all.filter(fn);
    }
    
    /**
     * Checks if this sequence is empty.
     * In haxe's Lambda module, this method is called empty.
     * Renamed to isEmpty as there's another static method called empty
     * which creates an empty sequence.
     * 
     * .NET equivalent: Enumerable.Any()
     */
    public inline function isEmpty():Bool
    {
        return all.isEmpty();
    }
    
    /**
     * Returns the index of the first element `v` within this sequence.
     * This function uses == operator to check for equality.
     * If not found, -1 is returned.
     */
    public inline function indexOf(v:T):Int
    {
        return all.indexOf(v);
    }
    
    /**
     * Returns the first element of this sequence for which `fn` is true.
     * This function returns as soon as an element is found.
     * Returns null if no such element is found.
     */
    public inline function find(fn:T->Bool):Null<T>
    {
        return all.find(fn);
    }
    
    /*==================================================
        New stuff not from Lambda
    ==================================================*/
    
    /**
     * Like map, except that each entry returns a sequence instead of value,
     * and all the sequences are flattened into a single sequence.
     * 
     * .NET: Enumerable.SelectMany
     */
    public inline function flatMap<U>(fn:T->Seq<U>):Seq<U>
    {
        return function():Seq<U> return all.flatMap(fn);
    }
    
    /**
     * Like mapi, except that each entry returns a sequence instead of value,
     * and all the sequences are flattened into a single sequence.
     * 
     * .NET: Enumerable.SelectMany
     */
    public inline function flatMapi<U>(fn:Int->T->Seq<U>):Seq<U>
    {
        return function():Seq<U> return all.flatMapi(fn);
    }
    
    /**
     * Checks if this sequence is equal to another sequence,
     * optionally using a comparison function `cmp`.
     * 
     * By using a comparison function, you can make use of
     * the Compare module.
     * 
     * seq.equals(other, CompareString.asc.equal);
     * 
     * .NET: Enumerable.SequenceEqual
     */
    public inline function equals(other:Seq<T>, ?cmp:T->T->Int):Bool
    {
        return all.equals(other.iterator(), cmp);
    }
    
    
    /**
     * Checks if this sequence contains a value using a
     * comparison function `cmp`.
     * 
     * By using a comparison function, you can make use of
     * the Compare module.
     * 
     * .NET: Enumerable.Contains
     */
    public inline function contains(v:T, ?cmp:T->T->Int):Bool
    {
        return all.contains(v, cmp);
    }
    
    /**
     * Returns unique elements from this sequence.
     * A custom comparison function `cmp` can be provided.
     * 
     * .NET: Enumerable.Distinct
     */
    public inline function distinct(?cmp:T->T->Int):Seq<T>
    {
        return function():Seq<T> return all.distinct(cmp);
    }
    
    /**
     * Skips `count` number of elements, then return the rest of the sequence.
     * 
     * .NET: Enumerable.Skip
     */
    public inline function skip(count:Int):Seq<T>
    {
        return function():Seq<T> return all.skip(count);
    }
    
    /**
     * Skips elements as long as `pred` is true, then returns the remaining elements.
     * 
     * .NET: Enumerable.SkipWhile
     */
    public inline function skipWhile(pred:T->Bool):Seq<T>
    {
        return function():Seq<T> return all.skipWhile(pred);
    }
    
    /**
     * Returns `count` number of elements, then skips the rest of the sequence.
     * 
     * .NET: Enumerable.Take
     */
    public inline function take(count:Int):Seq<T>
    {
        return function():Seq<T> return all.take(count);
    }
    
    /**
     * Returns elements as long as `pred` is true, then skips the remaining elements.
     * 
     * .NET: Enumerable.TakeWhile
     */
    public inline function takeWhile(pred:T->Bool):Seq<T>
    {
        return function():Seq<T> return all.takeWhile(pred);
    }
    
    /**
     * If there's only 1 element in the sequence, then return the element.
     * If the sequence has no elements, the defaultValue is returned.
     * Otherwise throw an exception.
     * 
     * .NET: Enumerable.Single
     */
    public inline function single():T
    {
        return all.single();
    }
    
    /**
     * If there's only 1 element in the sequence, then return the element.
     * Otherwise, the defaultValue is returned.
     * 
     * .NET: Enumerable.SingleOrDefault
     */
    public inline function singleOrDefault(defaultValue:T):T
    {
        return all.singleOrDefault(defaultValue);
    }
    
    /**
     * Returns the first element in the sequence.
     * 
     * .NET: Enumerable.First
     */
    public inline function first():T
    {
        return all.first();
    }
    
    /**
     * Returns the first element in the sequence.
     * 
     * .NET: Enumerable.FirstOrDefault
     */
    public inline function firstOrDefault(defaultValue:T):T
    {
        return all.firstOrDefault(defaultValue);
    }
    
    /**
     * Returns the last element in the sequence.
     * This is an O(n) operation.
     * 
     * .NET: Enumerable.Last
     */
    public inline function last():T
    {
        return all.last();
    }
    
    /**
     * Returns the last element in the sequence.
     * This is an O(n) operation.
     * 
     * .NET: Enumerable.LastOrDefault
     */
    public inline function lastOrDefault(defaultValue:T):T
    {
        return all.lastOrDefault(defaultValue);
    }
    
    /**
     * Returns the `i`th element in the sequence, or throws an error
     * if the index is out of range.
     * This is an O(n) operation.
     * 
     * .NET: Enumerable.ElementAt
     */
    public inline function get(i:Int):Null<T>
    {
        return all.get(i);
    }
    
    /**
     * Returns the `i`th element in the sequence, or defaultValue
     * if sequence is empty or index is out of range.
     * This is an O(n) operation.
     * 
     * .NET: Enumerable.ElementAtOrDefault
     */
    public inline function getOrDefault(i:Int, defaultValue:T):T
    {
        return all.getOrDefault(i, defaultValue);
    }
    
    /**
     * Returns a new Seq with its sequence reversed.
     * This is an O(n) operation.
     * 
     * .NET: Enumerable.Reverse
     */
    public inline function reverse():Seq<T>
    {
        return function():Seq<T> return all.reverse();
    }
    
    /**
     * Joins this sequence into a string seperated by `sep`.
     */
    public inline function join(sep:String):String
    {
        return all.join(sep);
    }
    
    /*==================================================
        Sorting operations
    ==================================================*/
    
    /**
     * Sort this sequence using function `cmp` where `cmp(x,y)` is
     *   0 when x == y,
     *   positive Int when x > y, and
     *   negative Int when x < y
     */
    public inline function sortBy(cmp:T->T->Int):Seq<T>
    {
        return function():Seq<T> return all.sortBy(cmp);
    }
    
    public inline function sortByValue<U>(?fn:T->U, order:Order=Asc):Seq<T>
    {
        return function():Seq<T> return all.sortByValue(fn, order);
    }
    
    public inline function sortByComparable<U:Comparable<U>>(fn:T->U, order:Order=Asc):Seq<T>
    {
        return function():Seq<T> return all.sortByComparable(fn, order);
    }
    
    public static inline function sortByOwnComparable<T:Comparable<T>>(seq:Seq<T>, order:Order=Asc):Seq<T>
    {
        return function():Seq<T> return seq.all.sortByOwnComparable(order);
    }
    
    /**
     * Returns the first element in the sequence.
     * 
     * .NET: Enumerable.GroupBy
     */
    public inline function groupBy<U,V>(fnKey:T->U, fnVal:U->T->V):Seq<Seq<V>>
    {
        return fromSeqSeqFunction(function() return all.groupBy(fnKey, fnVal));
    }
    
    /**
     * Sorts this sequence using the function `cmp` and groups the
     * results into a sequence of sub-sequences.
     * 
     * To further sort within each sub-sequence, use thenBy which
     * is better used as a static extension so you can do method chaining.
     * So instead of `import moon.core.Seq`, do `using moon.core.Seq`.
     * 
     * Usage:
     * 
     * using moon.core.Seq;     // needed for thenBy method chaining
     * ...
     * 
     * var fruits = "grape passionfruit banana mango orange raspberry apple blueberry";
     * var seq:Seq<String> = fruits.split(" ");
     * 
     * var y = seq
     *     .orderBy(Compare.map(function(x) return x.length, CompareFloat.asc))
     *     .thenBy(Compare.string(Asc, CaseInsensitive))
     *     .flatten();
     * 
     * // after orderBy:
     * //     {{grape, mango, apple}, {banana, orange}, {raspberry, blueberry}, passionfruit}
     * 
     * // after thenBy:
     * //     {{apple}, {grape}, {mango}, {banana}, {orange}, {blueberry}, {raspberry}, {passionfruit}}
     * 
     * // after flatten:
     * //     {apple, grape, mango, banana, orange, blueberry, raspberry, passionfruit}
     * 
     * .NET: Enumerable.OrderBy
     */
    public inline function orderBy(cmp:T->T->Int):Seq<Seq<T>>
    {
        return fromSeqSeqFunction(function() return all.orderBy(cmp));
    }
    
    public inline function orderByValue<U>(?fn:T->U, order:Order=Asc):Seq<Seq<T>>
    {
        return fromSeqSeqFunction(function() return all.orderByValue(fn, order));
    }
    
    public inline function orderByComparable<U:Comparable<U>>(fn:T->U, order:Order=Asc):Seq<Seq<T>>
    {
        return fromSeqSeqFunction(function() return all.orderByComparable(fn, order));
    }
    
    public static inline function orderByOwnComparable<T:Comparable<T>>(seq:Seq<T>, order:Order=Asc):Seq<Seq<T>>
    {
        return fromSeqSeqFunction(function() return seq.all.orderByOwnComparable(order));
    }
    
    /**
     * Sort each sub-sequence.
     * 
     * Usage:
     * var fruits = "grape passionfruit banana mango orange raspberry apple blueberry";
     * var result = fruits.split(" ").sequence()
     *     .orderBy(function(a, b) return a.length - b.length)
     *     .thenBy(function(a, b) return a == b ? 0 : a < b ? -1 : 1);
     * 
     * trace(result); // {apple, grape, mango, banana, orange, blueberry, raspberry, passionfruit}
     * 
     * .NET: Enumerable.ThenBy
     */
    public static function thenBy<T>(seq:Seq<Seq<T>>, cmp:T->T->Int):Seq<Seq<T>>
    {
        // flatMap is already delayed, so we don't need to wrap this with another function
        return seq.flatMap(function(grp) return grp.orderBy(cmp));
    }
    
    public static inline function thenByValue<T,U>(seq:Seq<Seq<T>>, ?fn:T->U, order:Order=Asc):Seq<Seq<T>>
    {
        return fn == null ?
            thenBy(seq, Compare.any(order)):
            thenBy(seq, Compare.map(fn, Compare.any(order)));
    }
    
    public static inline function thenByComparable<T,U:Comparable<U>>(seq:Seq<Seq<T>>, fn:T->U, order:Order=Asc):Seq<Seq<T>>
    {
        return thenBy(seq, Compare.map(fn, Compare.obj(order)));
    }
    
    public static inline function thenByOwnComparable<T:Comparable<T>>(seq:Seq<Seq<T>>, order:Order=Asc):Seq<Seq<T>>
    {
        return thenBy(seq, Compare.obj(order));
    }
    
    /*==================================================
        Aggregate operations
    ==================================================*/
    
    /**
     * Functional left fold on this sequence, with start argument `init`.
     * If this sequence is empty, then the result is `init`.
     * 
     * IMPORTANT:
     *      `fn` is function(prev:U, curr:T):U
     *      which is the order used by JavaScript and C#
     *      
     *      This is different than Haxe's Lambda.fold where
     *      `fn` is function(curr:T, prev:U):U
     * 
     * .NET equivalent: Enumerable.Aggregate
     */
    public inline function foldLeft<U>(fn:U->T->U, init:U):U
    {
        return all.foldLeft(fn, init);
    }
    
    /**
     * Functional right fold on this sequence, with start argument `init`.
     * If this sequence is empty, then the result is `init`.
     * This method is not recursive.
     * 
     * `fn` is function(prev:U, curr:T):U
     * 
     * .NET equivalent: Enumerable.Aggregate
     */
    public inline function foldRight<U>(fn:U->T->U, init:U):U
    {
        return all.foldRight(fn, init);
    }
    
    /**
     * Functional left fold on this sequence, with start argument
     * taken as the first element in this sequence.
     * If this sequence is empty, then the result is null.
     * 
     * `fn` is function(prev:T, curr:T):T
     * 
     * .NET equivalent: Enumerable.Aggregate
     */
    public inline function reduceLeft(fn:T->T->T):Null<T>
    {
        return all.reduceLeft(fn);
    }
    
    /**
     * Functional right fold on this sequence, with start argument
     * taken as the last element in this sequence.
     * If this sequence is empty, then the result is null.
     * 
     * `fn` is function(prev:T, curr:T):T
     * 
     * .NET equivalent: Enumerable.Aggregate
     */
    public inline function reduceRight(fn:T->T->T):Null<T>
    {
        return all.reduceRight(fn);
    }
    
    /**
     * Returns the number of elements in this sequence
     * for which `pred` is true. If `pred` is null,
     * the total number of elements in this sequence is
     * returned.
     * 
     * .NET: Enumerable.Count
     */
    public inline function count(?pred:T->Bool):Int
    {
        return all.count(pred);
    }
    
    /**
     * Returns the sum of values in the sequence.
     * 
     * .NET: Enumerable.Sum
     */
    public inline function sum(fn:T->Float):Float
    {
        return all.sum(fn);
    }
    
    /**
     * Returns the average of values in the sequence.
     * 
     * .NET: Enumerable.Average
     */
    public inline function average(fn:T->Float):Float
    {
        return all.average(fn);
    }
    
    /**
     * Returns the max value in the sequence.
     * max using cmp:T->T->Int?
     * .NET: Enumerable.Max
     */
    public inline function max<U:Float>(fn:T->U):U
    {
        return all.max(fn);
    }
    
    /**
     * Returns the min value in the sequence.
     * 
     * .NET: Enumerable.Min
     */
    public inline function min<U:Float>(fn:T->U):U
    {
        return all.min(fn);
    }
    
    /*==================================================
        Set operations
    ==================================================*/
    
    /**
     * Return a sequence of unique elements from both `this` and `other`.
     * 
     * (###(###)###)
     */
    public inline function union(other:Seq<T>, ?cmp:T->T->Int):Seq<T>
    {
        return function():Seq<T> return all.union(other.iterator(), cmp);
    }
    
    /**
     * Return a sequence of unique elements that appear in
     * both `this` and `other`, but not elements that only appear
     * in one of them.
     * 
     * (   (###)   )
     * .NET: Enumerable.Intersect
     */
    public inline function intersect(other:Seq<T>, ?cmp:T->T->Int):Seq<T>
    {
        return function():Seq<T> return all.intersect(other.iterator(), cmp);
    }
    
    /**
     * Return a sequence of unique elements that appear only in
     * `this` but take away elements from `other` that appears
     * in `this`.
     * 
     * (###(   )   )
     * .NET: Enumerable.Except
     */
    public inline function difference(other:Seq<T>, ?cmp:T->T->Int):Seq<T>
    {
        return function():Seq<T> return all.difference(other.iterator(), cmp);
    }
    
    /**
     * Return a sequence of unique elements that appear only in
     * either `this` or `other`, but not both of them.
     * 
     * (###(   )###)
     */
    public inline function exclude(other:Seq<T>, ?cmp:T->T->Int):Seq<T>
    {
        return function():Seq<T> return all.exclude(other.iterator(), cmp);
    }
    
    /*==================================================
        Conversions
    ==================================================*/
    
    /**
     * Solidifies this sequence. All deferred methods are executed
     * and a new sequence is created that won't be affected by previous
     * deferred method calls.
     * 
     * If this is a sequence of sequences, it'll only solidify the outer
     * sequence. Call flatten first, and then solidify.
     */
    public inline function solidify():Seq<T>
    {
        return toList();
    }
    
    /**
     * Flatten a 2-layer sequence into a 1-layer sequence.
     * 
     * IMPORTANT: flatten does not solidify a sequence.
     * 
     * This operation is O(1) as it does not iterate any sequence to create
     * a new list, but instead creates an Iterable with an Iterator that can
     * iterate through 2-layer sequences (IterableIterator).
     */
    public static inline function flatten<T>(seq:Seq<Seq<T>>):Seq<T>
    {
        return seq.iterator().flatten();
    }
    
    @:from @:noUsing public static function fromFunction<T>(fn:Void->Iterator<T>):Seq<T>
    {
        return new Sequence<T>(fn);
    }
    
    @:from @:noUsing public static function fromSeqFunction<T>(fn:Void->Seq<T>):Seq<T>
    {
        return new Sequence<T>(function() return fn().iterator());
    }
    
    @:noUsing public static function fromSeqSeqFunction<T>(fn:Void->Seq<Seq<T>>):Seq<Seq<T>>
    {
        return new Sequence<Seq<T>>(function() return fn().iterator());
    }
    
    @:from @:noUsing public static function fromVector<T>(v:Vector<T>):Seq<T>
    {
        return new Sequence<T>(function() return VectorTools.iterator(v));
    }
    
    @:from @:noUsing public static function fromIterable<T>(it:Iterable<T>):Seq<T>
    {
        return new Seq<T>(it);
    }
    
    @:from @:noUsing public static function fromIterator<T>(it:Iterator<T>):Seq<T>
    {
        // it's better to turn the iterator into an iterable,
        // so that calling multiple methods from the same seq
        // works properly (otherwise it'll exhaust the iterator).
        return fromIterable(it.toList());
    }
    
    @:from @:noUsing public static function fromString(s:String):Seq<String>
    {
        return new Sequence<String>(function() return new StringIterator(s, 0, s.length));
    }
    
    @:to public inline function toArray():Array<T>
    {
        return all.toArray();
    }
    
    @:to public inline function toList():List<T>
    {
        return all.toList();
    }
    
    @:to public inline function toVector():Vector<T>
    {
        return all.toVector();
    }
    
    @:to public inline function toMap():Map<Int,T>
    {
        return all.toMap();
    }
    
    @:to public inline function toString():String
    {
        return Std.string(this);
    }
    
    /*==================================================
        Static Extensions
    ==================================================*/
    
    
    
    /**
     * Static extension that applies to Iterables and other compatible types.
     * By calling the sequence method, you can easily access all the
     * sequence methods.
     * 
     * Usage:
     *      using moon.core.Seq;
     *      ...
     *      var result = [1,2,3].sequence().orderBy(fnA).thenBy(fnB).flatten().reduce(fnC);
     *      var result = "hello".sequence().map(fnA).flatMap(fnB).filter(fnC);
     */
    public static inline function sequence<T>(seq:Seq<T>):Seq<T>
    {
        return seq;
    }
    
    public static inline function toArrayOfArray<T>(seq:Seq<Seq<T>>):Array<Array<T>>
    {
        return seq.iterator().toArrayOfArray();
    }
    
    public static inline function toArrayOfVector<T>(seq:Seq<Seq<T>>):Array<Vector<T>>
    {
        return seq.iterator().toArrayOfVector();
    }
    
    public static inline function toListOfList<T>(seq:Seq<Seq<T>>):List<List<T>>
    {
        return seq.iterator().toListOfList();
    }
    
    public static inline function toVectorOfVector<T>(seq:Seq<Seq<T>>):Vector<Vector<T>>
    {
        return seq.iterator().toVectorOfVector();
    }
    
    public static inline function toMapOfMap<T>(seq:Seq<Seq<T>>):Map<Int, Map<Int, T>>
    {
        return seq.iterator().toMapOfMap();
    }
}


/**
 * Used to hold arbitrary Iterables from functions.
 * @author Munir Hussin
 */
class Sequence<T>
{
    public var iterator:Void->Iterator<T>;
    
    public function new(it:Void->Iterator<T>)
    {
        iterator = it;
    }
    
    public inline function toString():String
    {
        return iterator().toString();
    }
}