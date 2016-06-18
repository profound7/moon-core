package moon.numbers.random.algo;

import moon.numbers.random.Seed.IntSeed;

using moon.numbers.random.RandomTools;

/**
 * http://en.wikipedia.org/wiki/Lehmer_random_number_generator
 * https://en.wikipedia.org/wiki/Linear_congruential_generator
 * 
 * This is an LCG: Linear Congruential Generator
 * 
 * For the faster versions, use Lehmer, ParkMiller
 * or ParkMillerCarta.
 * 
 * X = (a * X + c) % m
 * 
 * @author Munir Hussin
 */
class LcgRandom
{
    public var _gauss:Float = 0;
    public var _hasGauss:Bool = false;
    public var seed(never, set):IntSeed;
    
    // seed
    private var x:Int;
    
    // parameters
    private var a:Float;
    private var c:Float;
    private var m:Float;
    private var s:Int;
    
    
    public function new(?seed:IntSeed)
    {
        initParameters(1103515245, 12345, Math.pow(2, 32), 0); // C11
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
        if (value > m)
            value = Std.int(value % m);
        
        x = value;
        return seed;
    }
    
    /*==================================================
        Methods
    ==================================================*/
    
    private function initParameters(a:Float, c:Float, m:Float, s:Int):Void
    {
        this.a = a;
        this.c = c;
        this.m = m;
        this.s = s;
    }
    
    /*==================================================
        Generator Methods
    ==================================================*/
    
    public inline function nextInt():Int
    {
        x = Std.int((a * x + c) % m);
        return x >> s;
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
