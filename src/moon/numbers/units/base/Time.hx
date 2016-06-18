package moon.numbers.units.base;

/**
 * ...
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Time, "", "s"))
abstract Time(Float)
{
    public static inline var TIME:Float             = 1.0;
    
    public static inline var NANOSECOND:Float       = 1e-9;
    public static inline var MICROSECOND:Float      = 1e-6;
    public static inline var MILLISECOND:Float      = 0.001;
    public static inline var SECOND:Float           = 1.0;
    public static inline var MINUTE:Float           = 60.0;
    public static inline var HOUR:Float             = 3600.0;
    public static inline var DAY:Float              = 3600.0 * 24;
    public static inline var WEEK:Float             = 3600.0 * 24 * 7;
    public static inline var MONTH:Float            = 3600.0 * 24 * 365 / 12;
    public static inline var YEAR:Float             = 3600.0 * 24 * 365;
    public static inline var DECADE:Float           = 3600.0 * 24 * 365 * 10;
    public static inline var CENTURY:Float          = 3600.0 * 24 * 365 * 100;
}

@:build(moon.macros.units.UnitsMacro.build(Time, "", "ns"))
abstract Nanosecond(Float){}

@:build(moon.macros.units.UnitsMacro.build(Time, "", "us"))
abstract Microsecond(Float){}

@:build(moon.macros.units.UnitsMacro.build(Time, "", "ms"))
abstract Millisecond(Float){}

@:build(moon.macros.units.UnitsMacro.build(Time, "", "s"))
abstract Second(Float){}

@:build(moon.macros.units.UnitsMacro.build(Time, "", "min"))
abstract Minute(Float){}

@:build(moon.macros.units.UnitsMacro.build(Time, "", "h"))
abstract Hour(Float){}

@:build(moon.macros.units.UnitsMacro.build(Time, "", " days"))
abstract Day(Float){}

@:build(moon.macros.units.UnitsMacro.build(Time, "", " weeks"))
abstract Week(Float){}

@:build(moon.macros.units.UnitsMacro.build(Time, "", " months"))
abstract Month(Float){}

@:build(moon.macros.units.UnitsMacro.build(Time, "", " years"))
abstract Year(Float){}

@:build(moon.macros.units.UnitsMacro.build(Time, "", " decades"))
abstract Decade(Float){}

@:build(moon.macros.units.UnitsMacro.build(Time, "", " centuries"))
abstract Century(Float){}