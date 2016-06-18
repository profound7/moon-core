package moon.data.array;

#if macro
    import haxe.macro.Context;
    import haxe.macro.Expr;
    import haxe.macro.Type;

    using haxe.macro.TypeTools;
    using haxe.macro.ComplexTypeTools;
    using moon.macros.FieldTools;
    using moon.macros.TypeReplaceTools;
#end

/**
 * NestedArray<Int, 2> ==> NestedArray2<Int> ==> Array<Array<Int>>
 * This generates typedefs to create nested arrays.
 * Nested arrays can be jagged. For even/fixed-sized nested arrays,
 * use HyperArray or MultiArray.
 * 
 * Usage:
 * var n = new NestedArray<Int, 2>();
 * // same as:
 * var n = new Array<Array<Int>>();
 * 
 * @author Munir Hussin
 */
@:genericBuild(moon.data.array.NestedArray.NestedArrayMacro.build())
class NestedArray<Rest> {}


#if macro
class NestedArrayMacro
{
    public static var cache = new Map<Int, Bool>();
    
    public static macro function build():ComplexType
    {
        //trace("-------");
        return switch(Context.getLocalType())
        {
            case TInst(_.get() => { name: "NestedArray" }, params):
                
                if (params.length != 2)
                    throw "Expected type parameter <Type, Depth>";
                    
                var type = params[0];
                var depth:Int = switch(params[1])
                {
                    case TInst(_.get() => { kind: KExpr({ expr: EConst(CInt(i)) }) }, _):
                        Std.parseInt(i);
                        
                    case _:
                        throw "Expected an Int literal";
                }
                
                //trace(type, size);
                buildClass(type, depth);
                
            case t:
                throw 'Incompatible type: $t';
        }
    }
    
    public static function buildClass(type:Type, depth:Int):ComplexType
    {
        var pos = Context.currentPos();
        var className = 'NestedArray$depth';
        var selfPath = { pack: [], name: className };
        var selfPathParam = { pack: [], name: className, params: [TPType(type.toComplexType())] };
        var selfType = TPath(selfPathParam);
        
        if (!cache.exists(depth))
        {
            var baseType = buildNestedArrayType(depth);
            //var fields = Context.getBuildFields();
            //trace(baseType.toString());
            
            // typedef NestedArray3<T> = Array<Array<Array<T>>>
            Context.defineType(
            {
                pack: [],
                name: className,
                pos: pos,
                params: [{ name: 'T' }],
                kind: TDAlias(baseType),
                fields: []
            });
            
            cache[depth] = true;
        }
        
        return selfType;
    }
    
    public static function buildNestedArrayType(depth:Int):ComplexType
    {
        if (depth == 0) return macro:T;
        var param = buildNestedArrayType(depth - 1);
        return macro:Array<$param>;
    }
}
#end