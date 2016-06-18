package moon.tools;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author Munir Hussin
 */
@:deprecated
class MacroTools
{
    public static function importModule(module:String, ?classPaths:Array<String>):Void
    {
        var displayValue = Context.definedValue("display");
        
        if (classPaths == null)
        {
            classPaths = Context.getClassPath();
            // do not force inclusion when using completion
            switch (displayValue)
            {
                case null:
                case "usage":
                case _: return;
            }
            
            // normalize class path
            for (i in 0...classPaths.length)
            {
                var cp = StringTools.replace(classPaths[i], "\\", "/");
                if (StringTools.endsWith(cp, "/"))
                    cp = cp.substr(0, -1);
                if (cp == "")
                    cp = ".";
                classPaths[i] = cp;
            }
        }
        
        var prefix = pack == '' ? '' : pack + '.';
        
        for (cp in classPaths)
        {
            var path = pack == '' ? cp : cp + "/" + pack.split(".").join("/");
            
            if (!sys.FileSystem.exists(path) || !sys.FileSystem.isDirectory(path))
                continue;
                
            for (file in sys.FileSystem.readDirectory(path))
            {
                if (StringTools.endsWith(file, ".hx"))
                {
                    var cl = prefix + file.substr(0, file.length - 3);
                    if( skip(cl) )
                        continue;
                    Context.getModule(cl);
                }
                else if( rec && sys.FileSystem.isDirectory(path + "/" + file) && !skip(prefix + file))
                    include(prefix + file, true, ignore, classPaths);
            }
        }
    }
    
}