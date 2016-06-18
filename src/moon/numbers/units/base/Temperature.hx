package moon.numbers.units.base;

/**
 * celcius = kelvin - 273.15
 * farenheit = kelvin * (9/5) - 459.67
 * rankine = kelvin * (9/5)
 * 
 * 1k = 1c = (9/5)f = (9/5)r
 * 
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Temperature, "", "K"))
abstract Temperature(Float)
{
    public static inline var TEMPERATURE:Float                  = 1.0;
    public static inline var KELVIN:Float                       = 1.0;
}