package moon.crypto;

import haxe.crypto.Hmac.HashMethod;
import haxe.crypto.Md5;
import haxe.crypto.Sha1;
import haxe.crypto.Sha224;
import haxe.crypto.Sha256;
import haxe.io.Bytes;
import moon.crypto.Hash.HashInfo;

/**
 * Lookup table of various hash methods where you can retrieve a hash
 * function by name or id.
 * 
 * Instead of:
 *      Md5.encode("blah");
 * 
 * You can instead get hash by name or id:
 *      HashInfo.fromString("md5").encode("blah");
 *      HashInfo.fromInt(1).encode("blah");
 *      HashInfo.fromEnum(HashMethod.MD5).encode("blah");
 * 
 * @author Munir Hussin
 */
class HashInfo
{
    public static var ids:Map<Int, HashInfo> = [0 => null];
    
    public static var methods:Map<String, HashInfo> =
    [
        "md5"    => new HashInfo(1, 64, 16, Md5.encode, Md5.make),
        "sha1"   => new HashInfo(2, 64, 20, Sha1.encode, Sha1.make),
        "sha224" => new HashInfo(3, 64, 28, Sha224.encode, Sha224.make),
        "sha256" => new HashInfo(4, 64, 32, Sha256.encode, Sha256.make),
    ];
    
    public var id(default, null):Int;
    public var blockSize(default, null):Int;
    public var length(default, null):Int;
    
    public var encode(default, null):String->String;
    public var make(default, null):Message->Message;
    
    
    private function new(id:Int, blockSize:Int, length:Int, encode:String->String, make:Message->Message)
    {
        this.id = id;
        this.blockSize = blockSize;
        this.length = length;
        
        this.encode = encode;
        this.make = make;
        
        ids.set(id, this);
    }
    
    public inline function hmac():Hmac
    {
        return new Hmac(make, blockSize, length);
    }
    
    public static inline function fromString(method:String):HashInfo
    {
        var m = method.toLowerCase();
        if (methods.exists(m))
            return methods[m];
        else
            throw 'Undefined hash method $method';
    }
    
    public static inline function fromInt(id:Int):HashInfo
    {
        if (ids.exists(id))
            return ids[id];
        else
            throw 'Undefined hash index $id';
    }
    
    public static inline function fromEnum(hm:HashMethod):Hash
    {
        return switch (hm)
        {
            case HashMethod.MD5:    fromString("md5");
            case HashMethod.SHA1:   fromString("sha1");
            case HashMethod.SHA256: fromString("sha256");
        }
    }
}

/**
 * Hash as abstract, so any argument that expects a Hash,
 * you can use a String or Int or HashInfo, and it'll work.
 * 
 * Two same hash methods have referential equality,
 * i.e: Hash.fromString("md5") == Hash.fromInt(1) == Hash.fromEnum(HashMethod.MD5)
 * 
 * Usage:
 *    The function:
 *      function foo(hash:Hash) { ... }
 *      
 *    You can call it in multiple ways:
 *      foo("md5");
 *      foo(1);
 *      foo(HashMethod.MD5)
 *      
 * @author Munir Hussin
 */
@:forward abstract Hash(HashInfo) to HashInfo from HashInfo
{
    @:from public static inline function fromString(method:String):Hash
    {
        return HashInfo.fromString(method);
    }
    
    @:from public static inline function fromInt(id:Int):Hash
    {
        return HashInfo.fromInt(id);
    }
    
    @:from public static inline function fromEnum(hm:HashMethod):Hash
    {
        return HashInfo.fromEnum(hm);
    }
    
    public static inline function of(hash:Hash):Hash
    {
        return hash;
    }
}