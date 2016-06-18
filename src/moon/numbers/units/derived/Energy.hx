package moon.numbers.units.derived;

/**
 * energy = force * length
 * energy = voltage * charge    // E = VQ
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Energy, "", "J"))
abstract Energy(Float)
{
    public static inline var ENERGY:Float               = 1.0;
    public static inline var TORQUE:Float               = 1.0;
    
    public static inline var NEWTON_METER:Float         = 1.0;
    public static inline var JOULE:Float                = 1.0;
    public static inline var KILOJOULE:Float            = 1000.0;
    
    public static inline var WATT_SECOND:Float          = 1.0;
    public static inline var WATT_HOUR:Float            = 3600.0;
    public static inline var KILOWATT_HOUR:Float        = 1000.0 * 3600.0;
    
    public static inline var CALORIE:Float              = 4.1858;
    public static inline var KILOCALORIE:Float          = 4185.8;
}

@:build(moon.macros.units.UnitsMacro.build(Energy, "", "Nm"))
abstract NewtonMeter(Float){}

@:build(moon.macros.units.UnitsMacro.build(Energy, "", "Nm"))
abstract Torque(Float){}

@:build(moon.macros.units.UnitsMacro.build(Energy, "", "J"))
abstract Joule(Float){}

@:build(moon.macros.units.UnitsMacro.build(Energy, "", "KJ"))
abstract Kilojoule(Float){}

@:build(moon.macros.units.UnitsMacro.build(Energy, "", "Wh"))
abstract WattHour(Float){}

@:build(moon.macros.units.UnitsMacro.build(Energy, "", "KWh"))
abstract KilowattHour(Float){}

@:build(moon.macros.units.UnitsMacro.build(Energy, "", "cal"))
abstract Calorie(Float){}

@:build(moon.macros.units.UnitsMacro.build(Energy, "", "Kcal"))
abstract Kilocalorie(Float){}