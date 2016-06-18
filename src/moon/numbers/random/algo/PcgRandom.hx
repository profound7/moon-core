package moon.numbers.random.algo;

import haxe.Int64;
import moon.numbers.random.Seed.IntArraySeed;

using moon.numbers.random.RandomTools;

/**
 * Algorithm based on
 * http://www.pcg-random.org/download.html
 * 
 * @author Munir Hussin
 */
class PcgRandom
{
    // 6364136223846793005ULL
    public static var magic:Int64 = Int64.make(0x5851F42D, 0x4C957F2D);
    
    public var _gauss:Float = 0;
    public var _hasGauss:Bool = false;
    public var seed(never, set):IntArraySeed;
    
    // seed
    private var state:Int64;
    private var inc:Int64;
    
    
    public function new(?seed:IntArraySeed, ?initseq:Int64)
    {
        if (initseq == null)
            inc = Int64.make(0xda3e39cb, 0x94b95bdb);
        else
            inc = (initseq << 1) | 1; // must be odd
            
        set_seed(seed);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private function set_seed(seed:IntArraySeed):IntArraySeed
    {
        var value = seed.value(2);
        state = Int64.make(value[0], value[1]);
        return seed;
    }
    
    /*==================================================
        Generator Methods
    ==================================================*/
    
    public inline function nextInt():Int
    {
        var oldState:Int64 = state;
        
        // advance internal state
        state = oldState * magic + inc;
        
        // calculate output function (XSH RR), uses old state for max ILP
        var xorshifted:Int = (((oldState >>> 18) ^ oldState) >>> 27).low;
        var rot:Int = (oldState >>> 59).low;
        var x:Int = (xorshifted >>> rot) | (xorshifted << (( -rot) & 31));
        return x;
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
