package moon.numbers.random.algo;

import moon.numbers.random.Seed.IntSeed;
import moon.numbers.random.RandomTools.*;

/**
 * This is also an LCG
 * 
 * @author Munir Hussin
 */
abstract FastParkMillerRandom(Int) from Int to Int
{
    public var seed(never, set):IntSeed;
    
    public static inline var A:Int = 16807;
    public static inline var M:Int = 0x7fffffff;
    public static inline var Q:Int = 127773;        // M div A
    public static inline var R:Int = 2836;          // M mod A
    
    public function new(?seed:IntSeed)
    {
        set_seed(seed);
    }
    
    private inline function set_seed(seed:IntSeed):IntSeed
    {
        var value:Int = seed.value();
        
        if (value == 0)
            value = 1;
        else if (value < 0)
            value = -value;
            
        if (value > 0x7fffffff)
            value = value % 0x7fffffff;
        
        this = value;
        return seed;
    }
    
    public inline function nextParkMiller():Int
    {
        var t = A * (this % Q) - R * Math.floor(this / Q);
        this = (t > 0) ? t : t + M;
        return this;
    }
    
    // same as Park-Miller but with optimizations by Carta
    public inline function nextParkMillerCarta():Int
    {
        var hi:Int = A * (this & 0xFFFF);
        var lo:Int = A * (this >>> 16) + ((hi & 0x7FFF) << 16) + (hi >>> 15);
        return this = (lo & 0x7FFFFFFF) + (lo >>> 31);
    }
}


/**
 * 
 * @author Munir Hussin
 */
abstract FastXorShift32Random(Int) from Int to Int
{
    public var seed(never, set):IntSeed;
    
    public function new(?seed:IntSeed)
    {
        set_seed(seed);
    }
    
    private inline function set_seed(seed:IntSeed):IntSeed
    {
        return this = seed.value();
    }
    
    public static inline function xorShift32(x:Int):Int
    {
        var t:Int = (x ^ (x << 11));
        return (x ^ (x >>> 19)) ^ (t ^ (t >>> 8));
    }
    
    public inline function nextInt():Int
    {
        return this = xorShift32(this);
    }
    
    public inline function nextFloat():Float
    {
        return (nextInt() / MAX_INT) * 0.5 + 0.5;
    }
    
    public inline function nextBool():Bool
    {
        return (nextInt() & 1) == 0;
    }
}