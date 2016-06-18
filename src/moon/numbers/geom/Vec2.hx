package moon.numbers.geom;

import moon.numbers.geom.Vec;

using moon.tools.FloatTools;

/**
 * Vector2 is a Tuple<Float, Float>, used for mathematical calculations.
 * 
 * TODO: Incomplete
 * 
 * @author Munir Hussin
 */
abstract Vec2(Vec) to Vec from Vec
{
    public static inline var epsilon:Float = 0.001;
    public static var zero:Vec2 = new Vec2(0, 0);
    public static var one:Vec2 = new Vec2(1, 1);
    public static var left:Vec2 = new Vec2(-1, 0);
    public static var right:Vec2 = new Vec2(1, 0);
    public static var up:Vec2 = new Vec2(0, 1);
    public static var down:Vec2 = new Vec2(0, -1);
    
    public var x(get, set):Float;
    public var y(get, set):Float;
    public var magnitude(get, never):Float;
    public var magnitudeSquared(get, never):Float;
    public var normalized(get, never):Vec2;
    
    public function new(x:Float=0.0, y:Float=0.0)
    {
        this = new Vec(2);
        this[0] = x;
        this[1] = y;
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    @:arrayAccess private inline function getValue(i:Int):Float return this[i];
    @:arrayAccess private inline function setValue(i:Int, v:Float):Float return this[i] = v;
    private inline function get_x():Float return this[0];
    private inline function get_y():Float return this[1];
    private inline function set_x(value:Float):Float return this[0] = value;
    private inline function set_y(value:Float):Float return this[1] = value;
    
    private inline function get_magnitude():Float
    {
        return Math.sqrt(magnitudeSquared);
    }
    
    private inline function get_magnitudeSquared():Float
    {
        return x * x + y * y;
    }
    
    private inline function get_normalized():Vec2
    {
        return divide(this, magnitude);
    }
    
    /*==================================================
        Operators
    ==================================================*/
    
    @:op(A * B) public static inline function dot(a:Vec2, b:Vec2):Float
    {
        return a.x * b.x + a.y * b.y;
    }
    
    /**
     * returns the magnitude of the vector that result from a regular 3D cross product
     * with Z taken as 0. this magnitude is also equal to the AREA of the parallelogram
     * of the 2 vectors
     */
    @:op(A & B) public static inline function cross(a:Vec2, b:Vec2):Float
    {
        return a.x * b.y - a.y * b.x;
    }
    
    @:op(A * B) @:commutative public static inline function multiply(a:Vec2, b:Float):Vec2
    {
        return new Vec2(a.x * b, a.y * b);
    }
    
    @:op(A / B) public static inline function divide(a:Vec2, b:Float):Vec2
    {
        return new Vec2(a.x / b, a.y / b);
    }
    
    @:op(A + B) public static inline function add(a:Vec2, b:Vec2):Vec2
    {
        return new Vec2(a.x + b.x, a.y + b.y);
    }
    
    @:op(-A) public static inline function negate(a:Vec2):Vec2
    {
        return new Vec2(-a.x, -a.y);
    }
    
    @:op(A - B) public static inline function subtract(a:Vec2, b:Vec2):Vec2
    {
        return new Vec2(a.x - b.x, a.y - b.y);
    }
    
    @:op(A == B) public static inline function equals(a:Vec2, b:Vec2):Bool
    {
        return a.x.isNear(b.x, epsilon) && a.y.isNear(b.y, epsilon);
    }
    
    @:op(A != B) public static inline function notEquals(a:Vec2, b:Vec2):Bool
    {
        return !equals(a, b);
    }
    
    /*==================================================
        Static Methods
    ==================================================*/
    
    public static inline function angle(a:Vec2, b:Vec2):Float
    {
        return Math.acos(dot(a, b) / (a.magnitude * b.magnitude));
    }
    
    public static inline function lerp(a:Vec2, b:Vec2, t:Float):Vec2
    {
        return new Vec2(a.x.lerp(b.x, t), a.y.lerp(b.y, t));
    }
    
    public static inline function distance(a:Vec2, b:Vec2):Float
    {
        return (a - b).magnitude;
    }
    
    public static inline function scale(a:Vec2, b:Vec2):Vec2
    {
        return new Vec2(a.x * b.x, a.y * b.y);
    }
    
    /**
     * Pivot point `a` around point `b` with angle theta.
     */
    public static function pivot(a:Vec2, b:Vec2, t:Float):Vec2
    {
        var c = Math.cos(t);
        var s = Math.sin(t);
        var dx = a.x - b.x;
        var dy = a.y - b.y;
        return new Vec2(dx * c - dy * s + b.x, dx * s + dy * c + b.y);
    }
    
    /*==================================================
        Methods
    ==================================================*/
    
    public function normalize():Void
    {
        var m:Float = magnitude;
        x /= m;
        y /= m;
    }
    
    public function set(x:Float, y:Float):Void
    {
        this[0] = x;
        this[1] = y;
    }
    
    public function copy():Vec2
    {
        return new Vec2(x, y);
    }
    
    /*==================================================
        Conversions
    ==================================================*/
    
    @:to public inline function toVec3():Vec3
    {
        return new Vec3(x, y, 0);
    }
    
    @:to public inline function toVec4():Vec4
    {
        return new Vec4(x, y, 0, 0);
    }
    
    @:to public function toString():String
    {
        return '($x, $y)';
    }
}