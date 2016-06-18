package moon.numbers.units.derived;

/**
 * power = energy / time            (joule per second)
 * power = voltage * current
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Power, "", "W"))
abstract Power(Float)
{
    public static inline var POWER:Float                = 1.0;
    
    // joules per second
    public static inline var MILLIWATT:Float            = 0.001;
    public static inline var WATT:Float                 = 1.0;
    public static inline var KILOWATT:Float             = 1000.0;
}

@:build(moon.macros.units.UnitsMacro.build(Power, "", "mW"))
abstract Milliwatt(Float){}

@:build(moon.macros.units.UnitsMacro.build(Power, "", "W"))
abstract Watt(Float){}

@:build(moon.macros.units.UnitsMacro.build(Power, "", "kW"))
abstract Kilowatt(Float){}