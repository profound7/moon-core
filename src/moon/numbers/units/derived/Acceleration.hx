package moon.numbers.units.derived;

/**
 * acceleration = velocity / time
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Acceleration, "", "m/s^2"))
abstract Acceleration(Float)
{
    public static inline var ACCELERATION:Float                 = 1.0;
    
    public static inline var METERS_PER_SECOND_SQUARED:Float    = 1.0 / (1.0 * 1.0);
    public static inline var KILOMETERS_PER_HOUR_SQUARED:Float  = 1000.0 / (3600.0 * 3600.0);
    
    public static inline var FEET_PER_SECOND_SQUARED:Float      = 0.0254 * 12 / (1.0 * 1.0);
    public static inline var MILES_PER_HOUR_SQUARED:Float       = 0.0254 * 63360 / (3600.0 * 3600.0);
    
    public static inline var KNOT_PER_HOUR:Float                = 1852.0 / (3600.0 * 3600.0);
}

@:build(moon.macros.units.UnitsMacro.build(Acceleration, "", "m/s^2"))
abstract MetersPerSecondSquared(Float){}

@:build(moon.macros.units.UnitsMacro.build(Acceleration, "", "km/h^2"))
abstract KilometersPerHour(Float){}

@:build(moon.macros.units.UnitsMacro.build(Acceleration, "", "ft/s^2"))
abstract FeetPerSecond(Float){}

@:build(moon.macros.units.UnitsMacro.build(Acceleration, "", "mi/h^2"))
abstract MilesPerHour(Float){}

@:build(moon.macros.units.UnitsMacro.build(Acceleration, "", "kn/h"))
abstract KnotPerHour(Float){}
