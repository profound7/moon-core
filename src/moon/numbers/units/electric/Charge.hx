package moon.numbers.units.electric;

/**
 * charge = current * time
 * charge = energy / voltage
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Charge, "", "Ah"))
abstract Charge(Float)
{
    public static inline var CHARGE:Float                       = 1.0;
    
    public static inline var COULOMB:Float                      = 1.0;
    public static inline var AMPERE_SECOND:Float                = 1.0;
    public static inline var AMPERE_HOUR:Float                  = 3600.0;
}

@:build(moon.macros.units.UnitsMacro.build(Charge, "", "C"))
abstract Coulomb(Float){}

@:build(moon.macros.units.UnitsMacro.build(Charge, "", "C"))
abstract AmpereSecond(Float){}

@:build(moon.macros.units.UnitsMacro.build(Charge, "", "Ah"))
abstract AmpereHour(Float){}