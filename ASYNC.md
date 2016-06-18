## Asynchronous Generators and Fibers

### Cooperative Multi-tasking in Haxe!

You can now easily write asynchronous cooperatively-multitasking codes in Haxe! Unlike threads, you don't need to worry about locking, and this works on single-threaded targets too.

This works just like the generator functions in JavaScript, Python, and C#. If a function or method contains a `@yield x` expression, then it is automatically transformed into a generator function.

### Generators

You can type the generator function with a valid async type, to get that type when the generator is called. In the following example, it's an `Iterator<String>`, but it could be other async types too.

```haxe
function names():Iterator<String>
{
    @yield "alice";
    @yield "bob";
    @yield "carol";
    @yield "dave";
}

for (x in names())
    trace(x);
```

In this example, we want a `Generator<Int, String>` instead. `Int` is what this generator produces. `String` is what this generator accepts via `send(value)`. This is like in JavaScript and Python where you can also send values back into the generator.

```
function greet(a:Int, b:String):Generator<Int, String>
{
    for (i in a...10)
    {
        if (i == 5)
            trace("yo" + @yield 999);
        else
            trace(b + @yield vv);
    }
}

var it = greet(3, "hi");
var m = 10;

while (it.hasNext())
{
    var out = it.send(" " + m++);
    trace("out:   " + out);
}
```

So what else is valid besides Iterator and Generator? Here's a complete list:

- Valid async generator types:
    - [`Iterator<T>`](https://github.com/HaxeFoundation/haxe/blob/development/std/StdTypes.hx#L109)
    - [`Iterable<T>`](https://github.com/HaxeFoundation/haxe/blob/development/std/StdTypes.hx#L140)
    - [`Seq<T>`](src/moon/core/Seq.hx)
    - [`Generator<T,V>`](src/moon/core/Generator.hx)
- Valid async fiber types:
    - [`Fiber<T>`](src/moon/core/Fiber.hx)
    - [`Future<T>`](src/moon/core/Future.hx)
    - [`Signal<T>`](src/moon/core/Signal.hx)
    - [`Observable<T>`](src/moon/core/Observable.hx)

### Fibers

Async generator types are simply iterators. You need to manually iterate through them. Async fiber types are iterators added into a `Fiber` object. The fiber `Processor` is usually added to your game loop or some interval/update function, and the processor will take turns switching between different fibers every loop.

```
function think(self:Entity):Fiber<Int>
{
    // some long-running algorithm
    var i = 0;
    for (e1 in entities)
        for (e2 in entities)
            if (++i % 10 == 0)
                @yield i; // allow other fibers to run
            else
                self.doSomething(e1, e2);
}

// these fibers are automatically added to Processor.main
var fiberA = think(a);
var fiberB = think(b);
var fiberC = think(c);

// this while loop represents your game loop/update
while (Processor.main.hasNext())
{
    // run the next 7 fibers.
    // this number is arbitrary.
    Processor.main.run(7);
}

```

The processor will automatically remove fibers that has terminated. You can manually kill a fiber using `fiber.kill()`.

### How to Use

There are 2 ways to use this async macro. One is by calling the `Async.async(function()...)` macro. The other way is to add a `@:build(moon.core.Sugar.buildAsync())` to your class. The second way results in cleaner looking code.

See [AsyncExamples](test/AsyncExamples.hx) for more generator function examples using `Async.async()`.

See [AsyncSugaredExamples](test/AsyncSugaredExamples.hx) for the examples that uses `@:build`.

Running the async examples:

```
haxe -main AsyncSugaredExamples -cp src -cp test -neko async.n
neko async
```

### How does it Work?

To make a function resummable, I need to transform the function into a form that can be resumed. So I have to maintain the state of the function, and when you call the function again, it will resume from that state.

So I have to turn a function from something that looks like this:

```
function hello()
{
    @yield "a";
    @yield "b";
    @yield "c";
}
```

Into a function that looks something like this:

```
function hello()
{
    var __state = 0;
    var __current;
    function __run()
    {
        while (true) switch (__state)
        {
            case -1:
                throw "function ended";
            case 0:
                __current = "a";
                __state = 1;
                return;
            case 1:
                __current = "b";
                __state = 2;
                return;
            case 2:
                __current = "c";
                __state = -1;
                return;
            case _:
                throw "invalid state";
        }
        ++_state;
    }
    return { hasNext: ... , next: ... , send: ... };
}
```

It gets tricky when there are various control structures, scoping, and variable declarations. So what I did was to hoist all variables to above the __run function, and I transformed all control structures (that contains `@yield`) into a *flattened* one by adding `@label x` and `@goto x` annotations. Due to the flattened code, variable names need to be renamed so they don't clash, since they're all within a single scope.

Since `@yield` is also an expression, it can have a value (via `send`).

So something like:

```haxe
foo(a, bar(), @yield 123);
```

Have to be transformed into (to maintain execution order):

```haxe
var a0 = a;
var a1 = bar();
var a2 = @yield 123;
foo(a0, a1, a2);
```

Before it becomes:

```haxe
var a0 = a;
var a1 = b();
var a2 = { __current = 123; @state next; return; @label next; __yielded; };
foo(a0, a1, a2);
```

All the scopes will then be merged and flattened, and cut up into switch cases at every `@label`.