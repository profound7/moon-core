package moon.crypto.ciphers;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import moon.core.Console;
import moon.core.Pair;
import moon.crypto.Message;
import moon.numbers.big.BigInteger;
import moon.numbers.big.BigMath;
import moon.numbers.big.BigRational;
import moon.numbers.random.algo.NativeRandom;
import moon.numbers.random.Random;


/**
 * RSA asymmetric cryptography
 * 
 * TODO: OAEP padding not yet done
 * 
 * OPTIMIZE: generating keys (512 bits and above) is veeeery slowwww...
 * It takes about 11 mins in neko to find a 1024 bit prime!!!!
 * Chinese remainder theorem implemented, but decryption is
 * still kinda slow.
 * 
 * Usage:
 *      var keys = Rsa.create(1024);
 *      var publicKey:RsaKey = keys.head;
 *      var privateKey:RsaKey = keys.tail;
 * 
 *      var c = publicKey.encode("Hello!");
 *      var m = privateKey.decode(c);
 * 
 * @author Munir Hussin
 */
class Rsa
{
    private static function __init__()
    {
        Console.compileTrace("WARNING: Rsa class is not ready for use");
    }
    
    public static function create(bits:Int):Pair<RsaKey, RsaKey>
    {
        // http://crypto.stackexchange.com/questions/19263/generation-of-n-bit-prime-numbers-what-is-the-actual-range
        
        // n = pq
        // n has to be the specified bits long, so
        // what's the range of p and q, such that when multiplied
        // together, will ALWAYS be that number of bits long?
        
        // if range is [2^(bits/2)-1, 2^(bits/2)),
        // then when you multiply p and q, half of the time the
        // result will be bits-1 long.
        
        //var lo = BigInteger.fromInt(2).pow(pBits - 1);
        //var hi = BigInteger.fromInt(2).pow(pBits);
        
        // Adjusting the range to the following solves the problem:
        // lo = sqrt(2) * 2^(bits/2-1)
        // hi = 2^(bits/2)
        
        // sqrt(2) is approximately 665857 / 470832
        // +1 because we want the ceiling of the result
        // without +1, in n = lo * lo, n will have one less bit.
        
        var lo = BigInteger.of(2).pow(bits / 2 - 1) * 665857 / 470832 + 1;
        var hi = BigInteger.of(2).pow(bits / 2);
        
        
        // choose 2 DISTINCT prime numbers
        var r:Random = new NativeRandom(); // TODO: new NativeSecureRandom();
        var p:BigInteger = BigMath.randomPrime(lo, hi, 0, r);
        var q:BigInteger = BigMath.randomPrime(lo, hi, p, r);
        
        //trace('p=$p');
        //trace('q=$q');
        
        return createFromPrimes(p, q);
    }
    
    public static function createFromPrimes(p:BigInteger, q:BigInteger):Pair<RsaKey, RsaKey>
    {
        // n = pq
        var n:BigInteger = p * q;
        
        // totient function: (p − 1)(q − 1) = n - (p + q - 1)
        var t:BigInteger = n - (p + q - 1);
        //trace('t=$t');
        
        // e is a random prime between [3, t) and gcd(e, t) == 1
        var e:BigInteger = 65537;
        
        while (BigInteger.gcd(e, t) != 1)
            ++e;
            
        // 1 = x*e + y*t
        var d:BigInteger = BigMath.modInv(e, t);
        
        // extra stuffs (not really needed)
        var dp:BigInteger = d % (p - 1);
        var dq:BigInteger = d % (q - 1);
        var c:BigInteger = BigMath.modInv(q, p);
        
        var publicKey = RsaKey.createPublic(n, e);
        var privateKey = RsaKey.createPrivate(n, e, d, p, q, dp, dq, c);
        return Pair.of(publicKey, privateKey);
    }
    
    /**
     * chinese remainder theorem optimization
     * for faster decoding
     */
    private static function crt(c:BigInteger, key:RsaKey):BigInteger
    {
        var p = key.p;
        var q = key.q;
        var dp = key.dp;
        var dq = key.dq;
        var qi = key.c;
        
        var m1 = c.modPow(dp, p);
        var m2 = c.modPow(dq, q);
        
        var h = m1 < m2 ?
            (qi * ((m1 + BigRational.create(q, p).ceil() * p) - m2)) % p:
            (qi * (m1 - m2)) % p;
        
        var m = m2 + h * q;
        return m;
    }
    
    private static function rsa(msg:Message, key:RsaKey, encode:Bool, allowVarLength:Bool=false):Message
    {
        var m:BigInteger = msg;
        
        if (m >= key.n)
        {
            var mBits = m.toBase(2).length;
            var nBits = key.n.toBase(2).length;
            
            if (allowVarLength)
            {
                var nBytes = Math.ceil(nBits / 8);
                var amsg = msg.split(nBytes);
                return [for (x in amsg) rsa(x, key, encode)];
            }
            else
            {
                throw 'Message is too big ($mBits bits). Max is $nBits bits.';
            }
        }
        
        if (!encode && key.useCrt)
            return crt(m, key);
        else
            return m.modPow(encode ? key.e : key.d, key.n);
    }
    
    public static function encode(msg:Message, key:RsaKey, allowVarLength:Bool=false):Message
    {
        return rsa(msg, key, true, allowVarLength);
    }
    
    public static function decode(msg:Message, key:RsaKey, allowVarLength:Bool=false):Message
    {
        if (!key.isPrivate)
            throw "Key is not a private key";
        return rsa(msg, key, false, allowVarLength);
    }
    
    
}


class RsaKey
{
    // These are non-standard formats.
    // TODO: add save/load for other rsa key formats
    // https://msdn.microsoft.com/en-us/library/windows/desktop/bb648645(v=vs.85).aspx
    public static var format =
    [
        "moon-pub" => ["n", "e"],
        "moon-pri" => ["n", "e", "d", "p", "q", "dp", "dq", "c"],
    ];
    
    public var isPrivate(get, never):Bool;
    public var useCrt(get, never):Bool;
    
    // public key
    public var n:BigInteger;
    public var e:BigInteger;
    
    // private key
    public var d:BigInteger;
    public var p:BigInteger;
    public var q:BigInteger;
    public var dp:BigInteger;
    public var dq:BigInteger;
    public var c:BigInteger;
    
    
    private function new()
    {
    }
    
    private function get_isPrivate():Bool
    {
        return d != null || p != null || q != null || dp != null || dq != null || c != null;
    }
    
    private function get_useCrt():Bool
    {
        return p != null && q != null && dp != null && dq != null && c != null;
    }
    
    public static function createPublic(n:BigInteger, e:BigInteger):RsaKey
    {
        var key:RsaKey = new RsaKey();
        key.n = n;
        key.e = e;
        return key;
    }
    
    public static function createPrivate(n:BigInteger, e:BigInteger, d:BigInteger, p:BigInteger, q:BigInteger, dp:BigInteger, dq:BigInteger, c:BigInteger):RsaKey
    {
        var key:RsaKey = new RsaKey();
        key.n = n;
        key.e = e;
        key.d = d;
        key.p = p;
        key.q = q;
        key.dp = dp;
        key.dq = dq;
        key.c = c;
        return key;
    }
    
    public inline function encode(msg:Message, allowVarLength:Bool=false):Message
    {
        return Rsa.encode(msg, this, allowVarLength);
    }
    
    public inline function decode(msg:Message, allowVarLength:Bool=false):Message
    {
        return Rsa.decode(msg, this, allowVarLength);
    }
    
    
    public function save(type:String):Bytes
    {
        var keys:Array<String> = format[type];
        var bo:BytesOutput = new BytesOutput();
        
        bo.writeInt32(type.length);
        bo.writeString(type);
        
        for (k in keys)
        {
            var v:BigInteger = Reflect.field(this, k);
            var vb:Bytes = v.toBytes();
            
            bo.writeInt32(vb.length);
            bo.write(vb);
        }
        
        return bo.getBytes();
    }
    
    public function load(b:Bytes):Void
    {
        var bi:BytesInput = new BytesInput(b);
        var typeLen:Int = bi.readInt32();
        var type:String = bi.readString(typeLen);
        var keys:Array<String> = format[type];
        
        for (k in keys)
        {
            var vbLen:Int = bi.readInt32();
            var vb:Bytes = bi.read(vbLen);
            var v:BigInteger = vb;
            
            Reflect.setField(this, k, v);
        }
    }
    
    public function toBytes():Bytes
    {
        return isPrivate ? save("moon-pri") : save("moon-pub");
    }
    
    public static function fromBytes(b:Bytes):RsaKey
    {
        var key:RsaKey = new RsaKey();
        key.load(b);
        return key;
    }
    
    public function toString():String
    {
        return Base64.encode(toBytes());
    }
    
    public static function fromString(s:String):RsaKey
    {
        s = ~/[ \n\r\t]+/g.replace(s, "");
        trace(s);
        return fromBytes(Base64.decode(s));
    }
}
