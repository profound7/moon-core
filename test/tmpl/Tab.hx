package tmpl;

import moon.web.Template;

/** template

**/

/**
 * ...
 * @author Munir Hussin
 */
@:template(tab.html)
class Tab extends Template
{
    public var contents:String;
    
    public function new(c:String)
    {
        super();
        contents = c;
    }
    
}
