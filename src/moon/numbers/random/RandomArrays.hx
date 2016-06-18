package moon.numbers.random;

import moon.numbers.random.Random;

/**
 * @author Munir Hussin
 */
abstract RandomArrays(Random) to Random from Random
{
    /*==================================================
        Methods
    ==================================================*/
    
    /**
     * pick a random element from an array
     * @return returns a random 32-bit Int
     */
    public inline function choice<T>(a:Array<T>):T
    {
        return a[this.below(a.length)];
    }
    
    /**
     * Unbiased in-place shuffle algo, Fisher-Yates (Knuth) Shuffle
     * @param a         the input array to shuffle
     */
    public function shuffle<T>(a:Array<T>):Void
    {
        var i:Int = a.length;
        var j:Int;
        var tmp:T;
        
        while (i >= 1)
        {
            //j = Math.floor(this.float() * (i+1));
            j = this.below(i--);
            
            tmp = a[i];
            a[i] = a[j];
            a[j] = tmp;
        }
    }
    
    /**
     * Returns a new array containing elements from the population
     * while leaving the original population unchanged.
     * 
     * A random element in the population will never be picked
     * more than once.
     * 
     * If k is greater than population size, an exception
     * is thrown.
     * 
     * If you wish to allow repetition, use pick();
     * 
     * @param population    a complete set of possible values
     * @param k             number of unique samples to pick from the population
     */
    public function sample<T>(population:Array<T>, k:Int):Array<T>
    {
        var n:Int = population.length;
        var a:Array<Int> = [for (i in 0...n) i];
        var result:Array<T> = [];
        
        var x:Int;
        var tmp:Int;
        
        if (k > n)
            throw "sample k has invalid value";
            
        // should loop at most k times
        while (k-->0)
        {
            // pick a random item and add to result
            x = this.below(n);
            result.push(population[a[x]]);
            
            // a[n] now points to the last item
            n--;
            
            // swap the random item with the last item
            tmp = a[x];
            a[x] = a[n];
            a[n] = tmp;
        }
        
        return result;
    }
    
    /**
     * Returns a new array containing elements from the population.
     * It is possible for a random element in the population to be
     * picked more than once.
     * 
     * Since repetition is allowed, k can be greater than the
     * population size.
     * 
     * If you don't wish to allow repetition, use sample();
     * 
     * @param population    a complete set of possible values
     * @param k             number of samples to pick from the population
     */
    public function pick<T>(population:Array<T>, k:Int):Array<T>
    {
        return [for (_ in 0...k) choice(population)];
    }
}