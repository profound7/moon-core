package ;

import moon.web.Template;

/**
 * ...
 * @author Munir Hussin
 */
class TemplateExamples
{
    
    public static function main() 
    {
        var s = new Something();
        Sys.println(s);
    }
    
}


@:template(something.html)
class Something extends Template
{
    public var foo:String;
    
    public function new()
    {
        super();
        foo = "BOB";
    }
}