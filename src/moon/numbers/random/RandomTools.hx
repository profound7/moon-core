package moon.numbers.random;

import moon.numbers.random.Random;

/**
 * ...
 * @author Munir Hussin
 */
class RandomTools
{
    public static inline var FLOAT_FACTOR:Float = 0.00000000046566128742;
    public static inline var MAX_INT:Int = 0x7FFFFFFF;
    
    
    // random float -> int
    public static inline function nextIntFromFloat(rnd:TRandom):Int
    {
        return Std.int((rnd.nextFloat() * 2 - 1) * MAX_INT);
    }
    
    // random float -> bool
    public static inline function nextBoolFromFloat(rnd:TRandom):Bool
    {
        return rnd.nextFloat() < 0.5;
    }
    
    // random uint -> float
    public static inline function nextFloatFromInt(rnd:TRandom):Float
    {
        //var r:Float = rnd.nextInt() * FLOAT_FACTOR;
        return (rnd.nextInt() / MAX_INT) * 0.5 + 0.5;
    }
    
    // random uint -> bool
    public static inline function nextBoolFromInt(rnd:TRandom):Bool
    {
        return (rnd.nextInt() & 1) == 0;
    }
}
