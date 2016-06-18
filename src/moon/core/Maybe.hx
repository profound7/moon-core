package moon.core;

typedef Option<T> = haxe.ds.Option<T>;

/**
 * Usage:
 *      var a:Maybe<String> = Some("hello"); // or None
 *      var b = a.map(function(x) return x + " there")
 *          .map(function(x) return x + " yoo")
 *          .map(function(x) return x + " hi")
 *          .apply(Some(function(x) return x + " zzz"));
 *          
 *      trace(b.value); 
 * 
 * @author Munir Hussin
 */
abstract Maybe<T>(Option<T>) to Option<T> from Option<T>
{
    public var value(get, set):Null<T>;
    public var isSome(get, never):Bool;
    public var isNone(get, never):Bool;
    
    public function new(?x:T)
    {
        this = x == null ? None : Some(x);
    }
    
    @:from public static function fromValue<T>(value:Null<T>):Maybe<T>
    {
        return new Maybe<T>(value);
    }
    
    private inline function get_value():Null<T>
    {
        return switch (this)
        {
            case None: null;
            case Some(x): x;
        }
    }
    
    private inline function set_value(x:T):Null<T>
    {
        this = x == null ? None : Some(x);
        return x;
    }
    
    private inline function get_isSome():Bool
    {
        return this != None;
    }
    
    private inline function get_isNone():Bool
    {
        return this == None;
    }
    
    public inline function flatMap<U>(fn:T->Maybe<U>):Maybe<U>
    {
        return switch (this)
        {
            case None: None;
            case Some(x): fn(x);
        }
    }
    
    public inline function map<U>(fn:T->U):Maybe<U>
    {
        return switch (this)
        {
            case None: None;
            case Some(x): new Maybe<U>(fn(x));
        }
    }
    
    public inline function apply<U>(m:Maybe<T->U>):Maybe<U>
    {
        return switch (m)
        {
            case None: None;
            case Some(x): map(x);
        }
    }
    
    public inline function filter(fn:T->Bool):Maybe<T>
    {
        return switch (this)
        {
            case None: None;
            case Some(x): fn(x) ? Some(x) : None;
        }
    }
    
    public inline function or(m:Maybe<T>):Maybe<T>
    {
        return this == None ? m : this;
    }
    
    public static inline function join<T>(m:Maybe<Maybe<T>>):Maybe<T>
    {
        return switch (m)
        {
            case None: None;
            case Some(x): x;
        }
    }
}