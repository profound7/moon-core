package moon.core;

import haxe.macro.Expr;
import moon.strings.ascii.Ascii;

using StringTools;

/**
 * Char abstract with underlying Int type
 * @author Munir Hussin
 */
abstract Char(Int) to Int from Int
{
    public inline function new(code:Int = 0) this = code;
    
    /*==================================================
        Methods
    ==================================================*/
    
    private inline function isBetween(lo:Int, hi:Int):Bool
    {
        return this >= lo && this <= hi;
    }
    
    public inline function isControl():Bool
    {
        return isBetween(0, 31);
    }
    
    public inline function isPrintable():Bool
    {
        return isBetween(32, 127);
    }
    
    public inline function isExtended():Bool
    {
        return isBetween(128, 255);
    }
    
    public inline function isLetter():Bool
    {
        return isLowerCase() || isUpperCase();
    }
    
    public inline function isDigit():Bool
    {
        return isBetween(Ascii.Digit0, Ascii.Digit9);
    }
    
    public inline function isAlphaNumeric():Bool
    {
        return isLetter() || isDigit();
    }
    
    public inline function isSpace():Bool
    {
        return this == Ascii.Space;
    }
    
    public inline function isWhiteSpace():Bool
    {
        return this == Ascii.Space || isBetween(Ascii.HorizontalTab, Ascii.CarriageReturn);
    }
    
    public inline function isLowerCase():Bool
    {
        return isBetween(Ascii.LowercaseA, Ascii.LowercaseZ);
    }
    
    public inline function isUpperCase():Bool
    {
        return isBetween(Ascii.UppercaseA, Ascii.UppercaseZ);
    }
    
    private inline function isPunctuation1():Bool
    {
        return isBetween(Ascii.ExclamationMark, Ascii.Slash);
    }
    
    private inline function isPunctuation2():Bool
    {
        return isBetween(Ascii.Colon, Ascii.At);
    }
    
    private inline function isPunctuation3():Bool
    {
        return isBetween(Ascii.SquareBracketOpen, Ascii.GraveAccent);
    }
    
    private inline function isPunctuation4():Bool
    {
        return isBetween(Ascii.CurlyBracketOpen, Ascii.Tilde);
    }
    
    public inline function isPunctuation():Bool
    {
        return isPunctuation1() || isPunctuation2() || isPunctuation3() || isPunctuation4();
    }
    
    private inline function isUrlSafePunctuation():Bool
    {
        return this == Ascii.Minus || this == Ascii.Period ||
            this == Ascii.Underscore || this == Ascii.Tilde;
    }
    
    private inline function isUrlSafe():Bool
    {
        return isAlphaNumeric() || isUrlSafePunctuation();
    }
    
    
    public inline function toLowerCase():Char
    {
        return isUpperCase() ? this + Ascii.Space.toInt() : this;
    }
    
    public inline function toUpperCase():Char
    {
        return isLowerCase() ? this - Ascii.Space.toInt() : this;
    }
    
    
    /**
     * TODO: this shouldn't belong here. move it.
     * 
     * this macro generates a string of characters. for example, this:
     * 
     *    var x:String = Char.generate("abc", LowerCase, Digit);
     * 
     * becomes this:
     * 
     *    var x:String = "0123456789defghijklmnopqrstuvwxyz";
     * 
     * generated chars are always in ascii order
     */ 
    public static macro function generate(exclude:String, include:String, enums:Array<Expr>):ExprOf<String>
    {
        var r:String = "";
        var c:Char = 0;
        var fns:Array<haxe.Constraints.Function> = [];
        
        // get all the char types given in the argument
        for (e in enums) switch (e.expr)
        {
            case EConst(CIdent(s)) if (Reflect.hasField(CharTypes, s)):
                if (Reflect.hasField(Char, "is" + s))
                    fns.push(Reflect.field(Char, "is" + s));
                else
                    throw "Char.is" + s + "() does not exist";
                
            default:
                throw "Invalid CharType";
        }
        
        if (exclude == null) exclude = "";
        if (include == null) include = "";
        
        for (i in 0...128) if (exclude.indexOf(String.fromCharCode(i)) == -1)
        {
            c = i;
            
            if (include.indexOf(String.fromCharCode(i)) != -1)
            {
                r += c.toString();
            }
            else
            {
                for (fn in fns)
                    if (Reflect.callMethod(c, fn, [c]))
                        r += c.toString();
            }
        }
        
        return macro $v{r};
    }
    
    /*==================================================
        Operator overloading
    ==================================================*/
    
    @:op(A + B) @:commutative private static inline function _add(self:Char, value:Int):Char
    {
        return self.toInt() + value;
    }
    
    public inline function add(value:Int):Char
    {
        return _add(this, value);
    }
    
    @:op(A - B) private static inline function _subtract(self:Char, value:Int):Char
    {
        return self.toInt() - value;
    }
    
    public inline function subtract(value:Int):Char
    {
        return _subtract(this, value);
    }
    
    @:op(A * B) @:commutative private static inline function _repeat(self:Char, count:Int):Text
    {
        return self.toText().repeat(count);
    }
    
    public inline function repeat(count:Int):Text
    {
        return _repeat(this, count);
    }
    
    @:op(A == B) public inline function isEquals(other:Char):Bool
    {
        return this == other.toInt();
    }
    
    @:op(A < B) public inline function isLesserThan(other:Char):Bool
    {
        return this < other.toInt();
    }
    
    @:op(A > B) public inline function isGreaterThan(other:Char):Bool
    {
        return this > other.toInt();
    }
    
    @:op(A <= B) public inline function isLesserOrEquals(other:Char):Bool
    {
        return this <= other.toInt();
    }
    
    @:op(A >= B) public inline function isGreaterOrEquals(other:Char):Bool
    {
        return this >= other.toInt();
    }
    
    
    /*==================================================
        Conversions
    ==================================================*/
    
    @:from public static inline function fromString(s:String):Char
    {
        return s.fastCodeAt(0);
    }
    
    @:from public static inline function fromInt(c:Int):Char
    {
        return c;
    }
    
    @:to public inline function toInt():Int
    {
        return this;
    }
    
    @:to public inline function toText():Text
    {
        return toString();
    }
    
    @:to public inline function toString():String
    {
        return String.fromCharCode(this);
    }
}


enum CharTypes
{
    Control;
    Printable;
    Extended;
    Letter;
    Digit;
    AlphaNumeric;
    Whitespace;
    LowerCase;
    UpperCase;
    Punctuation;
    UrlSafe;
}

