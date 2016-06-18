package moon.core;
import haxe.Json;

#if macro
    import haxe.macro.Context;
    import haxe.macro.Expr;
    import haxe.macro.ExprTools;
    import haxe.macro.Type;
    import haxe.macro.TypeTools;
    import haxe.macro.ComplexTypeTools;
#end

/**
 *  { expr => EConst(CIdent(Struct)), pos =>  }
 * @author Munir Hussin
 */
class Inspect
{
    #if macro
    
    public static function inspectStructExpr(structType:Expr):Array<Pair<String, Type>>
    {
        
        switch (structType.expr)
        {
            // Inspect.sss({ x:Int, y:String })
            /*case EObjectDecl(fields):
                var te = Context.typeExpr(structType);
                return inspectStructType(te.t);*/
                
            // Inspect.sss(Haha) or Inspect.sss(x)
            case EConst(CIdent(structTypeName)):
                try
                {
                    var t = Context.typeof(structType);
                    return inspectStructType(t);
                }
                catch (ex:Dynamic)
                {
                    var t:Type = Context.follow(Context.getType(structTypeName));
                    return inspectStructType(t);
                }
                
            case EParenthesis(_.expr => ECheckType(_, t)):
                var t = ComplexTypeTools.toType(t);
                return inspectStructType(t);
                
            case _:
                throw "Invalid expression";
        }
        
        throw "Unexpected error";
    }
    
    public static function inspectStructType(t:Type):Array<Pair<String, Type>>
    {
        switch (t)
        {
            case TAnonymous(ref):
                
                var anon:AnonType = ref.get();
                var ret:Array<Pair<String, Type>> = [];
                
                for (f in anon.fields)
                {
                    ret.push(Pair.of(f.name, f.type));
                }
                
                return ret;
                
            case _:
                throw "Not an anonymous type";
        }
    }
    
    // checks anon structs at runtime
    public static function instanceOf(struct:Expr, structType:Expr):Expr
    {
        var structCode = ExprTools.toString(struct);
        var fields = inspectStructExpr(structType);
        var lines:Array<String> = [];
        
        for (f in fields)
        {
            var isAnon:Bool = false;
            var field:String = f.head;
            var ftype:Type = f.tail;
            var type:String = switch (ftype)
            {
                case TEnum(x, _): x.toString();
                case TInst(x, _): x.toString();
                case TAbstract(x, _): x.toString();
                case TType(x, _): x.toString();
                
                case TAnonymous(x): isAnon = true; TypeTools.toString(ftype);
                case _: TypeTools.toString(ftype);
            }
            
            if (isAnon)
                lines.push('Reflect.hasField(o, "$field") && moon.core.Inspect.is(Reflect.field(o, "$field"), (t:$type))');
            else
                lines.push('Reflect.hasField(o, "$field") && moon.core.Inspect.is(Reflect.field(o, "$field"), $type)');
        }
        
        var codestr = lines.join(" && ");
        var code = Context.parse(codestr, Context.currentPos());
        
        return macro
        {
            var o = $struct;
            $code;
            //o;
        };
    }
    #end
    
    
    
    /**
     * Checks a value against a type, including typedef Anonymous Structs, and some
     * abstracts.
     * 
     * Special Types (can be used without import):
     * Any, Bits, Infinity, Finite, Number, NaN, UInt, Int32, Int64,
     * Object, Instance, Struct, Enum, EnumValue, Function, Map
     * 
     * Inspect.is is a macro that is replaced with Std.is or Reflect.isSomething or
     * Type.typeof().match(Something) depending on the type given.
     * 
     * Unlike Std.is, you can check against certain abstract types. You do not
     * need to import these abstract types to check against it.
     * 
     *              1  "a"  fn()    []  {}      new X()     EnumT   EnumV   Map
     * 
     * Number       t   t
     * Int          t
     * String           t
     * Function         t
     * Array                        t
     * 
     * Object           t           t   t       t           t       t       t
     * Instance         t           t           t                           t
     * Struct                           t
     * Enum                                                 t
     * EnumValue                                                    t
     * Map                                                                  t
     */
    public static macro function is(value:Dynamic, valueType:Dynamic):ExprOf<Bool>
    {
        //trace("out");
        //trace(valueType);
        
        return switch (valueType.expr)
        {
            case EConst(CIdent(typeName)):
                
                switch (typeName)
                {
                    case "Any":
                        //macro Std.is($value, Dynamic);
                        macro true; // lol
                        
                    case "Bits":
                        macro Std.is($value, Int);
                        
                    case "Infinity":
                        macro Std.is($value, Float) && !Math.isFinite($value) && !Math.isNaN($value);
                        
                    case "Finite":
                        macro Std.is($value, Float) && Math.isFinite($value);
                        
                    case "Number":
                        macro Std.is($value, Float) && !Math.isNaN($value);
                        
                    case "NaN":
                        macro Std.is($value, Float) && Math.isNaN($value);
                        
                    case "UInt":
                        macro Std.is($value, Int);
                        
                    case "Int32":
                        macro Std.is($value, Int);
                        
                    case "Int64":
                        Context.warning("Checking against Int64 isn't fully tested", valueType.pos);
                        macro Type.getClassName(Type.getClass($value)) == "haxe._Int64.___Int64";
                        
                    case "Object":
                        macro Reflect.isObject($value);
                        
                    case "Instance": // an instance of a class, not an anonymous object
                        macro Type.typeof($value).match(Type.ValueType.TClass(_));
                        // or Type.getClass($value) != null
                        
                    case "Struct": // an anonymous object
                        macro Type.typeof($value) == Type.ValueType.TObject && !Std.is($value, Enum);
                        
                    case "EnumValue":
                        macro Reflect.isEnumValue($value);
                        
                    case "Function":
                        macro Reflect.isFunction($value);
                        
                    case "Map":
                        macro Std.is($value, haxe.Constraints.IMap);
                        
                    case _:
                        try
                        {
                            // try and see if the type is an anonymous struct
                            inspectStructExpr(valueType);
                            instanceOf(value, valueType);
                        }
                        catch (ex:Dynamic)
                        {
                            macro Std.is($value, $valueType);
                        }
                }
                
            case EParenthesis(_.expr => ECheckType(_, t)):
                instanceOf(value, valueType);
                
            case _:
                macro Std.is($value, $valueType);
        }
    }
    
    /*
    #if test
        
        public static function main()
        {
            trace("\n\nObject");
            trace(Inspect.is(1,         Object));
            trace(Inspect.is("aa",      Object));
            trace(Inspect.is({aa:"aa"}, Object));
            trace(Inspect.is(["aa"],    Object));
            trace(Inspect.is(new Foo(), Object));
            trace(Inspect.is(Bar,       Object));
            trace(Inspect.is(Baz,       Object));
            trace(Inspect.is(foo,       Object));
            trace(Inspect.is([1=>"2"],  Object));
            
            trace("\n\nInstance");
            trace(Inspect.is(1,         Instance));
            trace(Inspect.is("aa",      Instance));
            trace(Inspect.is({aa:"aa"}, Instance));
            trace(Inspect.is(["aa"],    Instance));
            trace(Inspect.is(new Foo(), Instance));
            trace(Inspect.is(Bar,       Instance));
            trace(Inspect.is(Baz,       Instance));
            trace(Inspect.is(foo,       Instance));
            trace(Inspect.is([1=>"2"],  Instance));
            
            trace("\n\nStruct");
            trace(Inspect.is(1,         Struct));
            trace(Inspect.is("aa",      Struct));
            trace(Inspect.is({aa:"aa"}, Struct));
            trace(Inspect.is(["aa"],    Struct));
            trace(Inspect.is(new Foo(), Struct));
            trace(Inspect.is(Bar,       Struct));
            trace(Inspect.is(Baz,       Struct));
            trace(Inspect.is(foo,       Struct));
            trace(Inspect.is([1=>"2"],  Struct));
            
            trace("\n\nEnum");
            trace(Inspect.is(1,         Enum));
            trace(Inspect.is("aa",      Enum));
            trace(Inspect.is({aa:"aa"}, Enum));
            trace(Inspect.is(["aa"],    Enum));
            trace(Inspect.is(new Foo(), Enum));
            trace(Inspect.is(Bar,       Enum));
            trace(Inspect.is(Baz,       Enum));
            trace(Inspect.is(foo,       Enum));
            trace(Inspect.is([1=>"2"],  Enum));
            
            trace("\n\nEnumValue");
            trace(Inspect.is(1,         EnumValue));
            trace(Inspect.is("aa",      EnumValue));
            trace(Inspect.is({aa:"aa"}, EnumValue));
            trace(Inspect.is(["aa"],    EnumValue));
            trace(Inspect.is(new Foo(), EnumValue));
            trace(Inspect.is(Bar,       EnumValue));
            trace(Inspect.is(Baz,       EnumValue));
            trace(Inspect.is(foo,       EnumValue));
            trace(Inspect.is([1=>"2"],  EnumValue));
            
            trace("\n\nFunction");
            trace(Inspect.is(1,         Function));
            trace(Inspect.is("aa",      Function));
            trace(Inspect.is({aa:"aa"}, Function));
            trace(Inspect.is(["aa"],    Function));
            trace(Inspect.is(new Foo(), Function));
            trace(Inspect.is(Bar,       Function));
            trace(Inspect.is(Baz,       Function));
            trace(Inspect.is(foo,       Function));
            trace(Inspect.is([1=>"2"],  Function));
            
            
            trace("\n\nMap");
            trace(Inspect.is(1,         Map));
            trace(Inspect.is("aa",      Map));
            trace(Inspect.is({aa:"aa"}, Map));
            trace(Inspect.is(["aa"],    Map));
            trace(Inspect.is(new Foo(), Map));
            trace(Inspect.is(Bar,       Map));
            trace(Inspect.is(Baz,       Map));
            trace(Inspect.is(foo,       Map));
            trace(Inspect.is([1=>"2"],  Map));
            
            var x1 = { a: 3, b: "yoyo" };
            var y1 = { a: 3, b: true };
            var z1 = { a: 3, c: "yoyo" };
            
            var x2 = { a: 3, b: "yoyo", c: { x: "foo", y: 1.23 } };
            var y2 = { a: 3, b: "yoyo", c: { x: 1234, y: 1.23 } };
            var z2 = { a: 3, b: "yoyo", c: { x: "foo", y: true } };
            
            trace("\n\nObject");
            trace(Inspect.is(1,         Object));
            trace(Inspect.is("aa",      Object));
            trace(Inspect.is({aa:"aa"}, Object));
            trace(Inspect.is(["aa"],    Object));
            trace(Inspect.is(new Foo(), Object));
            trace(Inspect.is(Bar,       Object));
            trace(Inspect.is(Baz,       Object));
            trace(Inspect.is(foo,       Object));
            trace(Inspect.is([1=>"2"],  Object));
            
            trace("\n\nStruct");
            trace(Inspect.is({ a: 3, b: "yoyo" }, Yoyo));
            trace(Inspect.is(x1, Yoyo));
            trace(Inspect.is(y1, Yoyo));
            trace(Inspect.is(z1, Yoyo));
            
            trace("\n\nNested Struct");
            trace(Inspect.is({ a: 3, b: "yoyo", c: { x: "foo", y: 1.23 } }, Hehe));
            trace(Inspect.is(x2, Hehe));
            trace(Inspect.is(y2, Hehe));
            trace(Inspect.is(z2, Hehe));
        }
    #end*/
}

/*
#if test

    enum Bar
    {
        Baz;
        Yoo;
    }

    typedef Haha =
    {
        a:Int,
        b:String,
    };

    typedef Yoyo = Haha;

    typedef Hehe =
    {
        a:Int,
        b:String,
        c:{ x:String, y:Float },
    };

#end*/