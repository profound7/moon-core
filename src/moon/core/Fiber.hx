package moon.core;

import haxe.Timer;
import moon.core.Async;

/**
 * A Fiber is a way to have asynchronous logic, like having threads,
 * except that a Fiber uses cooperative multitasking.
 * 
 * It's intended to be used with moon.macros.async.Async, though
 * you can put up any Iterator you wish into the Fiber.
 * 
 * The Processor manages a collection of Fibers and deals with
 * running the Fibers in cycles.
 * 
 * You do not need to manually add Fibers into a Processor.
 * When you create a Fiber, it's automatically added to the main
 * Processor, which is a static instance.
 * 
 * You can also add it to other Processor instances, and it'll
 * automatically be removed from the previous Processor.
 * 
 * @author Munir Hussin
 */
@:allow(moon.core.Processor)
class Fiber<T>
{
    public var priority:Int;
    public var result(default, null):Future<T>;
    public var processor(get, never):Processor;
    public var isDead(get, never):Bool;
    public var yielded:Signal<T>; // BUG: completion issues due to this. works if type is Dynamic.
    
    private var it:Iterator<T>;
    private var _processor:Processor;
    
    public function new(priority:Int, it:Iterator<T>) 
    {
        this.priority = priority;
        this.result = new Future();
        this.it = it;
        
        Processor.main.add(this);
    }
    
    private inline function get_processor():Processor
    {
        return _processor;
    }
    
    private inline function get_isDead():Bool
    {
        return result.isDone;
    }
    
    /**
     * Kill the Fiber. If there's a Processor associated with it,
     * remove this Fiber from the Processor.
     */
    public function kill():Void
    {
        if (!result.isDone && it.hasNext())
        {
            result.fail(FunctionEnded);
        }
        
        if (processor != null)
        {
            processor.remove(this);
            _processor = null;
        }
    }
    
    public inline function hasNext():Bool
    {
        return it.hasNext();
    }
    
    /**
     * Runs the Fiber. It does so by calling the Iterator's next().
     * If the fiber has completed, the result Future is resolved.
     */
    public function next():T
    {
        if (hasNext())
        {
            var value:T = it.next();
            
            if (yielded != null)
                yielded.dispatch(value);
                
            if (!it.hasNext())
                result.complete(value);
            
            return value;
        }
        else
        {
            throw FunctionEnded;
        }
    }
    
    /**
     * Runs this fiber synchronously until it ends, and returns
     * the final result.
     */
    public function sync():T
    {
        if (hasNext())
        {
            var value:T = it.next();
            
            if (yielded != null)
            {
                while (it.hasNext())
                    yielded.dispatch(value = it.next());
            }
            else
            {
                while (it.hasNext())
                    value = it.next();
            }
                
            result.complete(value);
            return value;
        }
        
        throw FunctionEnded;
    }
    
    public function toString():String
    {
        return '<Fiber p=$priority d=$isDead>';
    }
}

/**
 * A Processor holds a collection of Fibers to run.
 * 
 * @author Munir Hussin
 */
class Processor
{
    public static var main(default, null) = new Processor();
    
    private var fibers:Array<Fiber<Dynamic>>;
    private var i:Int;
    private var j:Int;
    
    public function new()
    {
        fibers = [];
        i = 0;
        j = 0;
    }
    
    /**
     * Add a fiber to this processor.
     */
    public function add<T>(f:Fiber<T>):Void
    {
        if (f.processor != null)
            f.processor.remove(f);
            
        fibers.push(f);
        f._processor = this;
    }
    
    /**
     * Remove a fiber from this processor.
     */
    public function remove<T>(f:Fiber<T>):Bool
    {
        f._processor = null;
        return fibers.remove(f);
    }
    
    /**
     * Returns whether there are fibers to run.
     */
    public inline function hasNext():Bool
    {
        return fibers.length > 0;
    }
    
    /**
     * Calls run(1)
     */
    public inline function next():Void
    {
        run(1);
    }
    
    /**
     * Run the next `count` fibers.
     * Fibers with higher priority will be run more often per cycle.
     * Fibers with 0 priority will be skipped.
     */
    public function run(count:Int):Void
    {
        var fib:Fiber<Dynamic> = null;
        
        while (count > 0 && fibers.length > 0)
        {
            if (i >= fibers.length)
            {
                i = 0;
                j = 0;
            }
            
            fib = fibers[i];
            
            if (j >= fib.priority)
            {
                i++;
                j = 0;
            }
            else
            {
                if (fib.hasNext())
                {
                    fib.next();
                    count--;
                    j++;
                }
                else
                {
                    fibers.splice(i, 1);
                    j = 0;
                }
                
                /*fib.next();
                if (fib.run())
                {
                    count--;
                    j++;
                }
                else
                {
                    fibers.splice(i, 1);
                    j = 0;
                }*/
            }
            
        }
    }
    
    /**
     * Calls run(count) repeatedly, so long as there's fibers,
     * until at least the specified number of seconds has elasped.
     * 
     * Once hasNext() is false, the method returns after the cycle
     * is completed.
     * 
     * The bigger `count` is, the less function call overhead there'll
     * be when you're in tight loops. The smaller `count` is, the higher
     * chances to be more precise at stopping at the desired number
     * of seconds.
     */
    public function duration(seconds:Float, count:Int):Void
    {
        var start:Float = Timer.stamp();
        var elasped:Float = 0.0;
        
        while (hasNext() && elasped < seconds)
        {
            run(count);
            elasped = Timer.stamp() - start;
        }
    }
}