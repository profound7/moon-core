package moon.numbers.units.electric;

/**
 * resistance = voltage / current
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Resistance, "", "ohm"))
abstract Resistance(Float)
{
    public static inline var RESISTANCE:Float                   = 1.0;
    
    public static inline var OHM:Float                          = 1.0;
}

@:build(moon.macros.units.UnitsMacro.build(Current, "", "ohm"))
abstract Ohm(Float){}