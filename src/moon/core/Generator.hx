package moon.core;

/**
 * A Generator is a special Iterator that is returned by generator
 * functions. Those are functions that can be resumed after being
 * yielded.
 * 
 * Similar to JavaScript and Python, you can also send a value
 * back into the generator when resuming.
 * 
 * Create generators using moon.macros.async.Async
 * 
 * @author Munir Hussin
 */
typedef Generator<T,V> =
{
    /**
     * Checks if the generator function has completed.
     */
    function hasNext():Bool;
    
    /**
     * Returns the current value and then resumes the generator.
     * If the generator has ended, an AsyncException.FunctionEnded will be thrown.
     * 
     * The signature isn't next(?v:V) like in JavaScript to make a Generator
     * compatible with an Iterator. Use send(v:V) instead to send values
     * back into the generator.
     */
    function next():T;
    
    /**
     * The value to send back to the generator and call next();
     * 
     * Note that Generator<T, Void> will turn into Iterator<T> by the
     * async macro, and would not have the send method.
     */
    function send(v:V):T;
}