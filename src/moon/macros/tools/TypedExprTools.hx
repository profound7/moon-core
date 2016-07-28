package moon.macros.tools;

import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;
using moon.macros.tools.TypedExprTools;
using moon.macros.async.AsyncMacroTools;

/**
 * Used by async macros to convert between typed expr and expr
 * 
 * @author Munir Hussin
 */
class TypedExprTools
{
    
    public static function pos(e:ExprDef, pos:Position):Expr
    {
        return { expr: e, pos: pos };
    }
    
    public static function const(c:TConstant):Constant
    {
        return switch(c)
        {
            case TInt(i): CInt(Std.string(i));
            case TFloat(s): CFloat(s);
            case TString(s): CString(s);
            case TBool(b): CIdent(b ? "true" : "false");
            case TNull: CIdent("null");
            case TThis: CIdent("this");
            case TSuper: CIdent("super");
        }
    }
    
    public static function toComplexType(m:ModuleType):ComplexType
    {
        return switch(m)
        {
            case TClassDecl(_.get() => t): TPath({ pack: t.pack, name: t.module, sub: t.name });
            case TEnumDecl(_.get() => t): TPath({ pack: t.pack, name: t.module, sub: t.name });
            case TTypeDecl(_.get() => t): TPath({ pack: t.pack, name: t.module, sub: t.name });
            case TAbstract(_.get() => t): TPath({ pack: t.pack, name: t.module, sub: t.name });
            case _: throw "Unexpected";
        }
    }
    
    
    /**
     * finds a TypedExpr by position (min), and returns it
     */
    public static function find(te:TypedExpr, p:Position):TypedExpr
    {
        var found:TypedExpr = null;
        var min = p.getInfos().min;
        
        function findByMinPos(te:TypedExpr):Void
        {
            if (te.pos.getInfos().min == min)
                found = te;
            else
                te.iter(findByMinPos);
        }
        
        findByMinPos(te);
        return found;
    }
    
    /**
     * Converts a TypedExpr into an Expr with some other details like variable
     * names, identifiers, and so on.
     */
    public static function getInfo(te:TypedExpr, exprPos:Position):TypedExprInfo
    {
        var mapa:Array<TypedExpr>->Array<Expr> = null;
        var map:TypedExpr->Expr = null;
        
        var tmpName = "__tmp_";
        var varName = "__var_";
        
        var typedExprByPos:Map<Int, TypedExpr> = new Map();
        var identifiers:Map<Int, TVar> = new Map();
        var vars:Map<Int, Var> = new Map();
        var names:Map<Int, String> = new Map();
        
        
        function id(v:TVar, p:Position):String
        {
            var ePos = exprPos.getInfos();
            var vPos = p.getInfos();
            var name:String = null;
            
            if (names.exists(v.id))
            {
                name = names.get(v.id);
            }
            else if (vPos.min < ePos.min || vPos.max > ePos.max)
            {
                name = v.name;
                names.set(v.id, name);
            }
            else if (identifiers.exists(v.id))
            {
                if (v.name.indexOf("`") >= 0)
                    name = tmpName + v.id;
                else
                    name = varName + v.name + "_" + v.id;
                
                names.set(v.id, name);
                vars.set(v.id, { name: name, type: v.t.toComplexType(), expr: null });
            }
            else
            {
                name = v.name;
                names.set(v.id, name);
            }
            
            return name;
        }
        
        mapa = function(te:Array<TypedExpr>):Array<Expr>
        {
            return [for (e in te) map(e)];
        }
        
        map = function(te:TypedExpr):Expr
        {
            if (te == null)
                return null;
            else
                typedExprByPos.set(te.pos.getInfos().min, te);
                
            return switch (te.expr)
            {
                case TConst(c):
                    EConst(c.const()).pos(te.pos);
                    
                case TLocal(v):
                    /*if (v.name == "__yield__")
                    {
                        trace("TLOCAL YIELD: " + v.t);
                    }*/
                    EConst(CIdent(id(v, te.pos))).pos(te.pos);
                    
                case TArray(e1, e2):
                    EArray(map(e1), map(e2)).pos(te.pos);
                    
                case TBinop(op, e1, e2):
                    EBinop(op, map(e1), map(e2)).pos(te.pos);
                    
                case TField(e, fa):
                    
                    switch (e.t)
                    {
                        case TEnum(_, _):
                            
                            switch (fa)
                            {
                                case FDynamic(name) if (name == "index"):
                                    return macro ${map(e)}.getIndex();
                                    
                                case _:
                            }
                            
                        case _:
                    }
                    
                    EField(map(e), switch(fa)
                    {
                        case FInstance(_, _, _.get() => { name: name }): name;
                        case FStatic(_, _.get() => { name: name }): name;
                        case FAnon(_.get() => { name: name }): name;
                        case FDynamic(name): name;
                        case FClosure(_, _.get() => { name: name }): name;
                        case FEnum(_, { name: name }): name;
                        case _: throw "Unexpected";
                    }).pos(te.pos);
                    
                case TTypeExpr(m):
                    switch(m)
                    {
                        case TClassDecl(_.get() => { pack: pack, name: name }): macro $p{pack.concat([name])};
                        case TEnumDecl(_.get() => { pack: pack, name: name }): macro $p{pack.concat([name])}; //macro $i{name};
                        case TTypeDecl(_.get() => { pack: pack, name: name }): macro $p{pack.concat([name])};
                        case TAbstract(_.get() => { pack: pack, name: name }): macro $p{pack.concat([name])};
                        case _: throw "Unexpected";
                    };
                    
                case TParenthesis(e):
                    EParenthesis(map(e)).pos(te.pos);
                    
                case TObjectDecl(fields):
                    EObjectDecl([for (f in fields) { field: f.name, expr: map(f.expr) }]).pos(te.pos);
                    
                case TArrayDecl(el):
                    EArrayDecl(mapa(el)).pos(te.pos);
                    
                case TCall(e, el):
                    ECall(map(e), mapa(el)).pos(te.pos);
                    
                case TNew(_.get() => cls, params, el):
                    var typeParam = [for (t in params) TPType(t.toComplexType())];
                    ENew({ pack: cls.pack, name: cls.name, params: typeParam }, mapa(el)).pos(te.pos);
                    
                case TUnop(op, postFix, e):
                    EUnop(op, postFix, map(e)).pos(te.pos);
                    
                case TFunction(fn): // [TVar,TConstant], Type, TypedExpr
                    EFunction(null, {
                        args: [for (a in fn.args)
                                a.value == null ?
                                    { name: id(a.v, te.pos), type: a.v.t.toComplexType() }:
                                    { name: id(a.v, te.pos), type: a.v.t.toComplexType(), opt: true, value: EConst(a.value.const()).pos(te.pos) }],
                        ret: fn.t.toComplexType(),
                        expr: map(fn.expr),
                        // params?
                    }).pos(te.pos);
                    
                case TVar(v, e):
                    identifiers.set(v.id, v);
                    EVars([{ name: id(v, te.pos), type: v.t.toComplexType(), expr: map(e) }]).pos(te.pos);
                    
                case TBlock(el):
                    EBlock(mapa(el)).pos(te.pos);
                    
                case TFor(v, e1, e2):
                    identifiers.set(v.id, v);
                    EFor(EIn(EConst(CIdent(id(v, te.pos))).pos(e1.pos), map(e1)).pos(e1.pos), map(e2)).pos(te.pos);
                    
                case TIf(ec, et, ef):
                    EIf(map(ec), map(et), map(ef)).pos(te.pos);
                    
                case TWhile(ec, e, normal):
                    EWhile(map(ec), map(e), normal).pos(te.pos);
                    
                case TSwitch(e, cases, def):
                    var expr = map(e);
                    var etype = te.t;
                    
                    /*switch (te.t)
                    {
                        case TMono(_.get() => x):
                            trace("TSWITCH MONO " + x);
                            
                        case _:
                            trace("TSWITCH " + etype);
                    }*/
                    
                    //expr = macro @t((null:$etype)) $expr;
                    
                    ESwitch(expr, [for (c in cases) { values: mapa(c.values), expr: map(c.expr) }], map(def)).pos(te.pos);
                    
                case TTry(e, catches):
                    ETry(map(e), [for (c in catches)
                    {
                        identifiers.set(c.v.id, c.v);
                        { name: id(c.v, te.pos), type: c.v.t.toComplexType(), expr: map(c.expr) }
                        
                    }]).pos(te.pos);
                    
                case TReturn(e):
                    EReturn(map(e)).pos(te.pos);
                    
                case TBreak:
                    EBreak.pos(te.pos);
                    
                case TContinue:
                    EContinue.pos(te.pos);
                    
                case TThrow(e):
                    EThrow(map(e)).pos(te.pos);
                    
                case TCast(e, m):
                    m == null ?
                        ECast(map(e), null).pos(te.pos):
                        ECast(map(e), m.toComplexType()).pos(te.pos);
                        
                case TMeta(m, e):
                    EMeta(m, map(e)).pos(te.pos);
                        
                case TEnumParameter(e1, ef, index):
                    var e = map(e1);
                    macro $e.getParameters()[$v{index}];
                    
                case _:
                    throw "oops";
            }
        }
        
        var info = new TypedExprInfo();
        info.typedExprByPos = typedExprByPos;
        info.identifiers = identifiers;
        info.vars = vars;
        info.names = names;
        info.expr = map(te);
        info.typedExpr = te;
        return info;
    }
    
}


class TypedExprInfo
{
    public var typedExprByPos:Map<Int, TypedExpr>;
    
    public var identifiers:Map<Int, TVar>;
    public var vars:Map<Int, Var>;
    public var names:Map<Int, String>;
    public var expr:Expr;
    public var typedExpr:TypedExpr;
    
    public function new()
    {
    }
}