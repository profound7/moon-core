package moon.core;
import moon.core.Range.MappedRange;

/**
 * Iterator for python-esque Range.
 * Note that Range is an Iterable, not an Iterator.
 * Since it's an Iterable, once a range is created,
 * you can use it multiple times.
 * 
 * The output of Range.from(a, b, c) should match
 * python's range(a, b, c) exactly.
 * 
 * Usage:
 *  for (i in Range.from(5, 19, 3))
 *     trace(i);                    // [5, 8, 11, 14, 17]
 * 
 *  for (i in Range.count(4))
 *      trace(i);                   // [0, 1, 2, 3]
 * 
 * @author Munir Hussin
 */
class Range
{
    public var length(default, null):Int;
    
    private var start:Int;
    private var stop:Int;
    private var step:Int;
    
    /*==================================================
        Constructors
    ==================================================*/
    
    public function new(start:Int=0, stop:Int, step:Int=1)
    {
        this.start = start;
        this.stop = stop;
        this.step = step;
        this.length = Math.ceil((stop - start) / step);
    }
    
    /**
     * generate range from [0 ... n-1]
     * count(3) ==> 0, 1, 2
     */ 
    public static inline function count(stop:Int, step:Int=1):Range
    {
        return step < 0 ?
            new Range(stop, 0, step):
            new Range(0, stop, step);
    }
    
    /**
     * generate inclusive range from [0 ... n]
     * zeroTo(3) ==> 0, 1, 2, 3
     */ 
    public static inline function zeroTo(stop:Int, step:Int=1):Range
    {
        return step < 0 ?
            new Range(stop, -1, step):
            new Range(0, stop + 1, step);
    }
    
    /**
     * generate range from [m ... n-1] with step amount
     * from(3, 14, 3) ==> 3, 6, 9, 12
     */ 
    public static inline function from(start:Int, stop:Int, step:Int=1):Range
    {
        return new Range(start, stop, step);
    }
    
    /**
     * generate range that goes in decreasing order. step is negated for you.
     * for (x in Range.downTo(10, 2))
     */ 
    public static inline function downTo(start:Int, stop:Int, step:Int=1):Range
    {
        return new Range(start, stop, -step);
    }
    
    /**
     * negates step if start is bigger than stop
     */
    public static inline function auto(start:Int, stop:Int, step:Int=1):Range
    {
        return start < stop ?
            new Range(start, stop, step):
            new Range(start, stop, -step);
    }
    
    /*==================================================
        Methods
    ==================================================*/
    
    public function iterator():Iterator<Int>
    {
        return step > 0 ?
            new RangeForwardIterator(start, stop, step):
            new RangeBackwardIterator(start, stop, step);
    }
    
    private function index(i:Int):Int
    {
        var idx = i < 0 ? i + length : i;
        if (idx < 0 || idx >= length)
            throw 'Index $i out of bounds';
        return idx;
    }
    
    private inline function pos(i:Int):Int
    {
        return start + step * i;
    }
    
    public inline function get(i:Int):Int
    {
        return pos(index(i));
    }
    
    public function slice(range:Range):Range
    {
        return new Range(pos(range.start), pos(range.stop), range.step * step);
    }
    
    /*==================================================
        Other stuff
    ==================================================*/
    
    public inline function map<U>(fn:Int->U):MappedRange<U>
    {
        // T->U ==> Int->U
        return new MappedRange<U>(this, fn);
    }
    
    /**
     * Creates a copy of `this` Range object.
     */
    public function copy():Range
    {
        return new Range(start, stop, step);
    }
    
    /*==================================================
        Conversions
    ==================================================*/
    
    public function toArray():Array<Int>
    {
        return [for (x in iterator()) x];
    }
}


/**
 * Range's map returns a MappedRange, which works like a range,
 * but its integer index can be mapped to a function returning
 * some other type.
 * 
 * Usage:
 *      var chars = "abcdefghijklmnopqrstuvwxyz";
 *      var r = Range.zeroTo(26, 5)
 *          .map(function(x) return chars.substr(x, 1))
 *          .map(function(x) return x.charCodeAt(0));
 * 
 *      for (c in r)
 *          trace(c); // [97, 102, 107, 112, 117, 122]
 */
class MappedRange<T>
{
    public var length(get, never):Int;
    public var transform:Int->T;
    public var range:Range;
    
    /*==================================================
        Constructors
    ==================================================*/
    
    public function new(range:Range, transform:Int->T)
    {
        this.range = range;
        this.transform = transform;
    }
    
    private inline function get_length():Int
    {
        return range.length;
    }
    
    /*==================================================
        Methods
    ==================================================*/
    
    public function iterator():Iterator<T>
    {
        return new MappedRangeIterator<T>(this);
    }
    
    public inline function get(i:Int):T
    {
        return transform(range.get(i));
    }
    
    public inline function slice(range:Range):MappedRange<T>
    {
        return new MappedRange<T>(this.range.slice(range), transform);
    }
    
    /*==================================================
        Other stuff
    ==================================================*/
    
    public inline function map<U>(fn:T->U):MappedRange<U>
    {
        // T->U ==> Int->U
        return new MappedRange<U>(range, function(i:Int) return fn(transform(i)));
    }
    
    public inline function mapi<U>(fn:Int->T->U):MappedRange<U>
    {
        return new MappedRange<U>(range, function(i:Int) return fn(i, transform(i)));
    }
    
    /**
     * Creates a copy of `this` Range object.
     */
    public function copy():MappedRange<T>
    {
        return new MappedRange<T>(range.copy(), transform);
    }
    
    /*==================================================
        Conversions
    ==================================================*/
    
    public function toArray():Array<T>
    {
        return [for (x in iterator()) x];
    }
}


class RangeForwardIterator
{
    public var i:Int;
    public var stop:Int;
    public var step:Int;
    
    public inline function new(i:Int, stop:Int, step:Int)
    {
        this.i = i;
        this.stop = stop;
        this.step = step;
    }
    
    public inline function hasNext():Bool
    {
        return i < stop;
    }
    
    public inline function next():Int
    {
        var t = i;
        i += step;
        return t;
    }
}

class RangeBackwardIterator
{
    public var i:Int;
    public var stop:Int;
    public var step:Int;
    
    public inline function new(i:Int, stop:Int, step:Int)
    {
        this.i = i;
        this.stop = stop;
        this.step = step;
    }
    
    public inline function hasNext():Bool
    {
        return i > stop;
    }
    
    public inline function next():Int
    {
        var t = i;
        i += step;
        return t;
    }
}

class MappedRangeIterator<T>
{
    public var tx:Int->T;
    public var it:Iterator<Int>;
    
    public inline function new(mrange:MappedRange<T>)
    {
        this.it = mrange.range.iterator();
        this.tx = mrange.transform;
    }
    
    public inline function hasNext():Bool
    {
        return it.hasNext();
    }
    
    public inline function next():T
    {
        return tx(it.next());
    }
}