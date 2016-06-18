package moon.core;

import moon.core.Types.Comparable;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
#end

/**
 * Comparison functions for sorting.
 * 
 * @author Munir Hussin
 */
class Compare
{
    /**
     * General purpose ascending comparison function.
     * Uses Reflect.compare.
     * Usage:
     *      array.sort(Compare.asc);
     */
    public static inline function asc<T>(a:T, b:T):Int
    {
        return Reflect.compare(a, b);
    }
    
    /**
     * General purpose descending comparison function.
     * Uses Reflect.compare.
     * Usage:
     *      array.sort(Compare.desc);
     */
    public static inline function desc<T>(a:T, b:T):Int
    {
        return Reflect.compare(b, a);
    }
    
    /**
     * Compares a nullable type.
     * 
     * When `nullOrder` is Asc, then null is smaller than non-null values,
     * otherwise null is bigger than non-null values.
     * 
     * Usage:
     *      array.sort(Compare.nullable(Asc, CompareString.asc));
     */
    public static function nullable<T>(nullOrder:Order=Asc, cmp:T->T->Int):T->T->Int
    {
        var av:Int = nullOrder ? -1 : 1;
        var bv:Int = nullOrder ? 1 : -1;
        
        return function(a:Null<T>, b:Null<T>):Int
            return a == null ? av: b == null ? bv: cmp(a, b);
    }
    
    /**
     * General purpose comparison function. This handles null as well,
     * and null is taken as smaller than non-null values.
     * 
     * Usage:
     *      array.sort(Compare.any(Asc));
     */
    public static inline function any<T>(order:Order=Asc):T->T->Int
    {
        return order ? nullable(Asc, Compare.asc): nullable(Desc, Compare.desc);
    }
    
    /**
     * Create a comparison function from a comparable class.
     * A comparable class is a class with a compareTo(x:T):Int where T is the class itself.
     * This method is able to handle null, where null are smaller than non-null values.
     * 
     * Usage:
     *      array.sort(Compare.obj(Asc));       // T is inferred from type of array.
     *      var cmp = Compare.obj(Asc);         // T is monomorph until its used.
     *      var cmp = Compare.obj(Fruit, Asc);  // Let T be Fruit.
     */
    public static inline function obj<T:Comparable<T>>(cls:Class<T>=null, order:Order=Asc):T->T->Int
    {
        return order ?
            nullable(Asc, function(a:T, b:T):Int return a.compareTo(b)):
            nullable(Desc, function(a:T, b:T):Int return -a.compareTo(b));
    }
    
    /**
     * Automatically infer if the needed type is a Comparable<T> or not using macro.
     * If it is, this macro returns Compare.obj(order) otherwise Compare.any(order)
     * 
     * Usage:
     *      array.sort(Compare.auto(Asc));
     */
    public static macro function auto<T>(order:ExprOf<Order>):ExprOf<T->T->Int>
    {
        var expectedFn = Context.getExpectedType();
        
        function isComparable(type:Type):Bool
        {
            var ct = type.toComplexType();
            var comparableType = Context.typeof(macro (null:moon.core.Types.Comparable<$ct>));
            return type.unify(comparableType);
        }
        
        return switch (expectedFn)
        {
            // A->B->Int where A and B unifies
            case TFun([{t:a}, {t:b}],
              TAbstract(_.get() => { module: "StdTypes", pack: [], name: "Int" }, []))
              if (a.unify(b) && b.unify(a)):
                
                if (isComparable(a))
                    macro moon.core.Compare.obj($order);
                else
                    macro moon.core.Compare.any($order);
                
            case _:
                throw "Unsupported type. Expected T->T->Int";
        }
    }
    
    /**
     * Usage:
     *      array.sort(Compare.float(Asc));
     */
    /*public static inline function float(order:Order=Asc):Float->Float->Int
    {
        return order ? CompareFloat.asc : CompareFloat.desc;
    }*/
    
    /**
     * When sorting booleans, false is taken as smaller than true.
     * Usage:
     *      array.sort(Compare.bool(Asc));
     */
    /*public static inline function bool(order:Order=Asc):Bool->Bool->Int
    {
        return order ? CompareBool.asc : CompareBool.desc;
    }*/
    
    
    /**
     * Usage:
     *      array.sort(Compare.string(Asc, CaseInsensitive, false));
     */
    public static function string(order:Order=Asc, cs:CaseSensitivity=CaseSensitive, natural:Bool=false):String->String->Int
    {
        return
            if (natural)
                CompareString.natural(order, cs);
            else if (cs)
                order ? CompareString.asc : CompareString.desc;
            else
                order ? CompareString.asci : CompareString.desci;
    }
    
    
    
    /**
     * Transform values to another type, and compares based on that type.
     * 
     * Usage:
     *      array.sort(Compare.map(o=>o.weight, CompareFloat.asc));
     */
    public static inline function map<T, U>(val:T->U, cmp:U->U->Int):T->T->Int
    {
        return function(a:T, b:T):Int return cmp(val(a), val(b));
    }
    
    /**
     * Transform values to a comparable value (Int/Float/String), and then sort
     * using Compare.asc or Compare.desc.
     * 
     * This is slightly less verbose than using map.
     * 
     * Usage:
     *      array.sort(Compare.by(o=>o.name, Asc));
     *      
     *      // using map
     *      array.sort(Compare.map(o=>o.name, Compare.asc));
     */
    public static inline function by<T,U>(val:T->U, order:Order=Asc):T->T->Int
    {
        return order ? map(val, Compare.asc) : map(val, Compare.desc);
    }
    
}

/**
 * Compares two Float/Int
 */
/*class CompareFloat
{
    public static inline function asc(a:Float, b:Float):Int
    {
        return Std.int(a - b);
    }
    
    public static inline function desc(a:Float, b:Float):Int
    {
        return Std.int(b - a);
    }
}*/

/**
 * As false is commonly associated with 0, false is taken as smaller than true.
 */
/*class CompareBool
{
    public static inline function asc(a:Bool, b:Bool):Int
    {
        return a == b ? 0 : b ? -1 : 1;
    }
    
    public static inline function desc(a:Bool, b:Bool):Int
    {
        return a == b ? 0 : a ? -1 : 1;
    }
}*/


/**
 * Compares strings with optional case sensitivity or natural sorting.
 */
class CompareString
{
    private static var rxDigits:EReg = ~/(\d+)/;
    
    public static inline function asc(a:String, b:String):Int
    {
        return a == b ? 0 : a < b ? -1 : 1;
    }
    
    public static inline function desc(a:String, b:String):Int
    {
        return a == b ? 0 : a > b ? -1 : 1;
    }
    
    public static inline function asci(a:String, b:String):Int
    {
        a = a.toLowerCase();
        b = b.toLowerCase();
        return a == b ? 0 : a < b ? -1 : 1;
    }
    
    public static inline function desci(a:String, b:String):Int
    {
        a = a.toLowerCase();
        b = b.toLowerCase();
        return a == b ? 0 : a > b ? -1 : 1;
    }
    
    private static function naturalHelper(a:String, b:String, cs:CaseSensitivity, strCmpFn:String->String->Int, intCmpFn:Int->Int->Int):Int
    {
        var cmp:Int = 0;
        var aText:String = "";
        var bText:String = "";
        var aDigits:String = "";
        var bDigits:String = "";
        
        if (!cs)
        {
            a = a.toLowerCase();
            b = b.toLowerCase();
        }
        
        if (a == b)
            return 0;
        
        while (a.length > 0 && b.length > 0)
        {
            if (rxDigits.match(a))
            {
                // there's a digit somewhere inside
                aText = rxDigits.matchedLeft();
                aDigits = rxDigits.matched(1);
                a = rxDigits.matchedRight();
            }
            else
            {
                // there's no digits at all
                aText = a;
                aDigits = "0";
                a = "";
            }
            
            if (rxDigits.match(b))
            {
                // there's a digit somewhere inside
                bText = rxDigits.matchedLeft();
                bDigits = rxDigits.matched(1);
                b = rxDigits.matchedRight();
            }
            else
            {
                // there's no digits at all
                bText = b;
                bDigits = "0";
                b = "";
            }
            
            if (aText.length != bText.length)
            {
                // if lengths of the text are different
                // i.e.: abc123 abcd12
                // then just sort using the text
                return strCmpFn(aText, bText);
            }
            else
            {
                // lengths of text are the same
                cmp = strCmpFn(aText, bText);
                
                // if the text are different, return that result
                if (cmp != 0)
                    return cmp;
                    
                // text content are the same.
                // so we sort by digits
                // i.e.: abc123 abc42
                
                // BUG: this is bad if digits exceed max int
                cmp = intCmpFn(Std.parseInt(aDigits), Std.parseInt(bDigits));
                
                // if the digits are different, return that result
                if (cmp != 0)
                    return cmp;
                    
                // digits are the same!
                // i.e: abc123 abc123
                // get next sequence of text
            }
        }
        
        return strCmpFn(a, b);
    }
    
    public static function naturalCustom(cs:CaseSensitivity=CaseInsensitive, strCmpFn:String->String->Int, intCmpFn:Int->Int->Int):String->String->Int
    {
        /*if (strCmpFn == null)
            strCmpFn = CompareString.asc;
            
        if (intCmpFn == null)
            intCmpFn = CompareFloat.asc;*/
            
        return function(a:String, b:String):Int
        {
            return naturalHelper(a, b, cs, strCmpFn, intCmpFn);
        }
    }
    
    public static inline function natural(order:Order=Asc, cs:CaseSensitivity=CaseInsensitive):String->String->Int
    {
        return order ?
            naturalCustom(cs, Compare.asc, Compare.asc):
            naturalCustom(cs, Compare.desc, Compare.desc);
    }
    
    public static inline function naturalAsc(a:String, b:String):Int
    {
        return naturalCustom(CaseSensitive, Compare.asc, Compare.asc)(a, b);
    }
    
    public static inline function naturalDesc(a:String, b:String):Int
    {
        return naturalCustom(CaseSensitive, Compare.desc, Compare.desc)(a, b);
    }
    
    public static inline function naturalAsci(a:String, b:String):Int
    {
        return naturalCustom(CaseInsensitive, Compare.asc, Compare.asc)(a, b);
    }
    
    public static inline function naturalDesci(a:String, b:String):Int
    {
        return naturalCustom(CaseInsensitive, Compare.desc, Compare.desc)(a, b);
    }
}

@:enum abstract Order(Bool) to Bool from Bool
{
    var Asc = true;
    var Desc = false;
}

@:enum abstract CaseSensitivity(Bool) to Bool from Bool
{
    var CaseSensitive = true;
    var CaseInsensitive = false;
}
