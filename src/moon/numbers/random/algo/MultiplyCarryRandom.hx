package moon.numbers.random.algo;

import moon.numbers.random.Seed.IntArraySeed;

using moon.numbers.random.RandomTools;

/**
 * http://en.wikipedia.org/wiki/Random_number_generation
 * 
 * simple pseudo-random number generator using the
 * multiply-with-carry method invented by George Marsaglia.
 * It is computationally fast and has good (albeit not
 * cryptographically strong) randomness properties.
 * 
 * @author Munir Hussin
 */
class MultiplyCarryRandom
{
    public static inline var W_DEFAULT:Int = 1;
    public static inline var Z_DEFAULT:Int = 2;
    
    public var _gauss:Float = 0;
    public var _hasGauss:Bool = false;
    public var seed(never, set):IntArraySeed;
    
    // 64 bits of state
    public var m_w:Int = W_DEFAULT; // must not be zero, nor 0x464fffff
    public var m_z:Int = Z_DEFAULT; // must not be zero, nor 0x9068ffff
    
    public function new(?seed:IntArraySeed)
    {
        set_seed(seed);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private function set_seed(seed:IntArraySeed):IntArraySeed
    {
        var values:Array<Int> = seed.value(2);
        
        m_w = values[0];
        m_z = values[1];
        
        if (m_w == 0 || m_w == 0x464fffff) m_w = W_DEFAULT;
        if (m_z == 0 || m_z == 0x9068ffff) m_z = Z_DEFAULT;
        
        return seed;
    }
    
    /*==================================================
        Generator Methods
    ==================================================*/
    
    public function nextInt():Int
    {
        m_z = 36969 * (m_z & 65535) + (m_z >> 16);
        m_w = 18000 * (m_w & 65535) + (m_w >> 16);
        return (m_z << 16) + m_w;
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
