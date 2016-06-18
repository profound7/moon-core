package moon.numbers.units.derived;

/**
 * force = mass * acceleration
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Force, "", "N"))
abstract Force(Float)
{
    public static inline var FORCE:Float                = 1.0;
    
    // kg * m/s^2                                          kg    m       s^2
    public static inline var NEWTON:Float               = (1.0 * 1.0) / (1.0 * 1.0);
    
    // g * cm/s^2                                          g       cm       s^2
    public static inline var DYNE:Float                 = (0.001 * 0.01) / (1.0 * 1.0);
    
    // lb * ft/s^2                                         lb           ft              s^2
    public static inline var POUNDAL:Float              = (0.45359237 * 0.0254 * 12) / (1.0 * 1.0);
    
    // kilogram-force, a kilogram of mass in earth's gravity (weight)
    public static inline var KILOGRAM_FORCE:Float       = 9.80665;
    public static inline var POUND_FORCE:Float          = 0.45359237 * 9.80665;
}

@:build(moon.macros.units.UnitsMacro.build(Force, "", "N"))
abstract Newton(Float){}

@:build(moon.macros.units.UnitsMacro.build(Force, "", "dyn"))
abstract Dyne(Float){}

@:build(moon.macros.units.UnitsMacro.build(Force, "", "pdl"))
abstract Poundal(Float){}

@:build(moon.macros.units.UnitsMacro.build(Force, "", "kp"))
abstract KilogramForce(Float){}

@:build(moon.macros.units.UnitsMacro.build(Force, "", "lbf"))
abstract PoundForce(Float){}