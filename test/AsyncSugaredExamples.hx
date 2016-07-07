package;

import moon.core.Fiber;
import moon.core.Future;
import moon.core.Generator;
import moon.core.Observable;
import moon.core.Seq;
import moon.core.Signal;

enum Worker
{
    Employee(name:String);
    Manager(name:String, workers:Array<Worker>);
}


/**
 * Any function that contains @yield will be transformed into
 * generator function, including nested functions and class methods.
 * 
 * You can type the generator function with a valid async type, to
 * get that type when the generator is called.
 * 
 * Valid async generator types:
 *     Iterator<T>, Iterable<T>, Seq<T>, Generator<T,U>
 * 
 * Valid async fiber types:
 *     Fiber<T>, Future<T>, Signal<T>, Observable<T>
 * 
 * Async generator types are simply iterators. You need to manually
 * iterate through them.
 * 
 * Async fiber types are iterators added into a fiber object.
 * The fiber `Processor` is usually added to your game loop or some
 * interval/update function, and the processor will take turns
 * switching between different fibers every loop.
 * 
 * This allows you to have cooperative multitasking, something that
 * wasn't available in some single threaded targets. Unlike threads,
 * you don't need to worry about locking
 * 
 * @author Munir Hussin
 */
//@:build(moon.core.Sugar.build()) // also works but has other stuff also
@:build(moon.core.Sugar.buildAsync())
class AsyncSugaredExamples
{
    
    public static function main()
    {
        //methodExample();
        //simpleExample();
        awaitExample();
        //tryExample();
        //permutationsExample();
        //nestedExample();
        //fibonacciExample();
        //sendExample();
        //anotherSendExample();
        //fiberExample();
        //fiberFutureExample();
        //fiberDurationExample();
    }
    
    public static function methodExample()
    {
        for (name in customIterator("Hello", "How are you?"))
        {
            trace(name);
        }
    }
    
    public static function customIterator(greet:String, msg:String):Iterator<String>
    {
        var alice = Employee("alice");
        var alice = Employee("alice"), bob = Employee("bob");
        var carol = Employee("carol");
        var dave = Manager("dave", [alice, bob, carol]);
        
        for (p in [alice, bob, carol, dave])
        {
            //var x = 
            switch (p)
            {
                case Employee(name):
                    @yield (greet + " " + name + "! " + msg);
                    //Employee("aaa");
                    
                case Manager(name, workers):
                    @yield (greet + " manager " + name + "! How are " + workers.join(", ") + " doing?");
                    //Employee("bbb");
                    
                case _:
                    @yield "hello";
                    //Employee("ccc");
            }
            
            //@yield ("x is " + x);
            trace("test");
        }
    }
    
    
    public static function simpleExample()
    {
        function simple():Iterator<String>
        {
            @yield "foo";
            @yield "bar";
            @yield "baz";
        }
        
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
        catch (ex:Dynamic)
        {
            trace("AsyncException: " + ex);
        }
    }
    
    
    public static function awaitExample()
    {
        var someFuture = new Future<Int>();
        
        function await():Iterator<String>
        {
            @yield "foo";
            var x:Int = @await someFuture;
            trace('value of x is $x');
            @yield "bar";
        }
        
        trace("Await Example");
        trace("");
        
        var it = await();
        var i = 0;
        
        while (it.hasNext())
        {
            // trigger completion when i is 3
            if (i == 5) someFuture.complete(5318008);
            trace(i + ": " + it.next());
            ++i;
        }
        
    }
    
    
    public static function tryExample()
    {
        
        function trycatch():Iterator<String>
        {
            try
            {
                @yield "aaa";
                @yield "bbb";
                throw 123;
                @yield "ccc";
            }
            catch (ex:Int)
            {
                @yield ("ddd " + ex);
            }
            catch (ex:Bool)
            {
                @yield ("eee " + ex);
            }
        }
        
        trace("Try Example");
        trace("");
        
        var it = trycatch();
        
        for (x in it)
        {
            trace(x);
        }
    }
    
    
    public static function permutationsExample()
    {
        function permutations(items:Array<Dynamic>):Iterator<Array<Dynamic>>
        {
            var n = items.length;
            if (n == 0)
                @yield [];
            else
                for (i in 0...n)
                    for (cc in permutations(items.slice(0, i).concat(items.slice(i + 1))))
                        @yield [items[i]].concat(cc);
        }
        
        trace("Generator Permutations Example");
        var it = permutations(["a", "b", "c"]);
        
        for (x in it)
        {
            trace(x);
        }
    }
    
    public static function nestedExample()
    {
        function range(start:Int, stop:Int, step:Int):Iterator<Int>
        {
            while (start < stop)
            {
                @yield start;
                start += step;
            }
        }
        
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
        function fib():Iterator<Int>
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
            
        }
        
        trace("Generator Fibonacci Example");
        var it = fib();
        
        for (i in 0...13)
        {
            trace(i + ": " + it.next());
        }
    }
    
    public static function sendExample()
    {
        function sendFn(a:Int, b:String):Generator<Int, String>
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
        }
        
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
        function makeObject():Generator<String, Float>
        {
            var z =
            {
                aaa: @yield "foo",
                bbb: @yield "bar",
                ccc: @yield "baz",
            };
            
            @yield ("Done: " + z);
        }
        
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
        function fiber(m:String, a:Int, b:Int):Fiber<Int>
        {
            trace(m + ": fiber start");
            
            for (vv in a...b)
            {
                trace(m + ": " + vv);
                @yield vv;
            }
            
            trace(m + ": fiber end");
        }
        
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
        function fiberFuture(name:String, start:Int, stop:Int):Future<Int>
        {
            trace(name + ": fiber start");
            
            for (i in start...stop)
            {
                trace(name + ": " + i);
                @yield i;
            }
            
            trace(name + ": fiber end");
        }
        
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
        function fiberInfinite(name:String, start:Int):Fiber<Int>
        {
            trace(name + ": fiber start");
            
            // infinite loop
            while (true)
            {
                @yield start++;
            }
            
            // this will never reach
            trace(name + ": fiber end");
        }
        
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