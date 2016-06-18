package moon.macros.signal;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;

/**
 * ...
 * @author Munir Hussin
 */
class SignalMacro
{
    public static var cache = new Map<Int, Bool>();
    
    public static function build():ComplexType //#if display Type #else ComplexType #end
    {
        //trace("BUILD Signal -------");
        return switch(Context.getLocalType())
        {
            case TInst(_.get() => { name: "Signal" }, params):
                
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
        var className = 'Signal$n';
        var pack = ["moon", "core"];
        
        var complexParams = [for (p in params) TPType(p.toComplexType())];
        var selfType = { pack: pack, name: className, params: complexParams };
        //var selfType = { pack: pack, name: "Signal", sub: className, params: complexParams };
        
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
            //trace('does not exist $className');
            var pos = Context.currentPos();
            
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
            }
            
            
            // public inline function dispatch(v0:T0, v1:T1, v2:T2...):Void
            //      dynamicDispatch([v0, v1, v2...]);
            fields.push(
            {
                name: "dispatch",
                access: [APublic, AInline],
                doc: "Sends the values to all listeners.",
                kind: FFun(
                {
                    args: funArgs,
                    ret: macro:Void,
                    expr: macro dynamicDispatch([$a{vals}]),
                }),
                pos: pos,
            });
            
            
            // public inline function next():Future<Tuple<T0, T1, T2...>>
            fields.push(
            {
                name: "next",
                access: [APublic, AInline],
                doc: "Return a Future that will trigger the next time this Signal is triggered.",
                kind: FFun(
                {
                    args: [],
                    ret: TPath(
                    {
                        pack: ["moon", "core"],
                        name: "Future",
                        params: [TPType(TPath(
                        {
                            pack: ["moon", "core"],
                            name: "Tuple",
                            params: [for (p in argTypes) TPType(p)]
                        }))]
                    }),
                    expr: macro return cast dynamicNext(),
                }),
                pos: pos,
            });
            
            // class Signal0 extends SignalBase<Void->Void>
            // class Signal1<T0> extends SignalBase<T0->Void>
            // class Signal2<T0, T1> extends SignalBase<T0->T1->Void>
            // class Signal3<T0, T1, T2> extends SignalBase<T0->T1->T2->Void>
            
            // should this be an abstract instead?
            // @:forward abstract Signal2<T0, T1>(SignalBase<T0->T1->Void>)
            
            Context.defineType(
            {
                pack: ["moon", "core"],
                name: 'Signal$n',
                pos: pos,
                params: typeParams,
                kind: TDClass(
                {
                    // extends SignalBase<T0, T1...>
                    pack: ["moon", "macros", "signal"],
                    name: "SignalBase",
                    params: [TPType(TFunction(argTypes, macro:Void))]
                }),
                fields: fields
            });
            
            //trace('Created $pack.$className');
            
            cache[n] = true;
        }
    }
}
