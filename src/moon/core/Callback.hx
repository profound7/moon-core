package moon.core;

import haxe.Constraints.Function;

// custom callbacks
typedef Callback0 = Void->Void;
typedef Callback1<A> = A->Void;
typedef Callback2<A,B> = A->B->Void;
typedef Callback3<A,B,C> = A->B->C->Void;
typedef Callback4<A,B,C,D> = A->B->C->D->Void;
typedef Callback5<A,B,C,D,E> = A->B->C->D->E->Void;
typedef Callback6<A,B,C,D,E,F> = A->B->C->D->E->F->Void;
typedef Callback7<A,B,C,D,E,F,G> = A->B->C->D->E->F->G->Void;
typedef Callback8<A,B,C,D,E,F,G,H> = A->B->C->D->E-> F->G->H->Void;

/**
 * Callbacks are used for async operations.
 * 
 * The callback function signature is as follows:
 * 
 *      function<T>(error:Error, success:T):Void
 * 
 * The first argument is always the error, or null if there's no error.
 * The second argument can be any data type, and is used to indicate
 * success or the async call return values.
 * 
 * For Callback<T>, you can turn it into a function that
 * returns a Future<T> by using the CallbackTools.
 * 
 * NOTE:
 * See moon.tools.CallbackTools to convert functions with callback as the
 * last argument to
 * Perhaps provide wrapper to turn custom callbacks into futures as well?
 * Example, Callback3<A,B,C> into Future<Tuple<A,B,C>>
 * 
 * @author Munir Hussin
 */
typedef Callback<T> = Callback2<Error, T>;