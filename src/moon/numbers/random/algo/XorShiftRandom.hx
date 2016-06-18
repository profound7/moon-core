package moon.numbers.random.algo;

import haxe.Int64;
import moon.numbers.random.Random.TSeedableRandom;
import moon.numbers.random.Seed.IntArraySeed;

using moon.numbers.random.RandomTools;

/**
 * XorShift with selectable algorithm.
 * 
 * http://en.wikipedia.org/wiki/Xorshift
 * https://github.com/stroncium/hx-rnd/blob/master/rnd/FastRNG.hx
 * https://github.com/stroncium/hx-various
 * 
 * @author Munir Hussin
 */
class XorShiftRandom
{
    public var _gauss:Float = 0;
    public var _hasGauss:Bool = false;
    public var seed(never, set):IntArraySeed;
    
    public var r:TSeedableRandom;
    
    public function new(?seed:IntArraySeed, ?algo:XorShiftAlgo)
    {
        if (algo == null) algo = XS32;
        
        r = switch (algo)
        {
            case XSCustom(bits):
                new XorShiftCustomRandom(seed, bits);
                
            case XS32:
                new XorShift32Random(seed);
                
            case XS128:
                new XorShift128Random(seed);
                
            case XS64Star:
                new XorShift64StarRandom(seed);
                
            case XS1024Star:
                new XorShift1024StarRandom(seed);
                
            case XS128Plus:
                new XorShift128PlusRandom(seed);
        }
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private inline function set_seed(seed:IntArraySeed):IntArraySeed
    {
        return r.seed = seed;
    }
    
    /*==================================================
        Generator Methods
    ==================================================*/
    
    public inline function nextInt():Int
    {
        return r.nextInt();
    }
    
    public inline function nextFloat():Float
    {
        return r.nextFloat();
    }
    
    public inline function nextBool():Bool
    {
        return r.nextBool();
    }
}

enum XorShiftAlgo
{
    XS32;
    XS128;
    XS64Star;
    XS1024Star;
    XS128Plus;
    XSCustom(bits:Int);
}

/**
 * Generalized XorShift with arbitrary state size.
 * 
 * @author Munir Hussin
 */
class XorShiftCustomRandom
{
    public var _gauss:Float = 0;
    public var _hasGauss:Bool = false;
    public var seed(never, set):IntArraySeed;
    
    private var state:List<Int>;
    private var length:Int;
    
    
    public function new(?seed:IntArraySeed, stateBits:Int=32)
    {
        length = Math.ceil(stateBits / 32);
        set_seed(seed);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private function set_seed(seed:IntArraySeed):IntArraySeed
    {
        var values:Array<Int> = seed.value(length);
        state = new List<Int>();
        for (v in values)
            state.add(v);
        return seed;
    }
    
    /*==================================================
        Generator Methods
    ==================================================*/
    
    public function nextInt():Int
    {
        var x:Int = state.first();
        var t:Int = x ^ (x << 11);
        var w:Int = state.last();
        
        state.pop();
        w = w ^ (w >>> 19) ^ (t ^ (t >>> 8));
        state.add(w);
        
        return w;
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





class XorShift32Random
{
    public var _gauss:Float = 0;
    public var _hasGauss:Bool = false;
    public var seed(never, set):IntArraySeed;
    
    public var x:Int;
    
    public function new(?seed:IntArraySeed)
    {
        set_seed(seed);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private function set_seed(seed:IntArraySeed):IntArraySeed
    {
        var values:Array<Int> = seed.value(1);
        x = values[0];
        return seed;
    }
    
    /*==================================================
        Generator Methods
    ==================================================*/
    
    public inline function nextInt():Int
    {
        var t:Int = (x ^ (x << 11));
        return x = (x ^ (x >>> 19)) ^ (t ^ (t >>> 8));
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

class XorShift128Random
{
    public var _gauss:Float = 0;
    public var _hasGauss:Bool = false;
    public var seed(never, set):IntArraySeed;
    
    public var x:Int;
    public var y:Int;
    public var z:Int;
    public var w:Int;
    
    public function new(?seed:IntArraySeed)
    {
        set_seed(seed);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private function set_seed(seed:IntArraySeed):IntArraySeed
    {
        var values:Array<Int> = seed.value(4);
        x = values[0];
        y = values[1];
        z = values[2];
        w = values[3];
        return seed;
    }
    
    /*==================================================
        Generator Methods
    ==================================================*/
    
    public function nextInt():Int
    {
        var t:Int = x ^ (x << 11);
        x = y; y = z; z = w;
        return w = w ^ (w >>> 19) ^ (t ^ (t >>> 8));
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


class XorShift64StarRandom
{
    public var _gauss:Float = 0;
    public var _hasGauss:Bool = false;
    public var seed(never, set):IntArraySeed;
    
    public var x:Int64;
    public var tmp:Array<Int>;
    
    public function new(?seed:IntArraySeed)
    {
        set_seed(seed);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private function set_seed(seed:IntArraySeed):IntArraySeed
    {
        var values:Array<Int> = seed.value(2);
        x = Int64.make(values[1], values[0]);
        tmp = [];
        return seed;
    }
    
    /*==================================================
        Methods
    ==================================================*/
    
    public inline function nextInt64():Int64
    {
        x ^= x >> 12;
        x ^= x << 25;
        x ^= x >> 27;
        // UINT64_C(2685821657736338717) = [625341585, 1332534557]
        return x * Int64.make(625341585, 1332534557);
    }
    
    /*==================================================
        Generator Methods
    ==================================================*/
    
    public inline function nextInt():Int
    {
        if (tmp.length > 0)
        {
            return tmp.pop();
        }
        else
        {
            var val:Int64 = nextInt64();
            tmp.push(val.high);
            return val.low;
        }
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


class XorShift1024StarRandom
{
    public var _gauss:Float = 0;
    public var _hasGauss:Bool = false;
    public var seed(never, set):IntArraySeed;
    
    public var s:Array<Int64>;
    public var p:Int;
    public var tmp:Array<Int>;
    
    public function new(?seed:IntArraySeed)
    {
        set_seed(seed);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private function set_seed(seed:IntArraySeed):IntArraySeed
    {
        var values:Array<Int> = seed.value(32);
        var i:Int = 32 - 2;
        s = [];
        
        while (i >= 0)
        {
            s[Std.int(i / 2)] = Int64.make(values[i + 1], values[i]);
            //trace("[" + (Std.int(i/2)) + "] " + (i + 1) + " " + i);
            i -= 2;
        }
        //trace("length: " + s.length);
        
        p = 0;
        tmp = [];
        return seed;
    }
    
    /*==================================================
        Methods
    ==================================================*/
    
    public inline function nextInt64():Int64
    {
        var s0:Int64 = s[p];
        var s1:Int64 = s[p = (p + 1) & 15];
        s1 ^= s1 << 31; // a
        s1 ^= s1 >> 11; // b
        s0 ^= s0 >> 30; // c
        
        // UINT64_C(1181783497276652981) = [275155412, 1419247029]
        return (s[p] = s0 ^ s1) * Int64.make(275155412, 1419247029);
    }
    
    /*==================================================
        Generator Methods
    ==================================================*/
    
    public inline function nextInt():Int
    {
        if (tmp.length > 0)
        {
            return tmp.pop();
        }
        else
        {
            var val:Int64 = nextInt64();
            tmp.push(val.high);
            return val.low;
        }
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


class XorShift128PlusRandom
{
    public var _gauss:Float = 0;
    public var _hasGauss:Bool = false;
    public var seed(never, set):IntArraySeed;
    
    public var s:Array<Int64>;
    public var tmp:Array<Int>;
    
    public function new(?seed:IntArraySeed)
    {
        set_seed(seed);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private function set_seed(seed:IntArraySeed):IntArraySeed
    {
        var values:Array<Int> = seed.value(4);
        
        s =
        [
            Int64.make(values[3], values[2]),
            Int64.make(values[1], values[0]),
        ];
        
        tmp = [];
        return seed;
    }
    
    /*==================================================
        Methods
    ==================================================*/
    
    public inline function nextInt64():Int64
    {
        var x = s[0];
        var y = s[1];
        s[0] = y;
        x ^= x << 23;       // a
        x ^= x >> 17;       // b
        x ^= y ^ (y >> 26); // c
        s[1] = x;
        
        return x + y;
    }
    
    /*==================================================
        Generator Methods
    ==================================================*/
    
    public inline function nextInt():Int
    {
        if (tmp.length > 0)
        {
            return tmp.pop();
        }
        else
        {
            var val:Int64 = nextInt64();
            tmp.push(val.high);
            return val.low;
        }
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