package moon.data.iterators;

import haxe.ds.Vector;

/**
 * ...
 * @author Munir Hussin
 */
class VectorIterator<T>
{
    private var v:Vector<T>;
    private var i:Int;
    private var n:Int;
    
    public inline function new(v:Vector<T>, n:Int)
    {
        this.v = v;
        this.i = 0;
        this.n = n;
    }
    
    public inline function hasNext():Bool
    {
        return i < n;
    }
    
    public inline function next():T
    {
        return v[i++];
    }
}