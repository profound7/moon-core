package moon.numbers.units.derived;

/**
 * density = mass / volume
 * kg/m^3
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Density, "", "kg/m^3"))
abstract Density(Float)
{
    public static inline var DENSITY:Float                      = 1.0;
}