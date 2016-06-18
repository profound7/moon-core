package moon.numbers.random.algo;

import haxe.ds.Vector;
import moon.numbers.random.Seed.IntSeed;

using moon.numbers.random.RandomTools;

/**
 * NOTICE: change to UInt or Int32 or Int64? Is there inconsistent behavior with Int?
 * 
 * Ported from:
 * http://www.cs.gmu.edu/~sean/research/mersenne/MersenneTwister.java
 * https://gist.github.com/banksean/300494
 * http://en.wikipedia.org/wiki/Mersenne_twister
 * 
 * @author Munir Hussin
 */
class MersenneTwisterRandom
{
    // Period parameters
    private static inline var N:Int = 624;
    private static inline var M:Int = 397;
    private static inline var MATRIX_A:Int = 0x9908b0df;   // private static final * constant vector a
    private static inline var UPPER_MASK:Int = 0x80000000; // most significant w-r bits
    private static inline var LOWER_MASK:Int = 0x7fffffff; // least significant r bits
    
    public var _gauss:Float = 0;
    public var _hasGauss:Bool = false;
    public var seed(never, set):IntSeed;
    
    // Tempering parameters
    private static inline var TEMPERING_MASK_B:Int = 0x9d2c5680;
    private static inline var TEMPERING_MASK_C:Int = 0xefc60000;
    
    private var mt:Vector<Int>;
    private var mag01:Vector<Int>;
    private var mti:Int;
    
    
    public function new(?seed:IntSeed) 
    {
        set_seed(seed);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private function set_seed(seed:IntSeed):IntSeed
    {
        var value:Int = seed.value();
        
        mt = new Vector<Int>(N);
        mag01 = new Vector<Int>(2);
        mag01[0] = 0x0;
        mag01[1] = MATRIX_A;
        
        mt[0] = Std.int(value & 0xffffffff);
        mt[0] = Std.int(value);
        
        mti = 1;
        while (mti < N)
        {
            mt[mti] = 1812433253 * (mt[mti-1] ^ (mt[mti-1] >>> 30)) + mti;
            mti++;
        }
        
        return seed;
    }
    
    /*==================================================
        Methods
    ==================================================*/
    
    public function next(bits:Int):Int
    {
        var y:Int;
        
        if (mti >= N)   // generate N words at one time
        {
            var kk:Int;
            var mt:Vector<Int> = this.mt;       // locals are slightly faster 
            var mag01:Vector<Int> = this.mag01; // locals are slightly faster 
            
            kk = 0;
            while (kk < N - M)
            {
                y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
                mt[kk] = mt[kk + M] ^ (y >>> 1) ^ mag01[y & 0x1];
                kk++;
            }
            
            while (kk < N-1)
            {
                y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
                mt[kk] = mt[kk + (M - N)] ^ (y >>> 1) ^ mag01[y & 0x1];
                kk++;
            }
            
            y = (mt[N - 1] & UPPER_MASK) | (mt[0] & LOWER_MASK);
            mt[N - 1] = mt[M - 1] ^ (y >>> 1) ^ mag01[y & 0x1];
            
            mti = 0;
        }
        
        y = mt[mti++];
        y ^= y >>> 11;                          // TEMPERING_SHIFT_U(y)
        y ^= (y << 7) & TEMPERING_MASK_B;       // TEMPERING_SHIFT_S(y)
        y ^= (y << 15) & TEMPERING_MASK_C;      // TEMPERING_SHIFT_T(y)
        y ^= (y >>> 18);                        // TEMPERING_SHIFT_L(y)
        
        return y >>> (32 - bits);    // hope that's right!
    }
    
    /*public function nextInt():Int
    {
        var n = 5;
        if (n <= 0)
        {
            throw new Error("n must be positive, got: " + n);
        }
        
        if ((n & -n) == n) return (n * next(31)) >> 31;
        
        var bits:Int;
        var val:Int;
        
        do 
        {
            bits = next(31);
            val = bits % n;
        }
        while (bits - val + (n - 1) < 0);
        
        return val;
    }*/
    
    
    
    /*==================================================
        Generator Methods
    ==================================================*/
    
    public inline function nextInt():Int
    {
        return next(32);
    }
    
    public inline function nextFloat():Float
    {
        //return next(24) / cast(1 << 24, Float);
        return this.nextFloatFromInt();
    }
    
    public inline function nextBool():Bool
    {
        //return next(1) != 0;
        return this.nextBoolFromInt();
    }
}
