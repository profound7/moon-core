package moon.tools;

import moon.core.Struct;
import moon.core.Pair;
import moon.data.set.Histogram;

/**
 * using moon.tools.ArrayTools
 * 
 * @author Munir Hussin
 */
class ArrayTools
{
    /**
     * Create an array of a certain length, with an initial value.
     * var a:Array<String> = Array.alloc(3, "foo");
     */
    public static inline function alloc<T>(cl:Class<Array<T>>, length:Int, val:T):Array<T>
    {
        return [for (_ in 0...length) val];
    }
    
    /**
     * Resizes `this` array and ensures that the array is at least of a specified length.
     * arr.capacity(5);
     */
    public static inline function capacity<T>(a:Array<T>, length:Int, val:T):Void
    {
        // METHOD 1: not sure if this works on all targets
        /*if (a.length < length)
            a[length - 1] = null;*/
            
        // METHOD 2
        while (a.length < length) a.push(val);
    }
    
    /**
     * Checks if an array contains a value
     */
    public static inline function contains<T>(a:Array<T>, v:T):Bool
    {
        return a.indexOf(v) != -1;
    }
    
    /**
     * Checks if 2 array instances contains the same values
     */ 
    public static function equals<T>(a:Array<T>, b:Array<T>):Bool
    {
        if (a.length != b.length) return false;
        for (i in 0...a.length) if (a[i] != b[i]) return false;
        return true;
    }
    
    /**
     * Adds all values of v into this array
     * 
     * Like concat, but instead of returning a new array, pushArray
     * modifies the `this` array.
     */
    public static inline function pushMany<T>(a:Array<T>, it:Iterable<T>):Void
    {
        for (x in it) a.push(x);
    }
    
    /**
     * Adds all values of v into this array from the front
     */
    public static inline function unshiftMany<T>(a:Array<T>, it:Iterable<T>):Void
    {
        for (x in it) a.unshift(x);
    }
    
    /**
     * Clears all values of `this` array. This modifies the array in place.
     * Instead of setting arr = [] which loses reference, splicing will
     * retain the object reference.
     */
    public static inline function clear<T>(a:Array<T>):Void
    {
        a.splice(0, a.length);
    }
    
    /**
     * Removes all occurances of value in this array
     */
    public static inline function removeAll<T>(a:Array<T>, value:T):Void
    {
        while (a.remove(value)){};
    }
    
    /**
     * Copies a chunk within an array from src to dest
     * 
     * Example: Copy a[4] to b[7], a[5] to b[8]
     * a.copyTo(b, 4, 2, 7);
     */
    public static inline function copyTo<T>(src:Array<T>, dest:Array<T>, srcStart:Int, srcLen:Int, destStart:Int):Void
    {
        for (i in 0...srcLen) dest[destStart + i] = src[srcStart + i];
    }
    
    /**
     * Copies everything from src to dest
     */
    public static inline function copyAllTo<T>(src:Array<T>, dest:Array<T>, destStart:Int=0):Void
    {
        copyTo(src, dest, 0, src.length, destStart);
    }
    
    /**
     * Similar to python's zip()
     * a = [1, 2, 3, 4]
     * b = ["a", "b", "c", "d", "e"]
     * a.zip(b); // [1:"a", 2:"b", 3:"c", 4:"d"]
     */ 
    public static function zip<U, V>(a:Array<U>, b:Array<V>):Array<Pair<U, V>>
    {
        var r:Array<Pair<U, V>> = [];
        var length:Int = Math.floor(Math.min(a.length, b.length));
        for (i in 0...length)
            r.push(Pair.of(a[i], b[i]));
        return r;
    }
    
    /**
     * Reverse of zip()
     * p = [1:"a", 2:"b", 3:"c", 4:"d"]     where x:y is Pair.of(x, y)
     * p.unzip(); // [1, 2, 3, 4]:["a", "b", "c", "d"]
     */ 
    public static function unzip<U, V>(pairs:Array<Pair<U, V>>):Pair<Array<U>, Array<V>>
    {
        var a:Array<U> = [];
        var b:Array<V> = [];
        
        for (p in pairs)
        {
            a.push(p.head);
            b.push(p.tail);
        }
            
        return Pair.of(a, b);
    }
    
    /**
     * Creates an anonymous object based on given keys and values.
     * This is like zip, but instead of creating an Array of Pairs, it creates
     * an anonymous object (in moon lib, Struct is an abstract of {}).
     * 
     * Unlike zip which can have duplicate keys, zipObject will use
     * the latest value should there be duplicate keys.
     */
    public static function zipObject<T>(keys:Array<String>, vals:Array<T>):Struct
    {
        var r:Struct = new Struct();
        var length:Int = Math.floor(Math.min(keys.length, vals.length));
        for (i in 0...length)
            r[keys[i]] = vals[i];
        return r;
    }
    
    /**
     * Reverse of zipObject()
     * p = {"a":1, "b":2, "c":3, "d":4}
     * p.unzip(); // ["a", "b", "c", "d"]:[1, 2, 3, 4]
     */ 
    public static function unzipObject(obj:Struct):Pair<Array<String>, Array<Dynamic>>
    {
        var keys:Array<String> = obj.fields();
        var vals:Array<Dynamic> = [for (k in keys) obj[k]];
        return Pair.of(keys, vals);
    }
    
    
    /*==================================================
        Set operations
    ==================================================*/
    
    /**
     * Returns a new array containing all elements from `a`
     * as well as elements from `b`.
     * 
     * Venn: (###(###)###)
     */
    public static function union<T>(a:Array<T>, b:Array<T>):Array<T>
    {
        // [a,a,a,b,b,b,c,c,c,d] | [b,b,c,c,d,d,d] => [a,a,a,b,b,b,c,c,c,d,  ,d]
        return Histogram.of(a).mergeAdd(b).mergeSub(intersect(a, b)).toArray();
    }
    
    /**
     * Returns a new array containing common elements that
     * appears in both sets.
     * 
     * Venn: (   (###)   )
     */
    public static function intersect<T>(a:Array<T>, b:Array<T>):Array<T>
    {
        // [a,a,a,b,b,b,c,c,c,d] & [b,b,c,c,d,d,d] => [b,b,c,c,d]
        var ha:Histogram<T> = a;
        var hb:Histogram<T> = b;
        var hi = ha & hb;
        var arr = [];
        
        for (x in hi.pairs())
        {
            for (i in 0...Std.int(Math.min(ha.get(x.head), hb.get(x.head))))
                arr.push(x.head);
        }
        
        return arr;
    }
    
    /**
     * Returns a new array containing elements that appears in
     * `a` that does not appear in `b`.
     * 
     * Venn: (###(   )   )
     */
    public static function difference<T>(a:Array<T>, b:Array<T>):Array<T>
    {
        return Histogram.of(a).mergeSub(b).toArray();
    }
    
    /**
     * Returns a new array containing elements that appears in
     * either `a` or `b`, but not both.
     * 
     * Venn: (###(   )###)
     */
    public static function exclude<T>(a:Array<T>, b:Array<T>):Array<T>
    {
        return Histogram.of(difference(a, b)).mergeAdd(difference(b, a)).toArray();
    }
    
    
    /*==================================================
        Random operations
    ==================================================*/
    
    /**
     * pick a random element from an array
     * @return returns a random 32-bit Int
     */
    public static inline function choice<T>(a:Array<T>):T
    {
        return a[Std.random(a.length)];
    }
    
    /**
     * Unbiased in-place shuffle algo, Fisher-Yates (Knuth) Shuffle
     * @param a         the input array to shuffle
     */
    public static function shuffle<T>(a:Array<T>):Void
    {
        var i:Int = a.length;
        var j:Int;
        var tmp:T;
        
        while (i >= 1)
        {
            j = Std.random(i--);
            
            tmp = a[i];
            a[i] = a[j];
            a[j] = tmp;
        }
    }
    
    
    /**
     * Returns a new array containing elements from the population
     * while leaving the original population unchanged.
     * 
     * A random element in the population will never be picked
     * more than once.
     * 
     * If k is greater than population size, an exception
     * is thrown.
     * 
     * If you wish to allow repetition, use pick();
     * 
     * @param population    a complete set of possible values
     * @param k             number of unique samples to pick from the population
     */
    public static function sample<T>(population:Array<T>, k:Int):Array<T>
    {
        var n:Int = population.length;
        var a:Array<Int> = [for (i in 0...n) i];
        var result:Array<T> = [];
        
        var x:Int;
        var tmp:Int;
        
        if (k > n)
            throw "sample k has invalid value";
        
        // should loop at most k times
        while (k-->0)
        {
            // pick a random item and add to result
            x = Std.random(n);
            result.push(population[a[x]]);
            
            // a[n] now points to the last item
            n--;
            
            // swap the random item with the last item
            tmp = a[x];
            a[x] = a[n];
            a[n] = tmp;
        }
        
        return result;
    }
    
    /**
     * Returns a new array containing elements from the population.
     * It is possible for a random element in the population to be
     * picked more than once.
     * 
     * Since repetition is allowed, k can be greater than the
     * population size.
     * 
     * If you don't wish to allow repetition, use sample();
     * 
     * @param population    a complete set of possible values
     * @param k             number of samples to pick from the population
     */
    public static function pick<T>(population:Array<T>, k:Int):Array<T>
    {
        return [for (_ in 0...k) choice(population)];
    }
}
