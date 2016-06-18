package moon.numbers.big;

import moon.numbers.big.BigInteger.BigIntegerDivResult;

/**
 * https://github.com/peterolson/BigRational.js
 * 
 * @author Peter Olson (JavaScript original)
 * @author Munir Hussin (Haxe port)
 */
@:forward abstract BigRational(BigRationalType) to BigRationalType from BigRationalType
{
    public static var ZERO(default, null):BigRational;
    public static var ONE(default, null):BigRational;
    public static var HALF(default, null):BigRational;
    
    
    private static function __init__():Void
    {
        ZERO = new BigRational(0, 1);
        ONE = new BigRational(1, 1);
        HALF = new BigRational(1, 2);
    }
    
    
    public function new(numerator:BigInteger, denominator:BigInteger) 
    {
        this = { numerator: numerator, denominator: denominator };
    }
    
    private static inline function gcd(a:BigInteger, b:BigInteger):BigInteger
    {
        return BigInteger.gcd(a, b);
    }
    
    private static inline function lcm(a:BigInteger, b:BigInteger):BigInteger
    {
        return BigInteger.lcm(a, b);
    }
    
    public static function create(numerator:BigInteger, ?denominator:BigInteger, preventReduce:Bool=false):BigRational
    {
        if (denominator == null) denominator = BigInteger.ONE;
        var obj:BigRational = new BigRational(numerator, denominator);
        return preventReduce ? obj : obj.reduce();
    }
    
    public function reduce():BigRational
    {
        var divisor:BigInteger = gcd(this.numerator, this.denominator);
        var num:BigInteger = this.numerator.divide(divisor);
        var denom:BigInteger = this.denominator.divide(divisor);
        
        if (denom.lesser(0))
        {
            num = num.multiply(-1);
            denom = denom.multiply(-1);
        }
        
        if (denom.equals(0))
            throw "Denominator cannot be 0.";
            
        return create(num, denom, true);
    }
    
    public inline function abs():BigRational
    {
        return isPositive() ? this : negate();
    }
    
    @:op(A * B) public inline function multiply(r:BigRational):BigRational
    {
        return create(this.numerator.multiply(r.numerator),
            this.denominator.multiply(r.denominator));
    }
    
    @:op(A / B) public inline function divide(r:BigRational):BigRational
    {
        return create(this.numerator.multiply(r.denominator),
            this.denominator.multiply(r.numerator));
    }
    
    @:op(A % B) public inline function modulus(r:BigRational):BigRational
    {
        return subtract(r.multiply(divide(r).floor()));
    }
    
    @:op(A + B) public function add(r:BigRational):BigRational
    {
        var multiple:BigInteger = lcm(this.denominator, r.denominator);
        var a:BigInteger = multiple.divide(this.denominator);
        var b:BigInteger = multiple.divide(r.denominator);
        
        a = this.numerator.multiply(a);
        b = r.numerator.multiply(b);
        return create(a.add(b), multiple);
    }
    
    @:op(-A) public inline function negate():BigRational
    {
        var num:BigInteger = BigInteger.ZERO.subtract(this.numerator);
        return create(num, this.denominator);
    }
    
    @:op(A - B) public inline function subtract(r:BigRational):BigRational
    {
        return add(r.negate());
    }
    
    public inline function recipocate():BigRational
    {
        return create(this.denominator, this.numerator);
    }
    
    public inline function pow(exp:BigInteger):BigRational
    {
        return create(this.numerator.pow(exp), this.denominator.pow(exp));
    }
    
    public inline function isPositive():Bool
    {
        return this.numerator.isPositive();
    }
    
    public inline function isNegative():Bool
    {
        return !isPositive();
    }
    
    public inline function isZero():Bool
    {
        return equals(0);
    }
    
    public function compare(r:BigRational):Int
    {
        if (this.numerator.equals(r.numerator) && this.denominator.equals(r.denominator))
            return 0;
            
        var newDenom:BigInteger = this.denominator.multiply(r.denominator);
        var comparison:Int = newDenom.greater(0) ? 1 : -1;
        
        if (this.numerator.multiply(r.denominator).greater(r.numerator.multiply(this.denominator)))
        {
            return comparison;
        }
        else
        {
            return -comparison;
        }
    }
    
    @:op(A == B) public inline function equals(r:BigRational):Bool
    {
        return compare(r) == 0;
    }
    
    @:op(A != B) public inline function notEquals(r:BigRational):Bool
    {
        return !equals(r);
    }
    
    @:op(A < B) public inline function lesser(r:BigRational):Bool
    {
        return compare(r) < 0;
    }
    
    @:op(A <= B) public inline function lesserOrEquals(r:BigRational):Bool
    {
        return compare(r) <= 0;
    }
    
    @:op(A > B) public inline function greater(r:BigRational):Bool
    {
        return compare(r) > 0;
    }
    
    @:op(A >= B) public inline function greaterOrEquals(r:BigRational):Bool
    {
        return compare(r) >= 0;
    }
    
    public function floor():BigInteger
    {
        //return this.numerator.divide(this.denominator);
        var divmod = this.numerator.divmod(this.denominator);
        var result:BigInteger;
        
        if (divmod.remainder.isZero() || !divmod.quotient.sign)
            result = divmod.quotient;
        else
            result = divmod.quotient.prev();
        
        return result;
    }
    
    public function ceil():BigInteger
    {
        var divmod = this.numerator.divmod(this.denominator);
        var result:BigInteger;
        
        if (divmod.remainder.isZero() || divmod.quotient.sign)
            result = divmod.quotient;
        else
            result = divmod.quotient.next();
        
        return result;
    }
    
    public inline function round():BigInteger
    {
        return add(HALF).floor();
    }
    
    
    @:to public function toString():String
    {
        var o:BigRational = reduce();
        return o.numerator.toString() + "/" + o.denominator.toString();
    }
    
    public inline function toFloat():Float
    {
        return this.numerator.toFloat() / this.denominator.toFloat();
    }
    
    public function toDecimal(digits:Int=10):String
    {
        var signN = this.numerator.sign;
        var signD = this.denominator.sign;
        var sign:Bool = (signN && !signD) || (!signN && signD);
        
        var n:BigIntegerDivResult = this.numerator.divmod(this.denominator);
        var intPart:String = n.quotient.toString();
        var remainder:BigRational = create(n.remainder.abs(), this.denominator);
        var decPart:String = "";
        
        while (decPart.length <= digits)
        {
            var i:Int = 0;
            
            while (i <= 10)
            {
                var num:String = decPart + i;
                var denom:String = "1" + [for (_ in 0...decPart.length + 2) ""].join("0");
                var cmp:BigRational = create(num, denom);
                
                if (create(num, denom).greater(remainder))
                {
                    i--;
                    break;
                }
                
                ++i;
            }
            
            decPart += i;
        }
        
        while (decPart.substr(-1) == "0")
            decPart = decPart.substr(0, -1);
        
        if (decPart == "")
            return intPart;
            
        if (sign && intPart.substr(0, 1) != "-")
            intPart = "-" + intPart;
            
        return intPart + "." + decPart;
    }
    
    @:from public static inline function fromBigInteger(n:BigInteger):BigRational
    {
        return create(n);
    }
    
    @:from public static inline function fromInt(n:Int):BigRational
    {
        return create(n);
    }
    
    @:from public static inline function fromFloat(n:Float):BigRational
    {
        return fromDecimal(Std.string(n));
    }
    
    public static function fromDecimal(n:String):BigRational
    {
        var parts:Array<String> = ~/e/i.split(n);
        
        if (parts.length > 2)
            throw "Invalid input: too many 'e' tokens";
        
        // 123e456
        if (parts.length > 1)
        {
            var isPositive:Bool = true;
            
            if (parts[1].charAt(0) == "-")
            {
                parts[1] = parts[1].substr(1);
                isPositive = false;
            }
            
            if (parts[1].charAt(0) == "+")
            {
                parts[1] = parts[1].substr(1);
            }
            
            var significand:BigRational = fromDecimal(parts[0]);
            var exponent:BigRational = create(BigInteger.create(10).pow(parts[1]));
            
            return isPositive ? significand.multiply(exponent) : significand.divide(exponent);
        }
        
        // 123.456
        parts = n.split(".");
        
        if (parts.length > 2)
            throw "Invalid input: too many '.' tokens";
            
        if (parts.length > 1)
        {
            var intPart:BigRational = create(BigInteger.create(parts[0]));
            var length:Int = parts[1].length;
            
            while (parts[1].charAt(0) == "0")
                parts[1] = parts[1].substr(1);
            
            var exp:String = "1" + [for (x in 0...length + 1) ""].join("0");
            var decPart:BigRational = create(BigInteger.create(parts[1]), BigInteger.create(exp));
            intPart = intPart.add(decPart);
            
            if (parts[0].charAt(0) == "-")
                intPart = intPart.negate();
            return intPart;
        }
        
        return create(BigInteger.create(n));
    }
    
    @:from public static function fromString(a:String):BigRational
    {
        // 1 argument only,
        var num:BigInteger;
        var denom:BigInteger;
        
        var text:String = a + "";
        var texts:Array<String> = text.split("/");
        
        if (texts.length > 2)
            throw "Invalid input: too many '/' tokens";
            
        if (texts.length > 1)
        {
            var parts:Array<String> = texts[0].split("_");
            
            if (parts.length > 2)
                throw "Invalid input: too many '_' tokens";
            
            if (parts.length > 1)
            {
                var isPositive:Bool = parts[0].charAt(0) != "-";
                num = BigInteger.create(parts[0]).multiply(texts[1]);
                num = isPositive ? num.add(parts[1]) : num.subtract(parts[1]);
                denom = BigInteger.create(texts[1]);
                return create(num, denom);
            }
            
            return create(BigInteger.create(texts[0]), BigInteger.create(texts[1]));
        }
        
        return fromDecimal(text);
    }
    
    public static inline function of(numerator:BigRational, denominator:BigRational):BigRational
    {
        return numerator / denominator;
    }
}

private typedef BigRationalType =
{
    var numerator:BigInteger;
    var denominator:BigInteger;
}
