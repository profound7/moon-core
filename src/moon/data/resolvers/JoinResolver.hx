package moon.data.resolvers;

import moon.core.Types.Resolver;

/**
 * This resolver is safe for types like Int, Float, Bool,
 * Array<Int>, Array<Float> etc...
 * 
 * Not safe if type is a function.
 * 
 * May return incorrect key for String, Array<String> or
 * objects containing strings or implemented toString().
 * 
 * Use this only when the arguments are guaranteed not to
 * contain the character `|` or there's a chance this
 * resolver might return the wrong key for memoization.
 * 
 * foo("", "a") ==> "|a"
 * foo("a", "") ==> "a|"
 *
 * Example of different arguments generating the same key:
 * foo("|", "") ==> "||"
 * foo("", "|") ==> "||"
 *
 * Example of different types generating the same key:
 * foo("[a]") ==> "[a]"
 * foo(["a"]) ==> "[a]"
 *
 * Serializing the arguments is safer and will generate
 * the same keys for the same arguments, and is also
 * type-safe.
 * 
 * Usage:
 *   var x = fn.memoize(3, new JoinResolver("|"));
 * 
 * @author Munir Hussin
 */
class JoinResolver implements Resolver
{
    public var sep:String;
    
    public function new(sep:String="|")
    {
        this.sep = sep;
    }
    
    public function resolve(args:Array<Dynamic>):String
    {
        return args.join(sep);
    }
}