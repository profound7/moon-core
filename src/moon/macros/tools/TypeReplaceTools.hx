package moon.macros.tools;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

/**
 * This is probably buggy, but so far works as needed within MultiArray.
 * 
 * @author Munir Hussin
 */
class TypeReplaceTools
{
    
    /**
     * This replaces types found in field declarations.
     * This does not replace types found in expressions.
     */
    public static function replaceTypesInFields(fields:Array<Field>, fn:ComplexType->ComplexType)
    {
        for (field in fields) replaceTypesInField(field, fn);
    }
    
    public static function replaceTypesInField(field:Field, fn:ComplexType->ComplexType)
    {
        switch (field.kind)
        {
            case FVar(t, e):
                field.kind = FVar(replaceTypesInType(t, fn), e);
                
            case FFun(f):
                
                switch (f)
                {
                    case { args: args, ret: t, params: params }:
                        
                        f.ret = replaceTypesInType(t, fn);
                        
                        for (a in args)
                        {
                            a.type = replaceTypesInType(a.type, fn);
                        }
                            
                    case _:
                }
                
            case FProp(g, s, t, e):
                field.kind = FProp(g, s, replaceTypesInType(t, fn), e);
        }
    }
    
    public static function replaceTypesInType(ct:ComplexType, fn:ComplexType->ComplexType):ComplexType
    {
        if (ct == null) return null;
        
        switch (ct)
        {
            case TPath(p):
                
                replaceTypesInTypePath(p, fn);
                
            case TFunction(a, r):
                
                for (i in 0...a.length)
                {
                    a[i] = replaceTypesInType(a[i], fn);
                }
                
                ct = TFunction(a, replaceTypesInType(r, fn));
                
            case TAnonymous(f):
                
                replaceTypesInFields(f, fn);
                
            case TParent(t):
                
                ct = TParent(replaceTypesInType(t, fn));
                
            case TExtend(p, f):
                
                for (x in p) replaceTypesInTypePath(x, fn);
                replaceTypesInFields(f, fn);
                
            case TOptional(t):
                
                ct = TOptional(replaceTypesInType(t, fn));
        }
        
        return fn(ct);
    }
    
    public static function replaceTypesInTypePath(p:TypePath, fn:ComplexType->ComplexType):Void
    {
        if (p.params == null) return;
        
        for (i in 0...p.params.length)
        {
            switch (p.params[i])
            {
                case TPType(t):
                    
                    p.params[i] = TPType(replaceTypesInType(t, fn));
                    
                case _:
            }
        }
    }
    
}