package moon.strings;

using StringTools;

/**
 * Generates hash code from a string.
 * http://www.cse.yorku.ca/~oz/hash.html
 * 
 * You may want to use this together with HashCodeTools
 * i.e:
 *     import moon.strings.HashCode.*;
 *     using moon.tools.HashCodeTools;
 *     
 *     trace(djb2.hash("test"));
 *     trace(djb2.hash(123.45));
 * 
 * @author Munir Hussin
 */
class HashCode
{
    /**
     * Bernstein hash
     */
    public static function djb2(s:String):Int
    {
        var hash:Int = 5381;
        var len:Int = s.length;
        for (i in 0...len)
            hash = ((hash << 5) + hash) + s.fastCodeAt(i);
        return hash;
    }
    
    /**
     * Bernstein hash, using xor
     */
    public static function djb2a(s:String):Int
    {
        var hash:Int = 5381;
        var len:Int = s.length;
        for (i in 0...len)
            hash = hash * 33 ^ s.fastCodeAt(i);
        return hash;
    }
    
    /**
     * Hash used by a database library
     */
    public static function sdbm(s:String):Int
    {
        var hash:Int = 0;
        var len:Int = s.length;
        for (i in 0...len)
            hash = s.fastCodeAt(i) + (hash << 6) + (hash << 16) - hash;
        return hash;
    }
    
    /**
     * Java's hashCode from java.lang.String
     */
    public static function java(s:String):Int
    {
        var hash:Int = 0;
        var len:Int = s.length;
        for (i in 0...len)
            hash = 31 * hash + s.fastCodeAt(i);
        return hash;
    }
    
    /**
     * Fowler-Noll-Vo hash
     * http://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function
     */
    public static function fnv1a(s:String):Int
    {
        var hash:Int = 0x811C9DC5; // 2166136261
        var len:Int = s.length;
        for (i in 0...len)
            hash = (hash ^ s.fastCodeAt(i)) * 16777619;
        return hash;
    }
}

