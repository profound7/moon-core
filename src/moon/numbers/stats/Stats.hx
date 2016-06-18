package moon.numbers.stats;

import haxe.ds.Vector;
import moon.core.Seq;
import moon.data.iterators.MappedIterator;

using moon.tools.StatTools;

private typedef ValueFn<T> = T->Float;
private typedef FoldFn<T> = Array<T>->ValueFn<T>->Float;

/**
 * Performs stats related calculations on an Array.
 * 
 * Usage:
 * var a:Array<String> = ["alice", "bob", "carol"];
 * var s:Stats<String> = new Stats(a, function(x) return x.length);
 * 
 * trace(s.mean());
 * 
 * @author Munir Hussin
 */
class Stats<T>
{
    public var length(get, never):Int;
    public var data:Array<T>;
    public var value:T->Float;
    
    //public var items(get, never):StatItems<T>;
    //public var sample(get, never):StatSample<T>;
    
    public inline function new(data:Seq<T>, value:T->Float)
    {
        this.data = data.toArray();
        this.value = value;
    }
    
    /*==================================================
        Iterators
    ==================================================*/
    
    public inline function iterator():Iterator<T>
    {
        return data.iterator();
    }
    
    public inline function values():Iterator<Float>
    {
        return new MappedIterator<T,Float>(iterator(), value);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private inline function get_length():Int
    {
        return data.length;
    }
    
    /*private inline function get_items():StatItems<T>
    {
        return this;
    }
    
    private inline function get_sample():StatSample<T>
    {
        return this;
    }*/
    
    
    /*==================================================
        Service methods
    ==================================================*/
    
    public inline function sift(cmp:Float->Float->Bool):Float
    {
        return data.sift(value, cmp);
    }
    
    /*==================================================
        Aggregates
    ==================================================*/
    
    /**
     * Sums all values in the array.
     */
    public inline function sum():Float
    {
        return data.sum(value);
    }
    
    public inline function min():Float
    {
        return data.min(value);
    }
    
    public inline function max():Float
    {
        return data.max(value);
    }
    
    /*==================================================
        Misc
    ==================================================*/
    
    public inline function percentile(p:Float):Float
    {
        return data.percentile(p, value);
    }
    
    /**
     * Seperate the data into `len` distinct groups
     * and return the number of values in each group.
     */
    public inline function histogram(len:Int, lo:Float, hi:Float):Array<Int>
    {
        return data.histogram(len, lo, hi, value);
    }
    
    /*==================================================
        Central Tendencies
    ==================================================*/
    
    /**
     * Mid range is the mean of max and min
     */
    public inline function mid():Float
    {
        return data.mid(value);
    }
    
    public inline function mean():Float
    {
        return data.mean(value);
    }
    
    public inline function median():Float
    {
        return data.median(value);
    }
    
    /**
     * Returns the highest occuring value.
     * The function returns an array because there might be
     * more than one such value.
     * 
     *     [2,2, 3, 4,4, 5, 6,6]
     *     The highest occuring is a 3-way tie [2, 4, 6].
     */
    public inline function mode():Array<Float>
    {
        return data.mode(value);
    }
    
    /*==================================================
        Filters
    ==================================================*/
    
    public inline function filterMin():Array<T>
    {
        return data.filterMin(value);
    }
    
    public inline function filterMax():Array<T>
    {
        return data.filterMax(value);
    }
    
    /**
     * filterMedian() ==> filterPercentile(0.5)
     */
    public inline function filterPercentile(p:Float):Array<T>
    {
        return data.filterPercentile(p, value);
    }
    
    /**
     * filterMedian() ==> filterPercentile(0.5)
     */
    public inline function filterMedian():Array<T>
    {
        return data.filterMedian(value);
    }
    
    /**
     * There could be multiple modes. We return all of them.
     */
    public inline function filterMode():Array<Array<T>>
    {
        return data.filterMode(value);
    }
    
    /*==================================================
        Groupings
    ==================================================*/
    
    /**
     * Like histogram, the data is seperated into `len` distinct groups,
     * but the actual grouped values is returned instead of returning
     * the count of each group.
     */
    public inline function groupByHistogram(len:Int, lo:Float, hi:Float):Array<Array<T>>
    {
        return data.groupByHistogram(len, lo, hi, value);
    }
    
    public inline function groupByPartitions(partitions:Array<Float>):Array<Array<T>>
    {
        return data.groupByPartitions(partitions, value);
    }
    
    public inline function groupByLinearPartitions(partitions:Int):Array<Array<T>>
    {
        return data.groupByLinearPartitions(partitions, value);
    }
    
    public inline function groupByCurvedPartition(partitions:Int, maxSigma:Float=2):Array<Array<T>>
    {
        return data.groupByCurvedPartition(partitions, maxSigma, value);
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
    public inline function deviations(avg:FoldFn<T>, transform:Float->Float):Array<StatMeta<T>>
    {
        return data.deviations(value, avg, transform);
    }
    
    public inline function zScores():Array<StatMeta<T>>
    {
        return data.zScores(value);
    }
    
    public inline function variance():Float
    {
        return data.variance(value);
    }
    
    public inline function standardDeviation():Float
    {
        return data.standardDeviation(value);
    }
    
    /*==================================================
        Sample Methods
    ==================================================*/
    
    public inline function sampleMean():Float
    {
        return data.sampleMean(value);
    }
    
    public inline function sampleVariance():Float
    {
        return data.sampleVariance(value);
    }
    
    public inline function sampleStandardDeviation():Float
    {
        return data.sampleStandardDeviation(value);
    }
    
    /*==================================================
        Partitions
    ==================================================*/
    
    /**
     * partition based on percentiles
     */
    public inline function linearPartition(partitions:Int):Array<Float>
    {
        return data.linearPartition(partitions, value);
    }
    
    public inline function curvedPartition(partitions:Int, maxSigma:Float=2):Array<Float>
    {
        return data.curvedPartition(partitions, maxSigma, value);
    }
}
