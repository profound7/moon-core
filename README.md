# Moon Core Library

The `moon-core` lib is the result of accumulated codes over the years from freelancing, hobby, and professional work. The cross-platform/general stuff goes into this project.

## Some Stuff from this Library

### Core

[Any](src/moon/core/Any.hx) with deepEquals, [Bits](src/moon/core/Bits.hx) abstract for bit manipulations, [Compare](src/moon/core/Compare.hx) for easy comparisons and sorting. [Range](src/moon/core/Range.hx) for Pythonesque Int Iterator. [Future](src/moon/core/Future.hx), [Signal](src/moon/core/Signal.hx) and [Observable](src/moon/core/Observable.hx) as events primitives. [Pair](src/moon/core/Pair.hx) and [Tuple](src/moon/core/Tuple.hx) for ordered values, each with its own type. [Sugar](src/moon/core/Sugar.hx) for short lambdas and other conveniences.

[Text](src/moon/core/Text.hx) is a `String` abstract with operator overloading (eg. multiply with `Int` to repeat). Also some functions to display text in fixed width, with options to align left/right/center.

[Seq](src/moon/core/Seq.hx) is an abstract `Iterable`, with automatic conversions from `Iterator`, `Vector`, `String`, `Void->Iterator` and `Void->Seq`. It has all of Lambda methods, plus many more. Actually, I've implemented almost every method less some overloads from [.NET's LINQ Enumerable class](https://msdn.microsoft.com/en-us/library/system.linq.enumerable.aspx). Like .NET's Enumerable, a number of the query methods have deferred execution. This will pave way for a LINQ-like Haxe macro when I get around to doing it. Seq works best as a static extension (so sequences of sequences can have additional methods).

[Generator](src/moon/core/Generator.hx) and [Fiber](src/moon/core/Fiber.hx) for easy writing of asynchronous code using `@yield` expression to stop running a function, which can later be resumed. This is done with [Async](src/moon/core/Async.hx) to transform regular functions into a state machine. Not every Haxe expression is supported yet. For example, variable capture from a switch case isn't working. Array comprehension is also not working. In some special cases, `if` and `switch` may be detected incorrectly if they're expressions or statements. You can manually annotate with `@void` or `@expr` to avoid such compilation errors.

### Crypto

[PBKDF2](src/moon/crypto/PBKDF2.hx) for password hashing, [Jwt](src/moon/crypto/Jwt.hx) (JSON Web Tokens) for signed tokens. [Arc4](src/moon/crypto/ciphers/Arc4.hx) symmetric cipher, [Rsa](src/moon/crypto/ciphers/Rsa.hx) asymmetric crypto ([Oaep](src/moon/crypto/ciphers/Oaep.hx) padding not fully implemented).

### Data

[HyperArray](src/moon/data/array/HyperArray.hx) for creating multi-dimensional array at run-time. [MultiArray](src/moon/data/array/MultiArray.hx) for an efficient multi-dimensional array, where all calculations are pre-calculated and inlined at compile-time. [NestedArray](src/moon/data/array/NestedArray.hx) for multi-dimensional arrays that can be jagged.

There's a bunch of different iterators, including [IterableIterator](src/moon/data/iterators/IterableIterator.hx) and [IteratorIterator](src/moon/data/iterators/IteratorIterator.hx) for iterating through nested sequences as if they're a single linear sequence.

[LruCache](src/moon/data/map/LruCache.hx) (Least-Recently-Used Cache) which behaves like a `StringMap` except that it has limited capacity, and the least-recently used item will get kicked out when inserting a new item when full. It's implemented using [DoubleLinkedList](src/moon/data/list/DoubleLinkedList.hx). [Histogram](src/moon/data/set/Histogram.hx) for tallying stuff, and [Set](src/moon/data/set/Set.hx) for unique collections.

### Numbers

[BigInteger](src/moon/numbers/big/BigInteger.hx), [BigRational](src/moon/numbers/big/BigRational.hx), and [BigBits](src/moon/numbers/big/BigBits.hx) for dealing with numbers of arbitrary size. BigInteger is used for implementing [Rsa](src/moon/crypto/ciphers/Rsa.hx) (done for fun -- it's slow, not fully tested, so don't use).

[Stats](src/moon/numbers/stats/Stats.hx) for computing stuff like mean, median, mode, variance, standard deviation, zScore etc...

There's a number of seedable pseudo-random number generators to use, such as [MersenneTwisterRandom](src/moon/numbers/random/algo/MersenneTwisterRandom.hx), [LcgRandom](src/moon/numbers/random/algo/LcgRandom.hx) (Linear Congruent Generator), [XorShiftRandom](src/moon/numbers/random/algo/XorShiftRandom.hx), and a few others. Any of these PRNG algorithms could be assigned to a [Random](src/moon/numbers/random/Random.hx) abstract, where you'll get many more methods like shuffling arrays, random sample, n-dice rolls, and so on. You can also generate random numbers that follows a specific distribution like triangular, exponential, gamma, chi-squared, and a number of others.

[Units](src/moon/numbers/units/Units.hx) (work-in-progress!) uses Haxe abstracts to give meaning to numbers by typing it with a unit. Automatic conversions between units when you assign to a compatible type. TODO: Only allow units of the same type for add/sub. Dimensionless numbers can be multiplied/divided with a dimensioned number. Type conversion when two units are multiplied/divided.

### Remoting

[FutureProxy](src/moon/remoting/FutureProxy.hx) is like `AsyncProxy` for Haxe remoting, but it returns a [Future](src/moon/core/Future.hx) instead. Future is from moon-lib and not to be confused with the one from tink_core.

### Strings

[DamerauLevenshtein](src/moon/strings/metric/DamerauLevenshtein.hx) for checking edit distances between two strings. [Inflect](src/moon/strings/Inflect.hx) to convert from string cases like kebab-case to camelCase etc... [HashCode](src/moon/strings/HashCode.hx) has several different algorithms for calculating hash codes of strings.

### Tools

These are all meant to be used as a static extension.

[ArrayTools](src/moon/tools/ArrayTools.hx) lets you zip and unzip like in python. Also has some set operations between arrays. [FloatTools](src/moon/tools/FloatTools.hx) to round, truncate, clamp, interpolate, format numbers. [FunctionTools](src/moon/tools/FunctionTools.hx) to memoize functions. [IteratorTools](src/moon/tools/IteratorTools.hx) has all the methods from [Seq](src/moon/core/Seq.hx), except that it doesn't defer execution. [TextTools](src/moon/tools/TextTools.hx) is like [Text](src/moon/core/Text.hx), but as a `String` static extension instead of an abstract.

### Web

[Template](src/moon/web/Template.hx) is a compile-time templating system that allows you to write with ASP-like tags using Haxe as the language. Since it's a compile-time system, you get all the type checks from the Haxe compiler, and there's no special parsing at run-time. It works on all targets, even on those without `sys.io.File`.

[Router](src/moon/web/Router.hx) is a general routing class, that can be used as an alternative to `haxe.web.Dispatch`. It's general, and so it has no dependency on `haxe.web.Request`, making it available on all targets. There's an option to use a macro for defining routes using meta annotations on methods.

[Url](src/moon/web/Url.hx) can be used to break up a URL into its individual components. 


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

```haxe
function greet(a:Int, b:String):Generator<Int, String>
{
    for (i in a...10)
    {
        if (i == 5)
            trace("yo" + @yield 999);
        else
            trace(b + @yield i);
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

```haxe
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

```bash
haxe -main AsyncSugaredExamples -cp src -cp test -neko async.n
neko async
```

### How does it Work?

See [ASYNC.md](ASYNC.md)


## Contributing

I need help to iron out some issues related to the async stuff. Contibutions and bug fixes in general are welcomed.

- When using @:build to transform the class, generator methods couldn't really determine the type of certain expressions, leading to some compile errors. Temporary workaround is to annotate such expressions with @void or @expr to indicate if it is a statement or an expression.
- I don't yet know how to deal with try/catch in generator functions.
- Macro functions very unlikely to work within generator functions.
- Generator functions don't yet support array comprehensions, but its do-able, I just haven't gotten around to doing it yet.
- In a switch case, I don't know how to identify which EConst(CIdent(x)) are variable captures.
- It's possible to further optimize the result of transforming the generator function.
    - If you'd like to see the output of the various passes involved in transforming the generator function, open `moon.macros.async.AsyncTransformer.hx` and change `DEBUG_OUTPUT_TO_FILE` to `true`.


## Credits

Most of the lib was written by me, however, some portions of it was ported from other open source codes. Some are not ported, but are adaptations or implementations based on ideas and algorithms from articles and online discussions.


- BigInteger and BigRational `moon.numbers.big` (port)
  Peter Olson: https://github.com/peterolson/BigInteger.js/blob/master/BigInteger.js

- Template `moon.web` (inspired by)
  John Resig: http://ejohn.org/blog/javascript-micro-templating/

- RandomDistributions `moon.numbers.random` (port)
  NumPy developers: https://github.com/numpy/numpy/blob/master/numpy/random/mtrand/distributions.c
  
- Quarternion `moon.numbers.geom` (port)
  Will Perone: http://willperone.net/Code/quaternion.php

- NeuralNetwork `moon.ai.nnet` (port)
  Juan Calaza: https://github.com/cazala/synaptic

- MersenneTwisterRandom `moon.numbers.random.algo` (port)
  Sean Luke: http://www.cs.gmu.edu/~sean/research/mersenne/MersenneTwister.java
  Sean McCullough via Makoto Matsumoto and Takuji Nishimura: https://gist.github.com/banksean/300494
  
- DamerauLevenshtein `moon.strings.metric` (port)
  Kevin L. Stern: https://github.com/KevinStern/software-and-algorithms/blob/master/src/main/java/blogspot/software_and_algorithms/stern_library/string/DamerauLevenshteinAlgorithm.java
  
- Parser `moon.peg.grammar` (reference, ideas)
  Warth, Douglass, Millstein: http://www.vpri.org/pdf/tr2007002_packrat.pdf
  Mark Engelberg: https://github.com/Engelberg/instaparse
  
- Inflect `moon.strings.inflect` (ideas)
  Aura PHP developers: https://github.com/auraphp/Aura.Framework/blob/develop/src/Aura/Framework/Inflect.php
  
 
## License
  
MIT