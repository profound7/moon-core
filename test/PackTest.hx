package;

import haxe.Int64;
import haxe.io.Bytes;
import haxe.Serializer;
import moon.data.pack.Pack;
import moon.data.pack.PackTools;
import moon.data.pack.Unpack;

/**
 * ...
 * @author Munir Hussin
 */
class PackTest
{
    
    public static function main()
    {
        trace("pack");
        
        var pack = new Pack(true);
        
        
        //var input:Dynamic = { abc: "aaa", def: 123, ghi: null };
        var input:Dynamic = [
            new Cat("tom", 1.23),
            //new Animal("feline", 5),
            //new Cat("tom", 1.23),
        ];
        
        //input.ghi = input;
        
        trace("input:");
        trace(input);
        
        trace("");
        trace("");
        
        var b:Bytes = pack.pack(input);
        trace("serialized:");
        trace(b.toHex());
        
        
        trace("");
        trace("");
        
        var unpack = new Unpack();
        var output:Dynamic = unpack.unpack(b);
        trace("output:");
        trace(output);
        
        
    }
    
}


class Animal
{
    public var species:String;
    public var location:Int;
    
    public function new(species:String, location:Int)
    {
        this.species = species;
        this.location = location;
    }
}

class Cat extends Animal
{
    public var name:String;
    public var age:Float;
    public var onInit(never, default):Void->Int;
    
    public function new(name:String, age:Float)
    {
        super("feline", 6);
        
        this.name = name;
        this.age = age;
    }
    
    public function meow():Void
    {
        trace('$name meows!');
    }
}

