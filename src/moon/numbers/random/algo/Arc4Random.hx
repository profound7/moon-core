package moon.numbers.random.algo;

import haxe.io.Bytes;
import moon.core.Pair;
import moon.crypto.ciphers.Arc4;
import moon.numbers.random.Seed.StringSeed;

using moon.numbers.random.RandomTools;

/**
 * http://en.wikipedia.org/wiki/RC4
 * 
 * @author Munir Hussin
 */
class Arc4Random
{
    private var _gauss:Float = 0;
    private var _hasGauss:Bool = false;
    public var seed(never, set):StringSeed;
    
    private var s:Bytes;
    private var o:Bytes;
    private var state:Pair<Int, Int>;
    
    
    public function new(?seed:StringSeed)
    {
        // create output bytes, so we don't create new objects each time
        // we generate a random number
        s = Bytes.alloc(256);
        o = Bytes.alloc(4);
        state = Pair.of(0, 0);
        
        set_seed(seed);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private function set_seed(seed:StringSeed):StringSeed
    {
        Arc4.ksa(seed.value(256), s);
        return seed;
    }
    
    /*==================================================
        Generator Methods
    ==================================================*/
    
    public inline function nextInt():Int
    {
        Arc4.prga(s, o, 0, 4, state);
        return o.getInt32(0);
    }
    
    public inline function nextFloat():Float
    {
        return this.nextFloatFromInt();
    }
    
    public inline function nextBool():Bool
    {
        return this.nextBoolFromInt();
    }
}
