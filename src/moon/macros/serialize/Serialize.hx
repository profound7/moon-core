package moon.macros.serialize;

/**
 * This is a helper macro for serializing classes where you
 * want to ignore certain fields.
 * 
 * This will automatically add the hxSerialize and hxUnserialize
 * methods used by the haxe Serializer when there are fields
 * to ignore.
 * 
 * Usage:
 * 
 * // ignores foo and baz fields when serializing/unserializing
 * @:serializeIgnore(foo, baz)
 * class Whatever implements Serialize
 * {
 *     public var foo:Int;
 *     public var bar:Int;
 *     public var baz:Int;
 * }
 * 
 * @author Munir Hussin
 */
@:autoBuild(moon.macros.serialize.SerializeMacro.build(true))
interface Serialize
{
}