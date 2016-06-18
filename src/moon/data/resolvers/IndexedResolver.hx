package moon.data.resolvers;

import moon.core.Types.Resolver;

/**
 * ...
 * @author Munir Hussin
 */
class IndexedResolver implements Resolver
{
    public var argCache:Array<Dynamic> = [];
    
    public function new()
    {
    }
    
    public function getIndex(arg:Dynamic):Int
    {
        var idx:Int = argCache.indexOf(arg);
        
        if (idx == -1)
        {
            idx = argCache.length;
            argCache.push(arg);
        }
        
        return idx;
    }
    
    public function resolve(args:Array<Dynamic>):String
    {
        var sbuf = new StringBuf();
        
        for (a in args)
        {
            sbuf.add(getIndex(a));
            sbuf.addChar(",".code);
        }
        
        return sbuf.toString();
    }
}