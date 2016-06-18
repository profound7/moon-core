package moon.tools;

import haxe.crypto.BaseCode;
import haxe.io.Bytes;

/**
 * ...
 * @author Munir Hussin
 */
class BytesTools
{
    public static inline function binop(a:Bytes, b:Bytes, len:Int=-1, aStart:Int=0, aStep:Int=1, bStart:Int=0, bStep:Int=1, fn:Int->Int->Int):Bytes
    {
        var n:Int = 0;
        var i:Int = aStart >= 0 ? aStart : a.length - aStart; // start can be negative to start from the back
        var j:Int = bStart >= 0 ? bStart : b.length - bStart;
        
        if (len == -1) len = a.length;
        
        while (n < len && i < a.length && j < b.length && i >= 0 && j >= 0)
        {
            a.set(i, fn(a.get(i), b.get(j)));
            
            ++n;
            i += aStep;
            j += bStep;
        }
        
        return a;
    }
    
    private static inline function min(a:Int, b:Int):Int
    {
        return a < b ? a : b;
    }
    
    /**
     * Clones the byte buffer
     */
    public static inline function copy(a:Bytes):Bytes
    {
        var b:Bytes = Bytes.alloc(a.length);
        b.blit(0, a, 0, a.length);
        return b;
    }
    
    /**
     * Swap two values in the byte buffers
     */
    public static inline function swap(a:Bytes, b:Bytes, aIndex:Int, bIndex:Int):Void
    {
        var t:Int = a.get(aIndex);
        a.set(aIndex, b.get(bIndex));
        b.set(bIndex, t);
    }
    
    /**
     * Bitwise AND, left aligned, excess ignored
     */
    public static inline function and(a:Bytes, b:Bytes):Bytes
    {
        var n:Int = min(a.length, b.length);
        while (n-->0) a.set(n, a.get(n) & b.get(n));
        return a;
    }
    
    /**
     * Bitwise OR, left aligned, excess ignored
     */
    public static inline function or(a:Bytes, b:Bytes):Bytes
    {
        var n:Int = min(a.length, b.length);
        while (n-->0) a.set(n, a.get(n) | b.get(n));
        return a;
    }
    
    /**
     * Bitwise XOR, left aligned, excess ignored
     */
    public static inline function xor(a:Bytes, b:Bytes):Bytes
    {
        var n:Int = min(a.length, b.length);
        while (n-->0) a.set(n, a.get(n) ^ b.get(n));
        return a;
    }
    
    /**
     * Reverses the contents of the byte buffer.
     * Reversing twice gets back the original value.
     */
    public static inline function reverse(a:Bytes):Bytes
    {
        var n:Int = a.length;
        var h:Int = n >> 1;
        while (h-->0) swap(a, a, h, n - h - 1);
        return a;
    }
    
    /**
     * Performs an XOR of itself with its opposite side.
     * i.e. [a, b, c, d, e, f] => [a ^ f, b ^ e, c ^ d, d, e, f]
     * Flipping twice gets back the original value.
     */
    public static inline function flip(a:Bytes):Bytes
    {
        var n:Int = a.length;
        var h:Int = n >> 1;
        while (h-->0) a.set(h, a.get(h) ^ a.get(n - h - 1));
        return a;
    }
    
    
    // lol wut
    /*public static inline function flip0(a:Bytes):Bytes
    {
        var i:Int = 0;
        var j:Int = a.length - 1;
        
        while (i < j)
        {
            a.set(i, a.get(i) ^ a.get(j));
            i++;
            j--;
        }
        return a;
    }*/
    
    // both must be of the same length
    /*public static inline function xor(a:Bytes, b:Bytes):Bytes
    {
        var n:Int = a.length;
        while (n-->0) a.set(n, a.get(n) ^ b.get(n));
        return a;
    }*/
    
    
    /**
     * Compares two byte buffers for equality.
     * This does not run in length-constant time,
     * and returns the result as soon as it is known.
     */
    public static inline function equals(a:Bytes, b:Bytes):Bool
    {
        /*if (a.length != b.length) return false;
        var n:Int = a.length;
        while (n-->0)
            if (a.get(n) != b.get(n))
                return false;
        return true;*/
        return a != null && a == b ? true : a.compare(b) == 0;
    }
    
    /**
     * Compares two byte buffers in length-constant time.
     * https://crackstation.net/hashing-security.htm
     */
    public static function slowEquals(a:Bytes, b:Bytes):Bool
    {
        var diff:Int = a.length ^ b.length;
        var i:Int = 0;
        
        while (i < a.length && i < b.length)
        {
            diff |= a.get(i) ^ b.get(i);
            i++;
        }
        
        return diff == 0;
    }
}
