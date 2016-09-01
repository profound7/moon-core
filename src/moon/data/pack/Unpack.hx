package moon.data.pack;

import moon.data.pack.PackType;
import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import Type;

/**
 * ...
 * @author Munir Hussin
 */
class Unpack
{
    public var bytes:BytesInput;
    private var cache:Map<Int, {}>;
    
    public function new()
    {
        cache = new Map();
    }
    
    public function unpack(b:Bytes):Dynamic
    {
        bytes = new BytesInput(b);
        return unpackAny();
    }
    
    
    
    private function unpackAny():Dynamic
    {
        var type = bytes.readByte();
        
        return switch (type)
        {
            case PNull: null;
            case PTrue: true;
            case PFalse: false;
            
            case PRef8: unpackRef(bytes.readByte());
            case PRef16: unpackRef(bytes.readInt16());
            case PRef32: unpackRef(bytes.readInt32());
            
            case PInt8: bytes.readByte();
            case PInt16: bytes.readInt16();
            case PInt32: bytes.readInt32();
            case PInt64: Int64.make(bytes.readInt32(), bytes.readInt32());
            
            case PFloat32: bytes.readFloat();
            case PFloat64: bytes.readDouble();
            
            case PString0: "";
            case PString1: bytes.read(1).toString();
            case PString8: bytes.read(bytes.readInt8()).toString();
            case PString16: bytes.read(bytes.readInt16()).toString();
            case PString32: bytes.read(bytes.readInt32()).toString();
            
            case PArray0: [];
            case PArray1: [unpackAny()];
            case PArray8: [for (i in 0...bytes.readInt8()) unpackAny()];
            case PArray16: [for (i in 0...bytes.readInt16()) unpackAny()];
            case PArray32: [for (i in 0...bytes.readInt32()) unpackAny()];
            
            case PObject0: unpackObject(0);
            case PObject1: unpackObject(1);
            case PObject8: unpackObject(8);
            case PObject16: unpackObject(16);
            case PObject32: unpackObject(32);
            
            case t: throw "Unsupported: " + t;
        }
    }
    
    private function unpackRef(ptr:Int)
    {
        var val = cache.get(ptr);
        
        if (val == null)
        {
            // save and change position
            var pos = bytes.position;
            bytes.position = ptr;
            
            // unpack data and restore position
            val = unpackAny();
            cache.set(ptr, val);
            
            bytes.position = pos;
        }
        
        return val;
    }
    
    private function unpackObject(lenBytes:Int)
    {
        var obj:Dynamic = {};
        cache.set(bytes.position - 1, obj);
        
        var len = switch (lenBytes)
        {
            case 0: 0;
            case 1: 1;
            case 8: bytes.readInt8();
            case 16: bytes.readInt16();
            case 32: bytes.readInt32();
            case _: throw "Invalid";
        }
        
        for (i in 0...len)
        {
            var k:String = unpackAny();
            var v:Dynamic = unpackAny();
            Reflect.setField(obj, k, v);
        }
        
        return obj;
    }
}