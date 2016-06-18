package moon.tools;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author Munir Hussin
 */
class EnumTools
{
    
    /**
     * Compares two enum instances `a` and `b` by name.
     * They are the same if they have the same index.
     * 
     * Use case:
     * 
     *      If you have an enum like:
     *          enum { Foo; Bar(x:Int); Baz(x:String); }
     * 
     *      and you want to know if 2 enum values are the same, ignoring the argument:
     *          Foo.sameAs(Foo)                 ==> true
     *          Bar(5).sameAs(Bar(2))           ==> true
     *          Baz("a").sameAs(Baz("b"))       ==> true
     * 
     * When you use == or Type.enumEq, the 2nd and 3rd example above is false.
     * If `a` and `b` are from different enums, it'll be a compilation error.
     */
    public static inline function sameAs<T:EnumValue>(a:T, b:T):Bool
    {
        return a == b || a.getIndex() == b.getIndex();
    }
    
    // var test:Expr = EComma(EComma(EComma(EComma(EId("a"), EId("b")), EId("c")), EId("d")), EId("e"));
    // var a = test.flatten("EComma");
    @:deprecated
    public static function flatten<T:EnumValue>(x:T, type:String):Array<T>
    {
        if (x == null) return [];
        
        if (x.getName() == type)
        {
            var result:Array<T> = [];
            
            for (a in x.getParameters())
            {
                result = result.concat(flatten(a, type));
            }
            
            return result;
        }
        else
        {
            return [x];
        }
    }
    
    /**
     * // x = a if val is Foo(a), else throw error
     * var x = val.extract(Foo(a), a);
     * 
     * // x = a if val is Foo(a), else return 0
     * var x = val.extract(Foo(a), a, 0);
     * 
     * // code blocks are fine too
     * var x = val.extract(Foo(a), { doSomething(); }, { doOtherThing(); });
     * 
     * The extract macro will turn into a switch expression
     */
    public static macro function extract(x:ExprOf<EnumValue>, pattern:Array<Expr>)
    {
        return switch (pattern)
        {
            case //[macro $a ? $b : $c] | // lets avoid having too many ways to do the same thing
                [macro $a, macro $b, macro $c]:
                
                macro switch($x)
                {
                    case $a: $b;
                    case _: $c;
                }
                
            case [macro $a, macro $b]:
                
                macro switch($x)
                {
                    case $a: $b;
                    case _: throw "No match";
                }
                
            case _:
                Context.error("Invalid extraction pattern", x.pos);
        }
    }
}
