package moon.numbers.units.derived;

/**
 * velocity = length / time
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Velocity, "", "m/s"))
abstract Velocity(Float)
{
    public static inline var SPEED:Float                = 1.0;
    
    public static inline var METERS_PER_SECOND:Float    = 1.0 / 1.0;
    public static inline var KILOMETERS_PER_HOUR:Float  = 1000.0 / 3600.0;
    
    public static inline var FEET_PER_SECOND:Float      = 0.0254 * 12 / 1.0;
    public static inline var MILES_PER_HOUR:Float       = 0.0254 * 63360 / 3600.0;
    
    public static inline var KNOT:Float                 = 1852.0 / 3600.0;
}

@:build(moon.macros.units.UnitsMacro.build(Velocity, "", "m/s"))
abstract MetersPerSecond(Float){}

@:build(moon.macros.units.UnitsMacro.build(Velocity, "", "km/h"))
abstract KilometersPerHour(Float){}

@:build(moon.macros.units.UnitsMacro.build(Velocity, "", "ft/s"))
abstract FeetPerSecond(Float){}

@:build(moon.macros.units.UnitsMacro.build(Velocity, "", "mi/h"))
abstract MilesPerHour(Float){}

@:build(moon.macros.units.UnitsMacro.build(Velocity, "", "kn"))
abstract Knot(Float){}
