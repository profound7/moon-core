package moon.numbers.units.derived;

/**
 * area = length * length
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Acceleration, "", "m^2"))
abstract Area(Float)
{
    public static inline var AREA:Float                         = 1.0;
    
    public static inline var METER_SQUARED:Float                = 1.0;
    public static inline var KILOMETERS_SQUARED:Float           = 1000.0 * 1000.0;
    
    public static inline var CENTIARE:Float                     = 1.0; // ca
    public static inline var ARE:Float                          = 100.0; // a
    public static inline var DECARE:Float                       = 1000.0;  // daa
    public static inline var HECTARE:Float                      = 10000.0; // ha
    
    
    
    public static inline var INCH_SQUARED:Float                 = 0.0254 * 0.0254;
    public static inline var FOOT_SQUARED:Float                 = (0.0254 * 12) * (0.0254 * 12);
    public static inline var YARD_SQUARED:Float                 = (0.0254 * 36) * (0.0254 * 36);
    public static inline var MILE_SQUARED:Float                 = (0.0254 * 63360) * (0.0254 * 63360);
    
    public static inline var ACRE:Float                         = MILE_SQUARED / 640.0; // ac
}