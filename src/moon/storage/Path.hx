package moon.storage;

/**
 * Path is Array<String> abstract. In this form, it's more
 * natural to do path manipulations.
 * 
 * Does not handle windows drive letters. Just basic paths.
 * 
 * Directories MUST have a trailing slash
 * 
 * @author Munir Hussin
 */
@:forward abstract Path(Array<String>) from Array<String>
{
    public var isAbsolute(get, never):Bool;
    public var isRelative(get, never):Bool;
    public var isDirectory(get, never):Bool;
    public var isFile(get, never):Bool;
    public var withoutTrailingSlash(get, never):Path;
    public var withTrailingSlash(get, never):Path;
    public var asDirectory(get, never):Path;
    public var asFile(get, never):Path;
    public var asAbsolute(get, never):Path;
    public var asRelative(get, never):Path;
    
    public var directoryName(get, set):Path;
    public var fileName(get, set):String;
    public var fileRoot(get, set):String;
    public var fileExtension(get, set):String;
    
    
    public function new(?path:String) 
    {
        this = path == null ? new Array<String>() : path.split("/");
    }
    
    @:arrayAccess public inline function get(index:Int):String
    {
        return this[index];
    }
    
    @:arrayAccess public inline function set(index:Int, value:String):String
    {
        return this[index] = value;
    }
    
    // absolute:
    //      /abc/def/ghi
    //      c:/abc/def/ghi (not handled. should this be handled? using directives?)
    private inline function get_isAbsolute():Bool
    {
        return this[0].length == 0;
    }
    
    // relative: abc/def/ghi
    private inline function get_isRelative():Bool
    {
        return !isAbsolute;
    }
    
    // path is a directory:
    //      abc/def/ghi/
    //      
    private inline function get_isDirectory():Bool
    {
        return !isFile;
    }
    
    // path is a file: abc/def/ghi
    private inline function get_isFile():Bool
    {
        return fileName.length > 0; // && fileName != "." && fileName != "..";
    }
    
    private inline function get_withoutTrailingSlash():Path
    {
        var p:Path = normalize(this);
        if (isDirectory) p.pop();
        return p;
    }
    
    private inline function get_withTrailingSlash():Path
    {
        var p:Path = normalize(this);
        if (isFile) p.push("");
        return p;
    }
    
    private inline function get_asDirectory():Path
    {
        return isDirectory ? this.copy() : this.concat([""]);
    }
    
    private inline function get_asFile():Path
    {
        var path:Path = this.copy();
        if (isFile) return path;
        
        while (path.isDirectory)
        {
            if (path.length > 0)
                path.pop();
            else
                throw "Invalid"; // eg: /////// => no files in path, avoid infinite loop
        }
        
        return path;
    }
    
    // abc/def/ghi ==> /abc/def/ghi
    private inline function get_asAbsolute():Path
    {
        return isAbsolute ? this.copy() : [""].concat(this);
    }
    
    // /abc/def/ghi ==> abc/def/ghi
    private inline function get_asRelative():Path
    {
        var path:Path = this.copy();
        if (isRelative) return path;
        
        while (path.isAbsolute)
        {
            if (path.length > 0)
                path.shift();
            else
                throw "Invalid";
        }
        
        return path;
    }
    
    // aa/bb/cc/dd/eee.ff ==> aa/bb/cc/dd
    // aa/bb/cc/dd////eee.ff ==> aa/bb/cc/dd///
    /// get the directory name where the file resides
    private inline function get_directoryName():Path
    {
        var p:Path = this.copy();
        
        if (isFile)
        {
            p.pop();
            return p.withTrailingSlash;
        }
        else
        {
            return p;
        }
        
        /*if (isFile)
        {
            var p:Path = this.slice(0, this.length - 1);
            return p.withTrailingSlash;
        }
        else
        {
            return normalize(this);
        }*/
    }
    
    private inline function set_directoryName(dir:Path):Path
    {
        return this = dir.slice(0, this.length - 1).concat([fileName]);
    }
    
    // aa/bb/cc/dd/eee.ff ==> eee.ff
    /// get the filename
    private inline function get_fileName():String
    {
        return this[this.length - 1];
    }
    
    private inline function set_fileName(name:String):String
    {
        return this[this.length - 1] = name;
    }
    
    // aa/bb/cc/dd/eee.ff ==> eee
    /// get the extension of the filename
    private function get_fileRoot():String
    {
        var f:String = fileName;
        var i:Int = f.lastIndexOf(".");
        return i > 0 ? f.substr(0, i) : "";
        
        // inline solution. not sure if slice with negative numbers
        // works on all targets.
        //return fileName.split(".").slice(0, -1).join(".");
    }
    
    private inline function set_fileRoot(root:String):String
    {
        fileName = root + fileExtension;
        return root;
    }
    
    // aa/bb/cc/dd/eee.ff ==> .ff
    /// get the extension of the filename, including the dot
    /// it returns a dot as well to distinguish filenames without a dot at all
    private function get_fileExtension():String
    {
        var f:String = fileName;
        var i:Int = f.lastIndexOf(".");
        return i > 0 ? f.substr(i) : "";
    }
    
    private inline function set_fileExtension(ext:String):String
    {
        fileName = fileRoot + ext;
        return ext;
    }
    
    public static function normalize(path:Path):Path
    {
        var i:Int = 0;
        var n:Int = path.length;
        var isAbs:Bool = path.isAbsolute;
        var isDir:Bool = path.isDirectory;
        
        // QUICK FIX: don't modify the argument
        // previously, it modifies itself. returning a copy is better
        path = path.copy(); 
        
        while (i < n)
        {
            switch (path[i])
            {
                case "", ".":
                    path.splice(i--, 1);
                    n--;
                    
                case "..":
                    if (i == 0)
                    {
                        path.splice(i--, 1);
                        n--;
                    }
                    else
                    {
                        path.splice(i--, 1);
                        path.splice(i--, 1);
                        n -= 2;
                    }
            }
            
            i++;
        }
        
        if (isAbs) path.unshift("");
        if (isDir) path.push("");
        return path;
    }
    
    // adds a path to this path
    @:op(A + B) public inline function concat(path:Path):Path
    {
        return this = this.concat(path);
    }
    
    // creates a copy of the path
    public inline function copy():Path
    {
        return this.copy();
    }
    
    
    
    // jails the path to the base path, so multiple /../ in the path
    // won't go above the base path
    public static inline function jail(path:Path, base:Path):Path
    {
        base = base.asFile;
        path = Path.normalize(path.asRelative);
        return base.concat(path);
    }
    
    
    
    @:from public static inline function fromString(path:String):Path
    {
        return new Path(path);
    }
    
    @:to public inline function toString():String
    {
        return this.join("/");
    }
    
    @:from public static inline function fromArray(path:Array<String>):Path
    {
        return path;
    }
    
    @:to public inline function toArray():Array<String>
    {
        return this;
    }
    
}
