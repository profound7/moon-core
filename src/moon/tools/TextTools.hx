package moon.tools;

import moon.core.Char;
import moon.core.Range;
import moon.data.iterators.CharsIterator;
import moon.data.iterators.TextIterator;

using StringTools;

/**
 * ...
 * @author Munir Hussin
 */
class TextTools
{
    public static var tabSpaces:Int = 4;
    
    /*==================================================
        Service methods
    ==================================================*/
    
    // support negative indexing
    public static inline function pos(self:String, i:Int):Int
    {
        return i >= 0 ? i : self.length + i;
    }
    
    /*==================================================
        Goodies
    ==================================================*/
    
    /**
     * Internally it's the same as fastCodeAt, except it's returning
     * an abstract Char instead of an Int
     */
    public static inline function getCharAt(self:String, i:Int):Char
    {
        return self.fastCodeAt(pos(self, i));
    }
    
    /**
     * Overrides text starting at position `i`. For example:
     * "hello"[2] = "XY" ==> "heXYo"
     */
    public static inline function writeAt(self:String, i:Int, value:String):String
    {
        return self.substr(0, pos(self, i)) + value + self.substr(pos(self, i) + value.length);
    }
    
    /**
     * Combines 2 text together
     */
    public static inline function concat(self:String, other:String):String
    {
        return self + other;
    }
    
    /**
     * Repeats this text `count` times. Overloaded with multiply operator.
     * Eg: Text.of("hi") * 3 ==> "hihihi"
     */
    public static inline function repeat(self:String, count:Int):String
    {
        var s:StringBuf = new StringBuf();
        while (count-->0)
            s.add(self);
        return s.toString();
    }
    
    /**
     * Adds `count` spaces to the left
     */
    public static inline function shiftRight(self:String, count:Int):String
    {
        return repeat(" ", count) + self;
    }
    
    /**
     * Removes `count` spaces from the left
     */
    public static inline function shiftLeft(self:String, count:Int):String
    {
        var n:Int = 0;
        while (self.fastCodeAt(n) == " ".code && count-->0)
            ++n;
        return n == 0 ? self : self.substr(n);
    }
    
    /**
     * Shift right by 4 spaces per `count`
     */
    public static inline function indent(self:String, count:Int):String
    {
        return shiftRight(self, count * tabSpaces);
    }
    
    /**
     * Count the number of substring occurances
     */
    public static inline function count(self:String, substr:String):Int
    {
        // TODO: benchmark for different platforms and add
        // directives to use the better method based on platform
        
        #if v1
            var total:Int = 0;
            var pos:Int = self.indexOf(substr, 0);
            
            while (pos != -1)
            {
                total++;
                pos = self.indexOf(substr, pos + substr.length);
            }
            
            return total;
        #else
            return self.split(substr).length - 1;
        #end
    }
    
    /**
     * Based on the contents of this text, determine if newline
     * is CrLf (Windows) or Cr (Macintosh) or Lf (Unix).
     */
    public static function detectNewline(self:String):String
    {
        var rn:Int = count(self, "\r\n");
        var n:Int = count(self, "\n");
        var r:Int = count(self, "\r");
        
        // CrLf has the highest count
        if (rn > 0 && rn >= r && rn >= n)
            return "\r\n";
        // Lf has the highest count
        else if (n > 0 && n > rn && n > r)
            return "\n";
        // Cr has the highest count
        else if (r > 0 && r > rn && r > n)
            return "\r";
        // all other situations, assume Lf as default
        else
            return "\n";
    }
    
    public static function alignLine(str:String, mode:TextAlign, width:Int, blank:String=" ", crop:Bool=false):String
    {
        var background = "".rpad(blank, width).substr(0, width);
        var ret = switch (mode)
        {
            case Left:
                str + background.substr(str.length);
                
            case Right:
                background.substr(0, width - str.length) + str;
                
            case Center:
                var half = Std.int((width - str.length) / 2);
                if (half < 0) half = 0;
                background.substr(0, half) + str + background.substr(half + str.length);
        }
        
        return crop ? ret.substr(0, width) : ret;
    }
    
    /**
     * Aligns text to Left, Center or Right, based on a width.
     * Eg:
     *  var foo:Text = "abc";
     *  var width = 10;
     *  trace(foo.align(Left, width, "._", true));      ==> abc_._.
     *  trace(foo.align(Right, width, "._", true));     ==> ._._abc
     *  trace(foo.align(Center, width, "._", true));    ==> ._abc_.
     */
    public static function align(self:String, mode:TextAlign, width:Int, blank:String=" ", crop:Bool=false, newLine:String="\n"):String
    {
        var lines = self.split(newLine);
        for (i in 0...lines.length)
            lines[i] = alignLine(lines[i], mode, width, blank, crop);
        return lines.join(newLine);
    }
    
    /**
     * Like split() but same behavior as php's explode, with an
     * additional option `ignoreBlank`
     */
    public static function explode(self:String, delimiter:String, ?limit:Int, ignoreBlank:Bool=false):Array<String>
    {
        var rest:Array<String> = self.split(delimiter);
        var head:Array<String> = [];
        
        if (ignoreBlank)
        {
            // filter away blank items
            rest = [for (x in rest) if (x.length > 0) x];
        }
        
        if (limit == null)
        {
            // limit not given: same as split
            return rest;
        }
        else if (limit >= 0)
        {
            // limit given: split first n delimiters
            limit--;
            while (limit-->0)
            {
                head.push(rest.shift());
            }
            
            head.push(rest.join(delimiter));
            return head;
        }
        else
        {
            // negative limit: remove last few entries
            while (limit++ < 0)
            {
                rest.pop();
            }
            
            return rest;
        }
    }
    
    // TODO: implode() for arrays?
    
    /*==================================================
        Iterators
    ==================================================*/
    
    public static inline function iterator(self:String, ?range:Range):Iterator<String>
    {
        return new TextIterator(self, range == null ? Range.from(0, self.length, 1) : range);
    }
    
    public static inline function chars(self:String, ?range:Range):Iterator<Char>
    {
        return new CharsIterator(self, range == null ? Range.from(0, self.length, 1) : range);
    }
    
    /*==================================================
        Conversions
    ==================================================*/
    
    public static inline function toCharArray(self:String):Array<Char>
    {
        return [for (i in 0...self.length) self.fastCodeAt(i)];
        //return self.split("").map(function (a:String):Char return a.fastCodeAt(0));
    }
}


enum TextAlign
{
    Left;
    Right;
    Center;
}