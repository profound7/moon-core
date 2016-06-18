package moon.tools;

/**
 * 
 * @author Munir Hussin
 */
class ERegTools
{
    public static var rxEscape = ~/(\+|\*|\?|\^|\$|\.|\||\(|\)|\[|\]|\\)/g;
    
    public static function escape(text:String):String
    {
        return rxEscape.replace(text, "\\$1");
    }
    
    /**
     * via: https://github.com/RealyUniqueName/HUnit/blob/master/src/hunit/match/ERegMatch.hx#L56
     * Extracts pattern from an EReg.
     * Can't find a way to make it work in neko so far.
     */
    public static inline function pattern(self:EReg):String
    {
        return
            #if php
                Reflect.getProperty(self, 'pattern');
            #elseif js
                Reflect.getProperty(self, 'r').toString();
            #elseif cs
                Std.string(Reflect.getProperty(self, 'regex'));
            #elseif java
                Std.string(Reflect.getProperty(self, 'pattern'));
            #elseif flash
                Std.string(Reflect.getProperty(self, 'r'));
            #elseif python
                Std.string(Reflect.getProperty(self, 'pattern').pattern);
            #else
                throw "Unimplemented on this platform";
            #end
    }
}