package moon.numbers.geom;

using moon.tools.FloatTools;

private typedef FloatVector = haxe.ds.Vector<Float>;

/**
 * Generic float vector of any size
 * @author Munir Hussin
 */
abstract Vec(FloatVector) to FloatVector from FloatVector
{
    public function new(length:Int)
    {
        this = new FloatVector(length);
    }
    
    @:arrayAccess private inline function get(i:Int):Float return this[i];
    @:arrayAccess private inline function set(i:Int, v:Float):Float return this[i] = v;
    
    @:to public function toString():String
    {
        return "(" + this.toArray().join(", ") + ")";
    }
}
