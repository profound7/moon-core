package moon.core;

/**
 * Symbols are like strings, but are interned. So two same-named
 * symbols are the same objects in memory (reference equality).
 * 
 * @author Munir Hussin
 */
class Symbol
{
    private static var symbols:Map<String, Symbol>;
    
    public var name(default, null):String;
    
    private static function __init__():Void
    {
        symbols = new Map<String, Symbol>();
    }
    
    /**
     * Retrieve a symbol identified by `name`.
     */
    public static function of(name:Dynamic):Symbol
    {
        // if it's already a Symbol, return it
        if (Std.is(name, Symbol))
            return name;
            
        // see if the Symbol exist
        var key:String = Std.string(name);
        var sym = symbols.get(key);
        
        if (sym == null)
        {
            sym = new Symbol(key);
            symbols.set(key, sym);
        }
        
        return sym;
    }
    
    /**
     * TODO: this should be removed. doesn't belong here.
     * 
     * Convenience method to create an S-Expr of a symbol.
     * Symbol.call("foo", ["bar", 123]) ==> [Symbol.of("foo"), "bar", 123]
     */
    public static inline function call(name:String, args:Array<Dynamic>):Array<Dynamic>
    {
        var ret:Array<Dynamic> = [];
        ret.push(Symbol.of(name));
        return ret.concat(args);
    }
    
    public static inline function iterator():Iterator<String>
    {
        return symbols.keys();
    }
    
    public static inline function list():Array<String>
    {
        return [for (k in symbols.keys()) k];
    }
    
    private function new(name:String)
    {
        this.name = name;
    }
    
    public function toString():String
    {
        return "" + name;
    }
}
