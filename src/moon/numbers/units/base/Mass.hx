package moon.numbers.units.base;

/**
 * ...
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Mass, "", "kg"))
abstract Mass(Float)
{
    public static inline var MASS:Float         = 1.0;
    
    public static inline var MICROGRAM:Float    = 0.000000001;
    public static inline var MILLIGRAM:Float    = 0.000001;
    public static inline var GRAM:Float         = 0.001;
    public static inline var KILOGRAM:Float     = 1.0;
    public static inline var METRIC_TON:Float   = 1000.0;
    
    public static inline var OUNCE:Float        = 0.45359237 / 16.0;
    public static inline var POUND:Float        = 0.45359237; // exact legal definition
    public static inline var STONE:Float        = 0.45359237 * 14.0;
    public static inline var SHORT_TON:Float    = 0.45359237 * 2000.0;
    public static inline var LONG_TON:Float     = 0.45359237 * 2240.0;
    
}

@:build(moon.macros.units.UnitsMacro.build(Mass, "", "ug"))
abstract Microgram(Float){}

@:build(moon.macros.units.UnitsMacro.build(Mass, "", "mg"))
abstract Milligram(Float){}

@:build(moon.macros.units.UnitsMacro.build(Mass, "", "g"))
abstract Gram(Float){}

@:build(moon.macros.units.UnitsMacro.build(Mass, "", "kg"))
abstract Kilogram(Float){}

@:build(moon.macros.units.UnitsMacro.build(Mass, "", " metric tons"))
abstract MetricTon(Float){}

@:build(moon.macros.units.UnitsMacro.build(Mass, "", "oz"))
abstract Ounce(Float){}

@:build(moon.macros.units.UnitsMacro.build(Mass, "", "lb"))
abstract Pound(Float){}

@:build(moon.macros.units.UnitsMacro.build(Mass, "", "st"))
abstract Stone(Float){}

@:build(moon.macros.units.UnitsMacro.build(Mass, "", " short tons"))
abstract ShortTon(Float){}

@:build(moon.macros.units.UnitsMacro.build(Mass, "", " long tons"))
abstract LongTon(Float){}
