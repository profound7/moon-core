package moon.numbers.big;

import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.BytesOutput;
import moon.core.Bits;
import moon.numbers.random.algo.NativeRandom;
import moon.numbers.random.Random;

/**
 * https://github.com/peterolson/BigInteger.js/blob/master/BigInteger.js
 * 
 * @author Peter Olson (JavaScript original)
 * @author Munir Hussin (Haxe port)
 */
@:forward abstract BigInteger(BigIntegerType) to BigIntegerType from BigIntegerType
{
    public static var ZERO(default, null):BigInteger;
    public static var ONE(default, null):BigInteger;
    public static var MINUS_ONE(default, null):BigInteger;
    
    private static var base:Int;
    private static var logBase:Int;
    private static var zeros:String;
    
    private static var powersOfTwo:Array<Int>;
    private static var powers2Length:Int;
    private static var highestPower2:Int;
    
    public var length(get, never):Int;
    public var bits(get, never):Int;
    
    
    private static function __init__():Void
    {
        ZERO = new BigInteger([0], Sign.Positive);
        ONE = new BigInteger([1], Sign.Positive);
        MINUS_ONE = new BigInteger([1], Sign.Negative);
        
        base = 10000000;
        logBase = 7;
        zeros = "0000000";
        powersOfTwo = [1];
        
        // initialize the static powersOfTwo array
        while (powersOfTwo[powersOfTwo.length - 1] <= base)
            powersOfTwo.push(2 * powersOfTwo[powersOfTwo.length - 1]);
            
        powers2Length = powersOfTwo.length;
        highestPower2 = powersOfTwo[powers2Length - 1];
    }
    
    
    public function new(value:Array<Int>, sign:Bool) 
    {
        this = { sign: sign, value: value };
    }
    
    
    // wtf neko?
    // for neko targets, if an Int is assigned to a variable declared as Float,
    // it remains an Int, and might overflow on some operations.
    // The following does not work:
    //
    // var x:Float = 123456789;
    //
    // x * x;                       // OVERFLOW!
    // x * cast(x, Float);          // OVERFLOW!
    // x * Math.ffloor(x);          // OVERFLOW!
    // x * (x:Float);               // OVERFLOW!
    // x * (x + 0.0);               // OVERFLOW!
    // x * (x * 1.0);               // OVERFLOW!
    // x * (1.0 * x);               // OVERFLOW!
    // x * (x + (0.5 - 0.5));       // OVERFLOW!
    // x * (x + 0.5 - 0.5);         // works!
    // x * (x * 0.5 * 2.0);         // works!
    // x * (Math.pow(x, 1));        // works!
    //
    // for other platforms, this function does nothing
    private static inline function forceFloat(x:Float):Float
    {
        #if neko
            return x + 0.5 - 0.5;
        #else
            return x;
        #end
    }
    
    
    @:arrayAccess private inline function get(i:Int):Int
    {
        return i < this.value.length ? this.value[i] : 0;
    }
    
    @:arrayAccess private inline function set(i:Int, x:Int):Int
    {
        return this.value[i] = x;
    }
    
    private inline function get_length():Int
    {
        return this.value.length;
    }
    
    private inline function get_bits():Int
    {
        return toBase(2).length;
    }
    
    public static function create(?x:BigInteger, ?base:Int):BigInteger
    {
        if (x == null) return ZERO;
        if (base != null) return fromBase(x.toString(), base);
        return x;
    }
    
    
    
    public inline function toInt():Int
    {
        // some numbers that fits to int throws error
        return Std.int(toFloat());
    }
    
    public function toInt64():Int64
    {
        var neg:Bool = isNegative();
        var a:BigInteger = abs();
        var bytes:Bytes = a.toBytes();
        var i64:Int64 = bytes.getInt64(0);
        return neg ? -i64 : i64;
    }
    
    @:to public inline function toBigBits():BigBits
    {
        return toBase(2);
    }
    
    public function toFloat():Float
    {
        return Std.parseFloat(toString());
    }
    
    @:to public function toString():String
    {
        return toBase();
    }
    
    public function toBase(radix:Int=10):String
    {
        if (radix != 10) return toBaseInternal(radix);
        
        var first:BigInteger = this;
        var str:String = "";
        var len:Int = first.length;
        
        if (len == 0 || (len == 1 && first[0] == 0))
            return "0";
        
        len -= 1;
        str = Std.string(first[len]);
        
        while (--len >= 0)
        {
            var digit:String = Std.string(first[len]);
            str += zeros.substr(digit.length) + digit;
        }
        
        var s:String = first.sign == Sign.Positive ? "" : "-";
        return s + str;
    }
    
    private static function stringify(digit:BigInteger):String
    {
        var v:Array<Int> = digit.value;
        if (v.length == 1 && v[0] <= 36)
            return "0123456789abcdefghijklmnopqrstuvwxyz".charAt(v[0]);
        return "<" + v + ">";
    }
    
    private static function bytify(digit:BigInteger):Int
    {
        var v:Array<Int> = digit.value;
        if (v.length == 1 && v[0] <= 255)
            return v[0];
        throw "Byte out of range";
    }
    
    private function toBaseInternal(b:Int):String
    {
        var n:BigInteger = this;
        var base:BigInteger = create(b);
        
        if (base.equals(ZERO))
        {
            if (n.equals(ZERO)) return "0";
            throw "Cannot convert nonzero numbers to base 0.";
        }
        
        if (base.equals(MINUS_ONE))
        {
            if (n.equals(ZERO)) return "0";
            //if (n.lesser(0)) return Array(1 - n).join("10");
            //return "1" + Array(+n).join("01");
            if (n.lesser(ZERO)) return [for (_ in 0...1-n.toInt()) ""].join("10");
            return "1" + [for (_ in 0...n.toInt()) ""].join("01");
        }
        
        var minusSign:String = "";
        
        if (n.isNegative() && base.isPositive())
        {
            minusSign = "-";
            n = n.abs();
        }
        
        if (base.equals(ONE))
        {
            if (n.equals(ZERO)) return "0";
            //return minusSign + Array(+n + 1).join(1);
            return minusSign + [for (_ in 0...n.toInt() + 1) ""].join("1");
        }
        
        var out:Array<String> = [];
        var left:BigInteger = n;
        var divmod:BigIntegerDivResult;
        
        while (left.lesser(ZERO) || left.compareAbs(base) >= 0)
        {
            divmod = left.divmod(base);
            left = divmod.quotient;
            var digit:BigInteger = divmod.remainder;
            
            if (digit.lesser(ZERO))
            {
                digit = base.subtract(digit).abs();
                left = left.next();
            }
            
            out.push(stringify(digit));
        }
        
        out.push(stringify(left));
        out.reverse();
        return minusSign + out.join("");
    }
    
    @:to public function toBytes():Bytes
    {
        var n:BigInteger = this;
        var base:BigInteger = fromInt(256);
        
        var minusSign:String = "";
        
        if (n.isNegative())
        {
            throw "Cannot convert negative BigInteger to bytes";
            n = n.abs();
        }
        
        var out:Array<Int> = [];
        var left:BigInteger = n;
        var divmod:BigIntegerDivResult;
        
        while (left.lesser(ZERO) || left.compareAbs(base) >= 0)
        {
            divmod = left.divmod(base);
            left = divmod.quotient;
            var digit:BigInteger = divmod.remainder;
            
            if (digit.lesser(ZERO))
            {
                digit = base.subtract(digit).abs();
                left = left.next();
            }
            
            out.push(bytify(digit));
        }
        
        out.push(bytify(left));
        out.reverse();
        
        var bo:Bytes = Bytes.alloc(out.length);
        for (i in 0...bo.length)
        {
            bo.set(i, out[i]);
        }
        
        return bo;
    }
    
    
    @:op(!A) public function toRational():BigRational
    {
        return BigRational.create(this);
    }
    
    public static inline function of(x:BigInteger):BigInteger
    {
        return x;
    }
    
    
    @:from public static function fromBits(x:Bits):BigInteger
    {
        return fromBase(x.toString(), 2);
    }
    
    @:from public static function fromInt(x:Int):BigInteger
    {
        return fromFloat(x);
    }
    
    @:from public static function fromFloat(x:Float):BigInteger
    {
        return switch (x)
        {
            case 0: ZERO;
            case 1: ONE;
            case -1: MINUS_ONE;
            default:
                Math.abs(x) < base ?
                    new BigInteger([Std.int(Math.abs(x))], x < 0 || (1.0 / x) == Math.NEGATIVE_INFINITY)
                    : fromString(Std.string(x));
        }
    }
    
    
    
    /**
     * Create a BigInteger from an Int represented as String.
     * The String may contain negative sign as well as an exponent part.
     * The exponent part cannot be negative, i.e. "1e-10".
     * Positive exponent is ok, i.e. "1e10" or "1e+10".
     * 
     * Usage:
     *      var x:BigInteger = "123123123123123123123123123123123";
     *      var x:BigInteger = "-456456456456456456e789789789";
     */
    @:from public static function fromString(text:String):BigInteger
    {
        var s:Bool = Sign.Positive;
        var value:Array<Int> = [];
        
        if (text.charAt(0) == "-")
        {
            s = Sign.Negative;
            text = text.substr(1);
        }
        
        var textParts:Array<String> = text.split("e");
        if (textParts.length > 2) throw "Invalid integer: " + text;
        
        if (textParts.length == 2)
        {
            var expPart:String = textParts[1];
            if (expPart.charAt(0) == "+") expPart = expPart.substr(1);
            var exp:BigInteger = fromString(expPart);
            
            var decimalPlace:Int = textParts[0].indexOf(".");
            
            if (decimalPlace >= 0)
            {
                exp = exp.subtract(fromInt(textParts[0].length - decimalPlace));
                textParts[0] = textParts[0].substr(0, decimalPlace) + textParts[0].substr(decimalPlace + 1);
            }
            
            if (exp.lesser(ZERO)) throw "Cannot include negative exponent part for integers";
            
            while (exp.notEquals(ZERO))
            {
                textParts[0] += "0";
                exp = exp.prev();
            }
        }
        
        text = textParts[0];
        
        if (text == "-0") text = "0";
        var isValid:Bool = ~/^([0-9][0-9]*)$/.match(text);
        if (!isValid) throw "Invalid integer: " + text;
        
        while (text.length > 0)
        {
            var divider:Int = text.length > logBase ? text.length - logBase : 0;
            value.push(Std.parseInt(text.substr(divider)));
            text = text.substr(0, divider);
        }
        
        return new BigInteger(trim(value), s);
    }
    
    @:from public static inline function fromBytes(x:Bytes):BigInteger
    {
        var p:BigInteger = ONE;
        var val:BigInteger = ZERO;
        var isNegative:Bool = false;
        var i:Int = x.length;
        
        while (i-->0)
        {
            //val = val.add(base.pow(i) * x.get(j));
            
            // optimization. instead of pow each step,
            // do multiplication
            val = val.add(p * x.get(i));
            p *= 256;
        }
        
        return val;
    }
    
    public static function fromBase(text:String, base:Int):BigInteger
    {
        var b:BigInteger = fromInt(base);
        var p:BigInteger = ONE;
        var val:BigInteger = ZERO;
        var digits:Array<BigInteger> = [];
        var isNegative:Bool = false;
        
        function parseToken(text:String, i:Int):Void
        {
            var c:String = text.charAt(i).toLowerCase();
            
            if (i == 0 && text.charAt(i) == "-")
            {
                isNegative = true;
                return;
            }
            
            if (~/[0-9]/.match(c))
            {
                digits.push(fromString(c));
            }
            else if (~/[a-z]/.match(c))
            {
                digits.push(fromInt(c.charCodeAt(0) - 87));
            }
            else if (c == "<")
            {
                var start:Int = i;
                do { i++; } while (text.charAt(i) != ">");
                digits.push(fromString(text.substr(start + 1, i)));
            }
            else
            {
                throw c + " is not a valid character";
            }
        }
        
        for (i in 0...text.length)
            parseToken(text, i);
        
        //digits.reverse();
        
        //for (i in 0...digits.length)
        //    val = val.add(digits[i].multiply(base.pow(i)));
        
        var i:Int = digits.length;
        
        while (i-->0)
        {
            // optimization. instead of pow each step,
            // do multiplication instead
            val = val.add(p.multiply(digits[i]));
            p = p.multiply(b);
            
            // weird.. b * digits[i] causes compilation errors elsewhere
            // but it's totally okay for fromBytes to use operator
            // overloading though...
        }
        
        return isNegative ? val.negate() : val;
    }
    
    
    
    private static function trim(value:Array<Int>):Array<Int>
    {
        while (value[value.length - 1] == 0 && value.length > 1) value.pop();
        return value;
    }
    
    
    // commutative doesn't work when it's public function fastAdd(b:Int):BigInteger ?????
    // so I changed everything to static...
    @:op(A + B) @:commutative public static function fastAdd(a:BigInteger, b:Int):BigInteger
    {
        var sign:Bool = b < 0;
        
        if (a.sign != sign)
        {
            //if (sign) return fastSubtract(a.abs(), -b);
            //return fastSubtract(a.abs(), b).negate();
            if (sign) return fastSubtract(a.abs(), -b);
            return fastSubtract(a.abs(), b).negate();
        }
        
        if (sign) b = -b;
        
        //var value:Array<Int> = a.value;
        var result:Array<Int> = [];
        var carry:Int = 0;
        
        var i:Int = 0;
        while (i < a.length || carry > 0)
        {
            //var sum:Int = get(value, i) + (i > 0 ? 0 : b) + carry;
            var sum:Int = a[i] + (i > 0 ? 0 : b) + carry;
            carry = sum >= base ? 1 : 0;
            result.push(sum % base);
            ++i;
        }
        
        return new BigInteger(trim(result), a.sign);
    }
    
    @:op(A - B) public static function fastSubtract(a:BigInteger, b:Int):BigInteger
    {
        var value:Array<Int> = a.value;
        
        if (value.length == 1)
        {
            var x:Int = value[0];
            if (a.sign) x = -x;
            return new BigInteger([Std.int(Math.abs(x - b))], (x - b) < 0);
        }
        
        //if (a.sign != (b < 0)) return fastAdd(a, -b);
        if (a.sign != (b < 0)) return fastAdd(a, -b);
        
        var sign:Bool = false;
        
        if (a.sign) sign = true;
        if (value.length == 1 && value[0] < b) return new BigInteger([b - value[0]], !sign);
        if (sign) b = -b;
        
        var result:Array<Int> = [];
        var borrow:Int = 0;
        
        for (i in 0...value.length)
        {
            var tmp:Int = value[i] - borrow - (i > 0 ? 0 : b);
            borrow = tmp < 0 ? 1 : 0;
            result.push((borrow * base) + tmp);
        }
        
        return new BigInteger(trim(result), sign);
    }
    
    private static function fastMultiplyInternal(value:Array<Int>, lambda:Float):Array<Int>
    {
        var result:Array<Int> = [];
        var carry:Float = 0.0;
        
        for (i in 0...value.length)
        {
            carry += lambda * forceFloat(value[i]); // WTF NEKO?!
            var q:Float = Math.ffloor(carry / base);
            result[i] = Math.floor(carry - q * base);
            carry = q;
        }
        
        result[value.length] = Math.floor(carry);
        return result;
    }
    
    @:op(A * B) @:commutative public static function fastMultiply(a:BigInteger, b:Int):BigInteger
    {
        var result:Array<Int> = fastMultiplyInternal(a.value, b < 0 ? -b : b);
        return new BigInteger(trim(result), b < 0 ? !a.sign : a.sign);
    }
    
    private static function fastDivModInternal(value:Array<Int>, lambda:Float):BigIntegerDivInternalResult
    {
        var quotient:Array<Int> = [];
        
        for (i in 0...value.length)
            quotient[i] = 0;
        
        var remainder:Float = 0.0;
        var i:Int = value.length;
        
        while (i-->0)
        {
            var divisor:Float = forceFloat(remainder) * base + value[i];
            var q:Float = Math.ffloor(divisor / lambda);
            remainder = divisor - q * lambda;
            quotient[i] = Math.floor(q);
        }
        
        return
        {
            quotient: quotient,
            remainder: Math.floor(remainder)
        };
    }
    
    public static function fastDivMod(a:BigInteger, b:Int):BigIntegerDivResult
    {
        if (b == 0) throw "Cannot divide by zero.";
        var result:BigIntegerDivInternalResult = fastDivModInternal(a.value, b < 0 ? -b : b);
        
        return
        {
            quotient: new BigInteger(trim(result.quotient), b < 0 ? !a.sign : a.sign),
            remainder: new BigInteger([result.remainder], a.sign)
        };
    }

    public inline function isSmall():Bool
    {
        //return ((typeof n == "number" || typeof n == "string") && +Math.abs(n) <= base) ||
        //    (n instanceof BigInteger && n.value.length <= 1);
        return length <= 1;
    }
    
    
    
    @:op(-A) public inline function negate():BigInteger
    {
        return new BigInteger(this.value, !this.sign);
    }
    
    public inline function abs():BigInteger
    {
        return new BigInteger(this.value, Sign.Positive);
    }
    
    
    
    @:op(A + B) public function add(b:BigInteger):BigInteger
    {
        var a:BigInteger = this;
        if (b.isSmall()) return fastAdd(a, b.toInt());
        else if (a.isSmall()) return fastAdd(b, a.toInt());
        
        if (a.sign != b.sign)
        {
            if (a.sign == Sign.Positive) return a.abs().subtract(b.abs());
            return b.abs().subtract(a.abs());
        }
        
        var result:Array<Int> = [];
        var carry:Int = 0;
        var length:Int = Std.int(Math.max(a.length, b.length));
        
        var i:Int = 0;
        while (i < length || carry > 0)
        {
            var sum:Int = a[i] + b[i] + carry;
            carry = sum >= base ? 1 : 0;
            result.push(sum % base);
            ++i;
        }
        
        return new BigInteger(trim(result), a.sign);
    }
    
    @:op(A - B) public function subtract(b:BigInteger):BigInteger
    {
        var a:BigInteger = this;
        if (b.isSmall()) return fastSubtract(a, b.toInt());
        
        if (a.sign != b.sign) return a.add(b.negate());
        if (a.sign == Sign.Negative) return b.negate().subtract(negate());
        if (a.compare(b) < 0) return b.subtract(this).negate();
        
        var result:Array<Int> = [];
        var borrow:Int = 0;
        var length:Int = Std.int(Math.max(a.length, b.length));
        
        for (i in 0...length)
        {
            var ai:Int = a[i];
            var bi:Int = b[i];
            var tmp:Int = ai - borrow;
            borrow = tmp < bi ? 1 : 0;
            result.push((borrow * base) + tmp - bi);
        }
        
        return new BigInteger(trim(result), Sign.Positive);
    }
    
    @:op(A * B) public function multiply(n:BigInteger):BigInteger
    {
        if (n.isSmall()) return fastMultiply(this, n.toInt());
        else if (isSmall()) return fastMultiply(n, toInt());
        
        var sign:Bool = this.sign != n.sign;
        
        // change Array<Int> to BigInteger?
        var a:Array<Int> = this.value;
        var b:Array<Int> = n.value;
        var result:Array<Float> = [];
        var result:Array<Int> = [for (i in 0...a.length + b.length) 0];
        
        for (i in 0...a.length)
        {
            var x:Float = 1.0 * a[i];                       // force a float
            
            for (j in 0...b.length)
            {
                var y:Float = 1.0 * b[j];                   // needs to be float otherwise
                var product:Float = x * y + result[i + j];  // product might overflow
                var q:Int = Math.floor(product / base);
                
                result[i + j] = Std.int(product - q * base);
                result[i + j + 1] += q;
            }
        }
        
        return new BigInteger(trim(result), sign);
    }
    
    public function divmod(n:BigInteger):BigIntegerDivResult
    {
        if (n.isSmall()) return fastDivMod(this, n.toInt());
        
        var quotientSign:Bool = this.sign != n.sign;
        if (n.equals(ZERO)) throw "Cannot divide by zero";
        if (equals(ZERO)) return
        {
            quotient: new BigInteger([0], Sign.Positive),
            remainder: new BigInteger([0], Sign.Positive)
        };
        
        var a:Array<Int> = this.value;
        var b:Array<Int> = n.value;
        var result:Array<Int> = [0];
        
        for (i in 0...b.length)
        {
            result[i] = 0;
        }
        
        var divisorMostSignificantDigit:Int = b[b.length - 1];
        
        // normalization
        var lambda:Int = Math.ceil(base / 2.0 / divisorMostSignificantDigit);
        var remainder:Array<Int> = fastMultiplyInternal(a, lambda);
        var divisor:Array<Int> = fastMultiplyInternal(b, lambda);
        divisorMostSignificantDigit = divisor[b.length - 1];
        
        var shift:Int = a.length - b.length;
        
        while (shift >= 0)
        {
            var quotientDigit:Float = 1.0 * base - 1;
            
            if (remainder[shift + b.length] != divisorMostSignificantDigit)
            {
                quotientDigit = Math.ffloor((1.0 * remainder[shift + b.length] * base + remainder[shift + b.length - 1]) / divisorMostSignificantDigit);
            }
            
            // remainder -= quotientDigit * divisor
            var carry:Float = 0.0;
            var borrow:Float = 0.0;
            
            for (i in 0...divisor.length)
            {
                carry += quotientDigit * divisor[i];
                var q:Float = Math.ffloor(carry / base);
                borrow += remainder[shift + i] - (carry - q * base);
                carry = q;
                
                if (borrow < 0)
                {
                    remainder[shift + i] = Math.floor(borrow + base);
                    borrow = -1;
                }
                else
                {
                    remainder[shift + i] = Math.floor(borrow);
                    borrow = 0;
                }
            }
            
            while (borrow != 0)
            {
                quotientDigit -= 1;
                carry = 0.0;
                
                for (i in 0...divisor.length)
                {
                    carry += remainder[shift + i] - base + divisor[i];
                    
                    if (carry < 0)
                    {
                        remainder[shift + i] = Math.floor(carry + base);
                        carry = 0;
                    }
                    else
                    {
                        remainder[shift + i] = Math.floor(carry);
                        carry = 1;
                    }
                }
                
                borrow += carry;
            }
            
            result[shift] = Math.floor(quotientDigit);
            --shift;
        }
        
        // denormalization
        remainder = fastDivModInternal(remainder, lambda).quotient;
        
        return
        {
            quotient: new BigInteger(trim(result), quotientSign),
            remainder: new BigInteger(trim(remainder), this.sign)
        };
    }
    
    @:op(A / B) public function divide(n:BigInteger):BigInteger
    {
        return divmod(n).quotient;
    }
    
    @:op(A % B) public function modulus(n:BigInteger):BigInteger
    {
        return divmod(n).remainder;
    }
    
    @:op(A / B) public function over(n:BigRational):BigRational
    {
        return BigRational.create(this).divide(n);
    }
    
    public function pow(n:BigInteger):BigInteger
    {
        var a:BigInteger = this;
        var b:BigInteger = n;
        var r:BigInteger = ONE;
        
        if (b.equals(ZERO)) return r;
        if (a.equals(ZERO) || b.lesser(ZERO)) return ZERO;
        
        while (true)
        {
            if (b.isOdd()) 
                r = r.multiply(a);
                
            b = b.divide(2);
            if (b.equals(ZERO)) break;
            a = a.multiply(a);
        }
        
        return r;
    }
    
    public function modPow(exp:BigInteger, mod:BigInteger):BigInteger
    {
        if (mod.equals(ZERO)) throw "Cannot take modPow with modulus 0";
        
        var r:BigInteger = ONE;
        var base:BigInteger = modulus(mod);
        if (base.equals(ZERO)) return ZERO;
        
        while (exp.greater(0))
        {
            if (exp.isOdd()) r = r.multiply(base).modulus(mod);
            exp = exp.divide(2);
            base = base.square().modulus(mod);
        }
        
        return r;
    }
    
    public inline function square():BigInteger
    {
        return multiply(this);
    }
    
    
    public static function gcd(a:BigInteger, b:BigInteger):BigInteger
    {
        a = a.abs();
        b = b.abs();
        
        if (a.equals(b)) return a;
        if (a.equals(ZERO)) return b;
        if (b.equals(ZERO)) return a;
        
        if (a.isEven())
        {
            if (b.isOdd())
                return gcd(a.divide(2), b);
            return gcd(a.divide(2), b.divide(2)).multiply(2);
        }
        
        if (b.isEven())
            return gcd(a, b.divide(2));
        
        if (a.greater(b)) 
            return gcd(a.subtract(b).divide(2), b);
        
        return gcd(b.subtract(a).divide(2), a);
    }
    
    public static function lcm(a:BigInteger, b:BigInteger):BigInteger
    {
        a = a.abs();
        b = b.abs();
        return a.multiply(b).divide(gcd(a, b));
    }
    
    
    public inline function next():BigInteger
    {
        return fastAdd(this, 1);
    }
    
    public inline function prev():BigInteger
    {
        return fastSubtract(this, 1);
    }
    
    @:op(++A) public inline function preIncrement():BigInteger
    {
        return this = next();
    }
    
    @:op(A++) public inline function postIncrement():BigInteger
    {
        var tmp:BigInteger = this;
        preIncrement();
        return tmp;
    }
    
    @:op(--A) public inline function preDecrement():BigInteger
    {
        return this = prev();
    }
    
    @:op(A--) public inline function postDecrement():BigInteger
    {
        var tmp:BigInteger = this;
        preDecrement();
        return tmp;
    }
    
    
    public function compare(n:BigInteger):Int
    {
        var a:BigInteger = this;
        var b:BigInteger = n;
        
        if (a.length == 1 && b.length == 1
            && a[0] == 0 && b[0] == 0)
                return 0;
            
        if (b.sign != a.sign)
            return a.sign == Sign.Positive ? 1 : -1;
            
        var multiplier:Int = a.sign == Sign.Positive ? 1 : -1;
        var i:Int = Std.int(Math.max(a.length, b.length));
        
        while (i-->0)
        {
            var ai:Int = a[i];
            var bi:Int = b[i];
            //trace("      ai: " + ai + "    bi: " + bi);
            if (ai > bi) return 1 * multiplier;
            if (bi > ai) return -1 * multiplier;
        }
        
        return 0;
    }
    
    public function compareAbs(n:BigInteger):Int
    {
        return abs().compare(n.abs());
    }
    
    @:op(A == B) public function equals(n:BigInteger):Bool
    {
        return compare(n) == 0;
    }
    
    @:op(A != B) public function notEquals(n:BigInteger):Bool
    {
        return !equals(n);
    }
    
    @:op(A < B) public function lesser(n:BigInteger):Bool
    {
        return compare(n) < 0;
    }
    
    @:op(A > B) public function greater(n:BigInteger):Bool
    {
        return compare(n) > 0;
    }
    
    @:op(A >= B) public function greaterOrEquals(n:BigInteger):Bool
    {
        return compare(n) >= 0;
    }
    
    @:op(A <= B) public function lesserOrEquals(n:BigInteger):Bool
    {
        return compare(n) <= 0;
    }
    
    public static function max(a:BigInteger, b:BigInteger):BigInteger
    {
        return a.greater(b) ? a : b;
    }
    
    public static function min(a:BigInteger, b:BigInteger):BigInteger
    {
        return a.lesser(b) ? a : b;
    }
    
    public function isPositive():Bool
    {
        if (this.value.length == 1 && this.value[0] == 0) return false;
        return this.sign == Sign.Positive;
    }
    
    public function isNegative():Bool
    {
        if (this.value.length == 1 && this.value[0] == 0) return false;
        return this.sign == Sign.Negative;
    }
    
    public function isEven():Bool
    {
        return this.value[0] % 2 == 0;
    }
    
    public function isOdd():Bool
    {
        return this.value[0] % 2 == 1;
    }
    
    public function isUnit():Bool
    {
        return this.value.length == 1 && this.value[0] == 1;
    }
    
    public function isZero():Bool
    {
        return this.value.length == 1 && this.value[0] == 0;
    }
    
    public function isDivisibleBy(n:BigInteger):Bool
    {
        if (n.isZero()) return false;
        return modulus(n).equals(ZERO);
    }
    
    private function isBasicPrime():Primality
    {
        var n:BigInteger = abs();
        
        if (n.isUnit()) return Composite;
        if (n.equals(2) || n.equals(3) || n.equals(5)) return Prime;
        if (n.isEven() || n.isDivisibleBy(3) || n.isDivisibleBy(5)) return Composite;
        if (n.lesser(25)) return Prime;
        
        return Unsure;
    }
    
    public function isPrime():Bool
    {
        var basic:Primality = isBasicPrime();
        if (basic != Unsure)
            return basic == Prime;
        
        var n:BigInteger = abs();
        var nPrev:BigInteger = n.prev();
        
        var a:Array<Int> = [2, 3, 5, 7, 11, 13, 17, 19];
        var b:BigInteger = nPrev;
        var d:BigInteger;
        var t:Bool;
        var x:BigInteger;
            
        while (b.isEven()) b = b.divide(2);
        
        for (i in 0...a.length)
        {
            x = create(a[i]).modPow(b, n);
            if (x.equals(ONE) || x.equals(nPrev)) continue;
            
            t = true;
            d = b;
            
            while (t && d.lesser(nPrev))
            {
                x = x.square().modulus(n);
                if (x.equals(nPrev)) t = false;
                
                d = d.multiply(2);
            }
            
            if (t) return false;
        }
        
        return true;
    }
    
    public function isProbablePrime(iterations:Int=5):Bool
    {
        var basic:Primality = isBasicPrime();
        if (basic != Unsure)
            return basic == Prime;
            
        var n:BigInteger = abs();
        
        for (i in 0...iterations)
        {
            var a = BigInteger.randomBetween(2, n - 2);
            if (!a.modPow(n.prev(), n).isUnit())
                return false; // definitely composite
        }
        
        return true; // large chance of being prime
    }
    
    
    /**
     * Generates a random number in range [a, b).
     * Range includes `a` but does not include `b`.
     */
    public static function randomBetween(a:BigInteger, b:BigInteger, ?r:Random):BigInteger
    {
        if (r == null) r = new NativeRandom();
        
        var low:BigInteger = min(a, b);
        var high:BigInteger = max(a, b);
        var range:BigInteger = high.subtract(low);
        var result:Array<Int> = [];
        var restricted:Bool = true;
        var i:Int = range.length;
        
        while (i-->0)
        {
            var top:Int = restricted ? range[i] : base;
            var digit:Int = Math.floor(r.nextFloat() * top);
            result.unshift(digit);
            if (digit < top) restricted = false;
        }
        
        return low.add(new BigInteger(result, false));
    }
    
    
    @:op(A << B) public function shiftLeft(n:BigInteger):BigInteger
    {
        if (!n.isSmall())
        {
            if (n.isNegative()) return shiftRight(n.abs());
            return multiply(create(2).pow(n));
        }
        
        var x:Int = n.toInt();
        if (x < 0) return shiftRight(-x);
        var result:BigInteger = this;
        
        while (x >= powers2Length)
        {
            result = fastMultiply(result, highestPower2);
            x -= powers2Length - 1;
        }
        
        return fastMultiply(result, powersOfTwo[x]);
    }
    
    @:op(A >> B) public function shiftRight(n:BigInteger):BigInteger
    {
        if (!n.isSmall())
        {
            if (n.isNegative()) return shiftLeft(n.abs());
            return divide(create(2).pow(n));
        }
        
        var x:Int = n.toInt();
        if (x < 0) return shiftLeft(-x);
        var result:BigInteger = this;
        
        while (x >= powers2Length)
        {
            if (result.equals(ZERO)) return result;
            result = fastDivMod(result, highestPower2).quotient;
            x -= powers2Length - 1;
        }
        
        return fastDivMod(result, powersOfTwo[x]).quotient;
    }
    
    @:op(A >>> B) public inline function unsignedShiftRight(n:BigInteger):BigInteger
    {
        return isPositive() ? shiftRight(n) : shiftRight(n).negate();
    }
    
    // Note: the results are correct at the bit-level. So for bitwise operations, they're okay.
    // But you shouldn't use these for integer operations, as BigInteger have variable widths.
    // Reference: http://en.wikipedia.org/wiki/Bitwise_operation#Mathematical_equivalents
    private static function bitwise(x:BigInteger, y:BigInteger, fn:Int->Int->Int):BigInteger
    {
        var sum:BigInteger = ZERO;
        var limit:BigInteger = max(x.abs(), y.abs());
        var n:Int = 0;
        var _2n:BigInteger = ONE;
        
        while (_2n.lesserOrEquals(limit))
        {
            var xMod:Int = x.divide(_2n).isEven() ? 0 : 1;
            var yMod:Int = y.divide(_2n).isEven() ? 0 : 1;
            
            sum = sum.add(_2n.multiply(fn(xMod, yMod)));
            
            _2n = fastMultiply(_2n, 2);
        }
        
        return sum;
    }
    
    private static function notInternal(xMod:Int, yMod:Int):Int
    {
        return (xMod + 1) % 2;
    }
    
    private static function andInternal(xMod:Int, yMod:Int):Int
    {
        return xMod * yMod;
    }
    
    private static function orInternal(xMod:Int, yMod:Int):Int
    {
        return (xMod + yMod + xMod * yMod) % 2;
    }
    
    private static function xorInternal(xMod:Int, yMod:Int):Int
    {
        return (xMod + yMod) % 2;
    }
    
    private static inline function boolToInt(b:Bool):Int
    {
        return b ? 1 : 0;
    }
    
    private static inline function intToBool(i:Int):Bool
    {
        return i == 0 ? false : true;
    }
    
    @:op(~A) public function not():BigInteger
    {
        var body:BigInteger = bitwise(this, this, notInternal);
        return !this.sign ? body.negate() : body;
    }
    
    @:op(A & B) public function and(n:BigInteger):BigInteger
    {
        var body:BigInteger = bitwise(this, n, andInternal);
        return this.sign && n.sign ? body.negate() : body;
    }
    
    @:op(A | B) public function or(n:BigInteger):BigInteger
    {
        var body:BigInteger = bitwise(this, n, orInternal);
        return this.sign || n.sign ? body.negate() : body;
    }
    
    @:op(A ^ B) public function xor(n:BigInteger):BigInteger
    {
        var body:BigInteger = bitwise(this, n, xorInternal);
        return intToBool(boolToInt(this.sign) ^ boolToInt(n.sign)) ? body.negate() : body;
    }
}

private typedef BigIntegerType =
{
    var sign:Bool;
    var value:Array<Int>;
}

@:enum private abstract Sign(Bool) to Bool from Bool
{
    var Positive = false;
    var Negative = true;
}

private typedef BigIntegerDivInternalResult =
{
    var quotient:Array<Int>;
    var remainder:Int;
}

typedef BigIntegerDivResult =
{
    var quotient:BigInteger;
    var remainder:BigInteger;
}

private enum Primality
{
    Prime;
    Composite;
    Unsure;
}