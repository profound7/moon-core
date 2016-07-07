package moon.macros.async;

import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import moon.core.Pair;
import sys.io.File;

using haxe.macro.Tools;
using moon.macros.async.AsyncMacroTools;


/**
 * ...
 * @author Munir Hussin
 */
class AsyncMacroTools
{
    @:noUsing
    public static macro function asIterator(iter:Expr):Expr
    {
        var isIterable = Context.unify(Context.typeof(iter), Context.typeof(macro (null:Iterable<Dynamic>)));
        var isIterator = Context.unify(Context.typeof(iter), Context.typeof(macro (null:Iterator<Dynamic>)));
        
        return isIterable ?
            (macro $iter.iterator()):
            isIterator ?
                iter:
                throw Context.error("Expected Iterable or Iterator", iter.pos);
    }
    
}

class AsyncComplexTypeTools
{
    /**
     * Returns the default value based on the type.
     * 0 for Int, 0.0 for Float, false for Bool, null for others.
     */
    public static function getDefaultValue(ct:ComplexType):Expr
    {
        return ct == null ? null : switch (ct)
        {
            case (macro:Int) | (macro:StdTypes.Int): macro 0;
            case (macro:Float) | (macro:StdTypes.Float): macro 0.0;
            case (macro:Bool) | (macro:StdTypes.Bool): macro false;
            case _: macro null;
        }
    }
    
    public static function isVoid(ct:ComplexType):Bool
    {
        //return ct == null ? true : ct.match(TPath({ name: "StdTypes", pack: [], sub: "Void" }));
        return ct.match(TPath({ name: "StdTypes", pack: [], sub: "Void" }));
    }
}

class AsyncFunctionTools
{
    public static function isGenerator(fn:Function):Bool
    {
        return fn.expr.containsYield();
    }
    
    public static function functionPrint(fn:Function, name:String, e:Expr):String
    {
        var tmp = fn.expr;
        
        fn.expr = e;
        var fnexpr:Expr = { expr: EFunction(name, fn), pos: e.pos };
        var str = fnexpr.toString();
        
        fn.expr = tmp;
        return str;
    }
    
}



class AsyncExprTools
{
    /**
     * Checks if an expression contains a @yield subexpression.
     * If a subexpression is a function, do not search inside it.
     */
    public static function containsYield(e:Expr):Bool
    {
        if (e == null) return false;
        var foundYield:Bool = false;
        
        function findYield(e:Expr):Void
        {
            switch (e.expr)
            {
                case EMeta({ name: "yield" | "await" }, _):
                    foundYield = true;
                    
                case EFunction(_, _):
                    // don't look into nested functions
                    
                case _:
                    e.iter(findYield);
            }
        }
        
        findYield(e);
        return foundYield;
    }
    
    
    /**
     * Some control structures are of void type, and cannot be used as a value;
     */
    public static function isVoidExpr(e:Expr):Bool
    {
        try
        {
            // doesn't always work since some variables are not available in context :(
            var exprType = Context.typeof(e).toComplexType();
            return exprType.match(TPath({ name: "StdTypes", pack: [], params: [], sub: "Void" }));
        }
        catch (ex:Dynamic)
        {
            // make a guess, or get user to annotate in ambiguous cases
            return if (e == null) true else switch (e.expr)
            {
                case EVars(_) | EFor(_, _) | EWhile(_, _, _) | EIf(_, _, null):
                    true;
                    
                case EBlock(a):
                    // if length is 0, it should be parsed as EObjectDecl anyway.
                    // type of block depends on the last expression of the block.
                    a.length == 0 ? true : isVoidExpr(a[a.length - 1]);
                    
                case ESwitch(_, cases, d):
                    // if any case is a void type, then the switch is a void type
                    for (c in cases)
                        if (c.expr == null || isVoidExpr(c.expr))
                            return true;
                            
                    // no default case implies an exhaustive cases array
                    d == null ? false : isVoidExpr(d);
                    
                case EIf(_, t, f):
                    isVoidExpr(t) || isVoidExpr(f);
                    
                // manual annotation by user
                case EMeta({ name: "void" }, _):
                    true;
                    
                // manual annotation by user
                case EMeta({ name: "expr" }, _):
                    false;
                    
                case EMeta(_, e):
                    isVoidExpr(e);
                    
                // ECall could be void or not. if the function is outside the generator function,
                // then Context.typeof above should work. Otherwise it may not, and you need
                // to add @void to the function call
                
                // assume everything else is an expression
                case _:
                    false;
            }
        }
    }
}

class AsyncArrayExprTools
{
    public static function containsYield(exprs:Array<Expr>):Bool
    {
        for (e in exprs)
            if (e.containsYield())
                return true;
        return false;
    }
}
