package moon.crypto;

import haxe.crypto.Base64;
import haxe.crypto.Hmac;
import haxe.crypto.Md5;
import haxe.crypto.Sha1;
import haxe.crypto.Sha224;
import haxe.crypto.Sha256;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import moon.core.Char;
import moon.crypto.Hash;
import moon.numbers.random.algo.Arc4Random;
import moon.numbers.random.Random;

using moon.tools.BytesTools;

/**
 * Password class to hash and verify passwords
 * 
 * @author Munir Hussin
 */
class Password
{
    public static var random(get, null):Random;
    
    
    /*==================================================
        Private Methods
    ==================================================*/
    
    private static function get_random():Random
    {
        if (random == null)
            random = new Arc4Random();
        return random;
    }
    
    
    /*==================================================
        Public Methods
    ==================================================*/
    
    /**
     * Generates a random human password of a given length.
     * By default, `chars` consists of AlphaNumeric characters and Punctuations.
     */
    public static inline function generate(len:Int=64, ?chars:String):String
    {
        return random.create.string(len, chars == null ?
            Char.generate("", "", AlphaNumeric, Punctuation) :
            chars);
    }
    
    /**
     * Generates random bytes of a given length.
     * This is automatically used by the password hash method below.
     */
    public static inline function generateSalt(len:Int=64):Bytes
    {
        return random.create.bytes(len);
    }
    
    
    /**
     * Hash the password with a randomly generated salt.
     * Hash will always generate a different hash, even for the same password.
     */
    public static function hash(method:Hash, password:String, iterations:Int=10, keyLength:Int=256):String
    {
        // bytes:      1 |    n |   n
        // data:  method | salt | key
        
        var salt:Bytes = generateSalt(method.length);
        var hash:Bytes = PBKDF2.encode(method, password, salt, iterations, keyLength);
        var hashId:Int = method.id;
        
        // save data to buffer
        var bytesOut:BytesOutput = new BytesOutput();
        bytesOut.writeByte(hashId);
        bytesOut.writeInt16(iterations);
        bytesOut.writeInt16(keyLength);
        bytesOut.writeInt16(salt.length);
        bytesOut.writeInt16(hash.length);
        bytesOut.write(salt);
        bytesOut.write(hash);
        
        var final:Bytes = bytesOut.getBytes();
        
        // this next line is only for aesthetic reasons, not security
        #if passwordPrettyHash
            final.xorSelf();
        #end
        
        return Base64.encode(final);
    }
    
    
    /**
     * Hash the password and see if you get passwordHash.
     * If you can get passwordHash by hashing the password, then it
     * is verified and returns true. Otherwise return false.
     */
    public static function verify(passwordHash:String, password:String):Bool
    {
        try
        {
            var final:Bytes = Base64.decode(passwordHash);
            
            #if passwordPrettyHash
                final.xorSelf();
            #end
            
            var bytesIn:BytesInput = new BytesInput(final);
            
            // get data from buffer
            var hashId:Int = bytesIn.readByte();
            var iterations:Int = bytesIn.readInt16();
            var keyLength:Int = bytesIn.readInt16();
            var saltLength:Int = bytesIn.readInt16();
            var hashLength:Int = bytesIn.readInt16();
            
            var bytesRemaining:Int = bytesIn.length - bytesIn.position;
            
            if (!HashInfo.ids.exists(hashId) || iterations < 1 || keyLength < 0 || 
                saltLength < 0 || hashLength < 0 ||
                saltLength + hashLength > bytesRemaining)
            {
                //trace("verify: bad hash!");
                return false;
            }
            
            var salt:Bytes = bytesIn.read(saltLength);
            var hash:Bytes = bytesIn.read(hashLength);
            
            //trace(Base64.encode(salt));
            var test:Bytes = PBKDF2.encode(hashId, Bytes.ofString(password), salt, iterations, keyLength);
            
            //trace("verify: good hash!");
            return hash.slowEquals(test);
        }
        catch (ex:Dynamic)
        {
            //trace("verify: unexpected error");
            return false;
        }
    }
    
    /**
     * Similar to PHP's password_need_rehash(), this function checks the passwordHash,
     * and determines if it needs to be rehashed based on the other arguments.
     * 
     * passwordHash has some additional info embedded such as hashing method, iterations,
     * and keylength. If any of these do not match with those passed to this function,
     * then the hash is outdated, and needs to be rehashed.
     */
    public static function needsRehash(passwordHash:String, method:Hash, iterations:Int=10, keyLength:Int=256):Bool
    {
        try
        {
            var final:Bytes = Base64.decode(passwordHash);
            
            #if passwordPrettyHash
                final.xorSelf();
            #end
            
            var bytesIn:BytesInput = new BytesInput(final);
            
            // get data from buffer
            var currHashId:Int = bytesIn.readByte();
            var currIterations:Int = bytesIn.readInt16();
            var currKeyLength:Int = bytesIn.readInt16();
            var currSaltLength:Int = bytesIn.readInt16();
            var currHashLength:Int = bytesIn.readInt16();
            
            var bytesRemaining:Int = bytesIn.length - bytesIn.position;
            
            if (!HashInfo.ids.exists(currHashId) || currIterations < 1 || currKeyLength < 0 || 
                currSaltLength < 0 || currHashLength < 0 ||
                currSaltLength + currHashLength > bytesRemaining)
            {
                //trace("needsRehash: bad hash!");
                return true;
            }
            
            var currMethod:Hash = currHashId;
            
            if (currMethod != method || currIterations != iterations || currKeyLength != keyLength)
            {
                //trace("needsRehash: outdated hash");
                return true;
            }
            
            return false;
        }
        catch (ex:Dynamic)
        {
            //trace("needsRehash: unexpected error");
            return true;
        }
    }
}
