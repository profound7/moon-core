package moon.data.iterators;

import moon.core.Pair;

/**
 * Iterates through all the field/value pairs of an object.
 * This is done using Reflect.fields
 * 
 * @author Munir Hussin
 */
class FieldIterator<T:{}>
{
    private var obj:T;
    private var it:Iterator<String>;
    
    public inline function new(obj:T)
    {
        this.obj = obj;
        this.it = Reflect.fields(obj).iterator();
    }
    
    public inline function hasNext():Bool
    {
        return it.hasNext();
    }
    
    public inline function next():Pair<String, Dynamic>
    {
        var k = it.next();
        return Pair.of(k, Reflect.field(obj, k));
    }
}