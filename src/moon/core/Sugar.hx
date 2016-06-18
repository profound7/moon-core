package moon.core;

import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import moon.macros.lang.SugarBuilder;
import moon.macros.async.AsyncBuilder;

using haxe.macro.Tools;

/**
 * Some macro stuff like short lambdas.
 * 
 * Todo:
 * add safe . operator?
 * eg:
 * @nullsafe(foo.bar.baz) = 5;
 * 
 * which transforms into:
 * if (foo != null && foo.bar != null && foo.bar.baz != null)
 * {
 *      foo.bar.baz = 5;
 * }
 * 
 * Usage:
 * 
 * Add autobuild to moon.core.Sugar.build()
 * 
 * @author Munir Hussin
 */
class Sugar
{
    public static macro function notzero(args:Array<Expr>):Expr
    {
        return SugarBuilder.makeFirst(macro _ != 0, args);
    }
    
    public static macro function notnull(args:Array<Expr>):Expr
    {
        return SugarBuilder.makeFirst(macro _ != null, args);
    }
    
    public static macro function sugar(expr:Expr):Expr
    {
        return AsyncBuilder.transform(SugarBuilder.transform(expr));
    }
    
    #if macro
        public static function build():Array<Field>
        {
            var fields:Array<Field> = Context.getBuildFields();
            
            fields = SugarBuilder.build(fields);
            fields = AsyncBuilder.build(fields);
            
            return fields;
        }
        
        public static function buildAsync():Array<Field>
        {
            var fields:Array<Field> = Context.getBuildFields();
            fields = AsyncBuilder.build(fields);
            return fields;
        }
    #end
}