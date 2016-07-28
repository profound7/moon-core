package moon.core;

import Type;
import moon.core.Compare.CompareString;

/**
 * ...
 * @author Munir Hussin
 */
abstract Any(Dynamic)
{
    @:to public inline function toType<T>():T return this;
    @:from public static inline function fromType<T>(v:T):Any return new Any(v);
    public function new(v:Dynamic) this = v;
    
    /*==================================================
        Methods
    ==================================================*/
    
    public inline function isNull():Bool
    {
        return this == null;
    }
    
    public inline function isString():Bool
    {
        return Std.is(this, String);
    }
    
    public inline function isArray():Bool
    {
        return Std.is(this, Array);
    }
    
    public inline function isEnumValue():Bool
    {
        return Reflect.isEnumValue(this);
    }
    
    public inline function isFunction():Bool
    {
        return Reflect.isFunction(this);
    }
    
    public inline function isObject():Bool
    {
        return Reflect.isObject(this);
    }
    
    public inline function type():ValueType
    {
        return Type.typeof(this);
    }
    
    /*==================================================
        Static methods
    ==================================================*/
    
    public static inline function notEquals(a:Any, b:Any):Bool
    {
        return !equals(a, b);
    }
    
    public static inline function notDeepEquals(a:Any, b:Any):Bool
    {
        return !deepEquals(a, b);
    }
    
    public static function equals(a:Any, b:Any):Bool
    {
        return switch ([Type.typeof(a), Type.typeof(b)])
        {
            case [TEnum(p), TEnum(q)]:
                p != q ? false : Type.enumEq(a, b);
                
            case _:
                a == b;
        }
    }
    
    /**
     * Anonymous objects, arrays and enum value parameters can
     * have different references, but if their internal values
     * are the same, they're equal.
     * 
     * Instances of different classes will never be equal, even if
     * the fields and values are the same.
     * 
     * TODO: Test circular references.
     */
    public static function deepEquals(a:Any, b:Any):Bool
    {
        return checkDeepEquals(a, b, new Memo());
    }
    
    private static function checkDeepEquals(a:Any, b:Any, memo:Memo):Bool
    {
        if (a == b)
        {
            // same references
            return true;
        }
        else switch ([Type.typeof(a), Type.typeof(b)])
        {
            case
                [TNull, TNull]
                | [TInt, TInt]
                | [TFloat, TFloat]
                | [TFloat, TInt]
                | [TInt, TFloat]
                | [TBool, TBool]
                | [TClass(String), TClass(String)]:
                    
                //throw "Unexpected case";
                return a == b;
                
            case [TFunction, TFunction]:
                
                return Reflect.compareMethods(a, b);
                
            case [TObject, TObject]:
                
                if (memo.contains(a, b))
                {
                    return true;
                }
                else
                {
                    memo.push(a, b);
                    
                    var ak:Array<String> = Reflect.fields(a);
                    var bk:Array<String> = Reflect.fields(b);
                    
                    ak.sort(Compare.asc);
                    bk.sort(Compare.asc);
                    
                    // different keys means not equal
                    if (!checkDeepEquals(ak, bk, memo)) return false;
                    
                    // check every field
                    for (k in ak)
                    {
                        var av:Dynamic = Reflect.field(a, k);
                        var bv:Dynamic = Reflect.field(b, k);
                        
                        // found a value that doesn't match, so not equal
                        if (!checkDeepEquals(av, bv, memo)) return false;
                    }
                    
                    // the same!
                    return true;
                }
                
            case [TClass(Array), TClass(Array)]:
                
                if (memo.contains(a, b))
                {
                    return true;
                }
                else
                {
                    memo.push(a, b);
                    
                    var ax:Array<Dynamic> = a;
                    var bx:Array<Dynamic> = b;
                    
                    // different lengths means not equal
                    if (ax.length != bx.length) return false;
                    
                    // check every value
                    for (i in 0...ax.length)
                    {
                        if (!checkDeepEquals(ax[i], bx[i], memo)) return false;
                    }
                    
                    // the same!
                    return true;
                }
                
            case [TEnum(p), TEnum(q)]:
                
                if (memo.contains(a, b))
                {
                    return true;
                }
                else
                {
                    memo.push(a, b);
                    
                    // different enum types
                    if (p != q) return false;
                    
                    var ae:EnumValue = a;
                    var be:EnumValue = b;
                    
                    // not using enumEq since we need to run them through deepEquals
                    if (ae.getIndex() != be.getIndex()) return false;
                    return checkDeepEquals(ae.getParameters(), be.getParameters(), memo);
                }
                
            case [TClass(p), TClass(q)]:
                
                // different classes
                if (p != q) return false;
                
                if (memo.contains(a, b))
                {
                    return true;
                }
                else
                {
                    memo.push(a, b);
                    
                    // same class should have same keys
                    var ak:Array<String> = Reflect.fields(a);
                    //var bk:Array<String> = Reflect.fields(b);
                    
                    //ak.sort(Compare.asc);
                    //bk.sort(Compare.asc);
                    
                    // different keys means not equal
                    //if (!checkDeepEquals(ak, bk, memo)) return false;
                    
                    // check every field
                    for (k in ak)
                    {
                        var av:Dynamic = Reflect.getProperty(a, k);
                        var bv:Dynamic = Reflect.getProperty(b, k);
                        
                        // found a value that doesn't match, so not equal
                        if (!checkDeepEquals(av, bv, memo)) return false;
                    }
                    
                    // the same!
                    return true;
                }
                
            case [p, q]:
                
                // different types
                if (p != q) return false;
                
                // same values
                return a == b;
        }
    }
    
}

private class Memo
{
    public var a:Array<Dynamic> = [];
    public var b:Array<Dynamic> = [];
    
    public function new()
    {
    }
    
    public function contains(x:Dynamic, y:Dynamic):Bool
    {
        var i = a.indexOf(x);
        return i != -1 && i == b.indexOf(y);
    }
    
    public function push(x:Dynamic, y:Dynamic):Void
    {
        a.push(x);
        b.push(y);
    }
}