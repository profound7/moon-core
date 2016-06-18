package moon.core;

using StringTools;

/**
 * Bits is an Int, with methods to manipulate individual bits.
 * 
 * Usage:
 * 
 * var b:Bits = 0;
 * var i:Int = 0;
 * 
 * trace( b[2] );       // false
 * 
 * // set bit 2
 * // 0000 0000 0000 0000    0000 0000 0000 0100
 * b.on(2);
 * 
 * trace( b[2] );       // true
 * 
 * var i:Int = b;       // you can assign b to Int, since bits is really an integer
 * 
 * trace(i);            // 3
 * 
 * @author Munir Hussin
 */
abstract Bits(Int) to Int from Int
{
    //public static var pow:Array<Int> = [for (i in 0...32) Std.int(Math.pow(2, i))];
    
    /**
     * The number of bits in an Int
     */
    public static var size(default, null):Int;
    public var length(get, never):Int;
    
    // constructor
    public inline function new(i:Int=0) this = i;
    
    
    private static function __init__():Void
    {
        // count the number of bits, as it might be different in different systems.
        // for example, php's int could be 32 or 64 bits.
        // is this necessary though?
        // or is Haxe's Int always 32 bits?
        
        var i:Int = -1;     // -1 means set all bits to 1
        var b:Int = 0;
        
        // count the number of shifts to make i become 0
        while (i != 0)
        {
            b++;
            i >>>= 1;
        }
        
        size = b;
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private function get_length():Int
    {
        return size;
    }
    
    /*==================================================
        Helpers
    ==================================================*/
        
    /**
     * Gets the power of 2 value based on the bit's position
     */
    public static inline function mask(bit:Int):Bits
    {
        return 1 << bit;
    }
    
    /**
     * Iterates bits from left to right
     */
    public function iterator():Iterator<Bool>
    {
        return new BitsForwardIterator(this);
    }
    
    /**
     * Iterates bits from right to left
     */
    public function reverseIterator():Iterator<Bool>
    {
        return new BitsReverseIterator(this);
    }
    
    /*==================================================
        Operates on multiple bits
    ==================================================*/
    
    /**
     * Checks if multiple bits are set by mask
     */
    public inline function check(bitmask:Int):Bool
    {
        return (this & bitmask) != 0;
    }
    
    /**
     * Sets multiple bits by mask
     */
    public inline function apply(bitmask:Int):Bits
    {
        return this |= bitmask;
    }
    
    /**
     * Unsets multiple bits by mask
     */
    public inline function remove(bitmask:Int):Bits
    {
        return this &= ~bitmask;
    }
    
    /**
     * Toggles multiple bits by mask.
     */
    public inline function xor(bitmask:Int):Bits
    {
        return this ^= ~bitmask;
    }
    
    
    /*==================================================
        Operates on single bits
    ==================================================*/
    
    /**
     * Gets the value of the n-th bit
     */
    @:arrayAccess public inline function get(bit:Int):Bool
    {
        return check(mask(bit));
    }
    
    /**
     * Sets the n-th bit to a value
     */
    @:arrayAccess public inline function set(bit:Int, value:Bool):Bool
    {
        value ? on(bit) : off(bit);
        return value;
    }
    
    /**
     * Sets the n-th bit to 1
     */
    public inline function on(bit:Int):Bits
    {
        return apply(mask(bit));
    }
    
    /**
     * Sets the n-th bit to 0
     */
    public inline function off(bit:Int):Bits
    {
        return remove(mask(bit));
    }
    
    /**
     * Toggles the n-th bit
     */
    public inline function toggle(bit:Int):Bits
    {
        return xor(mask(bit));
    }
    
    /**
     * Sets all the bits to 1
     */
    public inline function all():Bits
    {
        return this = ~0;
    }
    
    /**
     * Sets all the bits to 0
     */
    public inline function none():Bits
    {
        return this = 0;
    }
    
    
    /*==================================================
        Misc
    ==================================================*/
    
    /**
     * Checks if the left-most bit is 0
     */
    public inline function isEven():Bool
    {
        return this & 1 == 0;
    }
    
    /**
     * Checks if the left-most bit is 1
     */
    public inline function isOdd():Bool
    {
        return this & 1 != 0;
    }
    
    /*
     * Rotates left by d bits
     */
    public inline function rotateLeft(d:Int):Bits
    {
        return (this << d) | (this >> (length - d));
    }
    
    /**
     * Rotates right by d bits
     */
    public inline function rotateRight(d:Int):Bits
    {
        return (this >> d) | (this << (length - d));
    }
    
    /**
     * Returns the number of bits that are true
     */
    public inline function cardinality():Int
    {
        var count = 0;
        for (bit in iterator())
            if (bit)
                ++count;
        return count;
    }
    
    /*==================================================
        Conversions
    ==================================================*/
    
    @:from public static function fromString(s:String):Bits
    {
        var i:Int = s.length;
        var j:Int = 0;
        var x:Bits = 0;
        
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
        }
        
        return x;
    }
    
    public function toPartialString(bitlen:Int):String
    {
        var bits:StringBuf = new StringBuf();
        var i:Int = bitlen;
        while (i-->0) bits.add(get(i) ? "1" : "0");
        return bits.toString();
    }
    
    @:to public inline function toString():String
    {
        return toPartialString(length);
    }
    
    @:to public inline function toInt():Int
    {
        return this;
    }
}


class BitsForwardIterator
{
    public var b:Bits;
    public var i:Int;
    
    public inline function new(bits:Bits)
    {
        this.b = bits;
        this.i = 0;
    }
    
    public inline function hasNext():Bool
    {
        return i < Bits.length;
    }
    
    public inline function next():Bool
    {
        return b[i++];
    }
}

class BitsReverseIterator
{
    public var b:Bits;
    public var i:Int;
    
    public inline function new(bits:Bits)
    {
        this.b = bits;
        this.i = Bits.length - 1;
    }
    
    public inline function hasNext():Bool
    {
        return i >= 0;
    }
    
    public inline function next():Bool
    {
        return b[i--];
    }
}
