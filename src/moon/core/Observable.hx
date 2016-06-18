package moon.core;

import moon.core.Signal;

/**
 * An observable value.
 * 
 * When the value is changed, all listeners will get a
 * signal called with the new value passed in.
 * 
 * @author Munir Hussin
 */
class Observable<T>
{
    public var changed(default, null):Signal<T>;
    public var value(default, set):T;
    
    public function new(?value:T) 
    {
        changed = new Signal<T>();
        this.value = value;
    }
    
    private function set_value(value:T):T
    {
        this.value = value;
        changed.dispatch(value);
        return value;
    }
    
    public inline function map<U>(fn:T->U):Observable<U>
    {
        return new Observable<U>(fn(value));
    }
    
    public inline function dispatch():Void
    {
        return changed.dispatch(value);
    }
    
    public inline function toString():String
    {
        //return Std.string(value);
        return '<$value>';
    }
}
