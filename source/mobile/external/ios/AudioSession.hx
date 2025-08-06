package mobile.external.ios;

/**
 * A Utility class to manage iOS audio.
 */
@:build(mobile.macros.LinkerMacro.xml('project/Build.xml'))
@:include('AudioSession.hpp')
@:unreflective
extern class AudioSession
{
  @:native('initialize')
  static function initialize():Void;
  @:native('setActive')
  static function setActive(active:Bool):Void;
}
