/*
 * Copyright (C) 2024 Mobile Porting Team
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package mobile.backend;

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