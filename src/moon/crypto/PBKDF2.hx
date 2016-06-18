package moon.crypto;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;

using moon.tools.BytesTools;

/**
 * Algorithm based on http://en.wikipedia.org/wiki/PBKDF2
 * NOTE: For the algorithms on the wikipedia page, || means concatenation, not logical OR.
 * 
 * @author Munir Hussin
 */
class PBKDF2
{
    private var hmac:Hmac;
    public var length(get, never):Int;
    
    /**
     * Encodes password with salt using PBKDF2.
     * Hash is an abstract that accepts String, Int, or HashMethod.
     * Example:
     *      x = encode("sha256", "abc123", "foo", 100, 256);
     *      x = encode(4, "abc123", "foo", 100, 256);
     *      x = encode(HashMethod.SHA256, "abc123", "foo", 100, 256);
     */
    public static function encode(hash:Hash, password:Message, salt:Message, iterations:Int, length:Int=256):Message
    {
        return new PBKDF2(hash).make(password, salt, iterations, length);
    }
    
    public function new(hash:Hash)
    {
        this.hmac = hash.hmac();
    }
    
    private inline function get_length():Int
    {
        return hmac.length;
    }
    
    // F(Password, Salt, c, i) = U1 ^ U2 ^ ... ^ Uc
    private inline function f(password:Bytes, salt:Bytes, iterations:Int, i:Int):Bytes
    {
        // salt concatenate with i in int32 big endian
        var sb = new BytesBuffer();
        sb.add(salt);
        sb.addByte( i >>> 24 & 0xFF );
        sb.addByte( i >>> 16 & 0xFF );
        sb.addByte( i >>> 8  & 0xFF );
        sb.addByte( i        & 0xFF );
        
        // U1 = PRF(Password, Salt || INT_32_BE(i))
        var prev:Bytes = hmac.make(password, sb.getBytes());
        var curr:Bytes;
        
        var final:Bytes = Bytes.alloc(prev.length);
        final.blit(0, prev, 0, prev.length);
        
        for (n in 1...iterations)
        {
            // Un = PRF(Password, Un-1)
            curr = hmac.make(password, prev);
            final.xor(curr);
            prev = curr;
        }
        
        return final;
    }
    
    /**
     * 
     * @param password
     * @param salt
     * @param iterations    number of iterations
     * @param length        generated derived key length
     * @return
     */
    public function make(password:Message, salt:Message, iterations:Int, length:Int):Message
    {
        if (length < hmac.length)
            throw 'The length should be at least ${hmac.length}';
            
        var dk:BytesBuffer = new BytesBuffer();  // derived key
        var n:Int = Std.int(length / hmac.length) + 1;
        var ti:Bytes;
        
        // DK = T1 || T2 || ... || Tdklen/hlen
        // Ti = F(Password, Salt, iterations, i)
        
        for (i in 1...n)
        {
            ti = f(password, salt, iterations, i);
            dk.add(ti);
        }
        
        return dk.getBytes();
    }
}
