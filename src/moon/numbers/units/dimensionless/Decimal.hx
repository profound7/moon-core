package moon.numbers.units.derived;

/**
 * ...
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Decimal, "", ""))
abstract Decimal(Float)
{
    public static inline var DECIMAL:Float          = 1.0;
    
    public static inline var QUINTILLIONTH:Float    = 0.000000000000000001;
    public static inline var QUADRILLIONTH:Float    = 0.000000000000001;
    public static inline var TRILLIONTH:Float       = 0.000000000001;
    public static inline var BILLIONTH:Float        = 0.000000001;
    public static inline var MILLIONTH:Float        = 0.000001;
    public static inline var THOUSANDTH:Float       = 0.001;
    public static inline var HUNDREDTH:Float        = 0.01;
    public static inline var TENTH:Float            = 0.1;
    public static inline var ONE:Float              = 1.0;
    public static inline var TEN:Float              = 10.0;
    public static inline var HUNDRED:Float          = 100.0;
    public static inline var THOUSAND:Float         = 1000.0;
    public static inline var MILLION:Float          = 1000000.0;
    public static inline var BILLION:Float          = 1000000000.0;
    public static inline var TRILLION:Float         = 1000000000000.0;
    public static inline var QUADRILLION:Float      = 1000000000000000.0;
    public static inline var QUINTILLION:Float      = 1000000000000000000.0;
}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", "a"))
abstract Quintillionth(Float){}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", "f"))
abstract Quadrillionth(Float){}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", "p"))
abstract Trillionth(Float){}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", "n"))
abstract Billionth(Float){}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", "u"))
abstract Millionth(Float){}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", "m"))
abstract Thousandth(Float){}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", "c"))
abstract Hundredth(Float){}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", "d"))
abstract Tenth(Float){}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", ""))
abstract One(Float){}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", "dk"))
abstract Ten(Float){}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", "h"))
abstract Hundred(Float){}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", "k"))
abstract Thousand(Float){}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", "M"))
abstract Million(Float){}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", "G"))
abstract Billion(Float){}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", "T"))
abstract Trillion(Float){}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", "P"))
abstract Quadrillion(Float){}

@:build(moon.macros.units.UnitsMacro.build(Decimal, "", "E"))
abstract Quintillion(Float){}