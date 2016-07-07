package moon.tools;

import moon.core.Compare;
import moon.numbers.math.Predicate;
import moon.numbers.math.Transform;
import moon.numbers.stats.StatMeta;

using moon.tools.FloatTools;
using moon.tools.StatTools;

private typedef ValueFn<T> = T->Float;
private typedef FoldFn<T> = Array<T>->ValueFn<T>->Float;

/**
 * If you don't wish to repeat the value:T->Float all over the place,
 * then use moon.numbers.stats.Stats class.
 * 
 * @author Munir Hussin
 */
class StatTools
{
    /*==================================================
        Service Methods
    ==================================================*/
    
    public static function sift<T>(data:Array<T>, value:T->Float, cmp:Float->Float->Bool):Float
    {
        if (data == null || data.length == 0)
            throw "No data";
            
        var x:Float = value(data[0]);
        var y:Float = 0.0;
        
        for (i in 1...data.length)
        {
            y = value(data[i]);
            if (cmp(y, x)) x = y;
        }
        
        return x;
    }
    
    /*==================================================
        Methods
    ==================================================*/
    
    /**
     * Sums all values in the array.
     */
    public static function sum<T>(data:Array<T>, value:T->Float):Float
    {
        var total = 0.0;
        for (d in data)
            total += value(d);
        return total;
    }
    
    public static inline function min<T>(data:Array<T>, value:T->Float):Float
    {
        return data.sift(value, Predicate.lesserThan);
    }
    
    public static inline function max<T>(data:Array<T>, value:T->Float):Float
    {
        return data.sift(value, Predicate.greaterThan);
    }
    
    public static inline function percentile<T>(data:Array<T>, p:Float, value:T->Float):Float
    {
        return data.filterPercentile(p, value).mean(value);
    }
    
    /**
     * Seperate the data into `len` distinct groups
     * and return the number of values in each group.
     */
    public static function histogram<T>(data:Array<T>, len:Int, lo:Float, hi:Float, value:T->Float):Array<Int>
    {
        var ret:Array<Int> = [for (i in 0...len) 0];
        for (d in data)
        {
            var f:Float = value(d);
            var i:Int = f.bin(len, lo, hi);
            ++ret[i];
        }
        return ret;
    }
    
    /*==================================================
        Central Tendencies
    ==================================================*/
    
    /**
     * Mid range is the mean of max and min
     */
    public static inline function mid<T>(data:Array<T>, value:T->Float):Float
    {
        return (data.max(value) + data.min(value)) * 0.5;
    }
    
    public static inline function mean<T>(data:Array<T>, value:T->Float):Float
    {
        // arithmetic mean without overflow
        /*var avg:Float = 0.0;
        var n:Int = 1;
        
        for (d in data)
            avg += (value(d) - avg) / n++;
        return avg;*/
        
        return data.sum(value) / data.length;
    }
    
    public static inline function median<T>(data:Array<T>, value:T->Float):Float
    {
        return data.filterMedian(value).mean(value);
    }
    
    /**
     * Returns the highest occuring value.
     * The function returns an array because there might be
     * more than one value.
     */
    public static function mode<T>(data:Array<T>, value:T->Float):Array<Float>
    {
        var items:Array<Array<T>> = data.filterMode(value);
        return [for (i in items) if (i.length > 0) value(i[0])];
    }
    
    /*==================================================
        Filter Methods
    ==================================================*/
    
    public static inline function filterMin<T>(data:Array<T>, value:T->Float):Array<T>
    {
        var x = data.min(value);
        return data.filter(function(d) return value(d) == x);
    }
    
    public static inline function filterMax<T>(data:Array<T>, value:T->Float):Array<T>
    {
        var x = data.max(value);
        return data.filter(function(d) return value(d) == x);
    }
    
    /**
     * filterMedian(value) ==> filterPercentile(0.5, value)
     */
    public static function filterPercentile<T>(data:Array<T>, p:Float, value:T->Float):Array<T>
    {
        var tmp:Array<T> = data.copy();
        tmp.sort(Compare.map(value, Compare.asc));
        
        var x:Float = p.interpolate(0.0, 1.0, 0, tmp.length - 1);
        var i:Int = Math.floor(x);
        
        return x == i ?
            [tmp[i]] :
            [tmp[i], tmp[i + 1]];
    }
    
    public static inline function filterMedian<T>(data:Array<T>, value:T->Float):Array<T>
    {
        return data.filterPercentile(0.5, value);
    }
    
    /**
     * Like histogram, the data is seperated into `len` distinct groups,
     * but the actual grouped values is returned instead of returning
     * the count of each group.
     */
    public static function groupByHistogram<T>(data:Array<T>, len:Int, lo:Float, hi:Float, value:T->Float):Array<Array<T>>
    {
        var ret:Array<Array<T>> = [for (i in 0...len) []];
        for (d in data)
            ret[value(d).bin(len, lo, hi)].push(d);
        return ret;
    }
    
    public static function filterMode<T>(data:Array<T>, value:T->Float):Array<Array<T>>
    {
        var min:Float = data.min(value);
        var max:Float = data.max(value);
        var len:Int = Math.ceil(max) - Math.floor(min) + 1;
        var hist = data.groupByHistogram(len, min, max, value);
        var items:Array<Array<T>> = hist.filterMax(function(a) return a.length);
        return items;
    }
    
    /*==================================================
        Deviations
    ==================================================*/
    
    /**
     * For every data point, calculate its difference from
     * the average value. That difference can be transformed
     * to another value. The definition of average can
     * be mean, median, mode, or mid.
     */
    public static function deviations<T>(data:Array<T>, value:T->Float, avg:FoldFn<T>, transform:Float->Float):Array<StatMeta<T>>
    {
        var center:Float = avg(data, value);
        return [for (d in data) new StatMeta<T>(d, transform(value(d) - center))];
    }
    
    public static function zScores<T>(data:Array<T>, value:T->Float):Array<StatMeta<T>>
    {
        var m:Float = data.mean(value);
        var sigma:Float = data.standardDeviation(value);
        return [for (d in data) new StatMeta<T>(d, (value(d) - m) / sigma)];
    }
    
    /*==================================================
        Population Methods
    ==================================================*/
    
    public static function variance<T>(data:Array<T>, value:T->Float):Float
    {
        return data.deviations(value, mean, Transform.squared).mean(StatMeta.value);
    }
    
    public static function standardDeviation<T>(data:Array<T>, value:T->Float):Float
    {
        return Math.sqrt(data.variance(value));
    }
    
    /*==================================================
        Sample Methods
    ==================================================*/
    
    public static inline function sampleMean<T>(data:Array<T>, value:T->Float):Float
    {
        return data.sum(value) / (data.length - 1);
    }
    
    public static function sampleVariance<T>(data:Array<T>, value:T->Float):Float
    {
        return data.deviations(value, mean, Transform.squared).sampleMean(StatMeta.value);
    }
    
    public static function sampleStandardDeviation<T>(data:Array<T>, value:T->Float):Float
    {
        return Math.sqrt(data.sampleVariance(value));
    }
    
    /*==================================================
        Partitions
    ==================================================*/
    
    public static function groupByPartitions<T>(data:Array<T>, partitions:Array<Float>, value:T->Float):Array<Array<T>>
    {
        var result:Array<Array<T>> = [for (i in 0...partitions.length+1) []];
        
        // TODO: benchmark with sorting the data first, then iterate once,
        // directly putting the data into the correct partition.
        
        for (d in data)
        {
            var v:Float = value(d);
            var i:Int = partitionIndex(partitions, v);
            result[i].push(d);
        }
        
        return result;
    }
    
    public static function partitionIndex<T>(partitions:Array<Float>, value:Float):Int
    {
        for (i in 0...partitions.length + 1)
            if (value < partitions[i])
                return i;
        return partitions.length;
    }
    
    // partition based on percentiles
    public static function linearPartition<T>(data:Array<T>, partitions:Int, value:T->Float):Array<Float>
    {
        var x:Float = 1.0 / partitions;
        var result:Array<Float> = [];
        
        for (i in 1...partitions)
        {
            result.push(percentile(data, i * x, value));
        }
        
        return result;
    }
    
    // partition based on bell curve
    //      |-------------------| totalWidth
    //                     |----| partitionWidth (e.g. partition: 4)
    // left |
    //  ----2----1----0----1----2---- zScore
    public static function curvedPartition<T>(data:Array<T>, partitions:Int, maxSigma:Float=2, value:T->Float):Array<Float>
    {
        var sigma:Float = data.standardDeviation(value);
        var center:Float = data.mean(value);
        
        var totalWidth:Float = 2 * maxSigma * sigma;
        var partitionWidth:Float = totalWidth / partitions;
        var left:Float = center - maxSigma * sigma;
        
        var result:Array<Float> = [];
        
        for (i in 1...partitions)
        {
            var lo:Float = left + i * partitionWidth;
            //var hi:Float = left + (i+1) * partitionWidth;
            //trace( "From " + lo + " to " + hi );
            result.push(lo);
        }
        
        return result;
    }
    
    public static inline function groupByLinearPartitions<T>(data:Array<T>, partitions:Int, value:T->Float):Array<Array<T>>
    {
        return groupByPartitions(data, linearPartition(data, partitions, value), value);
    }
    
    public static inline function groupByCurvedPartition<T>(data:Array<T>, partitions:Int, maxSigma:Float=2, value:T->Float):Array<Array<T>>
    {
        return groupByPartitions(data, curvedPartition(data, partitions, maxSigma, value), value);
    }
}







