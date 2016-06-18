package moon.core;

import haxe.macro.Expr;
import haxe.PosInfos;

/**
 * TODO: rename this class to Debug?
 * May cause confusion to javascript's Console
 * @author Munir Hussin
 */
class Console
{
    #if flash
        private static var tf:flash.text.TextField = null;
    #elseif js
        private static var mode:String;
        private static var d;
        
        private static function __init__() untyped
        {
            if (__js__("typeof")(document) != "undefined"
                && (d = document.getElementById("haxe:trace")) != null)
                mode = "document";
            else if (__js__("typeof process") != "undefined"
                && __js__("process").stdout != null
                && __js__("process").stdout.write != null)
                mode = "process";
            else if (__js__("typeof console") != "undefined"
                && __js__("console").log != null)
                mode = "console";
        }
    #end
    
    
    /**
     * modified from haxe.unit.TestRunner
     * Difference is, when compiled with -D server,
     * neko and php will print this out to the
     * console instead of to the browser.
     * 
     * To print to the browser in server, use
     * Sys.print instead (or response.write if
     * using the moon-coil lib).
     */
    public static function print(v:Dynamic) untyped
    {
        #if (server && (neko || php))
            var out = Sys.stdout();
            out.writeString(Std.string(v));
            out.flush();
        #elseif flash
            if( tf == null ) {
                tf = new flash.text.TextField();
                tf.selectable = false;
                tf.width = flash.Lib.current.stage.stageWidth;
                tf.autoSize = flash.text.TextFieldAutoSize.LEFT;
                flash.Lib.current.addChild(tf);
            }
            tf.appendText(v);
        #elseif neko
            neko.Lib.print(v);
        #elseif php
            php.Lib.print(v);
        #elseif cpp
            cpp.Lib.print(v);
        #elseif js
            var msg = js.Boot.__string_rec(v, "");
            switch (mode)
            {
                case "document":
                    msg = StringTools.htmlEscape(msg).split("\n").join("<br/>");
                    d.innerHTML += msg; //+"<br/>";
                    
                case "process":
                    __js__("process").stdout.write(msg); // node
                    
                case "console":
                    __js__("console").log(msg); // document-less js (which may include a line break)
            }
        #elseif cs
            cs.system.Console.Write(v);
        #elseif java
            var str:String = v;
            untyped __java__("java.lang.System.out.print(str)");
        #elseif python
            python.Lib.print(v);
        #end
    }
    
    public static inline function println(v:Dynamic):Void
    {
        #if js
            if (mode == "console")
                print(v);
            else
                print(v + "\n");
        #else
            print(v + "\n");
        #end
    }
    
    public static function trace(v:Dynamic, ?p:PosInfos)
    {
        println(p.fileName + ":" + p.lineNumber + ":" + Std.string(v));
    }
    
    /**
     * The message will appear during compilation, instead of runtime.
     * Used for printing out warnings and such for deprecated methods
     * and stuff.
     */
    public static macro function compileTrace(msg:String):Expr
    {
        trace(msg);
        return macro null;
    }
}
