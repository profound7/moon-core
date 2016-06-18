package moon.crypto.ciphers;

/**
 * https://en.wikipedia.org/wiki/Optimal_asymmetric_encryption_padding
 * Used by RSA for padding
 * 
 * TODO: incomplete
 * 
 * @author Munir Hussin
 */
class Oaep
{

    // TODO: oaep padding for messages
    // move to another class
    
    public static function oaep(msg:Message, bits:Int, g:HashMethod, h:HashMethod, rnd:Random):Message
    {
        // n: number of bits in RSA modulus
        
        var m:BigInteger = msg;
        var n:Int = bits;
        var k0:Int = 8;
        var k1:Int = 8;
        var G = HashTools.methods[g];
        var H = HashTools.methods[h];
        
        var maxBits:Int = n - k0 - k1;
        var msgBits:Int = m.toBase(16).length * 4;
        
        if (msgBits > maxBits)
            throw "Message is too long";
        
        // to encode
        // pad with k0 zeroes to be n - k0 bits in length
        var mm:BigInteger = m.shiftLeft(k1);
        var r:Bytes = rnd.create.bytes(Math.ceil(k1 / 8));
        var Gr:BigInteger = (G.make(r):Message);
        // Gr must be n-k0 bits
        
        var X = mm.xor(Gr);
        var HX:BigInteger = (H.make(X):Message);
        var Y = ((r:Message):BigInteger).xor(HX);
        
        return m;
    }
    
}