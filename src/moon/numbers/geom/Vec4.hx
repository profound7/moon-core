package moon.numbers.geom;

import moon.numbers.geom.Vec;

using moon.tools.FloatTools;

/**
 * Vec4 is a Tuple<Float, Float>, used for mathematical calculations.
 * 
 * TODO: Incomplete
 * 
 * @author Munir Hussin
 */
abstract Vec4(Vec) to Vec from Vec
{
    public static inline var epsilon:Float = 0.001;
    public static var zero:Vec4 = new Vec4(0, 0, 0, 0);
    public static var one:Vec4 = new Vec4(1, 1, 1, 1);
    
    public var x(get, set):Float;
    public var y(get, set):Float;
    public var z(get, set):Float;
    public var w(get, set):Float;
    public var magnitude(get, never):Float;
    public var magnitudeSquared(get, never):Float;
    public var normalized(get, never):Vec4;
    
    public function new(x:Float=0.0, y:Float=0.0, z:Float=0.0, w:Float=0.0)
    {
        this = new Vec(4);
        this[0] = x;
        this[1] = y;
        this[2] = z;
        this[3] = w;
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    @:arrayAccess private inline function getValue(i:Int):Float return this[i];
    @:arrayAccess private inline function setValue(i:Int, v:Float):Float return this[i] = v;
    private inline function get_x():Float return this[0];
    private inline function get_y():Float return this[1];
    private inline function get_z():Float return this[2];
    private inline function get_w():Float return this[3];
    private inline function set_x(value:Float):Float return this[0] = value;
    private inline function set_y(value:Float):Float return this[1] = value;
    private inline function set_z(value:Float):Float return this[2] = value;
    private inline function set_w(value:Float):Float return this[3] = value;
    
    private inline function get_magnitude():Float
    {
        return Math.sqrt(magnitudeSquared);
    }
    
    private inline function get_magnitudeSquared():Float
    {
        return x * x + y * y + z * z + w * w;
    }
    
    private inline function get_normalized():Vec4
    {
        return divide(this, magnitude);
    }
    
    /*==================================================
        Operators
    ==================================================*/
    
    @:op(A * B) public static inline function dot(a:Vec4, b:Vec4):Float
    {
        return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
    }
    
    @:op(A & B) public static inline function cross(a:Vec4, b:Vec4):Vec4
    {
        return new Vec4(
            a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
            a.w * b.y + a.y * b.w + a.z * b.x - a.x * b.z,
            a.w * b.z + a.z * b.w + a.x * b.y - a.y * b.x,
            a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
        );
    }
    
    @:op(A * B) @:commutative public static function multiply(a:Vec4, b:Float):Vec4
    {
        return new Vec4(a.x * b, a.y * b, a.z * b, a.w * b);
    }
    
    @:op(A / B) public static function divide(a:Vec4, b:Float):Vec4
    {
        return new Vec4(a.x / b, a.y / b, a.z / b, a.w / b);
    }
    
    @:op(A + B) public static function add(a:Vec4, b:Vec4):Vec4
    {
        return new Vec4(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w);
    }
    
    @:op(-A) public static inline function negate(a:Vec4):Vec4
    {
        return new Vec4(-a.x, -a.y, -a.z, -a.w);
    }
    
    @:op(A - B) public static function subtract(a:Vec4, b:Vec4):Vec4
    {
        return new Vec4(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w);
    }
    
    @:op(A == B) public static function equals(a:Vec4, b:Vec4):Bool
    {
        return a.x.isNear(b.x, epsilon) && a.y.isNear(b.y, epsilon) &&
            a.z.isNear(b.z, epsilon) && a.w.isNear(b.w, epsilon);
    }
    
    @:op(A != B) public static inline function notEquals(a:Vec4, b:Vec4):Bool
    {
        return !equals(a, b);
    }
    
    /*==================================================
        Static Methods
    ==================================================*/
    
    public static inline function angle(a:Vec4, b:Vec4):Float
    {
        return Math.acos(dot(a, b) / (a.magnitude * b.magnitude));
    }
    
    public static inline function lerp(a:Vec4, b:Vec4, t:Float):Vec4
    {
        return new Vec4(a.x.lerp(b.x, t), a.y.lerp(b.y, t), a.z.lerp(b.z, t), a.w.lerp(b.w, t));
    }
    
    public static inline function distance(a:Vec4, b:Vec4):Float
    {
        return (a - b).magnitude;
    }
    
    public static inline function scale(a:Vec4, b:Vec4):Vec4
    {
        return new Vec4(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w);
    }
    
    /*==================================================
        Methods
    ==================================================*/
    
    public function normalize():Void
    {
        var m:Float = magnitude;
        x /= m;
        y /= m;
        z /= m;
        w /= m;
    }
    
    public function set(x:Float, y:Float, z:Float, w:Float):Void
    {
        this[0] = x;
        this[1] = y;
        this[2] = z;
        this[3] = w;
    }
    
    public function copy():Vec4
    {
        return new Vec4(x, y, z, w);
    }
    
    /*==================================================
        Conversions
    ==================================================*/
    
    @:to public inline function toVec2():Vec2
    {
        return new Vec2(x, y);
    }
    
    @:to public inline function toVec3():Vec3
    {
        return new Vec3(x, y, z);
    }
    
    @:to public function toString():String
    {
        return '($x, $y, $z, $w)';
    }
}
