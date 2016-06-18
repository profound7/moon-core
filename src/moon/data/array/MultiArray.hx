package moon.data.array;

import haxe.ds.Vector;

#if macro
    import haxe.macro.Context;
    import haxe.macro.Expr;
    import haxe.macro.Type;

    using haxe.macro.TypeTools;
    using haxe.macro.ComplexTypeTools;
    using moon.macros.FieldTools;
    using moon.macros.TypeReplaceTools;
#end

private typedef Coords = Array<Int>;
private typedef Index = Int;
private typedef T = Dynamic;
private typedef SelfType<T> = Dynamic;

#if !macro
/**
 * This is similar to HyperArray, except that MultiArray is
 * enhanced by macro, inlining all the calculations, making it
 * faster than HyperArray.
 * 
 * While HyperArray allows you to specify dimensions at run-time,
 * MultiArray is a genericBuild that generates an abstract over
 * Vector<T>. The calculations that can be done at compile-time
 * are inlined, eliminating away some loops needed to convert
 * between indexes and coordinates.
 * 
 * Although called an Array, it's more like haxe's Vector since
 * the length is fixed.
 * 
 * Usage:
 *    var m = new MultiArray<String, 3,2>();
 *      // becomes MultiArray3x2<String>
 *      // a 2D String Array, all values null
 * 
 *    var m = new MultiArray<Int, 3,2,4>(7);
 *      // becomes MultiArray3x2x4<Int>
 *      // 3D Int Array, all values initialized to 7
 * 
 * This can be used as the basis of some other types:
 *    typedef Matrix3x3 = MultiArray<Float,3,3>
 * 
 * @author Munir Hussin
 */
@:genericBuild(moon.data.array.MultiArray.MultiArrayMacro.build())
class MultiArray<Rest>
{
    public var dimensions(get, never):Int;          // number of dimensions
    public var length(get, never):Int;              // raw length of data vector
    public var data(get, never):Vector<T>;          // 1d data
    
    private inline function get_data():Vector<T>
    {
        throw "Replaced by macro";
    }
    
    private inline function get_length():Int
    {
        throw "Replaced by macro";
    }
    
    private inline function get_dimensions():Int
    {
        throw "Replaced by macro";
    }
    
    /**
     * The length of a particular dimension.
     * The arg `dimension` is 0-indexed.
     */
    public inline function size(dimension:Int):Int
    {
        throw "Replaced by macro";
    }
    
    /**
     * Given coordinates, return its index to the 1D array.
     * Inverse of coords(index)
     */
    public inline function index(coords:Coords):Index
    {
        throw "Replaced by macro";
    }
    
    /**
     * Given an index to the 1D array, return its actual coordinates.
     * Inverse of index(coords)
     */
    public inline function coords(index:Index):Coords
    {
        throw "Replaced by macro";
    }
    
    public inline function get(coords:Coords):T
    {
        return data[index(coords)];
    }
    
    public inline function set(coords:Coords, value:T):T
    {
        return data[index(coords)] = value;
    }
    
    public inline function getAt(i:Index):T
    {
        return data[i];
    }
    
    public inline function setAt(i:Index, value:T):T
    {
        return data[i] = value;
    }
    
    public inline function swap(a:Coords, b:Coords):Void
    {
        swapAt(index(a), index(b));
    }
    
    public inline function swapAt(i:Index, j:Index):Void
    {
        var t:T = data[i];
        data[i] = data[j];
        data[j] = t;
    }
    
    public inline function fill(value:T):Void
    {
        for (i in 0...length) data[i] = value;
    }
    
    public function fillValues(values:Iterable<T>):Void
    {
        var i = 0;
        for (v in values)
            if (i < length) data[i++] = v;
            else return;
    }
    
    public function fillRegion(coords:Iterator<Coords>, values:Iterable<T>):Void
    {
        for (v in values)
            if (coords.hasNext()) set(coords.next(), v);
            else return;
    }
    
    public inline function fillEach(fn:Index->Coords->T):Void
    {
        for (i in 0...length) data[i] = fn(i, coords(i));
    }
    
    /**
     * Returns a coordinate iterator that iterates through
     * all the coordinates within the lower bound coordinates
     * and the upper bound coordinates.
     * 
     * Usage:
     * 
     *     var ha = new HyperArray<Int>([3, 2, 3], 0);
     *     for (coords in ha.region([0, 0, 0], [ha.size(0), ha.size(1), ha.size(2)]))
     *     {
     *         trace(coords + ' ==> ' + ha.get(coords));
     *     }
     */
    public function region(?lbound:Coords, ?ubound:Coords):Iterator<Coords>
    {
        if (lbound == null) lbound = [for (i in 0...dimensions) 0];
        if (ubound == null) ubound = [for (i in 0...dimensions) size(i)];
        return new moon.data.array.HyperArray.HyperCoordsIterator(lbound, ubound);
    }
    
    public inline function iterator():Iterator<T>
    {
        return moon.tools.VectorTools.iterator(data);
    }
    
    /**
     * Slice the hyper-array to get a subset of the hyper-array.
     * The result has the same number of dimensions, but the size
     * of each dimension may be smaller.
     */
    public function slice(lbound:Coords, ubound:Coords):HyperArray<T>
    {
        if (lbound == null) lbound = [for (i in 0...dimensions) 0];
        if (ubound == null) ubound = [for (i in 0...dimensions) size(i)];
        
        var h = new moon.data.array.HyperArray<T>([for (i in 0...dimensions) ubound[i] - lbound[i]]);
        var i:Int = 0;
        
        for (c in region(lbound, ubound))
            h.setAt(i++, get(c));
        
        return h;
    }
    
    public function map<U>(fn:T->U):SelfType<U>
    {
        throw "Replaced by macro";
    }
    
    /**
     * Searches the array for a value and returns its index
     */
    public inline function indexOf(value:T):Int
    {
        return moon.tools.VectorTools.indexOf(data, value);
    }
    
    /**
     * Searches the array for a value and returns its coordinates
     */
    public inline function coordsOf(value:T):Array<Int>
    {
        return coords(indexOf(value));
    }
    
    /**
     * Create a shallow copy of this array
     */
    public function copy():SelfType<T>
    {
        throw "Replaced by macro";
    }
    
    public function toString():String
    {
        return Std.string(data);
    }
}
#end

#if macro
class MultiArrayMacro
{
    public static var cache = new Map<String, Bool>();
    
    public static macro function build():Type
    {
        //trace("-------");
        return switch(Context.getLocalType())
        {
            case TInst(_.get() => { name: "MultiArray" }, params):
                
                if (params.length == 0)
                    throw "Expected type parameter <Type, Size0, Size1, ...SizeN>";
                    
                var type = params.shift();
                var size:Array<Int> = [];
                
                for (p in params) switch (p)
                {
                    case TInst(_.get() => { kind: KExpr({ expr: EConst(CInt(i)) }) }, _):
                        size.push(Std.parseInt(i));
                        
                    case _:
                        throw "Expected an Int literal";
                }
                
                //trace(type, size);
                buildClass(type, size).toType();
                
            case t:
                throw 'Incompatible type: $t';
        }
    }
    
    public static function buildClass(type:Type, dimensions:Array<Int>):ComplexType
    {
        var pos = Context.currentPos();
        var dim:Int = dimensions.length;
        var className = 'MultiArray' + dimensions.join("x");
        
        var localClass = Context.getLocalClass().get();
        var pack = localClass.pack;                         // [moon, lab, next]
        var module = pack.concat([localClass.name]);        // [moon, lab, next, Tuple]
        
        var selfPath = { pack: pack, name: className };
        var selfPathParam = { pack: pack, name: className, params: [TPType(type.toComplexType())] };
        var selfType = TPath(selfPathParam);
        
        if (!cache.exists(className))
        {
            var fields = Context.getBuildFields();
            var internalType = macro:haxe.ds.Vector<T>;
            
            // precalculate stuff for the hyper-array
            var n = dimensions.length;
            var sizes = new Vector<Int>(n);
            var strides = new Vector<Int>(n);
            
            strides[0] = 1;
            sizes[0] = dimensions[0];
            var length = dimensions[0];
            
            for (i in 1...n)
            {
                strides[i] = strides[i - 1] * dimensions[i - 1];
                sizes[i] = dimensions[i];
                length *= dimensions[i];
            }
            
            
            // replace all Vector to haxe.ds.Vector
            fields.replaceTypesInFields(function(t) return switch(t)
            {
                case macro:Coords:          macro:moon.data.array.HyperArray.Coords;
                case macro:Index:           macro:moon.data.array.HyperArray.Index;
                case macro:HyperArray<T>:   macro:moon.data.array.HyperArray<T>;
                
                case TPath({pack: [], name: "SelfType", params: [TPType(ct)]}):
                    TPath({pack: [], name: className, params: [TPType(ct)]});
                    
                case _: t;
            });
            
            
            // private var data(get, never):Vector<T>;      // 1d data
            fields.findField("data").kind = FProp("get", "never", internalType);
            
            
            // private inline function get_data():Vector<T>
            var fn = fields.findFunction("get_data");
            fn.expr = macro return this;
            fn.ret = internalType;
            
            
            // private inline function get_length():Int
            var fn = fields.findFunction("get_length");
            fn.expr = macro return $v{length};
            
            
            // private inline function get_dimensions():Int
            var fn = fields.findFunction("get_dimensions");
            fn.expr = macro return $v{n};
            
            
            // public inline function size(dimension:Int):Int
            var fn = fields.findFunction("size");
            var codes:Array<String> = [];
            codes.push('return switch (dimension) {');
            for (i in 0...n) codes.push('case $i: ${sizes[i]};');
            codes.push('default: throw "Index out of bounds";');
            codes.push('}');
            fn.expr = Context.parse(codes.join("\n"), pos);
            
            
            // public inline function index(coords:Coords):Int
            var fn = fields.findFunction("index");
            var codes:Array<String> = [];
            for (i in 0...n)
                codes.push('coords[$i] * ${strides[i]}');
            fn.expr = Context.parse("return " + codes.join(" + "), pos);
            
            
            // public inline function coords(index:Index):Coords
            var fn = fields.findFunction("coords");
            var codes:Array<Expr> = [];
            for (i in 0...n)
                codes.push(macro Std.int(index / $v{strides[i]}) % $v{sizes[i]});
            fn.expr = macro return $a{codes};
            
            
            // public function map<U>(fn:T->U):SelfType<U>
            var fn = fields.findFunction("map");
            fn.expr = macro
            {
                var h = new $selfPath<U>();
                for (i in 0...length)
                    h.data[i] = fn(data[i]);
                return h;
            };
            
            
            // public function copy():SelfType<T>
            var fn = fields.findFunction("copy");
            fn.expr = macro
            {
                var h = new $selfPath<T>();
                haxe.ds.Vector.blit(data, 0, h.data, 0, length);
                return h;
            };
            
            
            // public function new(dimensions:Array<Int>, ?init:T) 
            fields.push(
            {
                name: "new",
                access: [APublic],
                kind: FFun(
                {
                    args: [{ name: 'init', opt: true, type: TPath({ name: 'T', pack: [] }) }],
                    ret: macro:Void,
                    expr: macro
                    {
                        this = new haxe.ds.Vector<T>($v{length});
                        if (init != null) fill(init);
                    },
                }),
                pos: pos,
            });
            
            
            
            // abstract MultiArray2x3x6<T>(Vector<T>)
            Context.defineType(
            {
                pack: pack,
                name: className,
                pos: pos,
                params: [{ name: 'T' }],
                kind: TDAbstract(macro:haxe.ds.Vector<T>),
                fields: fields
            });
            
            cache[className] = true;
        }
        
        return selfType;
    }
    
}
#end