package moon.web;

/**
 * Template is a compile-time template that allows you to have ASP/PHP-like
 * templating system that allows you to write in Haxe.
 * 
 * You subclass Template and attach a template meta, and when you compile,
 * the subclass will have the `template` method that returns a String.
 * 
 * Since its compile-time, you can write in pure haxe codes and can have
 * proper compile-time error reporting. This templating is available in
 * all targets, and you're not limited to html.
 * 
 * 
 * Inspired by John Resig's Simple JavaScript Templating and adapted
 * to Haxe macro templating.
 * 
 * http://ejohn.org/blog/javascript-micro-templating/
 * 
 * Initially I ported Resig's js codes to haxe, but there were some issues
 * with quote escaping in some scenarios, so a custom simple parser was written.
 * 
 * Templates can be any text format, and it has ASP-like tags to write
 * Haxe source codes. Templates are attached to the template() function of
 * a given class.
 * 
 * Example:
 * <% if (isLoggedIn()) { %>
 *     Hello <%= name %>!
 * <% } %>
 * 
 * Usage:
 * 
 * @:template("views/test.html")
 * class Foo extends Template
 * {
 *     public var whatever:String = "aaa";
 * }
 * 
 * var foo:Foo = new Foo();
 * foo.render();
 * 
 * Advanced:
 * 
 * @:template("foo/bar/test.html")                  // string arg means use file path (relative to project)
 * @:template(foo.bar.test.html)                    // dotted path means relative to current class
 * @:template(~"views/test.html")                   // add ~ to output debug file
 * @:template(!"<div>inline template</div>")        // inline template
 * @:template("file1.html", ~"file2.html", ~"hi")   // template concatenation
 * 
 * Valid Tags:
 * <% codes %>      // runs haxe codes
 * <%= expr %>      // prints (raw) any valid haxe expression
 * <%=? expr %>     // prints (raw) any valid haxe expression if it isn't null
 * <%: expr %>      // prints (html escaped) any valid haxe expression
 * <%:? expr %>     // prints (html escaped) any valid haxe expression if it isn't null
 * <%# expr %>      // prints (url encoded) any valid haxe expression
 * <%#? expr %>     // prints (url encoded) any valid haxe expression if it isn't null
 * <%-- comments %> // these are commented out and wont appear in resulting .js or .php files
 * <%@ foo.html %>  // includes another template at compile-time
 *                  //      foo.html    includes based on current relative file
 *                  //      /foo.html   relative to project-root (or compiler)
 * 
 * Future ideas:
 * @:template("file.txt" => myMethod) // text processing?
 * 
 * @author Munir Hussin
 */
@:autoBuild(moon.macros.template.TemplateMacro.build())
class Template
{
    private var _buf:StringBuf;
    
    public function new() 
    {
    }
    
    /**
     * Prepares output buffer
     */
    public inline function begin():Void
    {
        _buf = new StringBuf();
    }
    
    /**
     * Get the string from the buffer and clears it
     */
    public inline function flush():String
    {
        var str = _buf.toString();
        _buf = null;
        return str;
    }
    
    /**
     * Prints raw values to the output buffer
     * <%= expr %>
     */
    public inline function print(v:Dynamic):Void
    {
        _buf.add(Std.string(v));
    }
    
    /**
     * Prints to the output buffer, but escapes special html chars
     * <%: expr %>
     */
    public inline function escape(v:Dynamic):Void
    {
        _buf.add(StringTools.htmlEscape(Std.string(v)));
    }
    
    /**
     * Prints to the output buffer, but does urlencode
     * <%# expr %>
     */
    public inline function urlEncode(v:Dynamic):Void
    {
        _buf.add(StringTools.urlEncode(Std.string(v)));
    }
    
    /**
     * The original template string specified from @:template meta
     */
    public function template():String
    {
        return "";
    }
    
    /**
     * Override this if you wish to transform the template in any way.
     * Otherwise it returns the template.
     */
    public function custom():String
    {
        return template();
    }
    
    /**
     * Subclasses may override render function to alter how the template is rendered.
     * In Html ajax templates, you may wish to render to a particular div tag for example:
     *      
     *     public override function render():Void
     *     {
     *         new JQuery(selector).html(toString());
     *     }
     */
    public function render():Void
    {
        trace(toString());
    }
    
    /**
     * Sometimes you may want to change how the template is displayed.
     * Using toString is a convenient way to output templates within templates.
     * i.e: <%=myTemplate%>
     */
    public function toString():String
    {
        return custom();
    }
}
