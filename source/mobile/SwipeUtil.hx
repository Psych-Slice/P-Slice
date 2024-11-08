package mobile;

import flixel.FlxG;

/**
 * Utility class for handling swipe gestures in HaxeFlixel and dispatching signals for different swipe directions.
 * @author: zacksgamerz (MoonDroid)
 */
class SwipeUtil
{
	public static var swipeDown(get, never):Bool;
	public static var swipeLeft(get, never):Bool;
	public static var swipeRight(get, never):Bool;
	public static var swipeUp(get, never):Bool;
	public static var swipeAny(get, never):Bool;

	@:noCompletion
	static function get_swipeDown():Bool
	{
		for (swipe in FlxG.swipes)
			return (swipe.degrees > -135 && swipe.degrees < -45 && swipe.distance > 20);

		return false;
	}

	@:noCompletion
	static function get_swipeLeft():Bool
	{
		for (swipe in FlxG.swipes)
			return (swipe.degrees > -45 && swipe.degrees < 45 && swipe.distance > 20);

		return false;
	}
	@:noCompletion
	static function get_swipeRight():Bool
	{
		for (swipe in FlxG.swipes)
			return ((swipe.degrees > 135 || swipe.degrees < -135) && swipe.distance > 20);

		return false;
	}

	@:noCompletion
	static function get_swipeUp():Bool
	{
		for (swipe in FlxG.swipes)
			return (swipe.degrees > 45 && swipe.degrees < 135 && swipe.distance > 20);

		return false;
	}

	@:noCompletion
	static function get_swipeAny():Bool
		return swipeDown || swipeLeft || swipeRight || swipeUp;
}