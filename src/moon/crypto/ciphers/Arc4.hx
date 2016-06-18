package moon.crypto.ciphers;

import haxe.io.Bytes;
import moon.core.Pair;

/**
 * Arc4 Symmetric Cipher
 * 
 * Algorithm based on:
 *      http://en.wikipedia.org/wiki/RC4
 * 
 * Usage:
 *      var a = Arc4.arc4("Key", "Plaintext");
 *      trace(a.toHex());       // BBF316E8D940AF0AD3
 *      
 *      var b = Arc4.arc4("Key", a);
 *      trace(b.toString());    // Plaintext
 * 
 * @author Munir Hussin
 */
class Arc4
{
    /**
     * ARC4 stream cipher
     * This function does not modify `message` in-place, and
     * returns a new message.
     */
    public static function encode(key:Message, message:Message):Message
    {
        var s:Bytes = ksa(key);
        var o:Bytes = Bytes.alloc(message.length);
        o.blit(0, message, 0, message.length);
        prga(s, o, 0, o.length);
        return o;
    }
    
    public static function decode(key:Message, message:Message):Message
    {
        return encode(key, message);
    }
    
    /**
     * key-scheduling algorithm (KSA)
     * you can provide an existing output bytes if you want,
     * and its values will be overridden
     */
    public static function ksa(key:Message, ?out:Bytes):Bytes
    {
        var len:Int = key.length;
        var s:Bytes = out == null ? Bytes.alloc(256) : out;
        
        for (i in 0...256)
        {
            s.set(i, i);
        }
        
        var j:Int = 0;
        var t:Int = 0;
        
        for (i in 0...256)
        {
            j = (j + s.get(i) + key.get(i % len)) % 256;
            
            // swap
            t = s.get(i);
            s.set(i, s.get(j));
            s.set(j, t);
        }
        
        return s;
    }
    
    /**
     * pseudo-random generation algorithm
     * 
     * s is KSA input
     * o is the input, as well as the output. the function will modify o in-place.
     * start and len is where to apply the function within o.
     * 
     * purpose of `state` is to allow this function to apply to the message
     * partially, and then allow resuming of the function by calling it
     * again and passing in the previous state.
     */
    public static function prga(s:Bytes, o:Bytes, start:Int, len:Int, ?state:Pair<Int, Int>):Void
    {
        // no state means we're not resuming. start from (0, 0)
        if (state == null)
            state = Pair.of(0, 0);
        
        var i:Int = state.head;
        var j:Int = state.tail;
        var t:Int;
        var k:Int;
        
        for (p in start...start+len)
        {
            i = (i + 1) % 256;
            j = (j + s.get(i)) % 256;
            
            // swap s[i] and s[j]
            t = s.get(i);
            s.set(i, s.get(j));
            s.set(j, t);
            
            k = s.get((s.get(i) + s.get(j)) % 256);
            o.set(p, o.get(p) ^ k);
        }
        
        // update the state so this function can be resumed
        state.head = i;
        state.tail = j;
    }
    
}