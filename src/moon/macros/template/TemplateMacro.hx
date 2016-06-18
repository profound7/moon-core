package moon.macros.template;

import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;
import moon.storage.Path;

using haxe.macro.Tools;
using StringTools;

/**
 * ...
 * @author Munir Hussin
 */
class TemplateMacro
{
    public static var metaPos:Position;
    
    public static function getTemplateMeta(type:Type):MetadataEntry
    {
        switch (type)
        {
            case TInst(cl, _):
                var ctype = cl.get();
                var meta = ctype.meta.get();
                
                // find out which fields to ignore
                for (m in meta)
                {
                    if (m.name == ":template")
                    {
                        if (m.params == null)
                            Context.error("No argument given for @:template meta", Context.currentPos());
                        else
                            return m;
                    }
                }
                
            case _:
                Context.error("Requires class definition", Context.currentPos());
        }
        
        return null;
    }
    
    public static function process(str:String):Array<Tag>
    {
        var rxOpen = ~/(<%)/g;
        
        var parts:Array<Tag> = [];
        var currPos:Int = 0;
        var nextPos:Int = 0;
        
        while (rxOpen.match(str))
        {
            var text = rxOpen.matchedLeft();
            parts.push(Text(text));
            str = rxOpen.matchedRight();
            
            var code = getTagContents(str);
            var c1 = code.substr(0, 1);
            var c2 = code.substr(1, 1);
            
            switch ([c1, c2])
            {
                case ["=", "?"]:
                    parts.push(NullCheck(Print(code.substr(2))));
                    
                case ["=", _]:
                    parts.push(Print(code.substr(1)));
                    
                case [":", "?"]:
                    parts.push(NullCheck(Escape(code.substr(2))));
                    
                case [":", _]:
                    parts.push(Escape(code.substr(1)));
                    
                case ["#", "?"]:
                    parts.push(NullCheck(UrlEncode(code.substr(2))));
                    
                case ["#", _]:
                    parts.push(UrlEncode(code.substr(1)));
                    
                case ["@", _]:
                    parts.push(Include(code.substr(1)));
                    
                case ["-", "-"]:
                    parts.push(Comments(code.substr(2)));
                    
                case _:
                    parts.push(Code(code));
            }
            
            // +2 to skip the 2 chars %>
            str = str.substring(code.length + 2);
        }
        
        parts.push(Text(str));
        //trace(parts);
        return parts;
    }
    
    public static function getTagContents(str:String):String
    {
        var rx = ~/(["']|%>)/g;
        var rx2 = ~/((?<!\\)")/g; // find a quote that is not preceeded by a slash
        var rx3 = ~/((?<!\\)')/g;
        var next:String = str;
        var len:Int = 0;
        
        while (rx.match(next))
        {
            var curr = rx.matched(1);
            len += rx.matchedPos().pos;
            
            switch (curr)
            {
                case "%>":
                    return str.substr(0, len);
                    
                case _:
                    var srx:EReg = curr == '"' ? rx2 : rx3;
                    
                    // right is the start of the literal string
                    var right = rx.matchedRight();
                    
                    // the end of the literal string
                    if (srx.match(right))
                    {
                        var slen = srx.matchedPos().pos + 1; // +1 to include closing quote
                        len += slen + 1; // +1 to account for the opening quote
                        next = right.substr(slen);
                        //trace('after str: |$next|');
                    }
                    else
                    {
                        throw "Literal string is unclosed.";
                    }
            }
        }
        
        throw "No closing tag found";
    }
    
    public static function makeTemplate(contents:String, srcFile:String, ?base:Array<String>):String
    {
        var tags = process(contents);
        var parts:Array<String> = base == null ? [""] : base;
        var path:Path = srcFile == null ? "" : srcFile;
        
        for (t in tags)
        {
            switch (t)
            {
                case NullCheck(tag):
                    
                    switch (tag)
                    {
                        // <%=? expr %>
                        case Print(s):
                            parts.push('if ($s != null) print($s);');
                            
                        // <%:? expr %>
                        case Escape(s):
                            parts.push('if ($s != null) escape($s);');
                            
                        // <%#? expr %>
                        case UrlEncode(s):
                            parts.push('if ($s != null) urlEncode($s);');
                            
                        case _:
                            throw "Unexpected ==> " + tag;
                    }
                    
                case Text(s):
                    s = StringTools.replace(s, '"', '\\"');
                    parts.push('print("$s");');
                    
                // <% codes %>
                case Code(s):
                    parts.push(s);
                    
                // <%= expr %>
                case Print(s):
                    parts.push('print($s);');
                    
                // <%: expr %>
                case Escape(s):
                    parts.push('escape($s);');
                    
                // <%# expr %>
                case UrlEncode(s):
                    parts.push('urlEncode($s);');
                    
                // <%-- expr %>
                case Comments(s):
                    // do nothing
                    
                // <%@ foo.html %>
                case Include(s):
                    s = StringTools.trim(s);
                    
                    var includeSrc = (StringTools.startsWith(s, "/")) ?
                        s.substr(1) :
                        path.directoryName + s;
                    
                    var contents:String = getFileContent(includeSrc);
                    makeTemplate(contents, includeSrc, parts);
            }
        }
        
        if (base != null) return null;
        
        var codes = parts.join('\n    ');
        var code = '{\n    begin();\n    $codes\n    return flush();\n}';
        return code;
    }
    
    
    /**
     * Resig's JS template. Short and simple, though there are some
     * issues with quote escaping. Or maybe I ported it wrong.
     * I rewrote my own version above.
     */
    /*public static function makeResigTemplate(str:String):String
    {
        var rx1 = ~/[\r\t\n]/g;
        var rx2 = ~/((^|%>)[^\t]*)'/g;
        var rx3 = ~/\t=(.*?)%>/g;
        
        str = rx1.replace(str, " ");
        str = str.split("<%").join("\t");
        str = rx2.replace(str, "$1\r");
        str = rx3.replace(str, "');\np.push($1);\np.push('");
        str = str.split("\t").join("');");
        str = str.split("%>").join("p.push('");
        str = str.split("\r").join("\\'");
        
        var code = "{
            var p:Array<Dynamic> = [];
            
            function print(v:Dynamic):Void
            {
                p.push(v);
            }
            
            p.push('" + str + "');
            return p.join('');
        }";
        
        return code;
    }*/
    
    public static function getTemplatePath():String
    {
        var type = Context.getLocalType();
        var meta:MetadataEntry = getTemplateMeta(type);
        var modFile:String = Context.getPosInfos(meta.pos).file;
        var modPath:String = Path.fromString(modFile).directoryName;
        return modPath;
    }
    
    public static function getFilePath(path:String, useClassPath:Bool):String
    {
        if (useClassPath)
        {
            var tmplPath:Path = getTemplatePath();
            path = Context.resolvePath(tmplPath + path);
        }
        
        return path;
    }
    
    public static function getFileContent(path:String):String
    {
        if (!FileSystem.exists(path))
            Context.error('File $path does not exist.', metaPos);
        return File.getContent(path);
    }
    
    public static function getContentInfo(expr:Expr, meta:MetadataEntry, pos:Position):ContentInfo
    {
        return switch (expr.expr)
        {
            // ~"foo/bar.html"      file template with debug output
            case EUnop(Unop.OpNegBits, false, subexpr):
                var info = getContentInfo(subexpr, meta, pos);
                
                #if !display
                    //trace("SAVING!!!!!!!!!! ", info.src + ".hx");
                    File.saveContent(info.src + ".hx", makeTemplate(info.contents, info.src));
                #end
                
                info;
                
            // "foo/bar.html"       file template using any path
            case EConst(CString(path)):
                {
                    contents: getFileContent(path),
                    src: path,
                    doc: 'File template: $path',
                }
                
            // foo.bar.html
            // file template relative to template class using class path
            // the reason there's both "foo/bar.html" as well as foo.bar.html
            // is because much later, we realized we wanted templates defined
            // in libraries that can be overriden in other projects.
            // instead of modifying the case above, we added this to avoid
            // breaking changes on our existing projects.
            case EField(e, ext):
                var path = e.toString().replace(".", "/") + "." + ext;
                var path = getFilePath(path, true);
                {
                    contents: getFileContent(path),
                    src: path,
                    doc: 'File template: $path',
                }
                
            // !"<div>inline template</div>"
            case EUnop(Unop.OpNot, false, { expr: EConst(CString(text)) }):
                {
                    contents: text,
                    src: null,
                    doc: 'Inline template: $text',
                }
                
            case _:
                var cls = Context.getLocalClass().toString();
                Context.error('$cls: Invalid @:template argument: $meta', pos);
                null;
        }
    }
    
    public static macro function build():Array<Field>
    {
        var type = Context.getLocalType();
        var fields:Array<Field> = Context.getBuildFields();
        var meta:MetadataEntry = getTemplateMeta(type);
        
        //trace("--"); trace("--");
        
        if (meta == null) return fields;
        
        var pos = Context.currentPos();
        metaPos = meta.pos;
        
        var i:Int = 0;
        var isMultiTemplates:Bool = meta.params.length > 1;
        var docs:Array<String> = [];
        
        // you can have more than 1 template in a single class.
        // the methods will be named template0(), template1(), template2() etc...
        for (i in 0...meta.params.length)
        {
            var param = meta.params[i];
            var info = getContentInfo(param, meta, pos);
            
            var codes = makeTemplate(info.contents, info.src);
            var tpl = Context.parse(codes, param.pos);
            docs.push(info.doc);
            
            fields.push(
            {
                name: isMultiTemplates ? "template" + i : "template",
                doc: info.doc,
                access: isMultiTemplates ? [APublic] : [APublic, AOverride],
                kind: FieldType.FFun(
                {
                    args: [],
                    ret: macro:String,
                    //expr: macro return $v{ contents },
                    expr: tpl,
                }),
                meta: [{ name: ":keep", pos: pos }],
                pos: pos,
            });
        }
        
        // when there's more than 1 templates, calling template()
        // will return the concatenation of all templates.
        if (isMultiTemplates)
        {
            var codes = "return " + [for (i in 0...meta.params.length) 'template$i()'].join(" + ");
            var tpl = Context.parse(codes, pos);
            
            fields.push({
                name: "template",
                doc: "This is a concatenation of all templates:\n" + docs.join("\n"),
                access: [APublic, AOverride],
                kind: FieldType.FFun(
                {
                    args: [],
                    ret: macro:String,
                    expr: tpl,
                }),
                meta: [{ name: ":keep", pos: pos }],
                pos: pos,
            });
        }
        
        return fields;
    }
}

private enum Tag
{
    Text(s:String);
    Code(s:String);
    Print(s:String);
    Escape(s:String);
    UrlEncode(s:String);
    Comments(s:String);
    Include(s:String);
    NullCheck(tag:Tag);
}

private typedef ContentInfo =
{
    var contents:String;
    var src:String;
    var doc:String;
}