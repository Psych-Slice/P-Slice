package mobile;

import flixel.FlxObject;
import flixel.input.touch.FlxTouch;

/**
 * ...
 * @author: Karim Akra
 */
class TouchUtil
{
	public static var pressed(get, never):Bool;
	public static var justPressed(get, never):Bool;
	public static var justReleased(get, never):Bool;
	public static var released(get, never):Bool;
	public static var touch(get, never):FlxTouch;

	public static function overlaps(object:FlxObject, ?camera:FlxCamera):Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.overlaps(object, camera ?? object.camera))
				return true;

		return false;
	}

	public static function overlapsComplex(object:FlxObject, ?camera:FlxCamera):Bool
	{
		if (camera == null)
			for (camera in object.cameras)
				for (touch in FlxG.touches.list)
					@:privateAccess
					if (object.overlapsPoint(touch.getWorldPosition(camera, object._point), true, camera))
						return true;
		else
			@:privateAccess
			if (object.overlapsPoint(touch.getWorldPosition(camera, object._point), true, camera))
				return true;

		return false;
	}

	@:noCompletion
	private static function get_pressed():Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.pressed)
				return true;

		return false;
	}

	@:noCompletion
	private static function get_justPressed():Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.justPressed)
				return true;

		return false;
	}

	@:noCompletion
	private static function get_justReleased():Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.justReleased)
				return true;

		return false;
	}

	@:noCompletion
	private static function get_released():Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.released)
				return true;

		return false;
	}

	@:noCompletion
	private static function get_touch():FlxTouch
	{
		for (touch in FlxG.touches.list)
			if (touch != null)
				return touch;

		return FlxG.touches.getFirst();
	}
}