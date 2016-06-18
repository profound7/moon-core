package moon.numbers.units.electric;

/**
 * current = voltage / resistance
 * current = charge / time
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Current, "", "A"))
abstract Current(Float)
{
    public static inline var CURRENT:Float                      = 1.0;
    
    public static inline var MILLIAMPERE:Float                  = 0.001;
    public static inline var AMPERE:Float                       = 1.0;
}

@:build(moon.macros.units.UnitsMacro.build(Current, "", "mA"))
abstract MilliAmpere(Float){}

@:build(moon.macros.units.UnitsMacro.build(Current, "", "A"))
abstract Ampere(Float){}