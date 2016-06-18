package moon.crypto;

import haxe.crypto.BaseCode;
import haxe.io.Bytes;

/**
 * Forked from haxe.crypto.Base64.
 * Added url-safe base64 encoding/decoding based on RFC 4648.
 * 
 * @author Munir Hussin
 */
class Base64
{
    public static var CHARS(default, null) = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    public static var BYTES(default, null) = haxe.io.Bytes.ofString(CHARS);
    public static var PAD(default, null) = "=";
    
    // Standard 'base64url' with URL and Filename Safe Alphabet
    // (RFC 4648 §5 'Table 2: The "URL and Filename safe" Base 64 Alphabet')
    public static var URLCHARS(default, null) = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
    public static var URLBYTES(default, null) = haxe.io.Bytes.ofString(URLCHARS);
    //public static var URLPAD(default, null) = "%3D";
    public static var URLPAD(default, null) = "";
    
    
    public static function baseEncode(bytes:Message, chars:Bytes, ?pad:String):String
    {
        var str = new BaseCode(chars).encodeBytes(bytes).toString();
        
        if (pad != null) switch (bytes.length % 3)
        {
            case 1:
                str += pad + pad;
            case 2:
                str += pad;
            default:
        }
        
        return str;
    }
    
    public static function baseDecode(str:String, chars:Bytes, ?pad:String):Message
    {
        if (pad != null)
        {
            while (str.substr(-pad.length) == pad)
                str = str.substr(0, -pad.length);
        }
        
        return new BaseCode(BYTES).decodeBytes(Bytes.ofString(str));
    }
    
    public static inline function encode(bytes:Message, complement:Bool=true):String
    {
        return baseEncode(bytes, BYTES, complement ? PAD : null);
    }
    
    public static inline function decode(bytes:Message, complement:Bool=true):String
    {
        return baseDecode(bytes, BYTES, complement ? PAD : null);
    }
    
    public static inline function urlEncode(bytes:Message, complement:Bool=true):String
    {
        return baseEncode(bytes, URLBYTES, complement ? URLPAD : null);
    }
    
    public static inline function urlDecode(bytes:Message, complement:Bool=true):String
    {
        return baseDecode(bytes, URLBYTES, complement ? URLPAD : null);
    }
}