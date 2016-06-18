package moon.macros.tools;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;

/**
 * ...
 * @author Munir Hussin
 */
class FieldTools
{
    
    public static function findField(fields:Array<Field>, name:String):Field
    {
        for (f in fields) if (f.name == name) return f;
        return null;
    }
    
    
    public static function findFunction(fields:Array<Field>, name:String):Function
    {
        var f = findField(fields, name);
        if (f == null) throw 'Field $name does not exist';
        
        switch (f.kind)
        {
            case FFun(fn):
                return fn;
                
            case _:
                throw 'Field $name is not a function';
        }
    }
}