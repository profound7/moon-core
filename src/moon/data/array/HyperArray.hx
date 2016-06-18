package moon.data.array;

import haxe.ds.Vector;

using moon.tools.VectorTools;

typedef Coords = Array<Int>;
typedef Index = Int;

/**
 * Multi-dimensional array of any dimensions.
 * Theses dimensions can be specified at runtime.
 * 
 * For a slightly faster version, see MultiArray, which
 * is the same as this, except it uses macros to create
 * an abstract of Vector<T>.
 * 
 * Usage:
 *     var ha = new HyperArray<Int>([3, 2, 3], 0);
 *     
 *     for (i in 0...ma.size(0))
 *         for (j in 0...ma.size(1))
 *             for (k in 0...ma.size(2))
 *                 trace('($i,$j,$k) ==> ' + ma.get([i, j, k]));
 * 
 * @author Munir Hussin
 */
class HyperArray<T>
{
    private var sizes:Vector<Int>;                  // size of each dimension
    private var strides:Vector<Int>;                // multiplier to calculate index
    
    public var dimensions(get, never):Int;          // number of dimensions
    public var length(get, never):Int;              // raw length of data vector
    private var data(default, null):Vector<T>;      // 1d data
    
    public function new(dimensions:Array<Int>, ?init:T) 
    {
        sizes = new Vector<Int>(dimensions.length);
        strides = new Vector<Int>(dimensions.length);
        
        strides[0] = 1;
        sizes[0] = dimensions[0];
        var length = dimensions[0];
        
        for (i in 1...dimensions.length)
        {
            strides[i] = strides[i - 1] * dimensions[i - 1];
            sizes[i] = dimensions[i];
            length *= dimensions[i];
        }
        
        data = new Vector<T>(length);
        
        if (init != null)
            for (i in 0...length)
                data[i] = init;
    }
    
    private inline function get_length():Int
    {
        return data.length;
    }
    
    private inline function get_dimensions():Int
    {
        return sizes.length;
    }
    
    /**
     * The length of a particular dimension.
     * The arg `dimension` is 0-indexed.
     */
    public inline function size(dimension:Int):Int
    {
        return sizes[dimension];
    }
    
    /**
     * Given coordinates, return its index to the 1D array.
     * Inverse of coords(index)
     */
    public inline function index(coords:Coords):Index
    {
        // i = c0 + c1*n0 + c2*n0*n1 + c3*n0*n1*n2
        // i = c0*s0 + c1*s1 + c2*s2 + c3*s3
        
        // i    = i0 + i1 + i2
        // i0   = c0 * s0
        // i1   = c1 * s1
        // i2   = c2 * s2
        
        var idx = coords[0];
        for (i in 1...coords.length)
            idx += coords[i] * strides[i];
        return idx;
    }
    
    /**
     * Given an index to the 1D array, return its actual coordinates.
     * Inverse of index(coords)
     */
    public inline function coords(index:Index):Coords
    {
        return [for (i in 0...dimensions) Std.int(index / strides[i]) % size(i)];
    }
    
    public inline function get(coords:Coords):T
    {
        return data[index(coords)];
    }
    
    public inline function set(coords:Coords, value:T):T
    {
        return data[index(coords)] = value;
    }
    
    public inline function getAt(i:Index):T
    {
        return data[i];
    }
    
    public inline function setAt(i:Index, value:T):T
    {
        return data[i] = value;
    }
    
    public inline function swap(a:Coords, b:Coords):Void
    {
        swapAt(index(a), index(b));
    }
    
    public inline function swapAt(i:Index, j:Index):Void
    {
        var t:T = data[i];
        data[i] = data[j];
        data[j] = t;
    }
    
    public inline function fill(value:T):Void
    {
        for (i in 0...length) data[i] = value;
    }
    
    public function fillValues(values:Iterable<T>):Void
    {
        var i = 0;
        for (v in values)
            if (i < length) data[i++] = v;
            else return;
    }
    
    public function fillRegion(coords:Iterator<Coords>, values:Iterable<T>):Void
    {
        for (v in values)
            if (coords.hasNext()) set(coords.next(), v);
            else return;
    }
    
    public inline function fillEach(fn:Index->Coords->T):Void
    {
        for (i in 0...length) data[i] = fn(i, coords(i));
    }
    
    /**
     * Returns a coordinate iterator that iterates through
     * all the coordinates within the lower bound coordinates
     * and the upper bound coordinates.
     * 
     * Usage:
     * 
     *     var ha = new HyperArray<Int>([3, 2, 3], 0);
     *     for (coords in ha.region([0, 0, 0], [ha.size(0), ha.size(1), ha.size(2)]))
     *     {
     *         trace(coords + ' ==> ' + ha.get(coords));
     *     }
     */
    public function region(?lbound:Coords, ?ubound:Coords):Iterator<Coords>
    {
        if (lbound == null) lbound = [for (i in 0...dimensions) 0];
        if (ubound == null) ubound = [for (i in 0...dimensions) size(i)];
        return new HyperCoordsIterator(lbound, ubound);
    }
    
    public inline function iterator():Iterator<T>
    {
        return data.iterator();
    }
    
    /**
     * Slice the hyper-array to get a subset of the hyper-array.
     * The result has the same number of dimensions, but the size
     * of each dimension may be smaller.
     */
    public function slice(lbound:Coords, ubound:Coords):HyperArray<T>
    {
        if (lbound == null) lbound = [for (i in 0...dimensions) 0];
        if (ubound == null) ubound = [for (i in 0...dimensions) size(i)];
        
        var h = new HyperArray<T>([for (i in 0...dimensions) ubound[i] - lbound[i]]);
        var i:Int = 0;
        
        for (c in region(lbound, ubound))
            h.data[i++] = get(c);
        
        return h;
    }
    
    public function map<U>(fn:T->U):HyperArray<U>
    {
        var h = new HyperArray<U>(sizes.toArray());
        for (i in 0...length)
            h.data[i] = fn(data[i]);
        return h;
    }
    
    /**
     * Searches the array for a value and returns its index
     */
    public inline function indexOf(value:T):Index
    {
        return data.indexOf(value);
    }
    
    /**
     * Searches the array for a value and returns its coordinates
     */
    public inline function coordsOf(value:T):Coords
    {
        return coords(indexOf(value));
    }
    
    /**
     * Create a shallow copy of this array
     */
    public function copy():HyperArray<T>
    {
        var h = new HyperArray<T>(sizes.toArray());
        Vector.blit(data, 0, h.data, 0, length);
        return h;
    }
    
    public function toString():String
    {
        return Std.string(data);
    }
}




class HyperCoordsIterator
{
    private var curr:Coords;
    private var coords:Coords;
    private var lbound:Coords;
    private var ubound:Coords;
    
    public function new(lbound:Coords, ubound:Coords)
    {
        this.lbound = lbound;
        this.ubound = ubound;
        this.coords = lbound.copy();
        this.curr = lbound.copy();
    }
    
    public function hasNext():Bool
    {
        // i < n for each dimension
        
        for (i in 0...coords.length)
            if (coords[i] < ubound[i])
                return true;
        
        return false;
    }
    
    public function next():Coords
    {
        // copy current results
        for (i in 0...coords.length)
            curr[i] = coords[i];
        
        // advance to next one
        for (i in 0...coords.length)
        {
            if (++coords[i] < ubound[i])
                return curr;
            else
                coords[i] = lbound[i];      // wrap back to lower bound
        }
        
        // code reaches here means its the last one.
        // since there was a wrap-around, we need to set
        // coords to upper bound to prevent infinite loop.
        
        coords = ubound;
        return curr;
    }
}