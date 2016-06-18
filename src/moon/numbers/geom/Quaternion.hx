package moon.numbers.geom;

import moon.core.Pair;
import moon.numbers.geom.Vector;

using moon.tools.NumberTools;

/**
 * Quarternion holds rotational data in 3D space
 * http://willperone.net/Code/quaternion.php
 * 
 * TODO: not working/incomplete
 *
 * @author Munir Hussin
 */
@:forward abstract Quaternion(Vec4) to Vec4 from Vec4
{
    public static inline var epsilon:Float = 0.00001;
    public static var identity:Quaternion = new Quaternion(0, 0, 0, 1);
    
    /*==================================================
        Constructors
    ==================================================*/
        
    public inline function new(x:Float=0.0, y:Float=0.0, z:Float=0.0, w:Float=0.0)
    {
        this = new Vector4(x, y, z, w);
    }
    
    /**
     * Create a Quarternion
     */
    public static inline function fromEuler(angles:Vec3):Quaternion
    {
        var cos_z_2:Float = Math.cos(0.5 * angles.z);
        var cos_y_2:Float = Math.cos(0.5 * angles.y);
        var cos_x_2:Float = Math.cos(0.5 * angles.x);
        
        var sin_z_2:Float = Math.sin(0.5 * angles.z);
        var sin_y_2:Float = Math.sin(0.5 * angles.y);
        var sin_x_2:Float = Math.sin(0.5 * angles.x);
        
        return new Quaternion(
            cos_z_2 * cos_y_2 * sin_x_2 - sin_z_2 * sin_y_2 * cos_x_2,
            cos_z_2 * sin_y_2 * cos_x_2 + sin_z_2 * cos_y_2 * sin_x_2,
            sin_z_2 * cos_y_2 * cos_x_2 - cos_z_2 * sin_y_2 * sin_x_2,
            cos_z_2 * cos_y_2 * cos_x_2 + sin_z_2 * sin_y_2 * sin_x_2
        );
    }
    
    public static inline function fromAngleAxis(angle:Float, axis:Vector3):Quaternion
    {
        var sin_angle_2:Float = Math.sin(angle * 0.5);
        return new Quaternion(
            axis.x * sin_angle_2,
            axis.y * sin_angle_2,
            axis.z * sin_angle_2,
            Math.cos(angle * 0.5)
        );
    }
    
    
    /*==================================================
        Properties
    ==================================================*/
    
    @:arrayAccess private inline function getValue(i:Int):Float return this[i];
    @:arrayAccess private inline function setValue(i:Int, v:Float):Float return this[i] = v;
    
    /*==================================================
        Operators
    ==================================================*/
    
    @:op(A * B) public static inline function dot(a:Quaternion, b:Quaternion):Float
    {
        return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
    }
    
    @:op(A & B) public static inline function cross(a:Quaternion, b:Quaternion):Quaternion
    {
        return new Quaternion(
            a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
            a.w * b.y + a.y * b.w + a.z * b.x - a.x * b.z,
            a.w * b.z + a.z * b.w + a.x * b.y - a.y * b.x,
            a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
        );
    }
    
    @:op(A * B) @:commutative public static function multiply(a:Quaternion, b:Float):Quaternion
    {
        return new Quaternion(a.x * b, a.y * b, a.z * b, a.w * b);
    }
    
    @:op(A / B) public static function divide(a:Quaternion, b:Float):Quaternion
    {
        return new Quaternion(a.x / b, a.y / b, a.z / b, a.w / b);
    }
    
    @:op(A + B) public static function add(a:Quaternion, b:Quaternion):Quaternion
    {
        return new Quaternion(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w);
    }
    
    @:op(-A) public static inline function negate(a:Quaternion):Quaternion
    {
        return new Quaternion(-a.x, -a.y, -a.z, -a.w);
    }
    
    @:op(A - B) public static function subtract(a:Quaternion, b:Quaternion):Quaternion
    {
        return new Quaternion(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w);
    }
    
    @:op(A == B) public static function equals(a:Quaternion, b:Quaternion):Bool
    {
        return a.x.isNear(b.x, epsilon) && a.y.isNear(b.y, epsilon) &&
            a.z.isNear(b.z, epsilon) && a.w.isNear(b.w, epsilon);
    }
    
    @:op(A != B) public static inline function notEquals(a:Quaternion, b:Quaternion):Bool
    {
        return !equals(a, b);
    }
    
    
    /*==================================================
        Static Methods
    ==================================================*/
    
    /*public static function fillMatrix(q:Quaternion, m:Matrix):Void
    {
        m[0][0] = 1.0 - 2.0 * (q.y * q.y + q.z * q.z);
        m[0][1] = 2.0 * (q.x * q.y - q.w * q.z);
        m[0][2] = 2.0 * (q.x * q.z + q.w * q.y);
        m[0][3] = 0.0;
        
        m[1][0] = 2.0 * (q.x * q.y + q.w * q.z);
        m[1][1] = 1.0 - 2.0 * (q.x * q.x + q.z * q.z);
        m[1][2] = 2.0 * (q.y * q.z - q.w * q.x);
        m[1][3] = 0.0;
        
        m[2][0] = 2.0 * (q.x * q.z - q.w * q.y);
        m[2][1] = 2.0 * (q.y * q.z + q.w * q.x);
        m[2][2] = 1.0 - 2.0 * (q.x * q.x + q.y * q.y);
        m[2][3] = 0.0;
        
        m[2][0] = 0;
        m[2][1] = 0;
        m[2][2] = 0;
        m[2][3] = 1.0;
    }*/
    
    /*public static function createMatrix(q:Quaternion):Matrix
    {
        var m:Matrix = Matrix.create4x4();
        fillMatrix(q, m);
        return m;
    }*/
    
    
    /*==================================================
        Methods
    ==================================================*/
    
    public inline function conjugate():Void
    {
        this.x = -this.x;
        this.y = -this.y;
        this.z = -this.z;
    }
    
    public inline function invert():Void
    {
        conjugate();
        Vector4.divide(this, this.magnitudeSquared);
    }
    
    public static function lerp(q:Quaternion, r:Quaternion, t:Float):Quaternion
    {
        var x:Quaternion = (q * (1.0 - t) + r * t);
        x.normalize();
        return x;
    }
    
    public static function slerp(q:Quaternion, r:Quaternion, t:Float):Quaternion
    {
        var s:Quaternion;
        var dot:Float = Vector4.dot(q, r);
        
        if (dot < 0)
        {
            dot = -dot;
            s = -r;
        }
        else
        {
            s = r;
        }
        
        if (dot < 0.95)
        {
            var angle:Float = Math.acos(dot);
            return (q * Math.sin(angle * (1 - t)) + s * Math.sin(angle * t)) / Math.sin(angle);
        }
        else
        {
            // if angle is small, use linear interpolation
            return lerp(q, s, t);
        }
    }
    
    /*==================================================
        Conversions
    ==================================================*/
    
    public function toAngleAxis():Pair<Float, Vector3>
    {
        throw "todo";
    }
    
    @:to public function toString():String
    {
        return '(${this.x}, ${this.y}, ${this.z}, ${this.w})';
    }
}

