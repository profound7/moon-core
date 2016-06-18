package;

import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import haxe.Serializer;
import haxe.Unserializer;
import hey.ya.Cat;
import moon.web.Router;
import moon.web.Template;

using moon.tools.ArrayTools;


/**
 * ...
 * @author Munir Hussin
 */
class RouteTest
{
    public var router:Router;
    
    public function new()
    {
        router = new Router();
        
        router.define("Cat", "([^/]+?)", function(value:String):Dynamic
        {
            return new Cat(value);
        });
        
        router.metaMap(this, true);
        //router.map("foo/{:String}/bar", test);
        
        router.route("hey/fsfsfs/fdfsdfbar");
        
        //router.route("aaa/YES/bbb");
        //router.route("ccc/tom/bar");
        
        /*router.route("hey/LOL/bar");
        router.route("hey/LOL/aaa");
        router.route("aaa/AAA/bbb");*/
        
        
    }
    
    @:route("ccc/{:Cat}/bar")
    public function ccc(b:Cat)
    {
        b.meow();
    }
    
    @:route("foo/{:String}/bar")
    @:route("aaa/{:String}/bbb")
    public function test(b:String)
    {
        trace("test: " + b);
    }
    
    @:route("hey/{:String}/{:String}bar")
    public function haha(b:String, c:String)
    {
        trace("haha: " + b);
    }
    
    @:route(error)
    public function notFound(err:Dynamic)
    {
        trace("not found: " + err);
    }
    
    public static function main()
    {
        var foo:RouteTest = new RouteTest();
    }
}

class Laa
{
    @:route("foo/{:String}/bar")
    @:route("aaa/{:String}/bbb")
    public static function tttt(b:String)
    {
        trace("tttt: " + b);
    }
    
    @:route("hey/{:String}/bar")
    public static function hhhh(b:String)
    {
        trace("hhhh: " + b);
    }
}
