package moon.numbers.random;

import moon.core.Char;
import moon.numbers.random.algo.AbstractRandom.FastXorShift32Random;
import moon.strings.HashCode.*;

using moon.tools.HashCodeTools;

/**
 * ...
 * @author Munir Hussin
 */
abstract IntSeed(Dynamic)
{
    private static var random(default, null):Random = Random.native;
    
    private function new(value:Dynamic)
    {
        this = value;
    }
    
    public function value():Int
    {
        return switch (Type.typeof(this))
        {
            case TNull:
                random.nextInt();
                
            case TInt:
                this;
                
            case _:
                djb2.hash(this);
        }
    }
    
    @:from public static inline function fromDynamic(value:Dynamic):IntSeed
    {
        return new IntSeed(value);
    }
}

abstract IntArraySeed(Dynamic)
{
    private static var random(default, null):Random = Random.native;
    
    private function new(value:Dynamic)
    {
        this = value;
    }
    
    public function value(length:Int):Array<Int>
    {
        var rnd = new FastXorShift32Random(djb2.hash(this));
        
        return switch (Type.typeof(this))
        {
            case TNull:
                [for (i in 0...length) random.nextInt()];
                
            case TClass(Array):
                var arr:Array<Dynamic> = this;
                
                // if arr is too short, extra entries are randomized
                // if entry is an integer, the entry will be as it is
                // if entry is not an integer, it'll be transformed into one
                // by hashCode(entry) xor randomInt()
                [for (i in 0...length)
                    if (i < arr.length)
                        if (Std.is(arr[i], Int))
                            arr[i];
                        else
                            djb2.hash(arr[i]) ^ rnd.nextInt();
                    else
                        rnd.nextInt()];
                
            case _:
                var str:String = Std.string(this);
                var arr:Array<String> = [];
                
                // distribute the chars across the array
                for (i in 0...str.length)
                {
                    var p:Int = i % length;
                    
                    if (p >= arr.length)
                        arr[p] = str.charAt(i);
                    else
                        arr[p] += str.charAt(i);
                }
                
                //trace(arr);
                
                [for (i in 0...length)
                    djb2.hash(arr[i]) ^ rnd.nextInt()];
        }
    }
    
    @:from public static inline function fromDynamic(value:Dynamic):IntArraySeed
    {
        return new IntArraySeed(value);
    }
}

abstract StringSeed(Dynamic)
{
    private static var random(default, null):Random = Random.native;
    
    private function new(value:Dynamic)
    {
        this = value;
    }
    
    public function value(genLength:Int=256):String
    {
        return switch (Type.typeof(this))
        {
            case TNull:
                random.create.string(genLength, Char.generate("", "", Printable));
                
            case TClass(String):
                this;
                
            case _:
                Std.string(this);
        }
    }
    
    @:from public static inline function fromDynamic(value:Dynamic):StringSeed
    {
        return new StringSeed(value);
    }
}