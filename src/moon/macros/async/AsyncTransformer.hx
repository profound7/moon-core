package moon.macros.async;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import moon.macros.signal.SignalMacro;
import sys.io.File;

using haxe.macro.Tools;
using moon.macros.async.AsyncMacroTools;
using moon.macros.tools.TypedExprTools;

/**
 * Transforms a regular function into a resummable function.
 * 
 * @author Munir Hussin
 */
class AsyncTransformer
{
    public static var DEBUG_OUTPUT_TO_FILE:Bool = true;
    
    public var nextVarId:Int;
    public var nextLabelId:Int;
    public var vars:Array<Var>;
    public var sets:Array<Var>;
    public var labels:Array<String>;
    public var typedExprInfo:TypedExprInfo;
    
    public var name:String;
    public var fn:Function;
    public var pos:Position;
    
    public var yieldOnly:Bool;
    public var wrapper:{ name:String, method:String };
    public var nextType:ComplexType;
    public var sendType:ComplexType;
    public var returnType:ComplexType;
    public var isIterable:Bool;
    public var priority:Int;
    
    
    private var void:Expr;
    
    // printing to file
    private var out:Array<String>;
    
    // pushScope/popScope to keep track of var statements
    
    public function new(name:String, fn:Function, pos:Position)
    {
        //trace("---"); trace("---");
        
        this.name = name;
        this.fn = fn;
        this.pos = pos;
        
        this.nextVarId = 0;
        this.nextLabelId = 0;
        this.vars = [];
        this.sets = [];
        this.labels = [];
        
        this.void = macro @void if (false) null;
        this.out = [];
        
        this.yieldOnly = true;
        this.wrapper = null;
        
        returnType = fn.ret;
        
        // if returnType is null, try to infer from expected type
        if (returnType == null)
        {
            try
            {
                returnType = Context.getExpectedType().toComplexType();
                
                if (returnType != null) switch (returnType)
                {
                    case TFunction(_, ret):
                        returnType = ret;
                        fn.ret = returnType; // update fn's return type
                        
                    case _:
                        throw Context.error("Expected a function that returns a valid async type", pos);
                }
            }
            catch (ex:Dynamic)
            {
                // handled in if/else below
            }
        }
        
        if (returnType != null)
        {
            // get the full long name of the returnType
            var rType = Context.typeof(macro (null:$returnType));
            returnType = rType.toComplexType();
            
            function checkReturnType(ct:ComplexType):Void
            {
                switch (ct)
                {
                    case  (macro:StdTypes.Iterator<$n>)
                        | (macro:moon.core.Fiber<$n>)
                        | (macro:moon.core.Future<$n>)
                        | (macro:moon.core.Signal1<$n>)
                        | (macro:moon.core.Observable<$n>)
                        :
                        //trace("ITERATOR");
                        returnType = ct;
                        nextType = n;
                        sendType = macro:StdTypes.Void;
                        isIterable = false;
                        
                    case  (macro:StdTypes.Iterable<$n>)
                        | (macro:moon.core.Seq<$n>)
                        :
                        //trace("ITERABLE");
                        returnType = ct;
                        nextType = n;
                        sendType = macro:StdTypes.Void;
                        isIterable = true;
                        
                    case macro:moon.core.Generator<$n,$s>:
                        //trace("GENERATOR");
                        returnType = ct;
                        nextType = n;
                        sendType = s;
                        isIterable = false;
                        
                    case _:
                        
                        // 3rd-party wrappers
                        var usings = Context.getLocalUsing();
                        var customParams:Array<Type> = null;
                        
                        switch (rType)
                        {
                            case TInst(_.get() => uclass, p):
                                customParams = p;
                                var statics = uclass.statics.get();
                                
                                // custom wrapper from static method of class
                                for (fn in statics)
                                {
                                    switch (fn)
                                    {
                                        case { name: "fromAsync", type: TFun([arg], ret) }
                                          if (ret.isCompatibleWrapper(rType)):
                                            
                                            var argType = arg.t.toComplexType();
                                            var tp:TypePath = argType.getParameters()[0];
                                            tp.params = [for (p in customParams) TPType(p.toComplexType())];
                                            
                                            wrapper = { name: uclass.name, method: fn.name };
                                            checkReturnType(argType);
                                            return;
                                            
                                        case _:
                                    }
                                }
                                
                            case _:
                                // throw
                        }
                        
                        // custom wrapper from static extensions of module
                        for (uref in usings)
                        {
                            var uclass = uref.get();
                            var statics = uclass.statics.get();
                            
                            for (fn in statics)
                            {
                                switch (fn)
                                {
                                    case { meta: _.has("asyncType") => true, type: TFun([arg], ret) }
                                      if (ret.isCompatibleWrapper(rType)):
                                        
                                        var argType = arg.t.toComplexType();
                                        var tp:TypePath = argType.getParameters()[0];
                                        tp.params = [for (p in customParams) TPType(p.toComplexType())];
                                        
                                        wrapper = { name: uclass.name, method: fn.name };
                                        checkReturnType(argType);
                                        return;
                                        
                                    case _:
                                }
                            }
                        }
                        
                        
                        
                        //trace("OTHERS");
                        throw Context.error
                        (
                            fn.ret.toString() + " is not a valid async type.\n" +
                            "Valid async types are: Iterator, Iterable, Seq, Generator, " +
                            "Fiber, Future, Signal, Observable",
                            pos
                        );
                }
            }
            
            checkReturnType(returnType);
        }
        else
        {
            //trace("UNKNOWN");
            
            // TODO: attempt to infer nextType and sendType
            // a = @yield x     ==> nextType = typeof(x), sendType = typeof(a)
            // if @yield is used where an expression is expected
            
            // leave the variables untyped, and let haxe compiler figure it out on its own
            nextType = null;
            sendType = null;
            isIterable = false;
        }
    }
    
    
    
    
    public function nextVar(name:String):String
    {
        var id = "__set_" + name + "_" + (++nextVarId);
        return id;
    }
    
    public function nextLabel(name:String):String
    {
        var id = name + "_" + (++nextLabelId);
        return id;
    }
    
    
    public function print(?comments:String, ?manyComments:Array<String>, ?e:Expr, ?te:TypedExpr)
    {
        #if !display
            
            if (te != null)
                e = te.getInfo(fn.expr.pos).expr;
            
            out.push("\n");
            
            if (comments != null)
            {
                if (manyComments == null)
                    manyComments = [comments];
                else
                    manyComments.unshift(comments);
            }
            
            if (manyComments != null)
                for (c in manyComments)
                    out.push("// " + c + "\n");
                    
            out.push(fn.functionPrint(name, e));
            
            if (DEBUG_OUTPUT_TO_FILE)
                save();
        #end
    }
    
    public function save(?filename:String)
    {
        #if !display
            if (filename == null) filename = getSaveName();
            
            // print to file for debugging
            for (i in 0...out.length)
                out[i] = StringTools.replace(out[i], "\t", "    ");
                
            File.saveContent(filename, out.join("\n"));
        #end
    }
    
    public function getSaveName():String
    {
        return Context.getLocalModule() + "_" + name + ".hx";
    }
    
    public function containsYield(expr:Expr):Bool
    {
        return yieldOnly ? expr.containsYield() : true;
    }
    
    
    public function build():Expr
    {
        #if display
            if (returnType != null)
                return macro (null:$returnType);
        #end
        
        var e = fn.expr;
        print("original function", e);
        
        // map the positions to tvars
        e = preprocess();
        print("typed expression", e);
        
        
        
        e = pass_init(e);
        print("add label 0 (start state) and label -1 (end state)", e);
        
        Scope.init();
        e = pass_var2(e);
        print("transform var statements", e);
        
        e = pass_structs(e);
        print("transforming control structures", e);
        
        Scope.init();
        e = pass_rename(e);
        print("renaming labels and vars", e);
        
        e = pass_merge(e);
        print("merging blocks to flatten the code", e);
        
        e = pass_labels(e);
        print("replace label/goto names to integers", e);
        
        e = pass_switch(e);
        print("wrapping with a switch", e);
        
        e = final_pass(e);
        print("final pass", e);
        
        if (DEBUG_OUTPUT_TO_FILE) save();
        return e;
    }
    
    
    public function preprocess():Expr
    {
        // prepare a temporary fn expr so it can be typed
        var eFunction = EFunction(name,
        {
            args: fn.args,
            ret: fn.ret,
            expr: macro { ${fn.expr}; return null; },
            params: fn.params
        }).pos(pos);
        
        
        // replace @yield x with __yield__(x) so that when typed
        // and if the meta disappear, we still have the yield keywords
        function replaceYield(e:Expr):Expr
        {
            return switch (e)
            {
                case macro @yield $i{"$"}:
                    macro __yield__();
                    
                case macro @yield $expr:
                    expr = replaceYield(expr);
                    macro __yield__($expr);
                    
                case macro @await $expr:
                    expr = replaceYield(expr);
                    macro __await__($expr);
                    
                case _:
                    e.map(replaceYield);
            }
        }
        
        var yieldFn = nextType.isVoid() ?
            (macro function __yield__():$sendType { throw "lol"; }):
            (macro function __yield__(x:$nextType):$sendType { throw "lol"; });
            
        var awaitFn = macro function __await__<T>(x:moon.core.Future<T>):T { throw "lol"; };
            
        // prepend the yield function
        var expr = macro
        {
            $yieldFn;
            $awaitFn;
            ${ replaceYield(eFunction) };
        }
        
        // get the types of the expressions.
        // fixes switch capture variable problem
        // thanks Cauê Waneck!
        var te = Context.typeExpr(expr);
        print("preprocessing", te);
        
        // return the function expression without the yieldFn and awaitFn
        te = te.find(fn.expr.pos);
        typedExprInfo = te.getInfo(fn.expr.pos);
        return typedExprInfo.expr;
    }
    
    
    public function final_pass(e:Expr):Expr
    {
        var codes:Array<Expr> = [];
        var nextDef = nextType.getDefaultValue();
        var sendDef = sendType.getDefaultValue();
        
        // declare state vars
        codes.push(macro var __started:Bool = false);
        codes.push(macro var __state:Int = 0);
        codes.push(macro var __try:Array<Int> = []);
        codes.push(macro var __caught:Dynamic = null);
        
        if (nextType == null)
            codes.push(macro var __current = $nextDef);
        else if (!nextType.isVoid())
            codes.push(macro var __current:$nextType = $nextDef);
            
        if (sendType == null)
            codes.push(macro var __yielded = null);
        else if (!sendType.isVoid())
            codes.push(macro var __yielded:$sendType = $sendDef);
            
        if (nextType != null && sendType != null && !sendType.isVoid())
            codes.push(macro var __generator:moon.core.Generator<$nextType, $sendType> = null);
        else if (nextType != null)
            codes.push(macro var __generator:Iterator<$nextType> = null);
        else
            codes.push(macro var __generator = null);
            
            
        // declare hoisted vars
        for (v in typedExprInfo.vars)
        {
            var name = v.name;
            var ctype = v.type;
            var val = ctype.getDefaultValue();
            codes.push(macro var $name:$ctype = $val);
        }
        
        // declare vars for expanded expressions (@set)
        for (v in sets)
        {
            var name = v.name;
            var ctype = v.type;
            var val = ctype.getDefaultValue();
            codes.push(macro var $name:$ctype = null);
        }
        
        // the async function
        codes.push(macro function __run():Void $e);
        
        // is the function still alive?
        codes.push(macro function __hasNext()
        {
            return __state >= 0;
        });
        
        // run the next part of the function
        codes.push(macro function __next()
        {
            if (__started)
            {
                var tmp = __current;
                __run();
                return tmp;
            }
            else
            {
                __started = true;
                __run();
                return __next();
            }
        });
        
        // can we send value into the resumable function?
        if (sendType != null && sendType.isVoid())
        {
            codes.push(macro __generator = { hasNext: __hasNext, next: __next });
        }
        else
        {
            codes.push(macro function __send(value:$sendType)
            {
                __yielded = value;
                return __next();
            });
            
            codes.push(macro __generator = { hasNext: __hasNext, next: __next, send: __send });
        }
        
        // whether to wrap the function with another function, returning
        // an Iterator, so it becomes an Iterable.
        if (isIterable)
        {
            codes.push(macro return __generator);
            
            var it:Function =
            {
                args: [],
                ret: nextType == null ? null : macro:Iterator<$nextType>,
                expr: macro $b{codes},
                params: fn.params
            };
            
            codes = [];
            codes.push({ expr: EFunction("__iterator", it), pos: fn.expr.pos });
        }
        
        
        if (returnType == null)
        {
            // fallback to iterator
            codes.push(macro return __generator);
            return macro $b{codes};
        }
        
        // based on how the function is typed, return the appropriate one
        var returnExpr:Expr = switch (returnType)
        {
            case macro:StdTypes.Iterator<$n>:
                
                macro __generator;
                
            case macro:StdTypes.Iterable<$n>:
                
                macro { iterator: function() return __iterator() };
                
            case macro:moon.core.Seq<$n>:
                
                macro { iterator: function() return __iterator() };
                
            case macro:moon.core.Generator<$n,$s>:
                
                macro __generator;
                
            case macro:moon.core.Fiber<$n>:
                
                macro new moon.core.Fiber<$nextType>(1, __generator);
                
            case macro:moon.core.Future<$n>:
                
                codes.push(macro var __fiber = new moon.core.Fiber<$nextType>(1, __generator));
                macro __fiber.result;
                
            case macro:moon.core.Signal1<$n>:
                
                codes.push(macro var __fiber = new moon.core.Fiber<$nextType>(1, __generator));
                codes.push(macro __fiber.yielded = new moon.core.Signal<$nextType>());
                macro __fiber.yielded;
                
            case macro:moon.core.Observable<$n>:
                
                codes.push(macro var __fiber = new moon.core.Fiber<$nextType>(1, __generator));
                codes.push(macro var __observable = new moon.core.Observable<$nextType>());
                codes.push(macro __fiber.yielded = new moon.core.Signal<$nextType>());
                codes.push(macro __fiber.yielded.add(function(x) __observable.value = x));
                macro __observable;
                
            case _:
                // fallback to iterator
                macro __generator;
        }
        
        // if a custom wrapper is defined, call the static fromAsync function
        if (wrapper == null)
        {
            codes.push(macro return $returnExpr);
        }
        else
        {
            var method = wrapper.method;
            codes.push(macro return $i{wrapper.name}.$method($returnExpr));
        }
            
        return macro $b{codes};
    }
    
    
    
    
    
    
    
    /**
     * Add the initial label 0 and the ending label -1
     */
    public function pass_init(e:Expr):Expr
    {
        return macro
        {
            @section start;
            $e;
            
            @section end;
            return;
        };
    }
    
    
    /**
     * This pass identifies all variable declarations for hoisting
     * later. It transforms the names, so 2 variable names will not
     * clash after being hoisted.
     */
    public function pass_var2(e:Expr):Expr
    {
        var recurse = pass_var2;
        
        return switch (e.expr)
        {
            case EMeta({ name: ":ast" }, expr):
                recurse(expr);
                
            case EFunction(_, _):
                e;
                
            case ECall({ expr: EConst(CIdent("__yield__"))}, [expr]):
                macro @yield ${recurse(expr)};
                
            case ECall({ expr: EConst(CIdent("__await__"))}, [expr]):
                expr = recurse(expr);
                macro
                {
                    while ($expr.state == moon.core.Future.FutureState.Awaiting)
                        @yield __current;
                        
                    switch ($expr.state)
                    {
                        case moon.core.Future.FutureState.Success(v): v;
                        case moon.core.Future.FutureState.Failure(e): throw e;
                        case moon.core.Future.FutureState.Awaiting: throw "assert";
                    }
                };
                
            case ETry(eBody, catches):
                
                eBody = recurse(eBody);
                
                var codes:Array<Expr> =
                [
                    macro __try.push(@addr catch_all),
                    eBody,
                    macro __try.pop(),
                    macro @goto end_try,
                ];
                
                for (i in 0...catches.length)
                {
                    var c = catches[i];
                    //vars.push({ name: c.name, type: c.type, expr: null });
                    var eCatch = recurse(c.expr);
                    var name = c.name;
                    var label = "catch_" + i;
                    
                    c.expr = macro @goto $i{label};
                    c.name = "__ex";
                    
                    codes.push(macro @label $i{label});
                    codes.push(macro
                    {
                        $i{name} = __caught;
                        $eCatch;
                        @goto end_try;
                    });
                }
                
                var eTry = { expr: ETry(macro throw __caught, catches), pos: e.pos };
                
                codes.push(macro @label catch_all);
                codes.push(eTry);
                codes.push(macro @label end_try);
                
                macro $b{codes};
                
                
            case EVars(args):
                
                var codes = [];
                
                for (i in 0...args.length)
                {
                    var v = args[i];
                    //var tv = varInfo.getVar(i, e.pos);
                    
                    if (v.expr != null)
                    {
                        //trace(getTVarName(tv));
                        var expr = recurse(v.expr);
                        //codes.push(macro $i{getTVarName(tv)} = $expr);
                        
                        //vars.push(v);
                        codes.push(macro $i{v.name} = $expr);
                    }
                }
                
                codes.length == 0 ? void : macro $b{codes};
                
            /*case EFor(cond, body):
                
                switch (cond.expr)
                {
                    case EIn(v, it):
                        
                        switch (v.expr)
                        {
                            case EConst(CIdent(id)):
                                
                                var tv1 = varInfo.getLocal(e.pos); // for var
                                var tv2 = varInfo.getLocal(v.pos); // const var
                                it = recurse(it);
                                body = recurse(body);
                                
                                //trace("FOR CONST " + id + " -- " + e.pos.getInfos().min);
                                
                                if (tv1 != null && tv1.name != "`")
                                {
                                    macro for ($i{getTVarName(tv1)} in $it) $body;
                                }
                                else if (tv2 != null)
                                {
                                    macro for ($i{getTVarName(tv2)} in $it) $body;
                                }
                                else
                                {
                                    e;
                                }
                                
                            case _:
                                throw "unsupported";
                        }
                        
                    case _:
                        throw "unsupported";
                }*/
                
                
            /*case EConst(CIdent(id)):
                
                var tv = varInfo.getLocal(e.pos);
                //trace("CONST " + id + " -- " + e.pos.getInfos().min);
                
                if (tv != null)
                {
                    macro $i{getTVarName(tv)};
                }
                else
                {
                    e;
                }*/
                
            case _:
                e.map(recurse);
        }
    }
    
    // unused. replaced by pass_var2
    /*public function pass_var(e:Expr):Expr
    {
        var recurse = pass_var;
        
        return switch (e.expr)
        {
            case EFunction(_, _):
                e;
                
            case EBlock(args):
                Scope.push();
                var expr = { expr: EBlock(args.map(recurse)), pos: e.pos };
                Scope.pop();
                expr;
                
            case EFor({expr: EIn({ expr: EConst(CIdent(vname)) }, eIter)}, eBody):
                Scope.push();
                
                // declare the variable
                var id:String = nextVar("for_var_" + vname);
                vars.push(id);
                Scope.current.declare(vname, id);
                
                eIter = recurse(eIter);
                eBody = recurse(eBody);
                
                var expr = macro for ($i{id} in $eIter) $eBody;
                
                Scope.pop();
                expr;
                
            case EConst(CIdent(name)):
                
                var id = Scope.current.get(name);
                if (id != null)
                    macro $i{id};
                else
                    e;
                
            case ESwitch(val, cases, def):
                    
                // Need to get a list of all captured variables for each case.
                e;
                    
            case EVars(args):
                
                var codes = [];
                
                for (v in args)
                {
                    var id:String = nextVar("var_" + v.name);
                    vars.push(id);
                    Scope.current.declare(v.name, id);
                    
                    if (v.expr != null)
                        codes.push(macro $i{id} = ${v.expr});
                }
                
                macro $b{codes};
                
            case _:
                e.map(recurse);
        }
    }*/
    
    
    /**
     * this determines if an Expr is a statement (void expr) or returns a value,
     * so we can tell if the Expr can be used as a right-hand-side expression.
     * 
     * if (cond) 4 else 5;              // expr is rhs compatible
     * if (cond) 4 else trace(x);       // not rhs compatible, since trace is Void
     * if (cond) 4 else throw x;        // expr is rhs compatible
     * if (cond) throw x else throw y;  // also rhs compatible
     * 
     * TODO: in a future refactor, this is unnecessary, as we can tell how to
     * generate the code based on the parent expression
     * 
     *      i.e.
     *      { if (c) t else f; x; }     // the if is definitely statement, although it an rhs-compatible expr
     *      x = if (c) t else trace(f); // the if generates an rhs expr, although its void, since its used that way. rely on compiler error
     *      { ...; if (c) t else f; }   // since if is last value in block, need to see block's parent
     */
    public function isVoidCheck(e:Expr):Bool
    {
        if (e == null) throw "expression is null";
        var result = false;
        //var typedExpr = varInfo.exprByPos.get(e.pos.getInfos().min);
        var typedExpr = typedExprInfo.typedExprByPos.get(e.pos.getInfos().min);
        //trace("TE: " + typedExpr);
        var typedCt = typedExpr != null ? typedExpr.t.toComplexType() : null;
        
        if (typedCt != null)
        {
            result = typedCt.isVoid(); // definitely correct
        }
        else
        {
            try
            {
                // doesn't always work since some variables are not available in context :(
                var exprType = Context.typeof(e).toComplexType();
                result = exprType.match(TPath({ name: "StdTypes", pack: [], params: [], sub: "Void" }));
            }
            catch (ex:Dynamic)
            {
                // make a guess, or get user to annotate in ambiguous cases
                result = if (e == null) true else switch (e.expr)
                {
                    case EVars(_) | EFor(_, _) | EWhile(_, _, _) | EIf(_, _, null):
                        true;
                        
                    case EBlock(a):
                        // if length is 0, it should be parsed as EObjectDecl anyway.
                        // type of block depends on the last expression of the block.
                        a.length == 0 ? true : isVoidCheck(a[a.length - 1]);
                        
                    case ESwitch(_, cases, d):
                        // if any case is a void type, then the switch is a void type
                        for (c in cases)
                            if (c.expr == null || isVoidCheck(c.expr))
                                return true;
                                
                        // no default case implies an exhaustive cases array
                        d == null ? false : isVoidCheck(d);
                        
                    case EIf(_, t, f):
                        isVoidCheck(t) || isVoidCheck(f);
                        
                    // manual annotation by user
                    case EMeta({ name: "void" }, _):
                        true;
                        
                    // manual annotation by user
                    case EMeta({ name: "expr" }, _):
                        false;
                        
                    case EMeta(_, e):
                        isVoidCheck(e);
                        
                    // ECall could be void or not. if the function is outside the generator function,
                    // then Context.typeof above should work. Otherwise it may not, and you need
                    // to add @void to the function call
                    
                    // assume everything else is an expression
                    case _:
                        false;
                }
            }
        }
        
        //trace("VOID: " + result + " -- " + e.toString());
        return result;
    }
    
    
    /**
     * Convert control structures to a form that could be easily
     * flattened in future passes.
     * 
     * When yieldOnly is true, only expressions that contains the
     * yield expression will be transformed. The others are ignored.
     * This is used for building generators.
     * 
     * When yieldOnly is false, every single control structure
     * will be transformed, resulting in more verbose code,
     * but useful for "fake threads" implementation.
     * 
     * $void: when placed at the last line of a block, it indicates
     * that this block is not an expression and doesn't return a value.
     * 
     * @label name: labels the current line of code to be used
     * with goto. the label only exist in current block.
     * 
     * @goto name: jumps code execution to the line identified
     * by label. you can only goto a label in the current block.
     * 
     * In a later step, labels will be transformed into case
     * statements. goto will be transformed into __state = number;
     * 
     */
    public function pass_structs(e:Expr):Expr
    {
        //var recurse = function(e:Expr) return pass_structs(e, yieldOnly);
        if (e == null) return null;
        var recurse = pass_structs;
        
        return switch (e.expr)
        {
            case EFunction(_, _):
                e; // stop and don't go deeper
                
                
            case EIf(eCond, eTrue, eFalse) | ETernary(eCond, eTrue, eFalse) if (containsYield(e)):
                
                var isVoid = isVoidCheck(e);
                
                if (containsYield(eCond)) eCond = recurse(eCond);
                if (containsYield(eTrue)) eTrue = recurse(eTrue);
                if (containsYield(eFalse)) eFalse = recurse(eFalse);
                
                if (isVoid)
                {
                    //trace("if is void!");
                    if (eFalse == null)
                    {
                        // void: if (eCond) eTrue
                        macro
                        {
                            @set cond = $eCond;
                            if (@get cond) @goto trueLabel;
                            @goto falseLabel;
                            
                            @label trueLabel;
                            $eTrue;
                            
                            @label falseLabel;
                            $void;
                        }
                    }
                    else
                    {
                        // void: if (eCond) eTrue else eFalse
                        macro
                        {
                            @set cond = $eCond;
                            if (@get cond) @goto trueLabel;
                            
                            $eFalse;
                            @goto endLabel;
                            
                            @label trueLabel;
                            $eTrue;
                            
                            @label endLabel;
                            $void;
                        }
                    }
                }
                else
                {
                    // since its an expression instead of a statement,
                    // we have to make sure the last expression of the block
                    // is the actual return value
                    macro
                    {
                        @set cond = $eCond;
                        if (@get cond) @goto trueLabel;
                        
                        @set ret = $eFalse;
                        @goto endLabel;
                        
                        @label trueLabel;
                        @set ret = $eTrue;
                        
                        @label endLabel;
                        @get ret;
                    }
                }
                
            case ESwitch(eValue, cases, eDefault) if (containsYield(e)):
                
                // if the switch is an expression instead of a statement,
                // we have to make sure the last expression of the block
                // is the actual return value
                
                /*var typedExpr = varInfo.exprByPos.get(e.pos.getInfos().min);
                var type = typedExpr.t.toComplexType();
                trace("SWITCH ", type);
                
                var isVoid = type == null ? e.isVoidExpr() : type.isVoid(); //: e.isVoidExpr();
                isVoid = type == null || type.isVoid();*/
                var isVoid = isVoidCheck(e);
                
                if (containsYield(eValue)) eValue = recurse(eValue);
                if (containsYield(eDefault)) eDefault = recurse(eDefault);
                
                var bodies:Array<Expr> = [];
                bodies.push(macro @goto end);
                
                
                
                for (i in 0...cases.length)
                {
                    var c = cases[i];
                    
                    for (cv in c.values)
                    {
                        if (cv.containsYield())
                        {
                            throw Context.error("switch cases cannot contain yield", cv.pos);
                        }
                    }
                    
                    if (c.guard.containsYield())
                    {
                        throw Context.error("switch guards cannot contain yield", c.guard.pos);
                        // i suppose this is possible, but i wanna keep this simple
                    }
                    
                    var label = "case_" + i;
                    var eCase = containsYield(c.expr) ? recurse(c.expr) : c.expr;
                    
                    bodies.push(macro @label $i{label});
                    bodies.push(isVoid ? eCase : macro @set ret = $eCase);
                    bodies.push(macro @goto end);
                    
                    c.expr = macro @goto $i{label};
                }
                
                if (eDefault != null)
                {
                    var label = "case_default";
                    bodies.push(macro @label $i{label});
                    bodies.push(eDefault);
                    
                    eDefault = macro @goto $i{label};
                }
                
                bodies.push(macro @label end);
                bodies.push(isVoid ? void : macro @get ret);
                
                // add the new switch statement
                bodies.unshift({ expr: ESwitch(eValue, cases, eDefault), pos: e.pos });
                
                macro $b{bodies};
                
            case EWhile(eCond, eBody, normal) if (containsYield(e)):
                
                if (containsYield(eCond)) eCond = recurse(eCond);
                if (containsYield(eBody)) eBody = recurse(eBody);
                
                if (normal)
                {
                    // while (cond) expr
                    macro
                    {
                        @label start_loop;
                        @set cond = $eCond;
                        if (!@get cond) @goto end_loop;
                        
                        $eBody;
                        @goto start_loop;
                        
                        @label end_loop;
                        $void;
                    }
                }
                else
                {
                    // do expr while (cond)
                    macro
                    {
                        @label start_loop;
                        $eBody;
                        
                        @set cond = $eCond;
                        if (@get cond) @goto start_loop;
                        
                        @label end_loop;
                        $void;
                    }
                }
                
            case EFor({ expr: EIn(eVar, eIter) }, eBody) if (containsYield(e)):
                
                if (containsYield(eVar)) eVar = recurse(eVar);
                if (containsYield(eIter)) eIter = recurse(eIter);
                if (containsYield(eBody)) eBody = recurse(eBody);
                
                // eIter can be Iterator or Iterable
                //var isIterable = Context.unify(Context.typeof(eIter), Context.typeof(macro (null:Iterable<Dynamic>)));
                //var isIterator = Context.unify(Context.typeof(eIter), Context.typeof(macro (null:Iterator<Dynamic>)));
                
                //var eIt = isIterable ?
                //    (macro $eIter.iterator()):
                //    isIterator ?
                //        eIter:
                //        throw Context.error("Expected Iterable or Iterator", eIter.pos);
                
                var it = macro @get it;
                
                // for (x in it)
                macro
                {
                    @set it = moon.macros.async.AsyncMacroTools.asIterator($eIter);
                    
                    @label start_loop;
                    if (!$it.hasNext()) @goto end_loop;
                    //@set $eVar = $it.next();
                    $eVar = $it.next();
                    
                    $eBody;
                    @goto start_loop;
                    
                    @label end_loop;
                    $void;
                }
                
            case EBreak:
                
                macro @goto end_loop;
                
            case EContinue:
                
                macro @goto start_loop;
                
            case EParenthesis(e1) if (containsYield(e1)):
                
                e1 = recurse(e1);
                macro $e1;
                
            case EField(eObj, field) if (containsYield(eObj)):
                
                eObj = recurse(eObj);
                var ret = { expr: EField(macro @get obj, field), pos: e.pos };
                
                macro
                {
                    @set obj = $eObj;
                    $ret;
                }
                
            // eArr[eIdx]
            case EArray(eArr, eIdx) if (containsYield(e)):
                
                if (containsYield(eArr)) eArr = recurse(eArr);
                if (containsYield(eIdx)) eIdx = recurse(eIdx);
                
                var arr = macro @get arr;
                
                macro
                {
                    @set arr = $eArr;
                    @set idx = $eIdx;
                    $arr[@get idx];
                }
                
            case EBinop(op, eLhs, eRhs) if (containsYield(e)):
                //trace(eLhs.toString(), op, eRhs.toString());
                
                if (containsYield(eRhs)) eRhs = recurse(eRhs);
                
                switch (op)
                {
                    // special case when we're assigning
                    case OpAssign | OpAssignOp(_):
                        
                        switch (eLhs.expr)
                        {
                            // id = rhs
                            case EConst(CIdent(id)):
                                var eSet = { expr: EBinop(op, macro $i{id}, macro @get rhs), pos: e.pos };
                                
                                macro
                                {
                                    @set rhs = $eRhs;
                                    $eSet;
                                }
                                
                            // arr[idx] = rhs
                            case EArray(eArr, eIdx):
                                
                                if (containsYield(eArr)) eArr = recurse(eArr);
                                if (containsYield(eIdx)) eIdx = recurse(eIdx);
                                
                                var arr = macro @get arr;
                                var eSet = { expr: EBinop(op, macro $arr[@get idx], macro @get rhs), pos: e.pos };
                                
                                macro
                                {
                                    @set rhs = $eRhs;
                                    @set arr = $eArr;
                                    @set idx = $eIdx;
                                    $eSet;
                                }
                                
                            // obj.field = rhs
                            case EField(eObj, field):
                                
                                if (containsYield(eObj)) eObj = recurse(eObj);
                                var eLhs = { expr: EField(macro @get obj, field), pos: e.pos };
                                var eSet = { expr: EBinop(op, macro $eLhs, macro @get rhs), pos: e.pos };
                                
                                macro
                                {
                                    @set rhs = $eRhs;
                                    @set obj = $eObj;
                                    $eSet;
                                }
                                
                            case _:
                                throw "unexpected assignment type";
                        }
                        
                    case _:
                        
                        if (containsYield(eLhs)) eLhs = recurse(eLhs);
                        var eBinop = { expr: EBinop(op, macro @get lhs, macro @get rhs), pos: e.pos };
                        
                        macro
                        {
                            @set lhs = $eLhs;
                            @set rhs = $eRhs;
                            $eBinop;
                        }
                }
                
            case EUnop(op, post, e1) if (containsYield(e1)):
                
                e1 = recurse(e1);
                var ret = { expr: EUnop(op, post, macro @get a1), pos: e.pos };
                
                macro
                {
                    @set a1 = $e1;
                    $ret;
                }
                
            case EThrow(eValue) if (containsYield(eValue)):
                
                eValue = recurse(eValue);
                var ret = { expr: EThrow(macro @get value), pos: e.pos };
                
                macro
                {
                    @set value = $eValue;
                    $ret;
                }
                
            case ECheckType(eValue, ct) if (containsYield(eValue)):
                
                eValue = recurse(eValue);
                var ret = { expr: ECheckType(macro @get value, ct), pos: e.pos };
                
                macro
                {
                    @set value = $eValue;
                    $ret;
                }
                
            case ECall(eFn, args) if (containsYield(e)):
                
                if (containsYield(eFn)) eFn = recurse(eFn);
                
                for (i in 0...args.length)
                    if (containsYield(args[i]))
                        args[i] = recurse(args[i]);
                
                var gets:Array<Expr> = [];
                var codes:Array<Expr> = [];
                
                for (i in 0...args.length)
                {
                    var id = macro $i{'arg$i'};
                    gets.push(macro @get $id);
                    codes.push(macro @set $id = ${args[i]});
                }
                
                var expr = { expr: ECall(eFn, gets), pos: e.pos };
                codes.push(expr);
                macro $b{codes};
                
            case ENew(tpath, args) if (containsYield(e)):
                
                for (i in 0...args.length)
                    if (containsYield(args[i]))
                        args[i] = recurse(args[i]);
                
                var gets:Array<Expr> = [];
                var codes:Array<Expr> = [];
                
                for (i in 0...args.length)
                {
                    var id = macro $i{'arg$i'};
                    gets.push(macro @get $id);
                    codes.push(macro @set $id = ${args[i]});
                }
                
                var expr = { expr: ENew(tpath, gets), pos: e.pos };
                codes.push(expr);
                macro $b{codes};
                
            case EArrayDecl(args) if (containsYield(e)):
                
                for (i in 0...args.length)
                    if (containsYield(args[i]))
                        args[i] = recurse(args[i]);
                
                var gets:Array<Expr> = [];
                var codes:Array<Expr> = [];
                
                for (i in 0...args.length)
                {
                    var id = macro $i{'arr$i'};
                    gets.push(macro @get $id);
                    codes.push(macro @set $id = ${args[i]});
                }
                
                var expr = { expr: EArrayDecl(gets), pos: e.pos };
                codes.push(expr);
                macro $b{codes};
                
            case EObjectDecl(fields) if (containsYield(e)):
                
                for (i in 0...fields.length)
                    if (containsYield(fields[i].expr))
                        fields[i].expr = recurse(fields[i].expr);
                
                var gets:Array<{ field:String, expr:Expr }> = [];
                var codes:Array<Expr> = [];
                
                for (i in 0...fields.length)
                {
                    var id = macro $i{'obj$i'};
                    gets.push({ field: fields[i].field, expr: macro @get $id });
                    codes.push(macro @set $id = ${fields[i].expr});
                }
                
                var expr = { expr: EObjectDecl(gets), pos: e.pos };
                codes.push(expr);
                macro $b{codes};
                
                
            case EReturn(eValue):
                
                if (eValue != null)
                {
                    if (containsYield(eValue))
                    {
                        eValue = recurse(eValue);
                        
                        macro
                        {
                            @state -1;
                            @set ret = $eValue;
                            __current = @get ret;
                            return;
                        }
                    }
                    else
                    {
                        macro
                        {
                            @state -1;
                            __current = $eValue;
                            return;
                        }
                    }
                }
                else
                {
                    macro
                    {
                        @state -1;
                        return;
                    }
                }
                
                
            case EMeta({ name: "yield" }, eValue):
                //trace(Context.typeof(macro { return; }).toComplexType());
                //var yielded = sendType.isVoid() ? void : macro __yielded;
                var yielded = sendType == null || !sendType.isVoid() ? macro __yielded : void;
                
                if (containsYield(eValue))
                {
                    eValue = recurse(eValue);
                    
                    return macro
                    {
                        @set ret = $eValue;
                        __current = @get ret;
                        @state next;
                        return;
                        
                        @label next;
                        $yielded;
                    }
                }
                else
                {
                    if (eValue.expr.match(EConst(CIdent("__current"))))
                    {
                        return macro
                        {
                            @state next;
                            return;
                            
                            @label next;
                            $yielded;
                        }
                    }
                    else
                    {
                        return macro
                        {
                            __current = $eValue;
                            @state next;
                            return;
                            
                            @label next;
                            $yielded;
                        }
                    }
                }
                
                
            case _:
                e.map(recurse);
        }
    }
    
    
    public function pass_rename(e:Expr):Expr
    {
        // convert each @label name to @label l_name_id
        // convert each @goto name to @goto l_name_id
        
        // convert each @section name to @label s_name_id
        // convert each @jump name to @goto s_name_id
        
        // convert each @set name to name_id
        // convert each @get name to name_id
        
        var recurse = pass_rename;
        
        return switch (e.expr)
        {
            case EFunction(_, _):
                e;
                
            case EBlock(args):
                Scope.push();
                var codes:Array<Expr> = [];
                
                // define all the labels/sections in this scope first
                // before transforming the gotos/jumps
                for (a in args)
                {
                    switch (a)
                    {
                        case macro @label $i{name}:
                            
                            var id:String = nextLabel(name);
                            Scope.current.declare("#" + name, id);
                            labels.push(id);
                            codes.push(macro @label $i{id});
                            //trace('@label $name => $id');
                            
                        case macro @section $i{name}:
                            
                            var id:String = nextLabel(name);
                            Scope.global.declare("#" + name, id);
                            labels.push(id);
                            codes.push(macro @label $i{id});
                            //trace('@section $name => $id');
                            
                        case _:
                            
                            codes.push(a);
                    }
                }
                
                var expr = { expr: EBlock(codes.map(recurse)), pos: e.pos };
                Scope.pop();
                expr;
                
            // @meta precedence changed from 3.2 to 3.3!
            #if (haxe_ver == 3.3)
            case EMeta({name: "set"},
                { expr: EBinop(OpAssign, { expr: EConst(CIdent(name)) }, rhs) }):
                
                //trace('@set $name');
                rhs = recurse(rhs);
                
                var id:String = Scope.current.vars.get("$" + name);
                
                if (id == null)
                {
                    id = nextVar(name);
                    Scope.current.declare("$" + name, id);
                    sets.push({ name: id, type: null, expr: null });
                }
                
                macro $i{id} = $rhs;
            #else
            case EBinop(OpAssign,
                { expr: EMeta({ name: "set" }, { expr: EConst(CIdent(name)) }) },
                rhs):
                
                //trace('@set $name');
                rhs = recurse(rhs);
                
                var id:String = Scope.current.vars.get("$" + name);
                
                if (id == null)
                {
                    id = nextVar(name);
                    Scope.current.declare("$" + name, id);
                    sets.push({ name: id, type: null, expr: null });
                }
                
                macro $i{id} = $rhs;
            #end
            
                
            case EMeta({ name: "get" }, { expr: EConst(CIdent(name)) }):
                
                var id = Scope.current.get("$" + name);
                if (id != null)
                    macro $i{id};
                else
                    throw '@get: $name does not exist';
                    
            case EMeta({ name: "addr" }, { expr: EConst(CIdent(name)) }):
                
                if (Scope.current.exists("#" + name))
                {
                    var id:String = Scope.current.get("#" + name);
                    macro @addr $i{id};
                }
                else
                {
                    throw '@label $name does not exist';
                }
                
            case EMeta({ name: "goto" }, { expr: EConst(CIdent(name)) }):
                
                if (Scope.current.exists("#" + name))
                {
                    var id:String = Scope.current.get("#" + name);
                    macro @goto $i{id};
                }
                else
                {
                    throw '@label $name does not exist';
                }
                
            case EMeta({ name: "state" }, { expr: EConst(CIdent(name)) }):
                
                if (Scope.current.exists("#" + name))
                {
                    var id:String = Scope.current.get("#" + name);
                    macro @state $i{id};
                }
                else
                {
                    throw '@label $name does not exist';
                }
                
            case EMeta({ name: "state" }, { expr: EConst(CInt(idx)) }):
                
                macro __state = $v{Std.parseInt(idx)};
                
            case EMeta({ name: "jump" }, { expr: EConst(CIdent(name)) }):
                
                if (Scope.global.exists("#" + name))
                {
                    var id:String = Scope.global.get("#" + name);
                    macro @goto $i{id};
                }
                else
                {
                    throw '@label $name does not exist';
                }
                
                
            case _:
                e.map(recurse);
        }
    }
    
    
    public function pass_merge(e:Expr):Expr
    {
        return switch (e.expr)
        {
            case EBlock(args):
                
                var codes:Array<Expr> = [];
                
                for (a in args)
                {
                    var out:Array<Expr> = [];
                    var expr = pass_merge2(a, args, out);
                    
                    for (o in out)
                        codes.push(o);
                    codes.push(expr);
                }
                
                macro $b{codes};
                
            case _:
                throw "Expected block as root expression";
        }
    }
    
    public function pass_merge2(e:Expr, parentBlock:Array<Expr>, out:Array<Expr>):Expr
    {
        var recurse = function(e:Expr) return pass_merge2(e, parentBlock, out);
        
        return switch (e.expr)
        {
            case EFunction(_, _):
                e; // stop and don't go deeper
                
            // { ...; { a; b; c; }; ... }       ==> { ...; a; b; c; ...; }
            // { ...; x = { a; b; c; }; ... }   ==> { ...; a; b; x = c; ...; }
            case EBlock(args):
                
                var last = args.pop();
                
                for (a in args)
                {
                    var out2:Array<Expr> = [];
                    var expr = pass_merge2(a, args, out2);
                    
                    for (o in out2)
                        out.push(o);
                    out.push(expr);
                }
                
                var out2:Array<Expr> = [];
                var expr = pass_merge2(last, args, out2);
                for (o in out2)
                    out.push(o);
                expr;
                
            case _:
                e.map(recurse);
        }
    }
    
    public function pass_labels(e:Expr):Expr
    {
        var index = 0;
        var labels = new Map<String, Int>();
        
        switch (e.expr)
        {
            case EBlock(args):
                
                var codes:Array<Expr> = [];
                
                // pass 1: retrieve label indexes
                for (a in args) switch (a)
                {
                    case macro @label $i{id}:
                        
                        var value = index++;
                        labels.set(id, value);
                        codes.push(macro @label $v{value});
                        
                    case macro @void if (false) null:
                        // skip these
                        
                    case macro $i{"__yielded"}:
                        // skip these also since we're only
                        // interested in something = __yielded
                        
                    case _:
                        codes.push(a);
                }
                
                // pass 2: replace gotos with label indexes
                return pass_gotos(macro $b{codes}, labels);
                
            case _:
                throw "Expected a block of codes";
        }
        
        
    }
    
    public function pass_gotos(e:Expr, labels:Map<String, Int>):Expr
    {
        var recurse = function(e:Expr) return pass_gotos(e, labels);
        
        return switch (e.expr)
        {
            case EFunction(_, _):
                e; // stop and don't go deeper
                
            case EMeta({ name: "addr" }, { expr: EConst(CIdent(id)) }):
                if (labels.exists(id))
                    macro $v{labels.get(id)};
                else
                    throw 'addr label $id does not exist';
                
            case EMeta({ name: "goto" }, { expr: EConst(CIdent(id)) }):
                if (labels.exists(id))
                    macro { __state = $v{labels.get(id)}; continue; };
                else
                    throw 'goto label $id does not exist';
                    
            case EMeta({ name: "state" }, { expr: EConst(CIdent(id)) }):
                if (labels.exists(id))
                    macro __state = $v{labels.get(id)};
                else
                    throw 'goto label $id does not exist';
                    
            case _:
                e.map(recurse);
        }
    }
    
    public function pass_switch(e:Expr):Expr
    {
        switch (e.expr)
        {
            case EBlock(args):
                
                var sw = macro switch (__state) { default: throw moon.core.Async.AsyncException.InvalidState(__state); };
                
                switch (sw.expr)
                {
                    case ESwitch(e, cases, def):
                        
                        var currCase:Case = null;
                        var codes:Array<Expr> = [];
                        
                        currCase =
                        {
                            values: [macro $v{-1}],
                            expr: macro { throw moon.core.Async.AsyncException.FunctionEnded; }
                        }
                        
                        for (a in args) switch (a.expr)
                        {
                            case EMeta({ name:"label" }, { expr:EConst(CInt(id)) }):
                                
                                if (currCase != null) cases.push(currCase);
                                var i:Int = Std.parseInt(id);
                                codes = [];
                                
                                currCase =
                                {
                                    values: [macro $v{i}],
                                    expr: { expr: EBlock(codes), pos: a.pos }
                                };
                                
                            case _:
                                codes.push(a);
                        }
                        
                        if (currCase != null) cases.push(currCase);
                        return macro while (true)
                        try
                        {
                            $sw;
                            ++__state;
                        }
                        catch (ex:Dynamic)
                        {
                            if (__try.length == 0)
                                throw ex;
                            else
                            {
                                __caught = ex;
                                __state = __try.pop();
                            }
                        };
                        
                    case _:
                        throw "oh noes";
                }
                
                
            case _:
                throw "Expected a block of codes";
        }
    }
    
}



private class Scope
{
    public static var global:Scope;
    public static var current:Scope;
    public static var stack:Array<Scope>;
    
    public var parent:Scope;
    public var vars:Map<String, String>;
    
    public static function init()
    {
        stack = [];
        current = global = new Scope(null);
    }
    
    public static function push()
    {
        stack.push(current);
        current = new Scope(current);
    }
    
    public static function pop()
    {
        current = stack.pop();
    }
    
    public function new(parent:Scope)
    {
        this.parent = parent;
        this.vars = new Map();
    }
    
    public function find(k:String):Null<Scope>
    {
        return vars.exists(k) ?
            this:
            parent != null ?
                parent.find(k):
                null;
    }
    
    public function exists(k:String):Bool
    {
        return find(k) != null;
    }
    
    public function get(k:String):Null<String>
    {
        var s = find(k);
        return s != null ? s.vars.get(k) : null;
    }
    
    public function set(k:String, v:String):Void
    {
        var s = find(k);
        if (s != null) s.set(k, v);
    }
    
    public function declare(k:String, v:String):Void
    {
        vars.set(k, v);
    }
}
