package;

import moon.core.Async;
import moon.core.Fiber;
import moon.core.Future;
import moon.core.Generator;
import moon.core.Observable;
import moon.core.Seq;
import moon.core.Signal;


/**
 * Completion does not work for Fiber and Observable unless you type it.
 * 
 * @author Munir Hussin
 */
class AsyncExamples
{
    
    public static function main()
    {
        simpleExample();
        //permutationsExample();
        //nestedExample();
        //fibonacciExample();
        //sendExample();
        //anotherSendExample();
        //fiberExample();
        //fiberFutureExample();
        //fiberDurationExample();
    }
    
    
    public static function simpleExample()
    {
        Async.async(function simple():Iterator<String>
        {
            @yield "foo";
            @yield "bar";
            @yield "baz";
        });
        
        trace("Generator Simple Example");
        
        trace("");
        trace("For loop to display yielded values");
        var it = simple();
        
        for (x in it)
        {
            trace(x);
        }
        
        trace("");
        trace("Manually calling next()");
        var it = simple();
        
        try
        {
            trace(it.next());
            trace(it.next());
            trace(it.next());
            trace(it.next());   // this raises exception
        }
        catch (ex:AsyncException)
        {
            trace("AsyncException: " + ex);
        }
    }
    
    
    public static function permutationsExample()
    {
        Async.async(function permutations(items:Array<Dynamic>):Iterator<Array<Dynamic>>
        {
            var n = items.length;
            if (n == 0)
                @yield [];
            else
                for (i in 0...n)
                    for (cc in permutations(items.slice(0, i).concat(items.slice(i + 1))))
                        @yield [items[i]].concat(cc);
        });
        
        trace("Generator Permutations Example");
        var it = permutations(["a", "b", "c"]);
        
        for (x in it)
        {
            trace(x);
        }
    }
    
    public static function nestedExample()
    {
        Async.async(function range(start:Int, stop:Int, step:Int):Iterator<Int>
        {
            while (start < stop)
            {
                @yield start;
                start += step;
            }
        });
        
        trace("Generator Nested Example");
        
        for (x in range(2, 6, 1))
        {
            for (y in range(4, 10, 2))
            {
                trace(x, y);
            }
        }
    }
    
    public static function fibonacciExample()
    {
        Async.async(function fib():Iterator<Int>
        {
            var a = 0;
            var b = 1;
            
            while (true)
            {
                @yield a;
                b = a + b;
                
                @yield b;
                a = a + b;
            }
            
        });
        
        trace("Generator Fibonacci Example");
        var it = fib();
        
        for (i in 0...13)
        {
            trace(i + ": " + it.next());
        }
    }
    
    public static function sendExample()
    {
        Async.async(function sendFn(a:Int, b:String):Generator<Int, String>
        {
            trace("gen start");
            
            for (vv in a...10)
            {
                if (vv == 5)
                    trace("yo" + @yield 999);
                else
                    trace(b + @yield vv);
            }
            
            trace("gen end");
        });
        
        trace("Generator Send Example");
        var it = sendFn(3, "hi");
        var m = 10;
        
        while (it.hasNext())
        {
            var out = it.send(" " + m++);
            trace("out:   " + out);
        }
        
    }
    
    public static function anotherSendExample()
    {
        Async.async(function makeObject():Generator<String, Float>
        {
            var z =
            {
                aaa: @yield "foo",
                bbb: @yield "bar",
                ccc: @yield "baz",
            };
            
            @yield ("Done: " + z);
        });
        
        trace("Generator Another Example");
        var it = makeObject();
        
        while (it.hasNext())
        {
            var out = it.send(Math.random());
            trace("out: " + out);
        }
    }
    
    
    public static function fiberExample()
    {
        Async.async(function fiber(m:String, a:Int, b:Int):Fiber<Int>
        {
            trace(m + ": fiber start");
            
            for (vv in a...b)
            {
                trace(m + ": " + vv);
                @yield vv;
            }
            
            trace(m + ": fiber end");
        });
        
        trace("Fiber Example");
        
        var f1 = fiber("foo", 1, 10);
        var f2 = fiber("bar", 100, 120);
        var f3 = fiber("baz", 1000, 1005);
        var v4 = fiber("hey", 9995, 9999).sync();
        
        trace("Immediate value: " + v4);
        
        //f3.yielded.add(function(x:Int) trace("SIGNAL: " + x));
        f1.result.log("Fiber 1: ");
        f2.result.log("Fiber 2: ");
        f3.result.log("Fiber 3: ");
        
        // the cycle will go: foo bar bar baz foo bar bar baz ...
        f2.priority = 2;
        
        // this while loop represents your game update loop
        while (Processor.main.hasNext())
        {
            // run the next 3 fibers
            Processor.main.run(3);
        }
    }
    
    
    public static function fiberFutureExample()
    {
        // Instead of returning a Fiber, you can also return a Future instead.
        // The final value yielded will be the result of this future.
        Async.async(function fiberFuture(m:String, a:Int, b:Int):Future<Int>
        {
            trace(m + ": fiber start");
            
            for (vv in a...b)
            {
                trace(m + ": " + vv);
                @yield vv;
            }
            
            trace(m + ": fiber end");
        });
        
        trace("Fiber Example");
        
        var f1 = fiberFuture("foo", 1, 10);
        var f2 = fiberFuture("bar", 100, 120);
        var f3 = fiberFuture("baz", 1000, 1005);
        
        //f3.yielded.add(function(x:Int) trace("SIGNAL: " + x));
        f1.log("Fiber 1: ");
        f2.log("Fiber 2: ");
        f3.log("Fiber 3: ");
        
        
        // this while loop represents your game update loop
        while (Processor.main.hasNext())
        {
            // run the next 3 fibers
            Processor.main.run(3);
        }
    }
    
    
    public static function fiberDurationExample()
    {
        Async.async(function fiberInfinite(name:String, start:Int):Fiber<Int>
        {
            trace(name + ": fiber start");
            
            // infinite loop
            while (true)
            {
                @yield start++;
            }
            
            trace(name + ": fiber end");
        });
        
        trace("Fiber Duration Example");
        
        var f1 = fiberInfinite("foo", 1);
        var f2 = fiberInfinite("bar", 100);
        var f3 = fiberInfinite("baz", 1000);
        
        //f3.yielded.add(function(x:Int) trace("SIGNAL: " + x));
        f1.result.log("Fiber 1: ");
        f2.result.log("Fiber 2: ");
        f3.result.log("Fiber 3: ");
        
        f2.priority = 2;
        
        
        // imagine this to be your update loop
        for (i in 0...5)
        {
            trace("-----");
            // run the fibers (so long as there's any) for 1.5 seconds
            // with 10 fibers at a time
            Processor.main.duration(1.5, 10);
        }
    }
}
