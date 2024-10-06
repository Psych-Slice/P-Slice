package mobile.input;

import flixel.system.macros.FlxMacroUtil;

/**
 * A high-level list of unique values for mobile input buttons.
 * Maps enum values and strings to unique integer codes
 * @author Karim Akra
 */
@:runtimeValue
enum abstract MobileInputID(Int) from Int to Int
{
	public static var fromStringMap(default, null):Map<String, MobileInputID> = FlxMacroUtil.buildMap("mobile.input.MobileInputID");
	public static var toStringMap(default, null):Map<MobileInputID, String> = FlxMacroUtil.buildMap("mobile.input.MobileInputID", true);
	// Nothing & Anything
	var ANY = -2;
	var NONE = -1;
	// Notes
	var NOTE_LEFT = 0;
	var NOTE_DOWN = 1;
	var NOTE_UP = 2;
	var NOTE_RIGHT = 3;
	// Touch Pad Buttons
	var A = 4;
	var B = 5;
	var C = 6;
	var D = 7;
	var E = 8;
	var F = 9;
	var G = 10;
	var H = 11;
	var I = 12;
	var J = 13;
	var K = 14;
	var L = 15;
	var M = 16;
	var N = 17;
	var O = 18;
	var P = 19;
	var Q = 20;
	var R = 21;
	var S = 22;
	var T = 23;
	var U = 24;
	var V = 25;
	var W = 26;
	var X = 27;
	var Y = 28;
	var Z = 29;
	// Touch Pad Directional Buttons Buttons
	var UP = 30;
	var UP2 = 31;
	var DOWN = 32;
	var DOWN2 = 33;
	var LEFT = 34;
	var LEFT2 = 35;
	var RIGHT = 36;
	var RIGHT2 = 37;
	// Hitbox Buttons
	var HITBOX_UP = 38;
	var HITBOX_DOWN = 39;
	var HITBOX_LEFT = 40;
	var HITBOX_RIGHT = 41;

	@:from
	public static inline function fromString(s:String)
	{
		s = s.toUpperCase();
		return fromStringMap.exists(s) ? fromStringMap.get(s) : NONE;
	}

	@:to
	public inline function toString():String
	{
		return toStringMap.get(this);
	}
}
