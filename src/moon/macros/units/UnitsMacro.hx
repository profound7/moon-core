package moon.macros.units;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import moon.strings.Inflect;

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;

/**
 * Base units:
 *      Length, Mass, Time, ElectricCurrent
 *      Temperature, Luminosity, Substance
 * 
 * Usage:
 *      // automatic type conversions
 *      var m:Meter = (5:Kilometer) + (3:Centimeter);
 * 
 * TODO: Dimensional Analysis
 *      
 *      base types are tagged with the meta @:dimension() for
 *      possible dimensional analysis.
 *      
 *      given the dimensions, generate all possible equations:
 *          ie. @:dimension(Mass * Length * Length, Time * Time) Energy
 *          generates:
 *              Energy = Force * Length
 *              Power = Energy / Time
 *              etc...
 *      
 *      for example, you can only compare, set, add, subtract from
 *      stuff with the same dimensions (commensurable quantities).
 *          Length + Length => Length
 *      
 *      To multiply or divide, they can be from different dimensions,
 *      or dimensionless (Float), and it'll result in a different
 *      dimension.
 *          Length * Length => Area
 *          Distance / Speed => Time
 *      
 *      If no dimension is defined as a result of multiplication or
 *      division (ie Length * Length * Length * Length), then
 *      a new dimension type is defined with the appropriate
 *      units inferred from existing units.
 *          
 *          // 120m^4, type is generated Length4
 *          trace( (2:Meter) * (3:Meter) * (4:Meter) * (5:Meter) );
 *          
 *          // 24m^3, type is existing Area
 *          trace( (2:Meter) * (3:Meter) * (4:Meter) );
 *          
 *          // 120m, type is Length
 *          trace( (2:Meter) * 3 * 4 * 5 );
 *      
 * @author Munir Hussin
 */
class UnitsMacro
{
    // @:build(moon.macros.units.UnitsMacro.build(Distance, "", "m"))
    
    public static macro function build(ref:Expr, prefix:String="", suffix:String=""):Array<Field>
    {
        //trace("units -------------");
        
        var pos = Context.currentPos();
        var fields:Array<Field> = Context.getBuildFields();
        
        // information regarding current type (the one we're building)
        var abstractType:AbstractType = getAbstractType(Context.getLocalClass().get());
        var pack:Array<String> = abstractType.module.split(".");
        var name:String = pack.pop();
        var self:String = abstractType.name;
        var selfPath:TypePath = { pack: pack, name: name, sub: self };
        var selfType:ComplexType = TPath(selfPath);
        
        // information regarding reference type (the type with float constants)
        var refClass:Type = getType(ref);               // TInst(..) | TAbstract(..)
        var refBase:BaseType = getBaseType(refClass);   // { name, module, pack... }
        var refPack:Array<String> = refBase.module.split(".");
        var refMod:String = refPack.pop();
        var refPath:TypePath = { pack: refPack, name: refMod, sub: refBase.name };
        var refType:ComplexType = TPath(refPath);
        
        // current type and reference type can be the same
        var isBaseType:Bool = selfType.toString() == refType.toString();
        var units:Map<String, Float> = isBaseType ? getOwnUnits() : getUnits(refClass);
        
        // fallback when no abstract defined for a constant
        var floatType:ComplexType = macro:StdTypes.Float;
        
        
        var ops:Array<Binop> = [OpAdd, OpSub, OpMult, OpDiv, OpMod];
        
        // operators (with own type)
        for (op in ops)
        {
            addBinOp(fields, selfType, selfType, op);
        }
        
        for (target in units.keys())
        {
            //if (self == target) continue;
            
            var factor:Float = convert(units, self, target);
            var targetType:ComplexType = TPath({ pack: pack, name: name, sub: target });
            var toSelf:String = 'to$self';
            
            var exist:Bool = typeExist(target);
            var isSameType:Bool = self == target;
            
            // every type has a conversion to every other type within the same measurement.
            //
            // alternative implementation is that only the base measurement type have a
            // conversion to and from the other types. this results in fewer generated
            // methods, but funneling everything through the base type will introduce
            // more rounding errors than direct conversions between types.
            //
            // i.e. converting Kilometer -> Centimeter directly has less rounding errors
            // than Kilometer -> Distance -> Centimeter
            
            addMethod(
                fields,
                'to$target',
                isSameType ? 'No conversion. Returns itself.' : 'Convert from $self to $target',
                [":to", ":impl"],
                [macro:Float],
                exist ? targetType : floatType,
                isSameType ? (macro return a0) : (macro return a0 * $v{factor})
            );
            
            // operators (with other types)
            if (!isSameType && exist) for (op in ops)
            {
                addBinOp(fields, selfType, targetType, op);
            }
        }
        
        // public function new()
        addMethod(fields, '_new', 'Create a new $self', [":impl"],
            [macro:Float], macro:Float, macro return a0);
        
        // @:from public static function of(a0:Float):Self
        addMethod(fields, 'of', 'Create a new $self value', [":from"],
            [macro:Float], selfType, macro return new $selfPath(a0));
        
        // @:to public function toFloat():Float
        addMethod(fields, 'toFloat', 'Float value of $self', [":to", ":impl"],
            [macro:Float], macro:Float, macro return a0);
        
        // @:to public function toString():String
        addMethod(fields, 'toString', 'String representation of $self', [":to", ":impl"],
            [macro:Float], macro:String, macro return $v{prefix} + a0 + $v{suffix});
        
        // public function getClass():Class<T>
        addMethod(fields, 'getMeasurementName', '${refBase.name}', [":impl"],
            [macro:Float], macro:String, macro return $v{refBase.name});
            
        addMethod(fields, 'getUnitName', '$self', [":impl"],
            [macro:Float], macro:String, macro return $v{self});
        
        return fields;
    }
    
    /**
     * Conversion from one unit to another, using a map of float constants
     */
    public static inline function convert(units:Map<String, Float>, base:String, target:String):Float
    {
        return units.get(base) / units.get(target);
    }
    
    public static inline function typeExist(name:String):Bool
    {
        return try { Context.getType(name); true; } catch (e:Dynamic) false;
    }
    
    public static function extractNameFromType(type:ComplexType):String
    {
        return switch (type)
        {
            case TPath({ sub: n }): n;
            case _: throw false;
        }
    }
    
    public static function addMethod(fields:Array<Field>, name:String, doc:String, meta:Array<String>,
        args:Array<ComplexType>, ret:ComplexType, expr:Expr)
    {
        var pos = Context.currentPos();
        
        fields.push(
        {
            name: name,
            doc: doc,
            access: [APublic, AStatic, AInline],
            kind: FFun(
            {
                args: [for (i in 0...args.length) { name: 'a$i', type: args[i] }],
                ret: ret,
                expr: expr,
            }),
            pos: pos,
            meta: [for (m in meta) { name: m, pos: pos }]
        });
    }
    
    /**
     * IDEA: possible reduction of rounding errors
     *   The return type is based on the binop you perform
     *      MEGA * KILO returns a GIGA
     *      GIGA / MEGA returns a KILO
     *   To do this, need to search the units map to find the closest factor
     */
    public static function addBinOp(fields:Array<Field>, selfType:ComplexType, targetType:ComplexType, op:Binop):Void
    {
        var pos = Context.currentPos();
        var self:String = extractNameFromType(selfType);
        var target:String = extractNameFromType(targetType);
        var toSelf:String = 'to$self';
        
        
        // same types:      (Meter, Meter)      => a.toFloat() + b.toFloat()
        // different types: (Meter, Kilometer)  => a.toFloat() + b.toMeter().toFloat()
        
        var binop:Expr =
        {
            expr: EBinop(op,
                macro a.toFloat(),
                selfType == targetType ? (macro b.toFloat()) : (macro b.$toSelf().toFloat())
            ),
            pos: pos
            
        };
        
        var metaop:Expr = { expr: EBinop(op, macro A, macro B), pos: pos };
        var opname:String = op.getName().substr(2).toLowerCase();
        
        fields.push(
        {
            name: '$opname$target', // addCentimeter, addMeter etc...
            access: [APrivate, AStatic, AInline],
            kind: FFun(
            {
                args: [{ name: 'a', type: selfType }, { name: 'b', type: targetType }],
                ret: selfType,
                expr: macro return $e{binop},
            }),
            pos: pos,
            meta: [{ name: ":op", pos: pos, params: [metaop] }]
        });
    }
    
    /**
     * getType(macro Distance) ==> TInst(..) or TAbstract(..)
     */
    public static function getType(id:Expr):Type
    {
        return switch (id.expr)
        {
            // extract reference className
            case EConst(CIdent(className)):
                Context.getType(className);
                
            case _:
                throw 'Unexpected expression: $id';
        }
    }
    
    public static function getBaseType(type:Type):BaseType
    {
        return switch (type)
        {
            // extract ClassType
            case TInst(_.get() => x, _):
                x;
                
            case TAbstract(_.get() => x, _):
                x;
                
            case e:
                throw 'Not a Class/Abstract. Got $e';
        }
    }
    
    
    public static function getAbstractType(ct:ClassType):AbstractType
    {
        return switch (ct.kind)
        {
            case KAbstractImpl(_.get() => a):
                a;
                
            case _:
                throw "Not an abstract type";
        }
    }
    
    
    /**
     * Extract the conversion factors from the class' static fields
     */
    public static function getUnits(type:Type):Map<String, Float>
    {
        var map = new Map<String, Float>();
        var pos = Context.currentPos();
        var fields:Array<ClassField> = switch (type)
        {
            case TInst(_.get() => x, _):
                x.statics.get();
                
            case TAbstract(_.get() => x, _):
                x.impl.get().statics.get();
                
            case _:
                throw 'Not a Class/Abstract. Got $type';
        }
        
        
        for (f in fields)
        {
            switch (f)
            {
                case { isPublic: true, kind: FVar(AccInline, AccNever) }:
                    
                    var name = Inflect.inflect(f.name, ScreamingSnakeCase, PascalCase);
                    
                    // calling f.expr() in display context breaks completion.
                    // so as a workaround, no need to extract the value
                    #if display
                        map.set(name, 1.0);
                    #else
                        switch (f.expr().expr)
                        {
                            case TConst(TFloat(v)):
                                map.set(name, Std.parseFloat(v));
                                
                            case _: // skip
                        }
                    #end
                    
                case _:
                    //trace(f.kind);
                    // ignore other fields
            }
        }
        
        return map;
    }
    
    /**
     * Like getUnits(), except that it uses own fields.
     * Used when constant values are within the class itself,
     * instead of from another class.
     */
    public static function getOwnUnits():Map<String, Float>
    {
        var map = new Map<String, Float>();
        var fields:Array<Field> = Context.getBuildFields();
        
        function replaceConst(e:Expr):Expr
        {
            return switch (e.expr)
            {
                case EConst(CIdent(id)):
                    
                    var name:String = Inflect.inflect(id, ScreamingSnakeCase, PascalCase);
                    
                    if (map.exists(name))
                        { expr: EConst(CFloat(Std.string(map.get(name)))), pos: e.pos };
                    else
                        throw 'Constant value $id not yet defined';
                    
                case _:
                    e.map(replaceConst);
            }
        }
        
        for (f in fields)
        {
            switch (f)
            {
                case { access: [AInline, AStatic, APublic], kind: FVar(type, expr) }:
                    
                    if (expr != null)
                    {
                        var name:String = Inflect.inflect(f.name, ScreamingSnakeCase, PascalCase);
                        var value:Float = replaceConst(expr).getValue();
                        
                        map.set(name, value);
                    }
                    
                case _:
                    // ignore
                    trace(f.access);
            }
        }
        
        return map;
    }
}