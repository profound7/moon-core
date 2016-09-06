package moon.data.pack;

#if macro
    import haxe.macro.Context;
    import haxe.macro.Expr;
#end


import haxe.io.FPHelper;
import moon.data.pack.PackType;
import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import Type;

/**
 * ...
 * @author Munir Hussin
 */
class Pack
{
    public var useCache:Bool;
    public var sortKeys:Bool;
    
    
    private var bytes:BytesOutput;
    
    // pointers into the bytes output
    private var stringCache:Map<String, Int>;
    private var objectCache:Map<{}, Int>;
    private var classCache:Map<String, Int>;
    
    
    public function new(useCache:Bool=false, sortKeys:Bool=false)
    {
        this.useCache = useCache;
        this.sortKeys = sortKeys;
        
        this.bytes = new BytesOutput();
        
        stringCache = new Map();
        objectCache = new Map();
        classCache = new Map();
    }
    
    
    private static macro function signedLo(b:Int):ExprOf<Int>
    {
        var e = Std.string(-(Math.pow(2, b - 1)));
        return { expr: EConst(CInt(e)), pos: Context.currentPos() };
    }
    
    private static macro function signedHi(b:Int):ExprOf<Int>
    {
        var e = Std.string(Math.pow(2, b - 1) - 1);
        return { expr: EConst(CInt(e)), pos: Context.currentPos() };
    }
    
    private static macro function unsignedHi(b:Int):ExprOf<Int>
    {
        var e = Std.string(Math.pow(2, b) - 1);
        return { expr: EConst(CInt(e)), pos: Context.currentPos() };
    }
    
    private static macro function unsignedCount(b:Int):ExprOf<Int>
    {
        var e = Std.string(Math.pow(2, b));
        return { expr: EConst(CInt(e)), pos: Context.currentPos() };
    }
    
    public function pack(v:Dynamic):Bytes
    {
        packAny(v);
        var b = bytes.getBytes();
        
        
        return b;
    }
    
    public function packAny(v:Dynamic)
    {
        switch (Type.typeof(v))
        {
            case TNull:
                bytes.writeByte(PNull);
                
            case TBool:
                packBool(v);
                
            case TInt:
                packInt(v);
            
            case TFloat:
                packFloat(v);
                
            case TObject:
                packObject(v);
                
            case TClass(c):
                
                switch (c)
                {
                    case String:
                        packString(v);
                        
                    case Array:
                        packArray(v);
                        
                    case Type.getClassName(_) => "haxe._Int64.___Int64":
                        packInt64(v);
                        
                    case _:
                        packInstance(v);
                }
                
            case t:
                throw 'Unexpected type: $t';
        }
    }
    
    public function packBool(v:Bool)
    {
        bytes.writeByte(v ? PTrue : PFalse);
    }
    
    public function packInt(v:Int)
    {
        if (v >= signedLo(8) && v <= signedHi(8))
        {
            bytes.writeByte(PInt8);
            bytes.writeByte(v);
        }
        else if (v >= signedLo(16) && v <= signedHi(16))
        {
            bytes.writeByte(PInt16);
            bytes.writeInt16(v);
        }
        else
        {
            bytes.writeByte(PInt32);
            bytes.writeInt32(v);
        }
    }
    
    public function packInt64(v:Int64)
    {
        bytes.writeByte(PInt64);
        bytes.writeInt32(v.high);
        bytes.writeInt32(v.low);
    }
    
    public function packFloat(v:Float)
    {
        // todo: decide if 32 or 64 bits
        //packFloat64(v);
        if (Math.isNaN(v))
        {
            bytes.writeByte(PFloatNaN);
        }
        else if (!Math.isFinite(v))
        {
            bytes.writeByte(v < 0 ? PFloatNegInf : PFloatPosInf);
        }
        else if (FPHelper.i32ToFloat(FPHelper.floatToI32(v)) == v)
        {
            //trace('$v is float32');
            packFloat32(v);
        }
        else
        {
            //trace('$v is float64');
            packFloat64(v);
        }
    }
    
    public function packFloat32(v:Float)
    {
        bytes.writeByte(PFloat32);
        bytes.writeFloat(v);
    }
    
    public function packFloat64(v:Float)
    {
        bytes.writeByte(PFloat64);
        bytes.writeDouble(v);
    }
    
    public function packRef(v:Int)
    {
        if (v >= signedLo(8) && v <= signedHi(8))
        {
            bytes.writeByte(PRef8);
            bytes.writeByte(v);
        }
        else if (v >= signedLo(16) && v <= signedHi(16))
        {
            bytes.writeByte(PRef16);
            bytes.writeInt16(v);
        }
        else
        {
            bytes.writeByte(PRef32);
            bytes.writeInt32(v);
        }
    }
    
    public function packString(str:String)
    {
        if (str.length == 0)
        {
            bytes.writeByte(PStringL0);
        }
        else
        {
            if (useCache)
            {
                var ptr = stringCache.get(str);
                
                if (ptr != null)
                {
                    packRef(ptr);
                    return;
                }
                else
                {
                    stringCache.set(str, bytes.length);
                }
            }
            
            var len = str.length;
            
            if (len == 1)
            {
                bytes.writeByte(PStringL1);
            }
            else if (len <= unsignedHi(8))
            {
                bytes.writeByte(PStringB8);
                bytes.writeInt8(len);
            }
            else if (len <= unsignedHi(16))
            {
                bytes.writeByte(PStringB16);
                bytes.writeInt16(len);
            }
            else if (len <= unsignedHi(32))
            {
                bytes.writeByte(PStringB32);
                bytes.writeInt32(len);
            }
            else
            {
                throw "String length too long";
            }
            
            bytes.write(Bytes.ofString(str));
        }
    }
    
    public function packArray(arr:Array<Dynamic>)
    {
        if (arr.length == 0)
        {
            bytes.writeByte(PArrayL0);
        }
        else
        {
            if (useCache)
            {
                var ptr = objectCache.get(arr);
                
                if (ptr != null)
                {
                    packRef(ptr);
                    return;
                }
                else
                {
                    objectCache.set(arr, bytes.length);
                }
            }
            
            var len = arr.length;
            
            if (len == 1)
            {
                bytes.writeByte(PArrayL1);
            }
            else if (len <= unsignedHi(8))
            {
                bytes.writeByte(PArrayB8);
                bytes.writeInt8(len);
            }
            else if (len <= unsignedHi(16))
            {
                bytes.writeByte(PArrayB16);
                bytes.writeInt16(len);
            }
            else if (len <= unsignedHi(32))
            {
                bytes.writeByte(PArrayB32);
                bytes.writeInt32(len);
            }
            else
            {
                throw "Array length too long";
            }
            
            for (v in arr) packAny(v);
        }
    }
    
    
    
    public function packFields(obj:{})
    {
        
    }
    
    public function packObject(obj:{})
    {
        var keys = Reflect.fields(obj);
        
        if (keys.length == 0)
        {
            bytes.writeByte(PObject0);
        }
        else
        {
            if (useCache)
            {
                var ptr = objectCache.get(obj);
                
                if (ptr != null)
                {
                    packRef(ptr);
                    return;
                }
                else
                {
                    objectCache.set(obj, bytes.length);
                }
            }
            
            var len = keys.length;
            
            if (len == 1)
            {
                bytes.writeByte(PObject1);
            }
            else if (len <= unsignedHi(8))
            {
                bytes.writeByte(PObject8);
                bytes.writeInt8(len);
            }
            else if (len <= unsignedHi(16))
            {
                bytes.writeByte(PObject16);
                bytes.writeInt16(len);
            }
            else if (len <= unsignedHi(32))
            {
                bytes.writeByte(PObject32);
                bytes.writeInt32(len);
            }
            else
            {
                throw "Object has too many fields";
            }
            
            // so a serialization of 2 different objects with same values
            // can be compared as string
            if (sortKeys) keys.sort(Reflect.compare);
            
            // store the fields for the first instance
            for (k in keys) packString(k);
            // todo: store RefFields instead for subsequent instances
            
            // now store the values
            for (k in keys) packAny(Reflect.field(obj, k));
        }
    }
    
    
    
    public function packInstance(obj:{})
    {
        var classRef = Type.getClass(obj);
        var className = Type.getClassName(classRef);
        
        if (useCache)
        {
            var ptr = objectCache.get(obj);
            
            if (ptr != null)
            {
                packRef(ptr);
                return;
            }
            else
            {
                objectCache.set(obj, bytes.length);
            }
        }
        
        
        var customMethodName = "__pack__";
        var customMethodFn = Reflect.field(obj, customMethodName);
        
        if (customMethodFn != null && Reflect.isFunction(customMethodFn))
        {
            Reflect.callMethod(obj, customMethodFn, [this]);
        }
        else
        {
            var keys = Type.getInstanceFields(classRef);
            keys.sort(Reflect.compare);
            
            bytes.writeByte(PInstance);
            packString(className);
            
            // store the values
            for (k in keys)
            {
                var v = Reflect.field(obj, k);
                
                if (!Reflect.isFunction(v))
                {
                    packAny(v);
                }
            }
        }
    }
}
