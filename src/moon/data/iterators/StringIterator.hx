package moon.data.iterators;

/**
 * Like TextIterator, but without using the Range object.
 * 
 * @author Munir Hussin
 */
class StringIterator
{
    public var s:String;
    public var i:Int;
    public var n:Int;
    
    public inline function new(str:String, start:Int, stop:Int)
    {
        s = str;
        i = start;
        n = stop;
    }
    
    public inline function hasNext():Bool
    {
        return i < n;
    }
    
    public inline function next():String
    {
        return s.charAt(i++);
    }
}