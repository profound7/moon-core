package moon.data.pack;

/**
 * ...
 * @author Munir Hussin
 */
class PackTools
{
    
    public static function getAttributes<T>(cls:Class<T>):Array<String>
    {
        var fields = Type.getInstanceFields(cls);
        var obj = Type.createEmptyInstance(cls);
        var attrs = [];
        for (f in fields)
            if (!Reflect.isFunction(Reflect.field(obj, f)))
                attrs.push(f);
        return attrs;
    }
    
}