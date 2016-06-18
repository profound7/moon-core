package moon.numbers.units.derived;

/**
 * volume = area * length
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Volume, "", "m^3"))
abstract Volume(Float)
{
    public static inline var VOLUME:Float                       = 1.0;
    
    public static inline var CUBIC_METER:Float                  = 1.0;
    public static inline var CUBIC_KILOMETER:Float              = 1000.0 * 1000.0;
    
    public static inline var LITER:Float                        = 0.001; // L
}