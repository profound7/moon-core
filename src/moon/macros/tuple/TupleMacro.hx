package moon.macros.tuple;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;
using moon.macros.tools.FieldTools;


class TupleMacro
{
    public static var cache = new Map<Int, Bool>();
    
    public static macro function build():ComplexType //#if display Type #else ComplexType #end
    {
        //trace('BUILD Tuple  ---------');
        return switch(Context.getLocalType())
        {
            case TInst(_.get() => { name: "Tuple" }, params):
                
                //#if display
                //    buildClass(params).toType();
                //#else
                    buildClass(params);
                //#end
                
            case t:
                throw 'Incompatible type: $t';
        }
    }
    
    public static function buildClass(params:Array<Type>):ComplexType
    {
        var n = params.length;
        var className = 'Tuple$n';
        var pack = ["moon", "core"];
        
        var complexParams = [for (p in params) TPType(p.toComplexType())];
        var selfType = { pack: pack, name: className, params: complexParams };
        
        if (!cache.exists(n))
        {
            create(n);
        }
        
        return TPath(selfType);
    }
    
    public static function create(n:Int):Void
    {
        if (!cache.exists(n))
        {
            var pos = Context.currentPos();
            var isAbstract = true;
            var fields = Context.getBuildFields();
            var vals:Array<Expr> = [];                  // v0, v1, v2...
            var argTypes:Array<ComplexType> = [];       // T0, T1, T2...
            var funArgs:Array<FunctionArg> = [];        // v0:T0, v1:T1, v2:T2...
            var typeParams:Array<TypeParamDecl> = [];   // T0, T1, T2...
            
            for (i in 0...n)
            {
                vals.push(macro $i{'v$i'});
                argTypes.push(TPath({ name: 'T$i', pack: [] }));
                funArgs.push({ name: 'v$i', type: argTypes[i] });
                typeParams.push({ name: 'T$i' });
                
                // private inline function get_vn():Tn return this[n];
                fields.push(
                {
                    name: 'get_v$i',
                    access: [APrivate, AInline],
                    kind: FFun(
                    {
                        args: [],
                        ret: argTypes[i],
                        expr: macro return data[$v{i}],
                    }),
                    pos: pos,
                });
                
                // private inline function set_vn(vn:Tn):Tn return this[n] = vn;
                fields.push(
                {
                    name: 'set_v$i',
                    access: [APrivate, AInline],
                    kind: FFun(
                    {
                        args: [funArgs[i]],
                        ret: argTypes[i],
                        expr: macro return data[$v{i}] = $i{'v$i'},
                    }),
                    pos: pos,
                });
                
                // public var vn(get,set):Tn
                fields.push(
                {
                    name: 'v$i',
                    access: [APublic],
                    kind: FProp("get", "set", argTypes[i]),
                    pos: pos,
                });
            }
            
            fields.push(
            {
                name: "new",
                access: [APublic],
                kind: FFun(
                {
                    args: funArgs,
                    ret: macro:Void,
                    expr: isAbstract ? (macro this = $a{vals}) : (macro data = $a{vals}),
                }),
                pos: pos,
            });
            
            // public function set(v0:T0, v1:T1, v2:T2...):Void
            fields.push(
            {
                name: "set",
                access: [APublic, AInline],
                kind: FFun(
                {
                    args: funArgs,
                    ret: macro:Void,
                    expr: isAbstract ? (macro this = $a{vals}) : (macro data = $a{vals}),
                }),
                pos: pos,
            });
            
            
            if (isAbstract)
            {
                var field = fields.findField("data");
                switch (field.kind)
                {
                    case FProp(_, _, t, _):
                        field.kind = FProp("get", "never", t);
                        
                    case _:
                        throw "Expected a property";
                }
                
                // private inline function get_data():Array<Dynamic> return this;
                fields.push(
                {
                    name: 'get_data',
                    access: [APrivate, AInline],
                    kind: FFun(
                    {
                        args: [],
                        ret: macro:Array<Dynamic>,
                        expr: macro return this,
                    }),
                    pos: pos,
                });
            }
            
            Context.defineType(
            {
                pack: ["moon", "core"],
                name: 'Tuple$n',
                pos: pos,
                params: typeParams,
                kind: isAbstract ? TDAbstract(macro:Array<Dynamic>) : TDClass(),
                fields: fields
            });
            
            cache[n] = true;
        }
    }
}