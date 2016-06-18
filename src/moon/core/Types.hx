package moon.core;

/**
 * ...
 * @author Munir Hussin
 */

/**
 * The Unit type has only one possible value, which is Unit.
 * Its used in place of Void where Void can't be used.
 * 
 * For example, Future<Void> will not work, since the onComplete
 * expects (Void)->Void which is different from Void->Void.
 * 
 * Unit is used by FutureProxy<T> where all methods returning
 * T will become Future<T>, and all Void methods become
 * Future<Unit> methods.
 */
enum Unit 
{
    Unit;
}

/**
 * An outcome of something. Either Success (with a value), or
 * a Failure (with an exception).
 */
enum Outcome<V,E>
{
    Success(value:V);
    Failure(error:E);
}

/**
 * A delayed outcome, where the result may not occur immediately.
 */
enum Delayed<V,E>
{
    Awaiting;
    Resolved(o:Outcome<V,E>);
}

/**
 * Static extensions available at moon.tools.CompareTools
 * for methods like equals, notEquals etc...
 * 
 * Sorting arrays require T->T->Int, which is available
 * at moon.core.Compare.
 *      
 *      array.sort(Compare.obj(Asc));
 */
typedef Comparable<T> =
{
    function compareTo(other:T):Int;
}

typedef Equatable<T> =
{
    function equals(other:T):Bool;
}

interface Resolver
{
    public function resolve(args:Array<Dynamic>):String;
}

