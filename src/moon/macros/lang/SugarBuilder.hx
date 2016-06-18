package moon.macros.lang;

import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;

/**
 * ...
 * @author Munir Hussin
 */
class SugarBuilder
{
    
    public static function build(?fields:Array<Field>):Array<Field>
    {
        if (fields == null) fields = Context.getBuildFields();
        
        for (f in fields)
        {
            switch (f.kind)
            {
                case FFun(fn):
                    fn.expr = transform(fn.expr);
                    
                case _:
            }
        }
        
        return fields;
    }
    
    public static function transform(e:Expr):Expr
    {
        return switch (e.expr)
        {
            /*==================================================
                Meta
            ==================================================*/
            
            case EMeta(s, a):
                
                switch ([s.name, a.expr])
                {
                    // @notzero [0, 0, 1, 0];
                    case ["notzero", EArrayDecl(args)]:
                        makeFirst(macro _ != 0, args);
                        
                    // @notnull [null, null, "a", "b"]
                    case ["notnull", EArrayDecl(args)]:
                        makeFirst(macro _ != null, args);
                        
                    case _:
                        e.map(transform);
                }
                
            /*==================================================
                Misc
            ==================================================*/
            
            // [x, y] => b
            case EBinop(OpArrow, { expr: EArrayDecl(args) }, body):
                makeFunction(args, body, e.pos);
                
            // x => b
            case EBinop(OpArrow, arg, body):
                makeFunction([arg], body, e.pos);
                
            case _:
                e.map(transform);
        }
    }
    
    public static function replaceUnderscore(expr:Expr, with:Expr):Expr
    {
        function recurse(e:Expr):Expr return replaceUnderscore(e, with);
        
        return switch (expr.expr)
        {
            case EConst(CIdent("_")):
                with ;
                
            case _:
                expr.map(recurse);
        }
    }
    
    public static function makeFirst(cond:Expr, args:Array<Expr>):Expr
    {
        var codes:Array<Expr> = [];
        
        if (args.length == 1)
        {
            return args[0];
        }
        else
        {
            codes.push(macro var tmp);
            codes.push(makeFirstIf(cond, args, 0));
            
            var x = macro $b{codes}; trace(x.toString());
            
            return macro $b{codes};
        }
    }
    
    public static function makeFirstIf(cond:Expr, args:Array<Expr>, i:Int):Expr
    {
        var a:Expr = args[i];
        var c:Expr = replaceUnderscore(cond, macro (tmp = $a));
        var t:Expr = macro tmp;
        var f:Expr = i == args.length -2 ? args[i + 1] : makeFirstIf(cond, args, i + 1);
        return macro if ($c) $t else $f;
    }
    
    
    public static function makeFunction(args:Array<Expr>, body:Expr, pos:Position):Expr
    {
        return
        {
            expr: EFunction(null,
            {
                args: [for (a in args) switch (a.expr)
                {
                    case EConst(CIdent(id)):
                        { name: id, type: null }
                        
                    case _:
                        throw "Invalid short lambda argument";
                }],
                ret: null,
                expr: macro return $body
            }),
            pos: pos
        }
    }
}