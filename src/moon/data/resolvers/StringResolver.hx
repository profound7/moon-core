package moon.data.resolvers;

import moon.core.Types.Resolver;

/**
 * Fuck it. Resolve by directly converting the array of arguments into a string.
 * 
 * @author Munir Hussin
 */
class StringResolver implements Resolver
{
    
    public function new()
    {
    }
    
    public function resolve(args:Array<Dynamic>):String
    {
        return Std.string(args);
    }
}