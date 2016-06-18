package;

import moon.core.Future;
import moon.core.Signal;
import moon.core.Tuple;


class FooTest
{
    public static function main()
    {
        //var f:Foo<Int, String> = new Foo<Int, String>();
        //f.yay(1, "hi");             // works
        
        var b:Tuple<Int, String> = new Tuple<Int, String>(1, "aa");
        
        b.set(4, "hi");
        
        trace(b);
        trace(b.v0);
        trace(b.v1);
        b.v1 = "bb";
        trace(b);
        trace(Type.getClassName(Type.getClass(b)));
        
        // works in 3.2. no longer works in 3.3 :(
        //var x = Tuple.of("fafa", 5);
        //trace(x);
        
        var fa:Future<Int> = new Future<Int>();
        var fb:Future<String> = new Future<String>();
        
        fa.and(fb).onComplete(function(x) trace('future $x'));
        
        fa.complete(77);
        fb.complete("afafafa");
        
        var s:Signal<Int> = new Signal<Int>();
        s.next().onComplete(function(x) trace("signal next " + x));
        
        s.add(function(x) trace('signal $x'));
        
        s.dispatch(4);
        s.dispatch(8);
        
        var s:Signal = new Signal();
        s.add(function() trace('signal unit'));
        s.dispatch();
        s.dispatch();
        
        var ss = Future.unitValue("4");
        ss.onComplete(function(x) trace(x));
    }
    
    public static function test<A,B>(a:A, b:B):Tuple<A,B>
    {
        var f:Tuple<A, B> = new Tuple<A, B>(a, b);
        f.set(a, b);                // works
        return f;
    }
    
    
}
