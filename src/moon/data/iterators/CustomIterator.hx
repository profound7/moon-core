package moon.data.iterators;

/**
 * ...
 * @author Munir Hussin
 */
class CustomIterator<T>
{
    public var hasNext:Void->Bool;
    public var next:Void->T;
    
    public inline function new(hasNext:Void->Bool, next:Void->T)
    {
        this.hasNext = hasNext;
        this.next = next;
    }
}
