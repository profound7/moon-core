package moon.tools;

/**
 * Base converter. Modified from: http://haxe.org/doc/snip/numericbase
 * It works with integer range only.
 * Use BigInteger for larger base conversions.
 * 
 * WARNING:
 *      Avoid using this directly for short-urls as some numbers
 *      may result in strings containing profanity
 * 
 * CHARS:
 *      max base is 94.
 * 
 * READABLE_CHARS:
 *      max base is 58.
 *      url friendly, for url shorterning purposes.
 *      excluded 0,O,1,l for readabilty.
 * 
 * Popular bases: 2, 4, 8, 16, 32, 58, 62, 64, 85, 91, 94
 * 
 * @author Munir Hussin
 */
class BaseTools
{
    // base 94
    public static inline var CHARS:String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_.~,!#$%&()*+/:;<=>?@[]^'{|}\"\\'";
    
    // base 58
    public static inline var READABLE_CHARS:String = "23456789abcdefghijkmnopqrstuvwxyzABCDEFGHIJKLMNPQRSTUVWXYZ";
    
    // base 62
    public static inline var ALPHANUM_CHARS:String = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    /**
     * 2.toBase(4);
     */
    public static function toBase(input:Int, base:Int, chars:String=CHARS):String
    {
        // base 2 means [0,1], therefore chars must have at least base-number of chars
        if (base > chars.length)
            throw 'Insufficient number of chars for base $base';
        else if (base < 2)
            throw 'Base $base unsupported.';
        
        var result:String = "";
        
        while (input > 0)
        {
            var pos:Int = input % base;
            
            result = chars.charAt(pos) + result;
            input = Std.int(input / base);
        }
        
        return result;
    }
    
    /**
     * "1AD37".fromBase(3)
     */
    public static function fromBase(input:String, base:Int, chars:String=CHARS):Int
    {
        // base 2 means [0,1], therefore chars must have at least base-number of chars
        if (base > chars.length)
            throw 'Insufficient number of chars for base $base';
        else if (base < 2)
            throw 'Base $base unsupported.';
                
        var i:Int, len:Int;
        i = len = input.length;
        var result:Int = 0;
        
        while (i-->0)
        {
            var char:String = input.charAt(len - i - 1);
            var pos:Int = chars.indexOf(char);
            
            if (pos == -1)
                throw '$input contains invalid characters';
            else if (pos >= base)
                throw '$input is not in base $base';
                
            result += Std.int(Math.pow(base, i) * pos);
        }
        
        return result;
    }
}
