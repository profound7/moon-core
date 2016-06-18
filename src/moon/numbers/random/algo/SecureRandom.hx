package moon.numbers.random.algo;

#if js
    import js.Browser;
#end

using moon.numbers.random.RandomTools;

/**
 * Generates secure random numbers (using platform's default)
 * Currently only works in js target.
 * 
 * todo:
 * python:
 *     import os
 *     map(ord, os.urandom(4)); // [65, 120, 218, 135]
 * 
 *   or
 *     import random
 *     random.SystemRandom().getrandbits(n) // uses urandom under the hood
 * 
 * java:
 *     rnd = new java.security.SecureRandom();
 *     rnd.nextInt() etc...
 * @author Munir Hussin
 */
class SecureRandom
{
    public var _gauss:Float = 0;
    public var _hasGauss:Bool = false;
    
    public function new()
    {
    }
    
    /*==================================================
        Generator Methods
    ==================================================*/
    
    public inline function nextInt():Int
    {
        #if js
            var buf = untyped __js__("new Int32Array(1)");
            Browser.window.crypto.getRandomBalues(buf);
            return buf[0];
        #end
    }
    
    public inline function nextFloat():Float
    {
        return this.nextFloatFromInt();
    }
    
    public inline function nextBool():Bool
    {
        return this.nextBoolFromInt();
    }
}
