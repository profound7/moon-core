package moon.strings;

using StringTools;
using moon.strings.Inflect;

/**
 * https://github.com/auraphp/Aura.Framework/blob/develop/src/Aura/Framework/Inflect.php
 * @author Munir Hussin
 */
class Inflect
{
    //private static var regex:EReg = ~/([a-z])([A-Z])/g;
    #if js
        private static var regex:EReg = ~/([A-Z][^A-Z]+)/g;
    #else
        private static var regex:EReg = ~/((?<=[a-z])[A-Z]|[A-Z](?=[a-z]))/g;
    #end
    
    // js doesnt have lookbehind
    
    /*==================================================
        Operations on Entire String
    ==================================================*/
    
    /**
     * Transform a string to upper case.
     * "HeLlO wOrLd" ==> "HELLO WORLD"
     */
    public static inline function upper(s:String):String
    {
        return s.toUpperCase();
    }
    
    /**
     * Transform a string to lower case.
     * "HeLlO wOrLd" ==> "hello world"
     */
    public static inline function lower(s:String):String
    {
        return s.toLowerCase();
    }
    
    /**
     * Transform the first character to upper case.
     * "heLlO wOrLd" ==> "HeLlO wOrLd"
     */
    public static inline function ucfirst(s:String):String
    {
        return s.substr(0, 1).toUpperCase() + s.substr(1);
    }
    
    /**
     * Transform the first character to lower case
     * "HeLlO wOrLd" ==> "heLlO wOrLd"
     */
    public static inline function lcfirst(s:String):String
    {
        return s.substr(0, 1).toLowerCase() + s.substr(1);
    }
    
    /**
     * Transform the string to lower case and change
     * the first character to upper case
     * "HeLlO wOrLd" ==> "Hello world"
     */
    public static inline function proper(s:String):String
    {
        return s.lower().ucfirst();
    }
    
    /*==================================================
        Operations on Each Word
    ==================================================*/
    
    /**
     * Transform the first character of each word to upper case.
     * "HeLlO wOrLd" ==> "HeLlO WOrLd"
     */
    public static inline function ucwords(s:String):String
    {
        return s.split(" ").map(ucfirst).join(" ");
    }
    
    /**
     * Transform the first character of each word to lower case.
     * "HeLlO wOrLd" ==> "heLlO wOrLd"
     */
    public static inline function lcwords(s:String):String
    {
        return s.split(" ").map(lcfirst).join(" ");
    }
    
    /**
     * Transform each word to proper case.
     * "HeLlO wOrLd" ==> "Hello World"
     */
    public static inline function title(s:String):String
    {
        return s.split(" ").map(proper).join(" ");
    }
    
    /*==================================================
        Service Methods
    ==================================================*/
    
    /**
     * Splits a joined string into space seperated words.
     * "TodayILiveInTheUSAWithSimon" ==> [Today, I, Live, In, The, USA, With, Simon]
     * "USAToday" ==> [USA, Today]
     * "IAmSOOOBored" ==> [I, Am, SOOO, Bored]
     */
    public static inline function decamel(s:String):Array<String>
    {
        #if js
            return regex.split(s).filter(function(x:String) return x.length > 0);
        #else
            return regex.replace(s, " $1").trim().split(" ");
        #end
    }
    
    public static function convert(s:String, currSeperator:String, newSeperator:String, ?wordFn:String->String, ?phraseFn:String->String):String
    {
        var words:Array<String> = currSeperator == "" ? decamel(s) : s.split(currSeperator);
        
        if (wordFn != null)
            words = words.map(wordFn);
            
        return phraseFn == null ?
            words.join(newSeperator) :
            phraseFn(words.join(newSeperator));
    }
    
    public static inline function seperator(inflectCase:InflectCase):String
    {
        return switch (inflectCase)
        {
            case LowerCase | UpperCase | TitleCase:
                " ";
                
            case PascalCase | CamelCase:
                "";
                
            case KebabCase | ScreamingKebabCase | TrainCase:
                "-";
                
            case SnakeCase | ScreamingSnakeCase | OxfordCase:
                "_";
        }
    }
    
    /**
     * lower case, UPPER CASE, Title Case
     * PascalCase, camelCase
     * kebab-case, SCREAMING-KEBAB-CASE, Train-Case
     * snake_case, SCREAMING_SNAKE_CASE, Oxford_Case
     */
    public static function inflect(s:String, currCase:InflectCase, newCase:InflectCase):String
    {
        var currSeperator:String = seperator(currCase);
        var newSeperator:String = seperator(newCase);
        
        return switch (newCase)
        {
            // quickBrownFox
            case CamelCase:
                s.convert(currSeperator, newSeperator, proper, lcfirst);
                
            // quick brown fox, quick-brown-fox, quick_brown_fox
            case LowerCase | KebabCase | SnakeCase:
                s.convert(currSeperator, newSeperator, null, lower);
                
            // QUICK BROWN FOX, QUICK-BROWN-FOX, QUICK_BROWN_FOX
            case UpperCase, ScreamingKebabCase | ScreamingSnakeCase:
                s.convert(currSeperator, newSeperator, null, upper);
                
            // Quick Brown Fox, Quick-Brown-Fox, Quick_Brown_Fox
            case TitleCase | PascalCase | TrainCase | OxfordCase:
                s.convert(currSeperator, newSeperator, proper);
        }
    }
}


enum InflectCase
{
                            // maybe change to this. more consistent
    LowerCase;              // SpacedLower
    UpperCase;              // SpacedUpper
    TitleCase;              // SpacedProper
    
    PascalCase;             // CamelUpper
    CamelCase;              // CamelLower
    
    KebabCase;              // DashedLower
    ScreamingKebabCase;     // DashedUpper
    TrainCase;              // DashedProper
    
    SnakeCase;              // UnderLower
    ScreamingSnakeCase;     // UnderUpper
    OxfordCase;             // UnderProper
    
    // Custom(sep:String, wordFn:String->String, phraseFn:String->String)
}

