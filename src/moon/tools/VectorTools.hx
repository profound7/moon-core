package moon.tools;

import haxe.ds.Vector;
import haxe.macro.Context;
import haxe.macro.Expr;
import moon.data.iterators.VectorIterator;

using haxe.macro.TypeTools;

typedef Vector<T> = haxe.ds.Vector<T>;

/**
 * 
 * @author Munir Hussin
 */
class VectorTools
{
    // Static extension of Class<Vector> seems better,
    // like Vector.of(3, 5, 6) but this doesn't work:
    // public static macro function of<T>(cls:ExprOf<Class<Vector<T>>>, rest:Array<Expr>):Expr
    
    /**
     * Usage:
     * var x = VectorTools.create(2, 5, 7);
     * ==>
     * var x =
     * {
     *     var v = new haxe.ds.Vector<Int>(3);
     *     v[0] = 2;
     *     v[1] = 5;
     *     v[2] = 7;
     *     v;
     * }
     * 
     * If the types are mixed, for example:
     *     VectorTools.create(2, "5", true);
     * then it'll generate Vector<Dynamic>
     */
    @:noUsing
    public static macro function create(rest:Array<Expr>):Expr
    {
        var n = rest.length;
        if (n == 0) return macro new haxe.ds.Vector<Dynamic>(0);
        
        var exprs:Array<Expr> = [];
        var paramType = try
        {
            // if the array is of mixed type, an exception is thrown
            switch (Context.typeof(macro $a{rest}))
            {
                case TInst(_.get() => { name: "Array", pack: [] }, [param]):
                    param.toComplexType();
                    
                case _:
                    throw "Unexpected";
            }
        }
        catch (ex:Dynamic)
        {
            macro:Dynamic;
        }
        
        // v[i] = vi;
        for (i in 0...rest.length)
        {
            exprs.push(macro v[$v{i}] = ${rest[i]});
        }
        
        exprs.unshift(macro var v = new haxe.ds.Vector<$paramType>($v{n}));
        exprs.push(macro v);
        
        var m = macro $b{exprs};
        //trace(m.toString().split("\n").join("|"));
        
        return m;
    }
    
    
    
    /**
     * finds an array value, and returns its index.
     * returns -1 if not found
     */
    public static function indexOf<T>(a:Vector<T>, v:T):Int
    {
        var i:Int = 0;
        var n:Int = a.length;
        
        while (i < n)
        {
            if (a[i] == v) return i;
            ++i;
        }
        
        return -1;
    }
    
    /**
     *  checks if an array contains a value
     */
    public static inline function contains<T>(a:Vector<T>, v:T):Bool
    {
        return indexOf(a, v) != -1;
    }
    
    /**
     * checks if 2 array instances contains the same values
     */
    public static function equals<T>(a:Vector<T>, b:Vector<T>):Bool
    {
        if (a.length != b.length) return false;
        for (i in 0...a.length) if (a[i] != b[i]) return false;
        return true;
    }
    
    /**
     * sets the vector with a value
     */
    public static inline function fillAll<T>(a:Vector<T>, val:T):Void
    {
        for (i in 0...a.length)
            a[i] = val;
    }
    
    /**
     * sets the vector with a value
     * if len is negative, then the len starts counting from the end
     */
    public static inline function fill<T>(a:Vector<T>, val:T, start:Int=0, len:Int=-1):Void
    {
        var end = len >= 0 ? start + len : a.length + len + 1;
        for (i in start...end)
            a[i] = val;
    }
    
    public static inline function clone<T>(v:Vector<T>):Vector<T>
    {
        // copy v to a
        var a:Vector<T> = new Vector<T>(v.length);
        Vector.blit(v, 0, a, 0, v.length);
        return a;
    }
    
    public static inline function swap<T>(v:Vector<T>, i:Int, j:Int):Void
    {
        var tmp:T = v[i];
        v[i] = v[j];
        v[j] = tmp;
    }
    
    public static inline function arrayCopy<T>(v:Vector<T>, a:Array<T>):Void
    {
        // copy v to a
        for (i in 0...v.length)
            v[i] = a[i];
    }
    
    public static inline function iterator<T>(v:Vector<T>):Iterator<T>
    {
        return new VectorIterator<T>(v, v.length);
    }
}



