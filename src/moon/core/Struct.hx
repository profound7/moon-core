package moon.core;

private typedef StructType = { };

/**
 * Abstract for Anonymous Objects, kinda like DynamicAccess<T>
 * @author Munir Hussin
 */
abstract Struct(StructType) to StructType from StructType
{
    public var length(get, never):Int;
    
    /*==================================================
        Constructors
    ==================================================*/
    
    public function new()
    {
        this = {};
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private inline function get_length():Int
    {
        return fields().length;
    }
    
    /*==================================================
        Base Methods
    ==================================================*/
    
    @:arrayAccess public inline function get(key:String):Null<Dynamic>
    {
        return Reflect.field(this, key);
    }
    
    @:arrayAccess public inline function set(key:String, value:Dynamic):Dynamic
    {
        Reflect.setField(this, key, value);
        return value;
    }
    
    public inline function remove(key:String):Bool
    {
        return Reflect.deleteField(this, key);
    }
    
    public inline function exists(key:String):Bool
    {
        return Reflect.hasField(this, key);
    }
    
    public function contains(value:Dynamic):Bool
    {
        for (f in fields())
            if (get(f) == value)
                return true;
        return false;
    }
    
    public inline function iterator():Iterator<Dynamic>
    {
        return new StructIterator(this);
    }
    
    public inline function fields():Array<String>
    {
        return Reflect.fields(this);
    }
    
    public inline function keys():Iterator<String>
    {
        return fields().iterator();
    }
    
    public inline function values():Iterator<Dynamic>
    {
        return iterator();
    }
    
    public inline function pairs():Iterator<Pair<String, Dynamic>>
    {
        return new StructPairIterator(this);
    }
    
    /**
     * Clones an object
     */
    public inline function clone():Struct
    {
        var obj:Struct = new Struct();
        copy(this, obj);
        return obj;
    }
    
    /*==================================================
        Static methods
    ==================================================*/
    
    /*
     * var base:Struct = {};
     * 
     * // class Animal extends Base
     * var animal:Struct = Struct.create(base,
     * {
     *     name: "unknown",
     *     age: 0.0,
     * });
     * 
     * // class Cat extends Animal
     * var cat:Struct = Struct.create(animal,
     * {
     *     weight: 0.0,
     *     height: 0.0,
     * });
     * 
     * // tom = new Cat();
     * var tom:Struct = Struct.create(cat
     * {
     *     name: "Tom",
     *     weight: 1.5,
     * });
     */
    public static inline function create(base:Struct, ?values:Struct):Struct
    {
        var obj = new Struct();
        copy(base, obj);
        if (values != null) copy(values, obj);
        return obj;
    }
    
    /*
     * Similar to create, but with type checks, and suitable for using
     * struct to initialize a struct with optional values.
     * 
     * var a:MyOptions = { blah: "haha", weight: 1.0 };
     * 
     * public static function init(o:MyOptions):Void
     * {
     *     var opt:MyOptions = Struct.options(o,
     *     {
     *         // default values of MyOptions
     *         enabled: true,
     *         blah: "yo",
     *         weight: 0.0,
     *     });
     *     
     *     trace(opt);
     * }
     */
    public static inline function options<P:Struct>(?given:P, defaults:P):P
    {
        var obj = new Struct();
        copy(defaults, obj);
        if (given != null) copy(given, obj);
        return cast obj;
    }
    
    /**
     * Merges an array of objects into a single object
     */
    public static inline function merge(?base:Struct, objs:Array<Struct>):Struct
    {
        var obj = base == null ? new Struct() : base;
        for (o in objs)
            copy(o, obj);
        return obj;
    }
    
    
    /*
     * Copies values of specified keys from src to dest.
     * 
     * If strict is true, then dest also requires the key to exist.
     */
    public static inline function copyByKeys(src:Struct, dest:Struct, keys:Array<String>, strict:Bool=false):Void
    {
        for (k in keys)
            if (!src.exists(k))
                throw 'Argument src does not have key $k';
            else if (strict && !dest.exists(k))
                throw 'Argument dest does not have key $k';
            else
                dest[k] = src[k];
    }
    
    /*
     * Copies values from src to dest
     */
    public static inline function copy(src:Struct, dest:Struct):Void
    {
        for (k in src.fields())
            dest[k] = src[k];
    }
    
    
    private static function containsKeysHelper(obj:Struct, keys:Array<String>):Bool
    {
        for (k in keys)
            if (!obj.exists(k)) return false;
        return true;
    }
    
    /**
     * Checks if all keys in cls exists in this object
     */
    public static inline function instanceOf(obj:Struct, cls:Struct):Bool
    {
        return containsKeys(cls, obj);
    }
    
    /*
     * Returns true if all keys in A can be found in B
     */
    public static inline function containsKeys(a:Struct, b:Struct):Bool
    {
        return containsKeysHelper(b, a.fields());
    }
    
    /*
     * Returns true if all keys in A can be found in B and
     * all keys in B can be found in A
     */
    public static function exactKeys(a:Struct, b:Struct):Bool
    {
        var fields:Array<String> = a.fields();
        if (fields.length != b.fields().length)
            return false;
        return containsKeysHelper(b, fields);
    }
}


class StructIterator
{
    public var struct:Struct;
    public var it:Iterator<String>;
    
    public inline function new(struct:Struct)
    {
        this.struct = struct;
        this.it = struct.fields().iterator();
    }
    
    public inline function next():Dynamic
    {
        return struct.get(it.next());
    }
    
    public inline function hasNext():Bool
    {
        return it.hasNext();
    }
}

class StructPairIterator
{
    public var struct:Struct;
    public var it:Iterator<String>;
    
    public inline function new(struct:Struct)
    {
        this.struct = struct;
        this.it = struct.fields().iterator();
    }
    
    public inline function next():Pair<String, Dynamic>
    {
        var k = it.next();
        return Pair.of(k, struct.get(k));
    }
    
    public inline function hasNext():Bool
    {
        return it.hasNext();
    }
}
