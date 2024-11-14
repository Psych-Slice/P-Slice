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

package mobile.psychlua;

import psychlua.CustomSubstate;
#if LUA_ALLOWED
import lime.ui.Haptic;
import psychlua.FunkinLua;
import psychlua.LuaUtils;
import mobile.backend.TouchUtil;
#if android import mobile.backend.PsychJNI; #end

/**
 * ...
 * @author: Karim Akra and Lily Ross (mcagabe19)
 */
#if TOUCH_CONTROLS_ALLOWED
class MobileFunctions
{
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;
		Lua_helper.add_callback(lua, 'mobileC', Controls.instance.mobileC);

		Lua_helper.add_callback(lua, 'mobileControlsMode', getMobileControlsAsString());

		Lua_helper.add_callback(lua, "extraHintPressed", (button:String) ->
		{
			button = button.toLowerCase();
			if (MusicBeatState.getState().hitbox != null)
			{
				switch (button)
				{
					case 'second':
						return MusicBeatState.getState().hitbox.buttonExtra2.pressed;
					default:
						return MusicBeatState.getState().hitbox.buttonExtra.pressed;
				}
			}
			return false;
		});

		Lua_helper.add_callback(lua, "extraHintJustPressed", (button:String) ->
		{
			button = button.toLowerCase();
			if (MusicBeatState.getState().hitbox != null)
			{
				switch (button)
				{
					case 'second':
						return MusicBeatState.getState().hitbox.buttonExtra2.justPressed;
					default:
						return MusicBeatState.getState().hitbox.buttonExtra.justPressed;
				}
			}
			return false;
		});

		Lua_helper.add_callback(lua, "extraHintJustReleased", (button:String) ->
		{
			button = button.toLowerCase();
			if (MusicBeatState.getState().hitbox != null)
			{
				switch (button)
				{
					case 'second':
						return MusicBeatState.getState().hitbox.buttonExtra2.justReleased;
					default:
						return MusicBeatState.getState().hitbox.buttonExtra.justReleased;
				}
			}
			return false;
		});

		Lua_helper.add_callback(lua, "extraHintReleased", (button:String) ->
		{
			button = button.toLowerCase();
			if (MusicBeatState.getState().hitbox != null)
			{
				switch (button)
				{
					case 'second':
						return MusicBeatState.getState().hitbox.buttonExtra2.released;
					default:
						return MusicBeatState.getState().hitbox.buttonExtra.released;
				}
			}
			return false;
		});

		Lua_helper.add_callback(lua, "vibrate", (?duration:Int, ?period:Int) ->
		{
			if (duration == null)
				return FunkinLua.luaTrace('vibrate: No duration specified.');
			else if (period == null)
				period = 0;
			return Haptic.vibrate(period, duration);
		});

		Lua_helper.add_callback(lua, "addTouchPad", (DPadMode:String, ActionMode:String, ?addToCustomSubstate:Bool = false, ?posAtCustomSubstate:Int = -1) ->
		{
			PlayState.instance.makeLuaTouchPad(DPadMode, ActionMode);
			if (addToCustomSubstate)
			{
				if (PlayState.instance.luaTouchPad != null || !PlayState.instance.members.contains(PlayState.instance.luaTouchPad))
					CustomSubstate.insertLuaTpad(posAtCustomSubstate);
			}
			else
				PlayState.instance.addLuaTouchPad();
		});

		Lua_helper.add_callback(lua, "removeTouchPad", () ->
		{
			PlayState.instance.removeLuaTouchPad();
		});

		Lua_helper.add_callback(lua, "addTouchPadCamera", () ->
		{
			if (PlayState.instance.luaTouchPad == null)
			{
				FunkinLua.luaTrace('addTouchPadCamera: Touch Pad does not exist.');
				return;
			}
			PlayState.instance.addLuaTouchPadCamera();
		});

		Lua_helper.add_callback(lua, "touchPadJustPressed", function(button:Dynamic):Bool
		{
			if (PlayState.instance.luaTouchPad == null)
			{
				return false;
			}
			return PlayState.instance.luaTouchPadJustPressed(button);
		});

		Lua_helper.add_callback(lua, "touchPadPressed", function(button:Dynamic):Bool
		{
			if (PlayState.instance.luaTouchPad == null)
			{
				return false;
			}
			return PlayState.instance.luaTouchPadPressed(button);
		});

		Lua_helper.add_callback(lua, "touchPadJustReleased", function(button:Dynamic):Bool
		{
			if (PlayState.instance.luaTouchPad == null)
			{
				return false;
			}
			return PlayState.instance.luaTouchPadJustReleased(button);
		});

		Lua_helper.add_callback(lua, "touchPadReleased", function(button:Dynamic):Bool
		{
			if (PlayState.instance.luaTouchPad == null)
			{
				return false;
			}
			return PlayState.instance.luaTouchPadReleased(button);
		});

		Lua_helper.add_callback(lua, "touchJustPressed", TouchUtil.justPressed);
		Lua_helper.add_callback(lua, "touchPressed", TouchUtil.pressed);
		Lua_helper.add_callback(lua, "touchJustReleased", TouchUtil.justReleased);
		Lua_helper.add_callback(lua, "touchReleased", TouchUtil.released);
		Lua_helper.add_callback(lua, "touchPressedObject", function(object:String, ?camera:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchPressedObject: $object does not exist.');
				return false;
			}
			return TouchUtil.overlaps(obj, cam) && TouchUtil.pressed;
		});

		Lua_helper.add_callback(lua, "touchJustPressedObject", function(object:String, ?camera:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchJustPressedObject: $object does not exist.');
				return false;
			}
			return TouchUtil.overlaps(obj, cam) && TouchUtil.justPressed;
		});

		Lua_helper.add_callback(lua, "touchJustReleasedObject", function(object:String, ?camera:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchJustReleasedObject: $object does not exist.');
				return false;
			}
			return TouchUtil.overlaps(obj, cam) && TouchUtil.justReleased;
		});

		Lua_helper.add_callback(lua, "touchReleasedObject", function(object:String, ?camera:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchReleasedObject: $object does not exist.');
				return false;
			}
			return TouchUtil.overlaps(obj, cam) && TouchUtil.released;
		});

		Lua_helper.add_callback(lua, "touchPressedObjectComplex", function(object:String, ?camera:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchPressedObjectComplex: $object does not exist.');
				return false;
			}
			return TouchUtil.overlapsComplex(obj, cam) && TouchUtil.pressed;
		});

		Lua_helper.add_callback(lua, "touchJustPressedObjectComplex", function(object:String, ?camera:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchJustPressedObjectComplex: $object does not exist.');
				return false;
			}
			return TouchUtil.overlapsComplex(obj, cam) && TouchUtil.justPressed;
		});

		Lua_helper.add_callback(lua, "touchJustReleasedObjectComplex", function(object:String, ?camera:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchJustReleasedObjectComplex: $object does not exist.');
				return false;
			}
			return TouchUtil.overlapsComplex(obj, cam) && TouchUtil.justReleased;
		});

		Lua_helper.add_callback(lua, "touchReleasedObjectComplex", function(object:String, ?camera:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchReleasedObjectComplex: $object does not exist.');
				return false;
			}
			return TouchUtil.overlapsComplex(obj, cam) && TouchUtil.released;
		});

		Lua_helper.add_callback(lua, "touchOverlapsObject", function(object:String, ?camera:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchOverlapsObject: $object does not exist.');
				return false;
			}
			return TouchUtil.overlaps(obj, cam);
		});

		Lua_helper.add_callback(lua, "touchOverlapsObjectComplex", function(object:String, ?camera:String):Bool
		{
			var obj = PlayState.instance.getLuaObject(object);
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			if (obj == null)
			{
				FunkinLua.luaTrace('touchOverlapsObjectComplex: $object does not exist.');
				return false;
			}
			return TouchUtil.overlapsComplex(obj, cam);
		});
	}

	public static function getMobileControlsAsString():String
		return 'hitbox';
}

class MobileDeprecatedFunctions
{
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;
		Lua_helper.add_callback(lua, "extraButtonPressed", (button:String) ->
		{
			FunkinLua.luaTrace("extraButtonPressed is deprecated! Use extraHintPressed instead", false, true);
			button = button.toLowerCase();
			if (MusicBeatState.getState().hitbox != null)
			{
				switch (button)
				{
					case 'second':
						return MusicBeatState.getState().hitbox.buttonExtra2.pressed;
					default:
						return MusicBeatState.getState().hitbox.buttonExtra.pressed;
				}
			}
			return false;
		});

		Lua_helper.add_callback(lua, "extraButtonJustPressed", (button:String) ->
		{
			FunkinLua.luaTrace("extraButtonJustPressed is deprecated! Use extraHintJustPressed instead", false, true);
			button = button.toLowerCase();
			if (MusicBeatState.getState().hitbox != null)
			{
				switch (button)
				{
					case 'second':
						return MusicBeatState.getState().hitbox.buttonExtra2.justPressed;
					default:
						return MusicBeatState.getState().hitbox.buttonExtra.justPressed;
				}
			}
			return false;
		});

		Lua_helper.add_callback(lua, "extraButtonJustReleased", (button:String) ->
		{
			FunkinLua.luaTrace("extraButtonJustReleased is deprecated! Use extraHintJustReleased instead", false, true);
			button = button.toLowerCase();
			if (MusicBeatState.getState().hitbox != null)
			{
				switch (button)
				{
					case 'second':
						return MusicBeatState.getState().hitbox.buttonExtra2.justReleased;
					default:
						return MusicBeatState.getState().hitbox.buttonExtra.justReleased;
				}
			}
			return false;
		});

		Lua_helper.add_callback(lua, "extraButtonReleased", (button:String) ->
		{
			FunkinLua.luaTrace("extraButtonReleased is deprecated! Use extraHintReleased instead", false, true);
			button = button.toLowerCase();
			if (MusicBeatState.getState().hitbox != null)
			{
				switch (button)
				{
					case 'second':
						return MusicBeatState.getState().hitbox.buttonExtra2.released;
					default:
						return MusicBeatState.getState().hitbox.buttonExtra.released;
				}
			}
			return false;
		});
	}
}
#end

#if android
class AndroidFunctions
{
	// static var spicyPillow:AndroidBatteryManager = new AndroidBatteryManager();
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;
		// Lua_helper.add_callback(lua, "isRooted", AndroidTools.isRooted());
		Lua_helper.add_callback(lua, "isDolbyAtmos", AndroidTools.isDolbyAtmos());
		Lua_helper.add_callback(lua, "isAndroidTV", AndroidTools.isAndroidTV());
		Lua_helper.add_callback(lua, "isTablet", AndroidTools.isTablet());
		Lua_helper.add_callback(lua, "isChromebook", AndroidTools.isChromebook());
		Lua_helper.add_callback(lua, "isDeXMode", AndroidTools.isDeXMode());
		// Lua_helper.add_callback(lua, "isCharging", spicyPillow.isCharging());

		Lua_helper.add_callback(lua, "backJustPressed", FlxG.android.justPressed.BACK);
		Lua_helper.add_callback(lua, "backPressed", FlxG.android.pressed.BACK);
		Lua_helper.add_callback(lua, "backJustReleased", FlxG.android.justReleased.BACK);

		Lua_helper.add_callback(lua, "menuJustPressed", FlxG.android.justPressed.MENU);
		Lua_helper.add_callback(lua, "menuPressed", FlxG.android.pressed.MENU);
		Lua_helper.add_callback(lua, "menuJustReleased", FlxG.android.justReleased.MENU);

		Lua_helper.add_callback(lua, "getCurrentOrientation", () -> PsychJNI.getCurrentOrientationAsString());
		Lua_helper.add_callback(lua, "setOrientation", function(?hint:String):Void
		{
			switch (hint.toLowerCase())
			{
				case 'portrait':
					hint = 'Portrait';
				case 'portraitupsidedown' | 'upsidedownportrait' | 'upsidedown':
					hint = 'PortraitUpsideDown';
				case 'landscapeleft' | 'leftlandscape':
					hint = 'LandscapeLeft';
				case 'landscaperight' | 'rightlandscape' | 'landscape':
					hint = 'LandscapeRight';
				default:
					hint = null;
			}
			if (hint == null)
				return FunkinLua.luaTrace('setOrientation: No orientation specified.');
			PsychJNI.setOrientation(FlxG.stage.stageWidth, FlxG.stage.stageHeight, false, hint);
		});

		Lua_helper.add_callback(lua, "minimizeWindow", () -> AndroidTools.minimizeWindow());

		Lua_helper.add_callback(lua, "showToast", function(text:String, ?duration:Int, ?xOffset:Int, ?yOffset:Int) /* , ?gravity:Int*/
		{
			if (text == null)
				return FunkinLua.luaTrace('showToast: No text specified.');
			else if (duration == null)
				return FunkinLua.luaTrace('showToast: No duration specified.');

			if (xOffset == null)
				xOffset = 0;
			if (yOffset == null)
				yOffset = 0;

			AndroidToast.makeText(text, duration, -1, xOffset, yOffset);
		});

		Lua_helper.add_callback(lua, "isScreenKeyboardShown", () -> PsychJNI.isScreenKeyboardShown());

		Lua_helper.add_callback(lua, "clipboardHasText", () -> PsychJNI.clipboardHasText());
		Lua_helper.add_callback(lua, "clipboardGetText", () -> PsychJNI.clipboardGetText());
		Lua_helper.add_callback(lua, "clipboardSetText", function(?text:String):Void
		{
			if (text != null)
				return FunkinLua.luaTrace('clipboardSetText: No text specified.');
			PsychJNI.clipboardSetText(text);
		});

		Lua_helper.add_callback(lua, "manualBackButton", () -> PsychJNI.manualBackButton());

		Lua_helper.add_callback(lua, "setActivityTitle", function(text:String):Void
		{
			if (text != null)
				return FunkinLua.luaTrace('setActivityTitle: No text specified.');
			PsychJNI.setActivityTitle(text);
		});
	}
}
#end
#end
