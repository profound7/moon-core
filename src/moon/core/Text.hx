package moon.core;

import moon.core.Range;

using StringTools;
using moon.tools.TextTools;
using moon.tools.ReplaceTools;

/**
 * Text is a String abstract with some goodies!
 * 
 * @author Munir Hussin
 */
@:forward abstract Text(String) to String from String
{
    public static var tabSpaces:Int = 4;
    public var length(get, never):Int;
    public var replace(get, never):TextReplace;
    
    public function new(s:String) this = s;
    
    /*==================================================
        Service methods
    ==================================================*/
    
    // support negative indexing
    public inline function pos(i:Int):Int
    {
        return this.pos(i);
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    @:op(!A) private inline function get_length():Int
    {
        return this.length;
    }
    
    private inline function get_replace():TextReplace
    {
        return this;
    }
        
    /*==================================================
        Goodies
    ==================================================*/
    
    /**
     * Internally it's the same as fastCodeAt, except it's returning
     * an abstract Char instead of an Int
     */
    @:arrayAccess public inline function getCharAt(i:Int):Char
    {
        return this.getCharAt(i);
    }
        
    /**
     * Overrides text starting at position `i`. For example:
     * "hello"[2] = "XY" ==> "heXYo"
     */
    @:arrayAccess public inline function writeAt(i:Int, value:Text):Text
    {
        this = this.writeAt(i, value);
        return value;
    }
    
    /**
     * Combines 2 text together
     */
    @:op(A + B) public inline function concat(other:Text):Text
    {
        return this.concat(other);
    }
    
    @:op(A * B) @:commutative private static function _repeat(self:Text, count:Int):Text
    {
        return self.repeat(count);
    }
    
    /**
     * Repeats this text `count` times. Overloaded with multiply operator.
     * Eg: Text.of("hi") * 3 ==> "hihihi"
     */
    public inline function repeat(count:Int):Text
    {
        return this.repeat(count);
    }
    
    @:op(A % B) private inline function indexedReplace(args:Array<Dynamic>):Text
    {
        return this.indexedReplace(args);
    }
    
    @:op(A % B) private inline function objectReplace(args:Struct):Text
    {
        return this.curlyReplace(args);
    }
    
    /**
     * Adds `count` spaces to the left
     */
    @:op(A >> B) public inline function shiftRight(count:Int):Text
    {
        return this.shiftRight(count);
    }
    
    /**
     * Removes `count` spaces from the left
     */
    @:op(A << B) public inline function shiftLeft(count:Int):Text
    {
        return this.shiftLeft(count);
    }
    
    /**
     * Shift right by 4 spaces per `count`
     */
    @:op(A >>> B) public inline function indent(count:Int):Text
    {
        return shiftRight(count * tabSpaces);
    }
    
    /**
     * Count the number of substring occurances
     */
    public function count(substr:String):Int
    {
        return this.count(substr);
    }
    
    /**
     * Based on the contents of this text, determine if newline
     * is CrLf (Windows) or Cr (Macintosh) or Lf (Unix).
     */
    public function detectNewline():Text
    {
        return this.detectNewline();
    }
    
    
    public function alignLine(mode:TextAlign, width:Int, blank:String=" ", crop:Bool=false):String
    {
        return this.alignLine(mode, width, blank, crop);
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
    public function align(mode:TextAlign, width:Int, blank:Text, crop:Bool=false):Text
    {
        return this.align(mode, width, blank, crop);
    }
    
    /**
     * Like split() but same behavior as php's explode, with an
     * additional option `ignoreBlank`
     */
    public function explode(delimiter:String, ?limit:Int, ignoreBlank:Bool=false):Array<String>
    {
        return this.explode(delimiter, limit, ignoreBlank);
    }
    
    // TODO: implode() for arrays?
    
    /*==================================================
        Iterators
    ==================================================*/
    
    public inline function iterator(?range:Range):Iterator<Text>
    {
        return this.iterator(range);
    }
    
    public inline function chars(?range:Range):Iterator<Char>
    {
        return this.chars(range);
    }
    
    /*==================================================
        Forward overrides
    ==================================================*/
    
    public inline function toUpperCase():Text
        return this.toUpperCase();
        
    public inline function toLowerCase():Text
        return this.toLowerCase();
        
    public inline function charAt(i:Int):Text
        return this.charAt(pos(i));
    
    public inline function split(delimiter:String):Array<Text>
        return this.split(delimiter);
        
    public inline function substr(pos:Int, ?len:Int):Text
        return this.substr(pos, len);
        
    public inline function substring(startIndex:Int, ?endIndex:Int):Text
        return this.substring(startIndex, endIndex);
        
    /*==================================================
        StringTools
    ==================================================*/
    
    public inline function urlEncode():Text
        return this.urlEncode();
        
    public inline function urlDecode():Text
        return this.urlDecode();
        
    public inline function htmlEscape(?quotes:Bool):Text
        return this.htmlEscape(quotes);
        
    public inline function htmlUnescape():Text
        return this.htmlUnescape();
        
    public inline function startsWith(start:String):Bool
        return this.startsWith(start);
        
    public inline function endsWith(end:String):Bool
        return this.endsWith(end);
        
    public inline function isSpace(pos:Int):Bool
        return this.isSpace(pos);
        
    public inline function ltrim():Text
        return this.ltrim();
        
    public inline function rtrim():Text
        return this.rtrim();
        
    public inline function trim():Text
        return this.trim();
        
    public inline function lpad(c:String, l:Int):Text
        return this.lpad(c, l);
        
    public inline function rpad(c:String, l:Int):Text
        return this.rpad(c, l);
        
    //public inline function replace(sub:String, by:String):Text
    //    return this.replace(sub, by);
        
    public inline function fastCodeAt(index:Int):Int
        return this.fastCodeAt(index);
        
    /*==================================================
        Conversions
    ==================================================*/
    
    @:from public static inline function fromCharCode(code:Int):Text
    {
        return String.fromCharCode(code);
    }
    
    @:from public static inline function fromCharArray(value:Array<Char>):Text
    {
        var sbuf:StringBuf = new StringBuf();
        for (c in value)
            sbuf.addChar(c);
        return sbuf.toString();
    }
    
    @:to public inline function toCharArray():Array<Char>
    {
        return this.toCharArray();
    }
    
    @:from public static inline function of(str:String):Text
    {
        return str;
    }
    
    @:to public inline function toString():String
    {
        return this;
    }
}

abstract TextReplace(String) to String from String
{
    /*==================================================
        ReplaceTools
    ==================================================*/
    
    public inline function map(args:Struct, regex:EReg):Text
    {
        return this.mapReplace(args, regex);
    }
    
    public inline function sequential(args:Array<Dynamic>):Text
    {
        return this.sequentialReplace(args);
    }
    
    @:op(A % B) public inline function indexed(args:Array<Dynamic>):Text
    {
        return this.indexedReplace(args);
    }
    
    public inline function dollar(args:Struct):Text
    {
        return this.dollarReplace(args);
    }
    
    @:op(A % B) public inline function curly(args:Struct):Text
    {
        return this.curlyReplace(args);
    }
    
    public inline function dollarCurly(args:Struct):Text
    {
        return this.dollarCurlyReplace(args);
    }
    
    public inline function moustache(args:Struct):Text
    {
        return this.moustacheReplace(args);
    }
    
    /*==================================================
        StringTools
    ==================================================*/
    
    public inline function substr(sub:String, by:String):Text
    {
        return this.replace(sub, by);
    }
}
