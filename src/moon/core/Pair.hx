package moon.core;

/**
 * Pair is a pair of values.
 * Pair is similar to Tuple2, but different implementation.
 * 
 * Usage:
 *  var x:Pair<String, Int> = Pair.of("hello", 5);
 *  trace(x.head);
 *  
 * @author Munir Hussin
 */
class Pair<A, B>
{
    private var data:Array<Dynamic>;
    public var head(get, set):A;
    public var tail(get, set):B;
    
    public function new(head:A, tail:B)
    {
        data = [head, tail];
    }
    
    // (head . tail)
    public static inline function of<A, B>(head:A, tail:B):Pair<A, B>
    {
        return new Pair(head, tail);
    }
    
    private inline function get_head():A
    {
        return data[0];
    }
    
    private inline function get_tail():B
    {
        return data[1];
    }
    
    private inline function set_head(v:A):A
    {
        return data[0] = v;
    }
    
    private inline function set_tail(v:B):B
    {
        return data[1] = v;
    }
    
    /*==================================================
        Methods
    ==================================================*/
    
    public function iterator():Iterator<Dynamic>
    {
        return data.iterator();
    }
    
    public inline function swap():Pair<B, A>
    {
        return Pair.of(tail, head);
    }
    
    public inline function join(sep:String):String
    {
        return data.join(sep);
    }
    
    public function equals(other:Pair<A, B>):Bool
    {
        return this.head == other.head && this.tail == other.tail;
    }
    
    public function toString():String
    {
        return "(" + join(": ") + ")";
    }
}