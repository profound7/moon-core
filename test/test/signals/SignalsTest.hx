package test.signals;

import moon.test.TestCase;
import moon.test.TestRunner;
import moon.core.Signal;

/**
 * ...
 * @author Munir Hussin
 */
class SignalsTest extends TestCase
{
    public static function main() 
    {
        var r = new TestRunner();
        r.add(new SignalsTest());
        r.run();
    }
    
    public function testVoid()
    {
        var i:Int = 0;
        var clicked:Signal = new Signal();
        
        clicked.add(function():Void
        {
            ++i;
            //trace('testVoid: triggered!');
        });
        
        
        clicked.dispatch();
        clicked.dispatch();
        clicked.dispatch();
        
        assert.isEqual(i, 3);
    }
    
    
    public function testSignal()
    {
        var i:Int = 0;
        var clicked:Signal<Float, Float> = new Signal<Float, Float>();
        
        // this callback will activate at most 2 times
        clicked.add(2, function(x:Float, y:Float):Void
        {
            ++i;
            //trace('testSignal: you clicked at: $x, $y');
        });
        
        clicked.add(function(x:Float, y:Float):Void
        {
            ++i;
            //trace("testSignal: other listener");
        });
        
        var x:Float = 12.34;
        var y:Float = 56.78;
        clicked.dispatch(x, y);
        clicked.dispatch(x, y);
        clicked.dispatch(x, y);
        assert.isEqual(i, 5);
    }
    
    public function testBox1()
    {
        var i:Int = 0;
        var b1:Box1 = new Box1("box1");
        var b2:Box1 = new Box1("box2");
        
        function onClick(b:Box1, x:Float, y:Float):Void
        {
            ++i;
            //trace('testBox1: you clicked ${b.name} at: $x, $y');
        }
        
        b1.clicked.add(onClick);
        b2.clicked.add(onClick);
        
        b1.clicked.dispatch(b1, 1, 2);
        b2.clicked.dispatch(b2, 3, 4);
        
        assert.isEqual(i, 2);
    }
    
    public function testBox2()
    {
        // The Box's signal is only 2 floats, x and y.
        //
        // But which box was clicked?
        //
        // Use closures to attach additional information to
        // the signal.
        
        var i:Int = 0;
        var b1:Box2 = new Box2("box1");
        var b2:Box2 = new Box2("box2");
        
        function onClick(b:Box2)
        {
            return function(x:Float, y:Float):Void
            {
                ++i;
                //trace('testBox2: you clicked ${b.name} at: $x, $y');
            }
        }
        
        b1.clicked.add(onClick(b1));
        b2.clicked.add(onClick(b2));
        
        b1.clicked.dispatch(1, 2);
        b2.clicked.dispatch(3, 4);
        
        assert.isEqual(i, 2);
    }
    
}


class Box1
{
    public var clicked:Signal<Box1, Float, Float>;
    public var name:String;
    
    public function new(name:String)
    {
        clicked = new Signal<Box1, Float, Float>();
        this.name = name;
    }
}

class Box2
{
    public var clicked:Signal<Float, Float>;
    public var name:String;
    
    public function new(name:String)
    {
        clicked = new Signal<Float, Float>();
        this.name = name;
    }
}
