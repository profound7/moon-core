package test.numbers;

import moon.core.Compare;
import moon.core.Console;
import moon.core.Text;
import moon.numbers.math.Transform;
import moon.numbers.random.algo.Arc4Random;
import moon.numbers.random.algo.LcgRandom;
import moon.numbers.random.algo.LehmerRandom;
import moon.numbers.random.algo.MersenneTwisterRandom;
import moon.numbers.random.algo.MultiplyCarryRandom;
import moon.numbers.random.algo.NativeRandom;
import moon.numbers.random.algo.SineRandom;
import moon.numbers.random.algo.XorShiftRandom;
import moon.numbers.random.Random;
import moon.test.TestCase;
import moon.test.TestRunner;

using moon.tools.FloatTools;
using moon.tools.StatTools;

/**
 * TODO: Add tests to check correctness on platforms where Int is 64 bits.
 * TODO: Add tests to check correctness of RC4 algorithm.
 * 
 * @author Munir Hussin
 */
class RandomTest extends TestCase
{
    public static inline var quick:Bool = true;
    
    public static function main() 
    {
        var r = new TestRunner();
        r.add(new RandomTest());
        r.run();
    }
    
    /*==================================================
        Service Methods
    ==================================================*/
    
    public static inline function println(v:Dynamic):Void
    {
        //#if debug
            Console.println(v);
        //#end
    }
    
    public static inline function f(v:Float)
    {
        return v.format(3);
    }
    
    public static function algoName(r:Random):String
    {
        var cls = Type.getClassName(Type.getClass(r)).split(".").pop();
        return cls == "XorShift" ?
            algoName(cast(r, XorShiftRandom).r) :
            cls;
    }
    
    public function makeRandom(seed:Dynamic, noNative:Bool=false):Array<Random>
    {
        return
        [
            noNative ?
                new XorShiftRandom(seed, XorShiftAlgo.XS32) :
                new NativeRandom(),
                
            new LcgRandom(seed),
            new LehmerRandom(seed),
            
            new MersenneTwisterRandom(seed),
            new MultiplyCarryRandom(seed),
            
            new Arc4Random(seed),
            new SineRandom(seed),
            
            new XorShift32Random(seed),
            new XorShift64StarRandom(seed),
            new XorShift128Random(seed),
            new XorShift128PlusRandom(seed),
            new XorShift1024StarRandom(seed),
            new XorShiftCustomRandom(seed, 32),
        ];
    }
    
    public function getAlgoNames(ra:Array<Random>):Array<Text>
    {
        return [for (r in ra) algoName(r)];
    }
    
    public function generateValues(r:Random, n:Int):Array<Float>
    {
        var vals = [for (i in 0...n) r.nextFloat()];
        vals.sort(Compare.asc);
        return vals;
    }
    
    public function generateData(ra:Array<Random>, n:Int):Array<Array<Float>>
    {
        return [for (r in ra) generateValues(r, n)];
    }
    
    
    /*==================================================
        Setup
    ==================================================*/
    
    public var rand:Random;
    public var rarr:Array<Random>;
    public var algos:Array<Text>;
    public var out:Array<Array<Float>>;
    public var len:Int;
    
    
    public function setup()
    {
        len = Std.int(Math.pow(2, quick ? 8 : 14));
        
        rand = new NativeRandom();
        rarr = makeRandom("hello");
        algos = getAlgoNames(rarr);
        out = generateData(rarr, len);
    }
    
    /*==================================================
        Test Cases
    ==================================================*/
    
    /**
     * Same seed should generate the same sequence of numbers.
     * Different seed should not generate the same sequence of numbers.
     */
    public function testSeed()
    {
        var n = 10;
        var seedA = rand.create.string(32);
        var seedB = rand.create.string(32);
        
        var ra = makeRandom(seedA, true);
        var rb = makeRandom(seedA, true);
        var rc = makeRandom(seedB, true);
        var oa = generateData(ra, n);
        var ob = generateData(rb, n);
        var oc = generateData(rc, n);
        
        assert.isDeepEqual(oa, ob);
        assert.isNotDeepEqual(oa, oc);
    }
    
    
    public function testXorShift()
    {
        var arr1:Array<Int> = [];
        var arr2:Array<Int> = [];
        
        // these two should produce the same sequence
        var c32:Random = new XorShiftRandom("hello", XSCustom(32));
        var r32:Random = new XorShiftRandom("hello", XS32);
        
        // so should these two
        var c128:Random = new XorShiftRandom("hello", XSCustom(128));
        var r128:Random = new XorShiftRandom("hello", XS128);
        
        for (i in 0...10)
        {
            arr1.push(c32.nextInt());
            arr1.push(c128.nextInt());
            
            arr2.push(r32.nextInt());
            arr2.push(r128.nextInt());
        }
        
        assert.isDeepEqual(arr1, arr2);
    }
}

