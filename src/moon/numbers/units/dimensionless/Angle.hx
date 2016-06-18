package moon.numbers.units;

/**
 *  DIRx use case:
 *      player can move in any angle, but sprite must be one of 8 images
 *           
 *      example:
 *          var d:Dir8 = player.angle;
 *          var i:Int = d % 8; // todo: d.snap();
 *          player.sprite = images[i];
 * 
 * @author Munir Hussin
 */
@:dimension() // dimensionless
@:build(moon.macros.units.UnitsMacro.build(Angle, "", " rad"))
abstract Angle(Float)
{
    public static inline var ANGLE:Float    = 1.0 / (2.0 * 3.141592653589793238);
    
    public static inline var TURN:Float     = 1.0;
    public static inline var DEGREE:Float   = 1.0 / 360.0;
    public static inline var RADIAN:Float   = 1.0 / (2.0 * 3.141592653589793238);
    public static inline var GRADIAN:Float  = 1.0 / 400.0;
    
    public static inline var DIR256:Float   = 1.0 / 256.0;  // fits a byte
    public static inline var DIR128:Float   = 1.0 / 128.0;
    public static inline var DIR64:Float    = 1.0 / 64.0;
    public static inline var DIR32:Float    = 1.0 / 32.0;
    public static inline var DIR16:Float    = 1.0 / 16.0;
    public static inline var DIR8:Float     = 1.0 / 8.0;    // 8 directions
    public static inline var DIR4:Float     = 1.0 / 4.0;
    public static inline var DIR2:Float     = 1.0 / 2.0;
}

@:build(moon.macros.units.UnitsMacro.build(Angle, "", " turns"))
abstract Turn(Float){}

@:build(moon.macros.units.UnitsMacro.build(Angle, "", " deg"))
abstract Degree(Float){}

@:build(moon.macros.units.UnitsMacro.build(Angle, "", " rad"))
abstract Radian(Float){}

@:build(moon.macros.units.UnitsMacro.build(Angle, "", " grad"))
abstract Gradian(Float){}

@:build(moon.macros.units.UnitsMacro.build(Angle, "", " dir256"))
abstract Dir256(Float){}

@:build(moon.macros.units.UnitsMacro.build(Angle, "", " dir128"))
abstract Dir128(Float){}

@:build(moon.macros.units.UnitsMacro.build(Angle, "", " dir64"))
abstract Dir64(Float){}

@:build(moon.macros.units.UnitsMacro.build(Angle, "", " dir32"))
abstract Dir32(Float){}

@:build(moon.macros.units.UnitsMacro.build(Angle, "", " dir16"))
abstract Dir16(Float){}

@:build(moon.macros.units.UnitsMacro.build(Angle, "", " dir8"))
abstract Dir8(Float){}

@:build(moon.macros.units.UnitsMacro.build(Angle, "", " dir4"))
abstract Dir4(Float){}

@:build(moon.macros.units.UnitsMacro.build(Angle, "", " dir2"))
abstract Dir2(Float){}