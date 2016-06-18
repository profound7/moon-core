package moon.crypto;

import haxe.crypto.Md5;
import haxe.crypto.Sha1;
import haxe.crypto.Sha224;
import haxe.crypto.Sha256;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;

/**
 * Forked from haxe.crypto.Hmac
 * 
 * Hmac is modified, so you can retrieve it by
 * name or id.
 * 
 * Usage:
 *      
 *      Hmac.of("sha256").make(a, b);
 *      Hmac.of(4).make(a, b);
 * 
 * blockSize is:
 *      64 bytes for MD5, SHA-1, SHA224, SHA-256
 *      128 bytes for SHA-384, SHA-512
 *      
 *      according to RFC2104 and RFC4868
 *          https://www.ietf.org/rfc/rfc2104.txt
 *          https://www.ietf.org/rfc/rfc4868.txt
 *      
 *      These info are stored within Hash.methods
 * 
 * @author Munir Hussin (modifications)
 */
class Hmac
{
    private var hash:Bytes->Bytes;
    private var blockSize:Int;
    public var length(default, null):Int;
    
    public function new(hash:Bytes->Bytes, blockSize:Int, ?length:Int)
    {
        this.hash = hash;
        this.blockSize = blockSize;
        this.length = length == null ?
            hash(Bytes.ofString("hello")).length :
            length;
    }
    
    public static function of(hash:Hash):Hmac
    {
        return hash.hmac();
    }
    
    private function nullPad(s:Bytes, chunkLen:Int):Bytes
    {
        var r = chunkLen - (s.length % chunkLen);
        if (r == chunkLen && s.length != 0)
            return s;
            
        var sb = new BytesBuffer();
        sb.add(s);
        
        for (x in 0...r)
            sb.addByte(0);
            
        return sb.getBytes();
    }
    
    public function make(key:Message, msg:Message):Message
    {
        if (key.length > blockSize)
        {
            key = hash(key);
        }
        
        key = nullPad(key, blockSize);
        
        var Ki = new BytesBuffer();
        var Ko = new BytesBuffer();
        
        for (i in 0...key.length)
        {
            Ko.addByte(key.get(i) ^ 0x5c);
            Ki.addByte(key.get(i) ^ 0x36);
        }
        
        // hash(Ko + hash(Ki + message))
        Ki.add(msg);
        Ko.add(hash(Ki.getBytes()));
        return hash(Ko.getBytes());
    }
    
}
