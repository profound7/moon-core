package moon.data.iterators;

import moon.core.Seq;

/**
 * An Iterator of Iterables.
 * Also see IteratorIterator for an Iterator of Iterators.
 * 
 * @author Munir Hussin
 */
class IterableIterator<T>
{
    public var outer:Iterator<Iterable<T>>;
    public var inner:Iterator<T>;
    
    public function new(it:Iterator<Iterable<T>>)
    {
        outer = it;
        nextOuter();
    }
    
    public static inline function of<T>(it:Seq<Seq<T>>):IterableIterator<T>
    {
        return new IterableIterator<T>(it.iterator());
    }
    
    private inline function nextOuter():Void
    {
        if (outer.hasNext())
            inner = outer.next().iterator();
    }
    
    public function hasNext():Bool
    {
        // there's more in the current iterator, so its true
        if (inner != null && inner.hasNext())
        {
            return true;
        }
        // no more in current iterator. are there more outer?
        else if (outer.hasNext())
        {
            nextOuter();
            return hasNext();
        }
        // no more outers and no more inners, so that's the end
        else
        {
            return false;
        }
    }
    
    public inline function next():T
    {
        return hasNext() ? inner.next() : null;
    }
}
