package moon.numbers.units.derived;

/**
 * pressure = force / area
 * N/m^2
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Pressure, "", "Pa"))
abstract Pressure(Float)
{
    public static inline var PRESSURE:Float                     = 1.0;
    
    public static inline var PASCAL:Float                       = 1.0;
    public static inline var ATMOSPHERE:Float                   = 101325.0;
    public static inline var ATMOSPHERE:Float                   = 100000.0;
    public static inline var TORR:Float                         = 133.322;
    public static inline var POUND_FORCE_PER_SQUARE_INCH:Float  = 0.45359237 * 9.80665 / (0.0254 * 0.0254);
}