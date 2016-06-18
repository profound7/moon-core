package moon.numbers.units.derived;

/**
 * momentum = mass * velocity
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Momentum, "", "Ns"))
abstract Momentum(Float)
{
    public static inline var MOMENTUM:Float                     = 1.0;
    public static inline var IMPULSE:Float                      = 1.0;
}