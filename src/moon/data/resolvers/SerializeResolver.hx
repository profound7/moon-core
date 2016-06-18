package moon.data.resolvers;

import moon.core.Types.Resolver;

/**
 * Resolve by serializing the arguments into a string.
 * This handles certain types of arguments better.
 * Doesn't work if argument is a function.
 * 
 * @author Munir Hussin
 */
class SerializeResolver implements Resolver
{
    public function new()
    {
    }
    
    public function resolve(args:Array<Dynamic>):String
    {
        var s = new Serializer();
        s.useCache = true;
        s.useEnumIndex = true;
        s.serialize(args);
        return s.toString();
    }
}