package moon.numbers.units.electric;

/**
 * voltage = current * resistance
 * voltage = energy / charge
 *         = force * length / charge
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Voltage, "", "V"))
abstract Voltage(Float)
{
    public static inline var VOLTAGE:Float                      = 1.0;
    
    public static inline var MILLIVOLT:Float                    = 0.001;
    public static inline var VOLT:Float                         = 1.0;
}

@:build(moon.macros.units.UnitsMacro.build(Voltage, "", "mV"))
abstract Millivolt(Float){}

@:build(moon.macros.units.UnitsMacro.build(Voltage, "", "V"))
abstract Volt(Float){}