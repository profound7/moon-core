package moon.numbers.big;

import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import moon.core.Bits;

using StringTools;

/**
 * The underlying type is not directly interchangable with
 * the underlying type of BigInteger without conversions.
 * 
 * @author Munir Hussin
 */
abstract BigBits(Array<Bits>) to Array<Bits> from Array<Bits>
{
    public var length(get, never):Int;
    
    public inline function new(a:Array<Bits>)
    {
        this = (a == null || a.length == 0) ? [0] : a;
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private inline function get_length():Int
    {
        return this.length;
    }
    
    /*==================================================
        Conversions
    ==================================================*/
    
    @:from public static function fromBytes(b:Bytes):BigBits
    {
        var bitsPerInt:Int = Bits.size;
        var a:Array<Bits> = [];
        var pos:Int = 0;
        var len:Int = b.length;
        var n:Int = len - 3;
        
        switch (bitsPerInt)
        {
            case 32:
                // 0123456789   len=10
                //    ----   
                while (pos < len)
                {
                    switch (len - pos)
                    {
                        case 1: a.push(b.get(pos++));
                        case 2: a.push(b.get(pos++) | b.get(pos++) << 8);
                        case 3: a.push(b.get(pos++) | b.get(pos++) << 8 | b.get(pos++) << 16);
                        case _: a.push(b.get(pos++) | b.get(pos++) << 8 | b.get(pos++) << 16 | b.get(pos++) << 24);
                    }
                }
                
            case 64:
                // PHP's Int might be 64 bits
                while (pos < len)
                {
                    switch (len - pos)
                    {
                        case 1: a.push(b.get(pos++));
                        case 2: a.push(b.get(pos++) | b.get(pos++) << 8);
                        case 3: a.push(b.get(pos++) | b.get(pos++) << 8 | b.get(pos++) << 16);
                        case 4: a.push(b.get(pos++) | b.get(pos++) << 8 | b.get(pos++) << 16 | b.get(pos++) << 24);
                        case 5: a.push(b.get(pos++) | b.get(pos++) << 8 | b.get(pos++) << 16 | b.get(pos++) << 24 | b.get(pos++) << 32);
                        case 6: a.push(b.get(pos++) | b.get(pos++) << 8 | b.get(pos++) << 16 | b.get(pos++) << 24 | b.get(pos++) << 32 | b.get(pos++) << 40);
                        case 7: a.push(b.get(pos++) | b.get(pos++) << 8 | b.get(pos++) << 16 | b.get(pos++) << 24 | b.get(pos++) << 32 | b.get(pos++) << 40 | b.get(pos++) << 48);
                        case _: a.push(b.get(pos++) | b.get(pos++) << 8 | b.get(pos++) << 16 | b.get(pos++) << 24 | b.get(pos++) << 32 | b.get(pos++) << 40 | b.get(pos++) << 48 | b.get(pos++) << 56);
                    }
                }
                
            case _:
                throw 'Unexpected Int$bitsPerInt';
        }
        
        return new BigBits(a);
    }
    
    @:from public static function fromIntArray(a:Array<Int>):BigBits
    {
        return new BigBits(a);
    }
    
    @:from public static function fromBigInteger(bi:BigInteger):BigBits
    {
        return bi.toBigBits();
    }
    
    /**
     * Create BigBits from a string of zeroes and ones.
     */
    @:from public static function fromString(s:String):BigBits
    {
        var i:Int = s.length;
        var j:Int = 0;
        var x:Bits = 0;
        var ret:Array<Bits> = [];
        
        while (i-->0)
        {
            var code:Int = s.fastCodeAt(i);
            
            switch(code)
            {
                case "0".code: // do nothing
                case "1".code: x.on(j);
                default: throw "Invalid bit";
            }
            
            j++;
            
            if (j == Bits.size)
            {
                ret.push(x);
                j = 0;
                x = 0;
            }
        }
        
        if (x.toInt() > 0)
            ret.push(x);
        
        return ret;
    }
    
    @:to public function toBytes():Bytes
    {
        var bitsPerInt:Int = Bits.size;
        var bytesPerInt:Int = Math.ceil(bitsPerInt / 8);
        var bb:BytesOutput = new BytesOutput();
        bb.prepare(length * bytesPerInt);
        
        switch (bitsPerInt)
        {
            case 32:
                for (i in 0...length)
                {
                    bb.writeInt32(this[i]);
                }
                
            case 64:
                for (i in 0...length)
                {
                    // 1. there's no writeInt64
                    // 2. most of haxe.Bytes stuff assumes Int is Int32...
                    var hi:Int = this[i] >>> 32;
                    var lo:Int = this[i] << 32 >>> 32;
                    bb.writeInt32(lo);
                    bb.writeInt32(hi);
                }
                
            case _:
                throw 'Unexpected Int$bitsPerInt';
        }
        
        return bb.getBytes();
    }
    
    @:to public inline function toIntArray():Array<Int>
    {
        return this;
    }
    
    @:to public inline function toBigInteger():BigInteger
    {
        return BigInteger.fromBase(toString(), 2);
    }
    
    @:to public inline function toInt():Int
    {
        if (this.length == 1)
            return this[0];
        throw "Cannot convert to an Int";
    }
    
    @:to public function toInt64():Int64
    {
        return
            if (this.length == 2)
                Int64.make(this[1], this[0]);
            else if (this.length == 1)
                Int64.make(0, this[0]);
            else
                { trace( "Cannot convert to an Int64 " + toString()); throw ""; };
    }
    
    @:to public inline function toString():String
    {
        var sbuf:StringBuf = new StringBuf();
        var i:Int = this.length;
        
        while (i-->0)
            sbuf.add(this[i].toString());
            
        return sbuf.toString();
    }
}