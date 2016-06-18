package moon.numbers.random.algo;

import moon.numbers.random.Seed.IntSeed;

using moon.numbers.random.RandomTools;

/**
 * http://stackoverflow.com/questions/521295/javascript-random-seeds
 * obviously, not very random
 * 
 * @author Munir Hussin
 */
class SineRandom
{
    public static inline var FACTOR:Int = 10000;
    
    public var _gauss:Float = 0;
    public var _hasGauss:Bool = false;
    public var seed(never, set):IntSeed;
    
    private var mseed:Int;
    
    
    public function new(?seed:IntSeed)
    {
        set_seed(seed);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private function set_seed(seed:IntSeed):IntSeed
    {
        mseed = seed.value();
        return seed;
    }
    
    /*==================================================
        Generator Methods
    ==================================================*/
    
    public inline function nextInt():Int
    {
        return this.nextIntFromFloat();
    }
    
    public inline function nextFloat():Float
    {
        var x:Float = Math.sin(mseed++) * FACTOR;
        return x - Math.floor(x);
    }
    
    public inline function nextBool():Bool
    {
        return this.nextBoolFromFloat();
    }
}
