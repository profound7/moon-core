package moon.numbers.random;

import haxe.ds.Vector;
import moon.core.Bits;
import moon.numbers.stats.Stats;

using moon.tools.VectorTools;
using moon.tools.FloatTools;

/**
 * ...
 * @author Munir Hussin
 */
class RandomTest
{
    
    public static function countBits(r:Random, iterations:Int):Vector<Int>
    {
        var count = new Vector<Int>(Bits.size);
        count.fill(0);
        
        for (i in 0...iterations)
        {
            var x:Bits = r.nextInt();
            //x.on(2);
            //x.off(3);
            
            for (b in 0...Bits.size)
            {
                if (x.get(b)) count[b] = count[b] + 1;
            }
        }
        
        return count;
    }
    
    public static function countBitsNormalized(r:Random, iterations:Int):Vector<Float>
    {
        var count = countBits(r, iterations);
        var stats = new Vector<Float>(count.length);
        
        for (i in 0...count.length)
        {
            stats[i] = count[i] / iterations;
        }
        
        return stats;
    }
    
    public static function countBitsNormalizedError(r:Random, iterations:Int):Vector<Float>
    {
        var count = countBits(r, iterations);
        var stats = new Vector<Float>(count.length);
        
        for (i in 0...count.length)
        {
            stats[i] = 0.5 - (count[i] / iterations);
        }
        
        return stats;
    }
    
    public static function testPrintBits(r:Random, iterations:Int):Void
    {
        var count = new Vector<Int>(Bits.size);
        count.fill(0);
        
        for (i in 0...iterations)
        {
            var x:Bits = r.nextInt();
            trace(x);
        }
    }
    
    private static function f(x:Float):Float return x;
    
    public static function test(r:Random, iterations:Int=100000, errorTolerance:Float=0.01):Map<Int, Float>
    {
        var stats:Stats<Float> = countBitsNormalized(r, iterations);
        var report = new Map<Int, Float>();
        
        var actualMedian = stats.median(f);
        var actualMean = stats.mean(f);
        var expectedMean = 0.5;
        var errorMedian = expectedMean - actualMedian;
        var errorMean = expectedMean - actualMean;
        
        var zScores = stats.zScores(f);
        
        trace('expected mean: $expectedMean');
        
        trace('actual mean: $actualMean');
        trace('actual median: $actualMedian');
        
        trace('error mean: $errorMean');
        trace('error median: $errorMedian');
        
        trace('data: ' + [for (s in stats) s]);
        
        for (i in 0...stats.length)
        {
            var actualError = expectedMean - stats[i];
            
            if (Math.abs(actualError) > 0.1)
            {
                trace('bit $i:');
                trace('   data:  ' + stats[i]);
                trace('   error: ' + actualError);
            }
        }
        
        
        for (i in 0...zScores.length)
        {
            var z = zScores[i];
            
            if (z.val > 2 || z.val < -2)
            {
                trace('bit $i:');
                trace('   data:  ' + z.data);
                trace('   error:  ' + (z.data - expectedMean));
                trace('   zScore: ' + z.val);
                report.set(i, z.val);
            }
        }
        
        return report;
    }
    
}