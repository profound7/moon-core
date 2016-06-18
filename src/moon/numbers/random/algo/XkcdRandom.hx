package moon.numbers.random.algo;

using moon.numbers.random.RandomTools;

/**
 * https://xkcd.com/221/
 * yes, this is a joke
 * 
 * @author Munir Hussin
 */
class XkcdRandom
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
        return 4;
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
