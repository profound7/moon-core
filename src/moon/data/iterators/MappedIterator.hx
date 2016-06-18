package moon.data.iterators;

/**
 * Turn an Iterator<T> into an Iterator<U> using the mapping
 * function `fn:T->U`
 * 
 * @author Munir Hussin
 */
class MappedIterator<T,U>
{
    public var it:Iterator<T>;
    public var fn:T->U;
    
    public inline function new(iterator:Iterator<T>, fn:T->U)
    {
        this.it = iterator;
        this.fn = fn;
    }
    
    public inline function hasNext():Bool
    {
        return it.hasNext();
    }
    
    public inline function next():U
    {
        return fn(it.next());
    }
}
