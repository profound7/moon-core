package moon.numbers.random.algo;

using moon.numbers.random.RandomTools;

/**
 * The underlying platform's random function.
 * This has no seed.
 * 
 * @author Munir Hussin
 */
class NativeRandom
{
    public var _gauss:Float = 0;
    public var _hasGauss:Bool = false;
    
    public function new()
    {
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
        return Math.random();
    }
    
    public inline function nextBool():Bool
    {
        return this.nextBoolFromFloat();
    }
}
