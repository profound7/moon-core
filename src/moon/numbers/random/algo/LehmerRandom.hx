package moon.numbers.random.algo;

import moon.numbers.random.Seed.IntSeed;

using moon.numbers.random.RandomTools;

/**
 * Same as LCG, but using 32-bit Int and the
 * increment (c) value is 0.
 * 
 * http://en.wikipedia.org/wiki/Lehmer_random_number_generator
 * https://en.wikipedia.org/wiki/Linear_congruential_generator
 * 
 * This is an LCG: Linear Congruential Generator
 * 
 * 16807 is a "full-period-multiplier", which can generate every
 * possible number without getting "stuck in loops of sequences".
 * 
 * NOTE: this produces 31 bits of randomness, not 32.
 * 
 * LCG:    X = (a * X + c) % m
 * Lehmer: X = (g * X    ) % n
 * 
 * @author Munir Hussin
 */
class LehmerRandom
{
    public static inline var G:Int = 16807; // A=16807
    public static inline var N:Int = 0x7fffffff; // M = 0x7fffffff
    
    public var _gauss:Float = 0;
    public var _hasGauss:Bool = false;
    public var seed(never, set):IntSeed;
    
    private var x:Int;  // seed
    private var g:Int;
    private var n:Int;
    private var q:Int;
    private var r:Int;
    
    
    public function new(?seed:IntSeed, g:Int=G, n:Int=N)
    {
        this.g = g;
        this.n = n;
        this.q = Math.floor(n / g);
        this.r = n % g;
        
        set_seed(seed);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private function set_seed(seed:IntSeed):IntSeed
    {
        var value:Int = seed.value();
        
        // seed must be between 1 and 0x7fffffff
        if (value == 0)
            value = 1;
        else if (value < 0)
            value = -value;
            
        // probably shouldn't happen
        if (value > 0x7fffffff)
            value = value % 0x7fffffff;
        
        x = value;
        return seed;
    }
    
    /*==================================================
        Methods
    ==================================================*/
    
    public inline function nextInt31():Int
    {
        var t = g * (x % q) - r * Math.floor(x / q);
        x = (t > 0) ? t : t + n;
        return x;
    }
    
    /*==================================================
        Generator Methods
    ==================================================*/
    
    public inline function nextInt():Int
    {
        return nextBool() ? nextInt31() : -nextInt31();
    }
    
    public inline function nextFloat():Float
    {
        return this.nextFloatFromInt();
    }
    
    public inline function nextBool():Bool
    {
        return (nextInt31() & 1) == 0;
    }
}