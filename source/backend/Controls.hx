package backend;

import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.mappings.FlxGamepadMapping;
import flixel.input.keyboard.FlxKey;

class Controls
{
	//Keeping same use cases on stuff for it to be easier to understand/use
	//I'd have removed it but this makes it a lot less annoying to use in my opinion

	//You do NOT have to create these variables/getters for adding new keys,
	//but you will instead have to use:
	//   controls.justPressed("ui_up")   instead of   controls.UI_UP

	//Dumb but easily usable code, or Smart but complicated? Your choice.
	//Also idk how to use macros they're weird as fuck lol

	// Pressed buttons (directions)
	public var UI_UP_P(get, never):Bool;
	public var UI_DOWN_P(get, never):Bool;
	public var UI_LEFT_P(get, never):Bool;
	public var UI_RIGHT_P(get, never):Bool;
	public var NOTE_UP_P(get, never):Bool;
	public var NOTE_DOWN_P(get, never):Bool;
	public var NOTE_LEFT_P(get, never):Bool;
	public var NOTE_RIGHT_P(get, never):Bool;
	private function get_UI_UP_P() return justPressed('ui_up');
	private function get_UI_DOWN_P() return justPressed('ui_down');
	private function get_UI_LEFT_P() return justPressed('ui_left');
	private function get_UI_RIGHT_P() return justPressed('ui_right');
	private function get_NOTE_UP_P() return justPressed('note_up');
	private function get_NOTE_DOWN_P() return justPressed('note_down');
	private function get_NOTE_LEFT_P() return justPressed('note_left');
	private function get_NOTE_RIGHT_P() return justPressed('note_right');

	// Held buttons (directions)
	public var UI_UP(get, never):Bool;
	public var UI_DOWN(get, never):Bool;
	public var UI_LEFT(get, never):Bool;
	public var UI_RIGHT(get, never):Bool;
	public var NOTE_UP(get, never):Bool;
	public var NOTE_DOWN(get, never):Bool;
	public var NOTE_LEFT(get, never):Bool;
	public var NOTE_RIGHT(get, never):Bool;
	private function get_UI_UP() return pressed('ui_up');
	private function get_UI_DOWN() return pressed('ui_down');
	private function get_UI_LEFT() return pressed('ui_left');
	private function get_UI_RIGHT() return pressed('ui_right');
	private function get_NOTE_UP() return pressed('note_up');
	private function get_NOTE_DOWN() return pressed('note_down');
	private function get_NOTE_LEFT() return pressed('note_left');
	private function get_NOTE_RIGHT() return pressed('note_right');

	// Released buttons (directions)
	public var UI_UP_R(get, never):Bool;
	public var UI_DOWN_R(get, never):Bool;
	public var UI_LEFT_R(get, never):Bool;
	public var UI_RIGHT_R(get, never):Bool;
	public var NOTE_UP_R(get, never):Bool;
	public var NOTE_DOWN_R(get, never):Bool;
	public var NOTE_LEFT_R(get, never):Bool;
	public var NOTE_RIGHT_R(get, never):Bool;
	private function get_UI_UP_R() return justReleased('ui_up');
	private function get_UI_DOWN_R() return justReleased('ui_down');
	private function get_UI_LEFT_R() return justReleased('ui_left');
	private function get_UI_RIGHT_R() return justReleased('ui_right');
	private function get_NOTE_UP_R() return justReleased('note_up');
	private function get_NOTE_DOWN_R() return justReleased('note_down');
	private function get_NOTE_LEFT_R() return justReleased('note_left');
	private function get_NOTE_RIGHT_R() return justReleased('note_right');


	// Pressed buttons (others)
	public var ACCEPT(get, never):Bool;
	public var FAVORITE(get, never):Bool;
	public var BAR_LEFT(get, never):Bool;
	public var BAR_RIGHT(get, never):Bool;
	public var BACK(get, never):Bool;
	public var PAUSE(get, never):Bool;
	public var SCREENSHOT(get, never):Bool;
	public var RESET(get, never):Bool;
	public var CHAR_SELECT(get, never):Bool;
	private function get_ACCEPT() return justPressed('accept');
	private function get_FAVORITE() return justPressed('favorite');
	private function get_BAR_LEFT() return justPressed('bar_left');
	private function get_BAR_RIGHT() return justPressed('bar_right');
	private function get_BACK() return justPressed('back');
	private function get_PAUSE() return justPressed('pause');
	private function get_SCREENSHOT() return justPressed('screenshot');
	private function get_RESET() return justPressed('reset');
	private function get_CHAR_SELECT() return justPressed('char_select');

	//Gamepad, Keyboard & Mobile stuff
	public var keyboardBinds:Map<String, Array<FlxKey>>;
	public var gamepadBinds:Map<String, Array<FlxGamepadInputID>>;
	#if TOUCH_CONTROLS_ALLOWED
	public var mobileBinds:Map<String, Array<MobileInputID>>;
	#end
	public function justPressed(key:String)
	{
		var result:Bool = (FlxG.keys.anyJustPressed(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result
			|| _myGamepadJustPressed(gamepadBinds[key]) == true
			#if TOUCH_CONTROLS_ALLOWED
			|| hitboxJustPressed(mobileBinds[key]) == true
			|| touchPadJustPressed(mobileBinds[key]) == true #end;
	}

	public function pressed(key:String)
	{
		var result:Bool = (FlxG.keys.anyPressed(keyboardBinds[key]) == true);
		if(result) controllerMode = false; 

		return result
			|| _myGamepadPressed(gamepadBinds[key]) == true
			#if TOUCH_CONTROLS_ALLOWED
			|| hitboxPressed(mobileBinds[key]) == true
			|| touchPadPressed(mobileBinds[key]) == true #end;
	}

	public function justReleased(key:String)
	{
		var result:Bool = (FlxG.keys.anyJustReleased(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result
			|| _myGamepadJustReleased(gamepadBinds[key]) == true
			#if TOUCH_CONTROLS_ALLOWED
			|| hitboxJustReleased(mobileBinds[key]) == true
			|| touchPadJustReleased(mobileBinds[key]) == true #end;
	}

	public var controllerMode:Bool = false;
	private function _myGamepadJustPressed(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyJustPressed(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}
	private function _myGamepadPressed(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyPressed(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}
	private function _myGamepadJustReleased(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyJustReleased(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}

	public var mobileC(get, never):Bool;
	public var isInSubstate:Bool = false; // don't worry about this it becomes true and false on it's own in MusicBeatSubstate
	public var requestedInstance(get, default):Dynamic; // is set to MusicBeatState or MusicBeatSubstate when the constructor is called
	#if TOUCH_CONTROLS_ALLOWED
	public var requestedHitbox(get, default):Hitbox; // for PlayState and EditorPlayState
	
	private function touchPadPressed(keys:Array<MobileInputID>):Bool
	{
		if (keys != null && requestedInstance.touchPad != null)
		{
			if (requestedInstance.touchPad.anyPressed(keys) == true)
			{
				return true;
			}
		}
		return false;
	}

	private function touchPadJustPressed(keys:Array<MobileInputID>):Bool
	{
		if (keys != null && requestedInstance.touchPad != null)
		{
			if (requestedInstance.touchPad.anyJustPressed(keys) == true)
			{
				return true;
			}
		}
		return false;
	}

	private function touchPadJustReleased(keys:Array<MobileInputID>):Bool
	{
		if (keys != null && requestedInstance.touchPad != null)
		{
			if (requestedInstance.touchPad.anyJustReleased(keys) == true)
			{
				return true;
			}
		}
		return false;
	}

	private function hitboxPressed(keys:Array<MobileInputID>):Bool
	{
		if (keys != null && requestedHitbox != null)
		{
			if (requestedHitbox.anyPressed(keys))
			{
				return true;
			}
		}
		return false;
	}

	private function hitboxJustPressed(keys:Array<MobileInputID>):Bool
	{
		if (keys != null && requestedHitbox != null)
		{
			if (requestedHitbox.anyJustPressed(keys))
			{
				return true;
			}
		}
		return false;
	}

	private function hitboxJustReleased(keys:Array<MobileInputID>):Bool
	{
		if (keys != null && requestedHitbox != null)
		{
			if (requestedHitbox.anyJustReleased(keys))
			{
				return true;
			}
		}
		return false;
	}

	@:noCompletion
	private function get_requestedHitbox():Hitbox
	{
		return requestedInstance.hitbox;
	}

	#end

	@:noCompletion
	private function get_requestedInstance():Dynamic
	{
		if (isInSubstate)
			return MusicBeatSubstate.instance;
		else
			return MusicBeatState.getState();
	}

	@:noCompletion
	private function get_mobileC():Bool
	{
		#if TOUCH_CONTROLS_ALLOWED
		if (ClientPrefs.data.controlsAlpha >= 0.1)
			return true;
		else
			return false;
		#else
		return false;
		#end
	}

	// IGNORE THESE/ karim: no.
	public static var instance:Controls;
	public function new()
	{
		keyboardBinds = ClientPrefs.keyBinds;
		gamepadBinds = ClientPrefs.gamepadBinds;
		#if TOUCH_CONTROLS_ALLOWED
		mobileBinds = ClientPrefs.mobileBinds;
		#end
	}
}