package moon.numbers.random;

import moon.numbers.random.algo.NativeRandom;

/**
 * http://en.wikipedia.org/wiki/List_of_random_number_generators
 * http://eternallyconfuzzled.com/arts/jsw_art_rand.aspx
 * https://github.com/rubycon/isaac.js/blob/master/isaac.js
 * http://en.wikipedia.org/wiki/Xorshift
 * http://en.wikipedia.org/wiki/Lagged_Fibonacci_generator
 * 
 * HQ random (between quality and speed)
 * http://www.javamex.com/tutorials/random_numbers/numerical_recipes.shtml
 * 
 * @author Munir Hussin
 */
@:forward abstract Random(TRandom) to TRandom from TRandom
{
    public static var native(default, null):Random = new NativeRandom();
    
    public var distributions(get, never):RandomDistributions;
    public var create(get, never):RandomCreate;
    public var arrays(get, never):RandomArrays;
    
    /*==================================================
        Constructors
    ==================================================*/
    
    public function new()
    {
        this = native;
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private inline function get_distributions():RandomDistributions
    {
        return this;
    }
    
    private inline function get_create():RandomCreate
    {
        return this;
    }
    
    private inline function get_arrays():RandomArrays
    {
        return this;
    }
    
    /*==================================================
        Basic methods
    ==================================================*/
    
    /**
     * Generates a random Int in range [0...hi) exclusive of `hi`
     * This is similar to Std.random(x)
     * @return returns a random 32-bit Int
     */
    public inline function below(hi:Int = 0x7FFFFFFF):Int
    {
        //return between(0, hi - 1);
        return Std.int(this.nextFloat() * hi);
    }
    
    /**
     * Generates a random Int in range [lo...hi] inclusive of `hi`
     * @return returns a random 32-bit Int
     */
    public inline function between(lo:Int = 0, hi:Int = 0x7FFFFFFF):Int
    {
        return Std.int(uniform(lo, hi + 1.0));
    }
    
    /**
     * Choose a random int in the range(start, stop, [step]).
     * This fixes the problem with between(start, stop) which includes
     * the endpoint, which you sometimes do not want.
     * @return returns a random 32-bit Int
     */
    public function range(start:Int = 0, ?stop:Int, step:Int = 1):Int
    {
        if (stop == null)
        {
            if (start > 0) // no stop, so take start as the stop
                return below(start);
            throw "empty range for range()";
        }
            
        // stop argument is supplied
        var width:Int = stop - start;
        
        if (step == 1)
        {
            if (width > 0)
                return Std.int(start + below(width));
            else
                throw "empty range for range(start, stop, step)";
        }
            
        // non-unit step argument is supplied.
        var n:Int;
        if (step > 0)
            n = Std.int((width + step - 1) / step);
        else if (step < 0)
            n = Std.int((width + step + 1) / step);
        else
            throw "zero step for range()";
            
        if (n <= 0)
            throw "empty range for range()";
            
        return start + step * below(n);
    }
    
    /**
     * Generates a random Float in range [lo...hi), excluding `hi`
     * @return returns a random Float between two floats
     */
    public inline function uniform(lo:Float = 0.0, hi:Float = 1.0):Float
    {
        return lo + this.nextFloat() * (hi - lo);
    }
    
    /**
     * Generates a random Bool with a probability of `p`
     * @return returns True with a probability of `p`, False with a probability of 1-`p`
     */
    public inline function chance(p:Float):Bool
    {
        return this.nextFloat() < p;
    }
    
    
    /*==================================================
        Other methods
    ==================================================*/
        
    /**
     * Using a `sides`-sided dice, roll `count` of them, and sum the total
     * @param count     the number of dice to roll
     * @param sides     number of sides per dice (default 6)
     * @param start     the lowest number on the dice (default 1)
     * @param step      the increment of numbers on the dice (default 1)
     * @return          the sum of the rolled dice
     */
    public function dice<T>(count:Int, sides:Int=6, start:Int=1, step:Int=1):Int
    {
        var stop:Int = sides * step + 1;
        var total:Int = 0;
        for (i in 0...count)
            total += range(start, stop, step);
            //total += between(1, sides);
            //total += Math.floor(this.float() * sides);
        return total;
    }
    
}


typedef TRandom =
{
    @:noCompletion private var _gauss:Float;
    @:noCompletion private var _hasGauss:Bool;
    
    /**
     * Generates 32 bits of randomness.
     */
    public function nextInt():Int;
    
    /**
     * Generates a random Float between [0...1)
     */
    public function nextFloat():Float;
    
    /**
     * Generates true or false
     */
    public function nextBool():Bool;
}



typedef TSeedableRandom =
{
    > TRandom,
    public var seed(never, set):Dynamic;
}