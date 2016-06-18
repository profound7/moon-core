package moon.numbers.math;

/**
 * ...
 * @author Munir Hussin
 */
class Numbers
{
    private static var factorialCache:Array<Float> = [1.0, 1.0];
    
    public static var PI:Float = 3.141592653589793238;
    public static var TAU:Float = 2.0 * 3.141592653589793238;
    public static var PHI:Float = (1 + Math.sqrt(5)) * 0.5; // golden ratio
    public static var E:Float = Math.exp(1.0);              // euler's number
    public static var SQRT_2:Float = Math.sqrt(2);          // pythagora's constant
    public static var SQRT_5:Float = Math.sqrt(5);
    
    /**
     * Multiply all the numbers from a to b, inclusive
     */
    public static function rangeMultiply(a:Int, b:Int):Float
    {
        var x:Float = 1.0;
        for (i in a...b + 1)
            x *= i;
        return x;
    }
    
    private static function generateFactorial(x:Int):Float
    {
        var y:Float = factorialCache[factorialCache.length - 1];
        for (i in factorialCache.length...x + 1)
            factorialCache.push(y *= i);
        return y;
    }
    
    /**
     * x factorial (x!)
     * e.g 5! = 5 * 4 * 3 * 2 * 1
     */
    public static inline function factorial(x:Int):Float
    {
        return x < factorialCache.length ?
            factorialCache[x] :
            generateFactorial(x);
    }
    
    /**
     * nPr = n! / (n-r)!
     */
    public static inline function permutations(n:Int, r:Int):Float
    {
        return factorial(n) / factorial(n - r);
    }
    
    /**
     * nCr = n! / (r! * (n - r)!)
     */
    public static inline function combinations(n:Int, r:Int):Float
    {
        return factorial(n) / (factorial(r) * factorial(n - r));
    }
    
    /**
     * Return the n-th fibonacci sequence
     */
    public static function fibonacci(n:Float):Float
    {
        return Math.fround(Math.pow(PHI, n) / SQRT_5);
    }
    
    
    /**
     * Greatest common divisor of a and b
     */
    public static inline function gcd(a:Float, b:Float):Float
    {
        //return a * b / lcm(a, b);
        return b == 0 ? a : gcd(b, a % b);
    }
    
    /**
     * Lowest common multiple of a and b
     */
    public static inline function lcm(a:Float, b:Float):Float
    {
        return a * b / gcd(a, b);
    }
    
    public static inline function isEven(x:Float):Bool
    {
        return x % 2 == 0;
    }
    
    public static inline function isOdd(x:Float):Bool
    {
        return x % 2 != 0;
    }
    
    /**
     * log with arbitrary base
     */
    public static inline function logb(base:Float, x:Float):Float
    {
        return Math.log(x) / Math.log(base);
    }
    
    /**
     * log base 10
     */
    public static inline function log10(x:Float):Float
    {
        return logb(10, x);
    }
    
    /**
     * log base 2
     */
    public static inline function log2(x:Float):Float
    {
        return logb(2, x);
    }
    
    /**
     * log base e
     */
    public static inline function log(x:Float):Float
    {
        return Math.log(x);
    }
    
    /**
     * Checks whether x is prime
     */
    public static function isPrime(x:Float):Bool
    {
        x = Math.abs(x);
        
        if (x != Math.ffloor(x) || !Math.isFinite(x) || x < 2)
            return false;
            
        if (x == 2 || x == 3 || x == 5)
            return true;
            
        if (x % 2 == 0 || x % 3 == 0 || x % 5 == 0)
            return false;
            
        if (x < 25)
            return true;
            
        
        var rootX:Float = Math.sqrt(x);
        var i:Int = 5;
        var w:Int = 2;
        
        while (i <= rootX)
        {
            if (x % i == 0)
                return false;
                
            i += w;
            
            // prime numbers is of the form 6k+1 and 6k-1 (except for 2 and 3)
            w = 6 - w;
        }
        
        return true;
    }
    
    /**
     * Given a number x, return the next smallest prime number.
     * If x is a prime number, the return value will be larger than x.
     */
    public static function nextPrime(x:Float):Float
    {
        x = Math.ffloor(x);
        
        if (x < 2)
            return 2;
        
        x += isEven(x) ? 1 : 2;
        
        while (!isPrime(x))
            x += 2;
            
        return x;
    }
    
    public static function primeFactors(x:Float):Array<Float>
    {
        if (x != Math.ffloor(x))
            throw "Expected a whole number";
            
        var factors:Array<Float> = [];
        var i:Float = 3.0;
        
        // deal with the only even prime
        while (x % 2 == 0)
        {
            factors.push(2);
            x /= 2;
        }
        
        // i should be odd numbers
        while (i <= x)
        {
            while (x % i == 0)
            {
                factors.push(i);
                x /= i;
            }
            
            i += 2.0;
        }
        
        return factors;
    }
    
    public static function divisors(x:Float):Array<Float>
    {
        if (x < 1 || x != Math.ffloor(x))
            throw "Argument should be a whole number greater than or equals to 1";
            
        var small:Array<Float> = [];
        var large:Array<Float> = [];
        var end:Float = Math.ffloor(Math.sqrt(x));
        var i:Float = 1.0;
        
        while (i <= end)
        {
            if (x % i == 0)
            {
                small.push(i);
                if (i * i != x)  // Don't include a square root twice
                    large.push(x / i);
            }
            
            i += 1.0;
        }
        
        large.reverse();
        return small.concat(large);
    }
}
