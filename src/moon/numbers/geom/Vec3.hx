package moon.numbers.geom;

import moon.numbers.geom.Vec;

using moon.tools.FloatTools;

/**
 * Vector3 is a Tuple<Float, Float>, used for mathematical calculations.
 * 
 * TODO: Incomplete
 * 
 * @author Munir Hussin
 */
abstract Vec3(Vec) to Vec from Vec
{
    public static inline var epsilon:Float = 0.001;
    public static var zero:Vec3 = new Vec3(0, 0, 0);
    public static var one:Vec3 = new Vec3(1, 1, 1);
    public static var left:Vec3 = new Vec3(-1, 0, 0);
    public static var right:Vec3 = new Vec3(1, 0, 0);
    public static var up:Vec3 = new Vec3(0, 1, 0);
    public static var down:Vec3 = new Vec3(0, -1, 0);
    public static var forward:Vec3 = new Vec3(0, 0, 1);
    public static var back:Vec3 = new Vec3(0, 0, -1);
    
    public var x(get, set):Float;
    public var y(get, set):Float;
    public var z(get, set):Float;
    public var magnitude(get, never):Float;
    public var magnitudeSquared(get, never):Float;
    public var normalized(get, never):Vec3;
    
    public function new(x:Float=0.0, y:Float=0.0, z:Float=0.0)
    {
        this = new Vec(3);
        this[0] = x;
        this[1] = y;
        this[2] = z;
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    @:arrayAccess private inline function getValue(i:Int):Float return this[i];
    @:arrayAccess private inline function setValue(i:Int, v:Float):Float return this[i] = v;
    private inline function get_x():Float return this[0];
    private inline function get_y():Float return this[1];
    private inline function get_z():Float return this[2];
    private inline function set_x(value:Float):Float return this[0] = value;
    private inline function set_y(value:Float):Float return this[1] = value;
    private inline function set_z(value:Float):Float return this[2] = value;
    
    private inline function get_magnitude():Float
    {
        return Math.sqrt(magnitudeSquared);
    }
    
    private inline function get_magnitudeSquared():Float
    {
        return x * x + y * y + z * z;
    }
    
    private inline function get_normalized():Vec3
    {
        return divide(this, magnitude);
    }
    
    /*==================================================
        Operators
    ==================================================*/
    
    @:op(A * B) public static inline function dot(a:Vec3, b:Vec3):Float
    {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }
    
    @:op(A & B) public static inline function cross(a:Vec3, b:Vec3):Vec3
    {
        return new Vec3(
            a.y * b.z - a.z * b.y,
            a.z * b.x - a.x * b.z,
            a.x * b.y - a.y * b.x
        );
    }
    
    @:op(A * B) @:commutative public static function multiply(a:Vec3, b:Float):Vec3
    {
        return new Vec3(a.x * b, a.y * b, a.z * b);
    }
    
    @:op(A / B) public static function divide(a:Vec3, b:Float):Vec3
    {
        return new Vec3(a.x / b, a.y / b, a.z / b);
    }
    
    @:op(A + B) public static function add(a:Vec3, b:Vec3):Vec3
    {
        return new Vec3(a.x + b.x, a.y + b.y, a.z + b.z);
    }
    
    @:op(-A) public static inline function negate(a:Vec3):Vec3
    {
        return new Vec3(-a.x, -a.y, -a.z);
    }
    
    @:op(A - B) public static function subtract(a:Vec3, b:Vec3):Vec3
    {
        return new Vec3(a.x - b.x, a.y - b.y, a.z - b.z);
    }
    
    @:op(A == B) public static function equals(a:Vec3, b:Vec3):Bool
    {
        return a.x.isNear(b.x, epsilon) && a.y.isNear(b.y, epsilon) &&
            a.z.isNear(b.z, epsilon);
    }
    
    @:op(A != B) public static inline function notEquals(a:Vec3, b:Vec3):Bool
    {
        return !equals(a, b);
    }
    
    /*==================================================
        Static Methods
    ==================================================*/
    
    public static inline function angle(a:Vec3, b:Vec3):Float
    {
        return Math.acos(dot(a, b) / (a.magnitude * b.magnitude));
    }
    
    public static inline function lerp(a:Vec3, b:Vec3, t:Float):Vec3
    {
        return new Vec3(a.x.lerp(b.x, t), a.y.lerp(b.y, t), a.z.lerp(b.z, t));
    }
    
    public static inline function distance(a:Vec3, b:Vec3):Float
    {
        return (a - b).magnitude;
    }
    
    public static inline function scale(a:Vec3, b:Vec3):Vec3
    {
        return new Vec3(a.x * b.x, a.y * b.y, a.z * b.z);
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
    }
    
    public function set(x:Float, y:Float, z:Float):Void
    {
        this[0] = x;
        this[1] = y;
        this[2] = z;
    }
    
    public function copy():Vec3
    {
        return new Vec3(x, y, z);
    }
    
    /*==================================================
        Conversions
    ==================================================*/
    
    @:to public inline function toVec2():Vec2
    {
        return new Vec2(x, y);
    }
    
    @:to public inline function toVec4():Vec4
    {
        return new Vec4(x, y, z, 0);
    }
    
    @:to public function toString():String
    {
        return '($x, $y, $z)';
    }
}