## Asynchronous Generators and Fibers

### How does it Work?

To make a function resummable, I need to transform the function into a form that can be resumed. So I have to maintain the state of the function, and when you call the function again, it will resume from that state.

So I have to turn a function from something that looks like this:

```haxe
function hello()
{
    @yield "a";
    @yield "b";
    @yield "c";
}
```

Into a function that looks something like this:

```haxe
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
var a1 = bar();
var a2 = { __current = 123; @state next; return; @label next; __yielded; };
foo(a0, a1, a2);
```

All the scopes will then be merged and flattened, and cut up into switch cases at every `@label`.

Here's an example of all the [transformations that a fibonacci function goes through](https://gist.github.com/profound7/0408725cc82068a3019ad1a3b7beacf6).