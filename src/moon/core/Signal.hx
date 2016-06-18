package moon.core;

/**
 * ...
 * @author Munir Hussin
 */
#if !macro
@:genericBuild(moon.macros.signal.SignalMacro.build())
class Signal<Rest> {}
#end