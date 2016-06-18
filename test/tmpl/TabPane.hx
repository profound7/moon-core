package tmpl;
import moon.web.Template;

/**
 * ...
 * @author Munir Hussin
 */
@:template(~tabpane.html)
class TabPane extends Template
{
    public var tabs:Array<Tab>;
    public var currentIndex:Int;
    public var currentTab(get, never):Tab;
    
    public function new()
    {
        super();
        tabs = [];
    }
    
    
    private function get_currentTab():Tab
    {
        return tabs[currentIndex];
    }
}