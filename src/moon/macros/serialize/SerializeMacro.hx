package moon.macros.serialize;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.Serializer;
import haxe.Unserializer;
import moon.core.Pair;

/**
 * ...
 * @author Munir Hussin
 */
class SerializeMacro
{
    
    public static function getFieldsInfo(type:Type):Pair<Array<String>, Array<String>>
    {
        var vars:Array<String> = [];
        var hide:Array<String> = getIgnoreMeta(type);
        if (hide == null) hide = [];
        var ignored:Array<String> = hide.copy();
        
        switch (type)
        {
            case TInst(cl, _):
                var ctype = cl.get();
                var fields = ctype.fields.get();
                
                for (f in fields)
                {
                    switch (f.kind)
                    {
                        // only interested in vars, not methods
                        case FVar(_, _):
                            
                            var name = f.name;
                            
                            if (hide.indexOf(name) == -1)
                                vars.push(name);
                            else
                                hide.remove(name);
                            
                        case _:
                    }
                }
                
            case _:
                throw "Invalid";
        }
        
        
        if (hide.length == 1)
            throw "Field " + hide[0] + " not found.";
        else if (hide.length > 1)
            throw "Fields " + hide.join(", ") + " not found.";
        
        return Pair.of(vars, ignored);
    }
    
    
    public static function getIgnoreMeta(type:Type):Array<String>
    {
        var hide:Array<String> = null;
        
        switch (type)
        {
            case TInst(cl, _):
                var ctype = cl.get();
                var meta = ctype.meta.get();
                
                // find out which fields to ignore
                for (m in meta)
                {
                    if (m.name == ":serializeIgnore")
                    {
                        hide = [];
                        
                        for (p in m.params)
                        {
                            switch (p.expr)
                            {
                                case EConst(CIdent(s)):
                                    hide.push(s);
                                    
                                case _:
                            }
                        }
                    }
                }
                
            case _:
        }
        
        return hide;
    }
    
    /**
     * Returns an array of field names that are vars, ignoring methods
     * and fields listed in @:serializeIgnore meta.
     */
    public static macro function getVarFields():ExprOf<Array<String>>
    {
        var info = getFieldsInfo(Context.getLocalType());
        return Context.makeExpr(info.head, Context.currentPos());
    }
    
    /**
     * Returns an array of field names that are vars, ignoring methods
     * and fields listed in @:serializeIgnore meta.
     */
    public static macro function getIgnoredFields():ExprOf<Array<String>>
    {
        var info = getFieldsInfo(Context.getLocalType());
        return Context.makeExpr(info.tail, Context.currentPos());
    }
    
    public static macro function serialize(s:ExprOf<Serializer>)
    {
        return macro
        {
            var x:Array<String> = moon.macros.serialize.SerializeMacro.getVarFields();
            
            for (f in x)
            {
                var v = Reflect.field(this, f);
                //trace("serializing: " + f + " = " + v);
                $s.serialize(v);
            }
        }
    }
    
    public static macro function unserialize(u:ExprOf<Unserializer>)
    {
        return macro
        {
            var x:Array<String> = moon.macros.serialize.SerializeMacro.getVarFields();
            
            for (f in x)
            {
                var v = u.unserialize();
                //trace("unserializing: " + f + " = " + v);
                Reflect.setField(this, f, v);
            }
            
            x = moon.macros.serialize.SerializeMacro.getIgnoredFields();
            
            for (f in x)
            {
                //trace("unserializing ignored: " + f + " = " + null);
                Reflect.setField(this, f, null);
            }
        }
    }
    
    public static macro function build(always:Bool):Array<Field>
    {
        //trace("hey hey");
        var pos = Context.currentPos();
        var type = Context.getLocalType();
        var fields:Array<Field> = Context.getBuildFields();
        var ignoreMeta:Array<String> = getIgnoreMeta(type);
        
        if (always || ignoreMeta != null)
        {
            fields.push({
                name: "hxSerialize",
                doc: null,
                access: [APublic],
                kind: FieldType.FFun(
                {
                    args: [{ name: "s", type: macro:haxe.Serializer }],
                    ret: macro:Void,
                    expr: macro { moon.macros.serialize.SerializeMacro.serialize(s); },
                }),
                meta: [{ name: ":keep", pos: pos }],
                pos: pos,
            });
            
            fields.push({
                name: "hxUnserialize",
                doc: null,
                access: [APublic],
                kind: FieldType.FFun(
                {
                    args: [{ name: "u", type: macro:haxe.Unserializer }],
                    ret: macro:Void,
                    expr: macro moon.macros.serialize.SerializeMacro.unserialize(u),
                }),
                meta: [{ name: ":keep", pos: pos }],
                pos: pos,
            });
        }
        
        return fields;
    }
}