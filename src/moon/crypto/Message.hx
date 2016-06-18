package moon.crypto;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import moon.numbers.big.BigBits;
import moon.numbers.big.BigInteger;

/**
 * Message is internally Bytes. It provides automated conversions
 * between Bytes, String, BigInteger, Base64 String, and arrays
 * of Messages.
 * 
 * @author Munir Hussin
 */
@:forward abstract Message(Bytes) to Bytes from Bytes
{
    private static var rxWhitespace = ~/[ \n\r\t]+/g;
    
    public function new()
    {
        this = fromString("");
    }
    
    /**
     * Split into smaller messages where each message is at
     * most `bytesPerMessage` bytes long.
     */
    public function split(bytesPerMessage:Int):Array<Message>
    {
        var arr:Array<Message> = [];
        var i:Int = 0;
        var n:Int = this.length;
        
        // 012345
        // abcdef
        // i        0
        //       n  6
        // bpm = 3
        while (i < n)
        {
            var len:Int = i + bytesPerMessage > n ? n - i : bytesPerMessage;
            //trace(i, n, bytesPerMessage);
            var b:Bytes = this.sub(i, len);
            arr.push(b);
            i += bytesPerMessage;
        }
        
        return arr;
    }
    
    @:to public function toString():String
    {
        return this.toString();
    }
    
    public function toBase64():String
    {
        return Base64.encode(this);
    }
    
    @:to public function toBytes():Bytes
    {
        return this;
    }
    
    @:to public function toBigInteger():BigInteger
    {
        return BigInteger.fromBytes(this);
    }
    
    @:to public function toBigBits():BigBits
    {
        return BigBits.fromBytes(this);
    }
    
    @:from public static function fromString(s:String):Message
    {
        return Bytes.ofString(s);
    }
    
    public static function fromBase64(s:String):Message
    {
        // remove all whitespaces because base64 strings are
        // usually formatted in multiple lines
        s = rxWhitespace.replace(s, "");
        return Base64.decode(s);
    }
    
    @:from public static function fromBytes(b:Bytes):Message
    {
        return b;
    }
    
    @:from public static function fromBigInteger(b:BigInteger):Message
    {
        return b.toBytes();
    }
    
    @:from public static function fromBigBits(b:BigBits):Message
    {
        return b.toBytes();
    }
    
    /**
     * Joins multiple messages into a single message
     */
    @:from public static function join(a:Array<Message>):Message
    {
        var bb:BytesBuffer = new BytesBuffer();
        for (b in a)
            bb.add(b);
        return bb.getBytes();
    }
}