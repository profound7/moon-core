package moon.tools;

import moon.core.Struct;

/**
 * Usage:
 * 
 *  using moon.tools.ReplaceTools;
 * 
 *  var a:String = "hello %@ would you like some %@ today?".sequentialReplace(["Bob", "tea"]);
 *  var b:String = "hey $0, meet $1. $1, meet $0!".indexedReplace(["Bob", "Alice"]);
 * 
 * @author Munir Hussin
 */
class ReplaceTools
{
    public static var SEQ_REGEX:EReg = ~/(%@)/g;
    public static var INDEXED_REGEX:EReg = ~/\$(\d+)/g;
    public static var DOLLAR_REGEX:EReg = ~/\$(\w+)/g;
    public static var CURLY_REGEX:EReg = ~/{(\w+)}/g;
    public static var DCURLY_REGEX:EReg = ~/${(\w+)}/g;
    public static var MOUSTACHE_REGEX:EReg = ~/{{(\w+)}}/g;
    
    @:noUsing
    private static inline function transform(val:Dynamic, ?tx:Dynamic->Dynamic):Dynamic
    {
        return tx == null ? val : tx(val);
    }
    
    public static function mapReplace(str:String, replace:Struct, regex:EReg, ?tx:Dynamic->Dynamic):String
    {
        return regex.map(str, function(r:EReg):String
        {
            return Std.string(transform(replace[ r.matched(1) ], tx));
        });
    }
    
    // replaces each %@ with the replace array in sequence
    public static function sequentialReplace(str:String, replace:Array<Dynamic>, ?tx:Dynamic->Dynamic):String
    {
        var i:Int = 0;
        return SEQ_REGEX.map(str, function(r:EReg):String
        {
            return Std.string(transform(replace[i++], tx));
        });
    }
    
    // searches the string for $x where x is the index of the replace array
    // indexedReplace("abc $1 def $2 ghi $1 jkl $0 mno", ["A", 2, true])
    // ==> "abc 2 def true ghi 2 jkl A mno"
    public static function indexedReplace(str:String, replace:Array<Dynamic>, ?tx:Dynamic->Dynamic):String
    {
        return INDEXED_REGEX.map(str, function(r:EReg):String
        {
            return Std.string(transform(replace[ Std.parseInt(r.matched(1)) ], tx));
        });
    }
    
    // "abc $hello ghi", {hello: "yay"} ==> "abc yay ghi"
    public static function dollarReplace(str:String, replace:Struct, ?tx:Dynamic->Dynamic):String
    {
        return mapReplace(str, replace, DOLLAR_REGEX, tx);
    }
    
    // "abc {hello} ghi", {hello: "yay"} ==> "abc yay ghi"
    public static function curlyReplace(str:String, replace:Struct, ?tx:Dynamic->Dynamic):String
    {
        return mapReplace(str, replace, CURLY_REGEX, tx);
    }
    
    // "abc ${hello} ghi", {hello: "yay"} ==> "abc yay ghi"
    public static function dollarCurlyReplace(str:String, replace:Struct, ?tx:Dynamic->Dynamic):String
    {
        return mapReplace(str, replace, DCURLY_REGEX, tx);
    }
    
    // "abc {{hello}} ghi", {hello: "yay"} ==> "abc yay ghi"
    public static function moustacheReplace(str:String, replace:Struct, ?tx:Dynamic->Dynamic):String
    {
        return mapReplace(str, replace, MOUSTACHE_REGEX, tx);
    }
    
}
