package moon.core;

/**
 * A tuple is fixed-length, and every entry is typed.
 * Tuple is a TupleData abstract, which is an Array<Dynamic> abstract.
 * 
 * Usage:
 * var a = new Tuple<Int, String, Float>(5, "foo", 1.23);
 * trace(a.v0);
 * trace(a.v1);
 * trace(a.v2);
 * 
 * Shorter way of creating a tuple:
 * var a = Tuple.of(5, "foo", 1.23);
 * 
 * Compile-time type checking:
 * a.v1 = 1;    // Error, expected String, Int given.
 * 
 * Note: Should this be a Vector<Dynamic> abstract instead?
 * 
 * @author Munir Hussin
 */
#if !macro
@:genericBuild(moon.macros.tuple.TupleMacro.build())
class Tuple<Rest>
{
    //@:noCompletion
    private var data(default, null):Array<Dynamic>;
    public var length(get, never):Int;
    
    
    private inline function get_length():Int
    {
        return data.length;
    }
    
    public inline function iterator():Iterator<Dynamic>
    {
        return data.iterator();
    }
    
    /**
     * Returns an array representation of this tuple.
     * Internally, a tuple is an Array<Dynamic>. Calling
     * this method will return a copy of that array.
     */
    public inline function toArray():Array<Dynamic>
    {
        return data.copy();
    }
    
    public inline function toString():String
    {
        return "(" + data.join(", ") + ")";
    }
    
    /**
     * Macro to create a typed tuple of any arity.
     * 
     * var a = Tuple.of(1, "hello");
     * is equivalent to
     * var a = new Tuple<Int, String>(1, "hello");
     * 
     * This works in 3.2 but no longer works in 3.3.
     * In 3.3, Tuple.of(1, "hello"), Tuple is resolved to Tuple0,
     * and the compiler gives the error: Type not found: moon.core.Tuple0
     */
    public static macro function of(args:Array<haxe.macro.Expr>):haxe.macro.Expr
    {
        var typeParams:Array<haxe.macro.Expr.TypeParam> = [];
        
        for (r in args)
        {
            var ct = haxe.macro.TypeTools.toComplexType(haxe.macro.Context.typeof(r));
            typeParams.push(haxe.macro.Expr.TypeParam.TPType(ct));
        }
        
        return
        {
            expr: ENew({ pack: ["moon", "core"], name: "Tuple", params: typeParams }, args),
            pos: haxe.macro.Context.currentPos()
        };
    }
}
#end