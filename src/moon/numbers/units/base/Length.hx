package moon.numbers.units.base;

/**
 * 
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Length, "", "m"))
abstract Length(Float)
{
    public static inline var LENGTH:Float           = 1.0;
    
    public static inline var MILLIMETER:Float       = 0.001;
    public static inline var CENTIMETER:Float       = 0.01;
    public static inline var METER:Float            = 1.0;
    public static inline var KILOMETER:Float        = 1000.0;
    public static inline var NAUTICAL_MILE:Float    = 1852.0;
    
    public static inline var INCH:Float             = 0.0254;
    public static inline var FOOT:Float             = 0.0254 * 12;
    public static inline var YARD:Float             = 0.0254 * 36;
    public static inline var MILE:Float             = 0.0254 * 63360;
}

@:build(moon.macros.units.UnitsMacro.build(Length, "", "m"))
abstract Meter(Float){}

@:build(moon.macros.units.UnitsMacro.build(Length, "", "mm"))
abstract Millimeter(Float){}

@:build(moon.macros.units.UnitsMacro.build(Length, "", "cm"))
abstract Centimeter(Float){}

@:build(moon.macros.units.UnitsMacro.build(Length, "", "km"))
abstract Kilometer(Float){}

@:build(moon.macros.units.UnitsMacro.build(Length, "", "nmi"))
abstract NauticalMile(Float){}

@:build(moon.macros.units.UnitsMacro.build(Length, "", "in"))
abstract Inch(Float){}

@:build(moon.macros.units.UnitsMacro.build(Length, "", "ft"))
abstract Foot(Float){}

@:build(moon.macros.units.UnitsMacro.build(Length, "", "yd"))
abstract Yard(Float){}

@:build(moon.macros.units.UnitsMacro.build(Length, "", "mi"))
abstract Mile(Float){}
