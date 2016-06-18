package moon.numbers.units.derived;

/**
 * ...
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Metric, "", " units"))
abstract Metric(Float)
{
    public static inline var METRIC:Float           = 1.0;
    
    public static inline var YOCTO:Float            = 0.000000000000000000000001;
    public static inline var ZEPTO:Float            = 0.000000000000000000001;
    public static inline var ATTO:Float             = 0.000000000000000001;
    public static inline var FEMTO:Float            = 0.000000000000001;
    public static inline var PICO:Float             = 0.000000000001;
    public static inline var NANO:Float             = 0.000000001;
    public static inline var MICRO:Float            = 0.000001;
    public static inline var MILLI:Float            = 0.001;
    public static inline var CENTI:Float            = 0.01;
    public static inline var DECI:Float             = 0.1;
    public static inline var UNIT:Float             = 1.0;
    public static inline var DECA:Float             = 10.0;
    public static inline var HECTO:Float            = 100.0;
    public static inline var KILO:Float             = 1000.0;
    public static inline var MEGA:Float             = 1000000.0;
    public static inline var GIGA:Float             = 1000000000.0;
    public static inline var TERA:Float             = 1000000000000.0;
    public static inline var PETA:Float             = 1000000000000000.0;
    public static inline var EXA:Float              = 1000000000000000000.0;
    public static inline var ZETTA:Float            = 1000000000000000000000.0;
    public static inline var YOTTA:Float            = 1000000000000000000000000.0;
}


@:build(moon.macros.units.UnitsMacro.build(Metric, "", "y"))
abstract Yocto(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "z"))
abstract Zepto(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "a"))
abstract Atto(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "f"))
abstract Femto(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "p"))
abstract Pico(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "n"))
abstract Nano(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "u"))
abstract Micro(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "m"))
abstract Milli(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "c"))
abstract Centi(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "d"))
abstract Deci(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", " units"))
abstract Unit(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "da"))
abstract Deca(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "h"))
abstract Hecto(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "k"))
abstract Kilo(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "M"))
abstract Mega(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "G"))
abstract Giga(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "T"))
abstract Tera(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "P"))
abstract Peta(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "E"))
abstract Exa(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "Z"))
abstract Zetta(Float){}

@:build(moon.macros.units.UnitsMacro.build(Metric, "", "Y"))
abstract Yotta(Float){}