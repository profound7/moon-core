package moon.core;

#if neko
    import neko.vm.Mutex;
    import neko.vm.Thread;
#elseif cpp
    import cpp.vm.Mutex;
    import cpp.vm.Thread;
#else
    import haxe.Timer;
#end

/**
 * Invoke.later() and Invoke.repeating() which is similar to
 * JavaScript's setTimeout() and setInverval().
 * 
 * TODO: Make this cross platform by using setTimeout/setInterval
 * in js/flash, use threads in targets with threads, and
 * invoke immediately on other targets that cannot simulate the
 * functionality.
 * 
 * TODO: Make another similar class, Async, whose purpose is
 * to run some function asynchronously, and returns a Future.
 * Use threads where available, or webworkers on js, or
 * call immediately on remaining targets.
 * 
 *      var result:Future<Int> = Async.run(function():Int return longTask());
 * 
 * @author Munir Hussin
 */
class Invoke
{
    #if (neko || cpp)
        private static var thread:Thread;
    #else
        private static var timer:Timer;
    #end
    
    private static var tasks:Array<Invoke> = [];
    
    public var fn:Void->Void;
    public var start:Float;
    public var interval:Float;
    public var time:Float;
    public var count:Int;
    public var total:Int;
    public var hasExpired(get, never):Bool;
    
    
    private function new(fn:Void->Void, start:Float, interval:Float, time:Float, count:Int, total:Int) 
    {
        this.fn = fn;
        this.start = start;
        this.interval = interval;
        this.time = time;
        this.count = count;
        this.total = total;
        
        #if (flash || js || java || python)
            timer = new Timer(toMs(start));
            timer.run = function()
            {
                timer.stop();
                
                if (!hasExpired)
                {
                    invoke();
                    
                    timer = new Timer(toMs(interval));
                    timer.run = function()
                    {
                        if (hasExpired)
                            timer.stop();
                        else
                            invoke();
                    }
                }
            }
        #end
    }
    
    private static inline function toMs(s:Float):Int
    {
        return Std.int(s * 1000);
    }
    
    public static function init():Void
    {
        #if (neko || cpp)
            thread = Thread.create(run);
            thread.sendMessage(Thread.current());
        #end
    }
    
    private static function run():Void
    {
        #if (neko || cpp)
            var main:Thread = Thread.readMessage(true);
            var m:Mutex = new Mutex();
            
            var prevTime:Float = Sys.time();
            var currTime:Float = 0;
            var deltaTime:Float = 0;
            var i:Int = 0;
            var n:Int = 0;
            
            while (true)
            {
                if (Thread.readMessage(false) == 1)
                {
                    break;
                }
                
                currTime = Sys.time();
                deltaTime = currTime - prevTime;
                
                m.acquire();
                
                i = 0;
                n = tasks.length;
                
                while (i < n)
                {
                    var t = tasks[i];
                    
                    // expired
                    if (t.total != -1 && t.count >= t.total)
                    {
                        // remove
                        tasks[i] = tasks[n - 1];
                        tasks.pop();
                        --n;
                    }
                    else
                    {
                        t.time -= deltaTime;
                        
                        if (t.time <= 0)
                        {
                            t.count++;
                            t.time += t.interval;
                            t.fn();
                        }
                        
                        ++i;
                    }
                }
                
                m.release();
                prevTime = currTime;
            }
            
            main.sendMessage("done");
        #end
    }
    
    public static function kill():Void
    {
        #if (neko || cpp)
            thread.sendMessage(1);
        #end
    }
    
    public static function wait():Void
    {
        #if (neko || cpp)
            Thread.readMessage(true);
        #end
    }
    
    public static function later(fn:Void->Void, start:Float):Invoke
    {
        var x:Invoke = new Invoke(fn, start, 0, start, 0, 1);
        tasks.push(x);
        return x;
    }
    
    public static function repeat(fn:Void->Void, start:Float, interval:Float, total:Int=-1):Invoke
    {
        var x:Invoke = new Invoke(fn, start, interval, start, 0, total);
        tasks.push(x);
        return x;
    }
    
    /**
     * Stops the repeating invokes.
     */
    public function stop():Void
    {
        total = count = 0;
    }
    
    /**
     * Manually invoke immediately. This will trigger the function
     * even if stop() was called.
     * 
     * `noCount` indicates whether this invoke will increment the count
     * variable (which, if it's equal or greater than total, will stop
     * further invokes).
     */
    public function invoke(noCount:Bool=false):Void
    {
        if (!noCount) ++count;
        fn();
    }
    
    /**
     * Delays the next invoke by a number of seconds.
     */
    public function delay(seconds:Float):Void
    {
        time += seconds;
    }
    
    private function get_hasExpired():Bool
    {
        return total != -1 && count >= total;
    }
}