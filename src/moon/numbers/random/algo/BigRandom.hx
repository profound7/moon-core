package moon.numbers.random.algo;

import moon.numbers.big.BigBits;
import moon.numbers.big.BigInteger;
import moon.numbers.random.Seed.IntArraySeed;

using moon.numbers.random.RandomTools;

/**
 * http://en.wikipedia.org/wiki/Lehmer_random_number_generator
 * https://en.wikipedia.org/wiki/Linear_congruential_generator
 * 
 * This is an LCG: Linear Congruential Generator
 * 
 * This is the general version that works with arbitrarily
 * huge numbers. Due to the large numbers using BigInteger,
 * this RNG is slow.
 * 
 * For the faster versions, use Lehmer, ParkMiller
 * or ParkMillerCarta.
 * 
 * X = (a * X + c) % m
 * 
 * @author Munir Hussin
 */
class BigRandom
{
    public var _gauss:Float = 0;
    public var _hasGauss:Bool = false;
    public var seed(never, set):IntArraySeed;
    
    // seed
    private var x:BigInteger;
    
    // parameters
    private var a:BigInteger;
    private var c:BigInteger;
    private var m:BigInteger;
    private var s:Int;
    
    
    public function new(?seed:IntArraySeed, ?options:BigRandomOptions)
    {
        if (options == null) options = LCGJava;
        
        switch (options)
        {
            case LCGCustom(a, c, m, s):
                initParameters(a, c, m, s);
                
            case LCGC11:
                initParameters("1103515245", 12345, (2:BigInteger).pow(32), 0);
                
            case LCGNewlib:
                initParameters("6364136223846793005", 1, (2:BigInteger).pow(64), 32);
                
            case LCGJava:
                initParameters("25214903917", 11, (2:BigInteger).pow(48), 16);
        }
        
        set_seed(seed);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private function set_seed(seed:IntArraySeed):IntArraySeed
    {
        var bits:BigBits = m.toBigBits();
        bits = seed.value(bits.length);
        x = bits.toBigInteger();
        return seed;
    }
    
    /*==================================================
        Methods
    ==================================================*/
    
    private function initParameters(a:BigInteger, c:BigInteger, m:BigInteger, s:Int):Void
    {
        //trace(m.toBigBits().toIntArray());
        this.a = a;
        this.c = c;
        this.m = m;
        this.s = s;
    }
    
    public inline function nextBigInt():BigInteger
    {
        x = (a * x + c) % m;
        return (x >> s);
    }
    
    /*==================================================
        Generator Methods
    ==================================================*/
    
    public inline function nextInt():Int
    {
        return nextBigInt().toBigBits()[0];
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

enum BigRandomOptions
{
    LCGCustom(a:BigInteger, c:BigInteger, m:BigInteger, s:Int);
    LCGC11;
    LCGNewlib;
    LCGJava;
}