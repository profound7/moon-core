package moon.numbers.big;

import haxe.Timer;
import moon.core.Pair;
import moon.numbers.random.Random;

/**
 * https://github.com/dimchansky/real-life-applications-of-mathematics/blob/master/code/NaiveBayes/BigRational.cs
 * 
 * Some of these methods are implemented very very poorly.
 * 
 * @author Munir Hussin
 */
class BigMath
{
    // finding large prime optimization
    // http://stackoverflow.com/a/23039391/3761791
    private static var GCD_30_DELTA = [6, 4, 2, 4, 2, 4, 6, 2];
    
    /**
     * Extended euclidean algorithm based on:
     * https://comeoncodeon.wordpress.com/2011/10/09/modular-multiplicative-inverse/
     * 
     * This function returns Pair<g, Pair<x, y>> where
     * `g` is the gcd of `a` and `b` and a pair `x` and `y` where
     * `x` and `y` is of the equation ax + by = gcd(a, b)
     */
    public static function extendedEuclid(a:BigInteger, b:BigInteger):Pair<BigInteger, Pair<BigInteger, BigInteger>>
    {
        var x:BigInteger = 1;
        var y:BigInteger = 0;
        var xLast:BigInteger = 0;
        var yLast:BigInteger = 1;
        var q, r, m, n;
        
        while (a != 0)
        {
            var t = b.divmod(a);
            q = t.quotient;
            r = t.remainder;
            
            m = xLast - q * x;
            n = yLast - q * y;
            
            xLast = x;
            yLast = y;
            x = m;
            y = n;
            b = a;
            a = r;
        }
        
        return Pair.of(b, Pair.of(xLast, yLast));
    }
    
    /**
     * Modulus multiplicative inverse
     */
    public static function modInv(a:BigInteger, m:BigInteger):BigInteger
    {
        return (extendedEuclid(a, m).b.a + m) % m;
    }
    
    /**
     * Searches and returns a random prime number within a given
     * range [lo, hi). An optional `not` to reject a specific prime
     * number (needed for RSA).
     * 
     * The bigger the bits, the longer it'll take to find a random prime.
     */
    public static function randomPrime(lo:BigInteger, hi:BigInteger, ?not:BigInteger, ?rnd:Random):BigInteger
    {
        if (not == null) not = BigInteger.ZERO;
        var deltaIdx:Int = 0;
        var n:BigInteger = BigInteger.randomBetween(lo, hi);
        
        // align to 30k + 1
        n += BigInteger.of(31) - (n % 30);
        //if (n.isEven()) ++n;
        
        while (true)
        {
            // exceeded range
            if (n >= hi || n == not)
            {
                n = BigInteger.randomBetween(lo, hi, rnd);
                n += BigInteger.of(31) - (n % 30);
                //if (n.isEven()) ++n;
            }
            // within range
            else if (n.isProbablePrime(1))
            {
                // based on benchmarks between isPrime, isProbablePrime(1),
                // isProbablePrime(2) ... isProbablePrime(n):
                //
                // - isPrime is most often the fastest when the number
                //   is not a prime.
                // - isProbablePrime(1...n) is only faster than isPrime
                //   when the number is actually prime, however, if the n is
                //   big enough, then isPrime will be faster.
                
                //if (n.isPrime())
                    break;
                
                //n += 2;
            }
            else
            {
                //n = BigInteger.fastAdd(n, 2);
                n = BigInteger.fastAdd(n, GCD_30_DELTA[deltaIdx++ % 8]);
            }
        }
        
        return n;
    }
    
    
    public static function sqrti(x:BigInteger):BigInteger
    {
        var div:BigInteger = BigInteger.of(1).shiftLeft(Std.int(x.bits / 2));
        var div2 = div;
        
        while (true)
        {
            var y:BigInteger = (div + (x / div)) >> 1;
            
            if (y == div || y == div2)
                return y;
                
            div2 = div;
            div = y;
        }
    }
    
    public static function sqrt(n:BigRational, digits:Int=10):BigRational
    {
        var x:BigRational = 1;
        var prev:String = "";
        var curr:String = "";
        var i:Int = 0;
        
        while (true)
        {
            ++i;
            
            x = BigRational.HALF * (x + (n / x));
            curr = x.toDecimal(digits);
            //trace('$i : $curr');
            
            // if you get the same result twice, stop
            if (curr == prev)
                break;
                
            prev = curr;
        }
        
        //trace('$i iterations');
        return x;
    }
    
    private static inline var LOG2 = Math.log(2.0);
    
    private static function logi(x:BigInteger):Float
    {
        if (x == 1) return 0.0;
        var bits:Int = x.bits - 1023; // any value in 60..1023 is ok
        
        if (bits > 0)
            x = x >> bits;
            
        var result:Float = Math.log(x.toFloat());
        return bits > 0 ? result + bits * LOG2 : result;
    }
    
    // log(ab) = log(a) + log(b)
    // log_e(a) = log_2(a) / log_2(e)
    // log_e(2) log_e(x)
    /*private static function logi(x:BigInteger):Float
    {
        if (x == 1) return 0.0;
        
        var shift = 16;
        var big = 1 << shift;
        var sum:Float = 0;
        
        while (x > big)
        {
            var ab = x;
            var a = ab >> shift;
            var b = ab / a;
            
            trace(ab);
            trace(a * b);
            trace(a);
            trace(b);
            
            sum += Math.log(b.toFloat());
            x = a;
        }
        
        
        sum += Math.log(x.toFloat());
        return sum;
    }*/
    
    // log(a/b) = log(a) - log(b)
    public static function log(x:BigRational):Float
    {
        return logi(x.numerator) - logi(x.denominator);
    }
    
    
    public function pow(v:BigRational, exp:BigInteger):BigRational
    {
        if (exp == 0)
        {
            return BigRational.ONE;
        }
        else if (exp.sign) // negative exponent
        {
            if (v.isZero())
            {
                throw "Cannot raise zero to a negative power";
            }
            
            v = v.recipocate();
            exp = exp.negate();
        }
        
        var result:BigRational = v;
        
        while (exp > 1)
        {
            result *= v;
            --exp;
        }
        
        return result;
    }
    
    
    public static function trig(x:BigRational, digits:Int=20, start:Int, t0:BigRational):BigRational
    {
        var prev:String = "";
        var curr:String = "";
        var sub:Bool = true;
        var i:Int = 0;
        var j:Int = start;                  // start
        
        var f:BigInteger = 1;
        var n:BigRational;
        var x2:BigRational = x * x;
        var xp:BigRational = t0;            // first term
        
        var c:BigRational = xp;
        
        
        while (true)
        {
            ++i;
            j += 2;
            
            // 3! == 1 * 2 * 3
            xp = xp * x2;
            //trace('x^$j = $xp');
            
            f = f * (j - 1) * (j);
            //trace('f($j): $f');
            
            n = xp / f;
            if (sub) n = -n;
            
            //trace('term $j: $c + $n');
            
            c += n;
            
            sub = !sub;
            
            curr = c.toDecimal(digits);
            //trace('$i : $curr');
            
            // if you get the same result twice, stop
            if (curr == prev)
                break;
                
            prev = curr;
        }
        
        //trace('$i iterations');
        return c;
    }
    
    
    public static function sin(x:BigRational, digits:Int=20):BigRational
    {
        return trig(x, digits, 1, x);
    }
    
    public static function cos(x:BigRational, digits:Int=20):BigRational
    {
        return trig(x, digits, 0, 1);
    }
    
}