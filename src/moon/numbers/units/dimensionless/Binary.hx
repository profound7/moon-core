package moon.numbers.units.derived;

/**
 * ...
 * @author Munir Hussin
 */
@:build(moon.macros.units.UnitsMacro.build(Binary, "", "b"))
abstract Binary(Float)
{
    public static inline var BINARY:Float           = 1.0;
    
    
    public static inline var BYTE:Float             = 1.0;
    
    public static inline var KILOBYTE:Float         = 1000.0;
    public static inline var MEGABYTE:Float         = KILOBYTE * KILOBYTE;
    public static inline var GIGABYTE:Float         = MEGABYTE * KILOBYTE;
    public static inline var TERABYTE:Float         = GIGABYTE * KILOBYTE;
    public static inline var PETABYTE:Float         = TERABYTE * KILOBYTE;
    public static inline var EXABYTE:Float          = PETABYTE * KILOBYTE;
    public static inline var ZETTABYTE:Float        = EXABYTE * KILOBYTE;
    public static inline var YOTTABYTE:Float        = ZETTABYTE * KILOBYTE;
    
    public static inline var KIBIBYTE:Float         = 1024.0;
    public static inline var MEBIBYTE:Float         = KIBIBYTE * KIBIBYTE;
    public static inline var GIBIBYTE:Float         = MEBIBYTE * KIBIBYTE;
    public static inline var TEBIBYTE:Float         = GIBIBYTE * KIBIBYTE;
    public static inline var PEBIBYTE:Float         = TEBIBYTE * KIBIBYTE;
    public static inline var EXBIBYTE:Float         = PEBIBYTE * KIBIBYTE;
    public static inline var ZEBIBYTE:Float         = EXBIBYTE * KIBIBYTE;
    public static inline var YOBIBYTE:Float         = ZEBIBYTE * KIBIBYTE;
    
    
    public static inline var BIT:Float              = 0.125;
    
    public static inline var KILOBIT:Float          = BIT * KILOBYTE;
    public static inline var MEGABIT:Float          = KILOBIT * KILOBYTE;
    public static inline var GIGABIT:Float          = MEGABIT * KILOBYTE;
    public static inline var TERABIT:Float          = GIGABIT * KILOBYTE;
    public static inline var PETABIT:Float          = TERABIT * KILOBYTE;
    public static inline var EXABIT:Float           = PETABIT * KILOBYTE;
    public static inline var ZETTABIT:Float         = EXABIT * KILOBYTE;
    public static inline var YOTTABIT:Float         = ZETTABIT * KILOBYTE;
    
    public static inline var KIBIBIT:Float          = BIT * KIBIBYTE;
    public static inline var MEBIBIT:Float          = KIBIBIT * KIBIBYTE;
    public static inline var GIBIBIT:Float          = MEBIBIT * KIBIBYTE;
    public static inline var TEBIBIT:Float          = GIBIBIT * KIBIBYTE;
    public static inline var PEBIBIT:Float          = TEBIBIT * KIBIBYTE;
    public static inline var EXBIBIT:Float          = PEBIBIT * KIBIBYTE;
    public static inline var ZEBIBIT:Float          = EXBIBIT * KIBIBYTE;
    public static inline var YOBIBIT:Float          = ZEBIBIT * KIBIBYTE;
    
    
    
    
}




@:build(moon.macros.units.UnitsMacro.build(Binary, "", "B"))
abstract Byte(Float){}




@:build(moon.macros.units.UnitsMacro.build(Binary, "", "kB"))
abstract Kilobyte(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "MB"))
abstract Megabyte(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "GB"))
abstract Gigabyte(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "TB"))
abstract Terabyte(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "PB"))
abstract Petabyte(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "EB"))
abstract Exabyte(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "ZB"))
abstract Zettabyte(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "YB"))
abstract Yottabyte(Float){}




@:build(moon.macros.units.UnitsMacro.build(Binary, "", "kiB"))
abstract Kibibyte(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "MiB"))
abstract Mebibyte(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "GiB"))
abstract Gibibyte(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "TiB"))
abstract Tebibyte(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "PiB"))
abstract Pebibyte(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "EiB"))
abstract Exbibyte(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "ZiB"))
abstract Zebibyte(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "YiB"))
abstract Yobibyte(Float){}




@:build(moon.macros.units.UnitsMacro.build(Binary, "", "b"))
abstract Bit(Float){}




@:build(moon.macros.units.UnitsMacro.build(Binary, "", "kb"))
abstract Kilobit(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "Mb"))
abstract Megabit(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "Gb"))
abstract Gigabit(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "Tb"))
abstract Terabit(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "Pb"))
abstract Petabit(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "Eb"))
abstract Exabit(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "Zb"))
abstract Zettabit(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "Yb"))
abstract Yottabit(Float){}




@:build(moon.macros.units.UnitsMacro.build(Binary, "", "kib"))
abstract Kibibit(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "Mib"))
abstract Mebibit(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "Gib"))
abstract Gibibit(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "Tib"))
abstract Tebibit(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "Pib"))
abstract Pebibit(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "Eib"))
abstract Exbibit(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "Zib"))
abstract Zebibit(Float){}

@:build(moon.macros.units.UnitsMacro.build(Binary, "", "Yib"))
abstract Yobibit(Float){}