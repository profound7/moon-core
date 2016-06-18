package;

import moon.web.Template;
import tmpl.Tab;
import tmpl.TabPane;


/**
 * ...
 * @author Munir Hussin
 */
class TemplateTest
{
    
    public function new()
    {
        
    }
    
    public static function main()
    {
        trace("-------------");
        
        var tabpane:TabPane = new TabPane();
        tabpane.tabs.push(new Tab("aaa"));
        tabpane.tabs.push(new Tab("b<a>b</a>b"));
        tabpane.tabs.push(new Tab("ccc"));
        tabpane.currentIndex = 1;
        
        //tabpane.render();
        trace(tabpane.template());
        
        var button:Button = new Button("test");
        button.render();
    }
}

class Widget extends Template
{
    public function new()
    {
        super();
    }
    
    public override function custom():String
    {
        return "<c>" + super.custom() + "</c>";
    }
}

// inline template starts with !
@:template(!"<button><%=label%></button>")
class Button extends Widget
{
    public var label:String;
    
    public function new(label:String)
    {
        super();
        this.label = label;
    }
}

