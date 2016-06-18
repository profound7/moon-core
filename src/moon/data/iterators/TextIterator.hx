package moon.data.iterators;

import moon.core.Range;

/**
 * Iterates each char as a string.
 * Used by TextTools.
 * 
 * @author Munir Hussin
 */
class TextIterator
{
    public var s:String;
    public var r:Iterator<Int>;
    
    public inline function new(s:String, r:Range)
    {
        this.s = s;
        this.r = r.iterator();
    }
    
    public inline function hasNext():Bool
    {
        return r.hasNext();
    }
    
    public inline function next():String
    {
        return s.charAt(r.next());
    }
}