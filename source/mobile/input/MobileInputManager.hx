package mobile.input;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import haxe.ds.Map;

/**
 * A TouchButton group with functions for input handling
 * @author Karim Akra
 */
class MobileInputManager extends FlxTypedSpriteGroup<TouchButton>
{
	/**
	 * A map to keep track of all the buttons using it's ID
	 */
	public var trackedButtons:Map<MobileInputID, TouchButton> = new Map<MobileInputID, TouchButton>();

	public function new()
	{
		super();
		updateTrackedButtons();
	}

	/**
	 * Check to see if the button was pressed.
	 *
	 * @param	button 	A button ID
	 * @return	Whether at least one of the buttons passed was pressed.
	 */
	public inline function buttonPressed(button:MobileInputID):Bool
	{
		return anyPressed([button]);
	}

	/**
	 * Check to see if the button was just pressed.
	 *
	 * @param	button 	A button ID
	 * @return	Whether at least one of the buttons passed was just pressed.
	 */
	public inline function buttonJustPressed(button:MobileInputID):Bool
	{
		return anyJustPressed([button]);
	}

	/**
	 * Check to see if the button was just released.
	 *
	 * @param	button 	A button ID
	 * @return	Whether at least one of the buttons passed was just released.
	 */
	public inline function buttonJustReleased(button:MobileInputID):Bool
	{
		return anyJustReleased([button]);
	}

	/**
	 * Check to see if the button is released.
	 *
	 * @param	button 	A button ID
	 * @return	Whether at least one of the buttons passed is released.
	 */
	public inline function buttonReleased(button:MobileInputID):Bool
	{
		return anyReleased([button]);
	}

	/**
	 * Check to see if at least one button from an array of buttons is pressed.
	 *
	 * @param	buttonsArray 	An array of buttos names
	 * @return	Whether at least one of the buttons passed in is pressed.
	 */
	public inline function anyPressed(buttonsArray:Array<MobileInputID>):Bool
	{
		return checkButtonArrayState(buttonsArray, PRESSED);
	}

	/**
	 * Check to see if at least one button from an array of buttons was just pressed.
	 *
	 * @param	buttonsArray 	An array of buttons names
	 * @return	Whether at least one of the buttons passed was just pressed.
	 */
	public inline function anyJustPressed(buttonsArray:Array<MobileInputID>):Bool
	{
		return checkButtonArrayState(buttonsArray, JUST_PRESSED);
	}

	/**
	 * Check to see if at least one button from an array of buttons was just released.
	 *
	 * @param	buttonsArray 	An array of button names
	 * @return	Whether at least one of the buttons passed was just released.
	 */
	public inline function anyJustReleased(buttonsArray:Array<MobileInputID>):Bool
	{
		return checkButtonArrayState(buttonsArray, JUST_RELEASED);
	}

	/**
	 * Check to see if at least one button from an array of buttons is released.
	 *
	 * @param	buttonsArray 	An array of button names
	 * @return	Whether at least one of the buttons passed is released.
	 */
	public inline function anyReleased(buttonsArray:Array<MobileInputID>):Bool
	{
		return checkButtonArrayState(buttonsArray, RELEASED);
	}

	/**
	 * Check the status of a single button
	 *
	 * @param	Button		button to be checked.
	 * @param	state		The button state to check for.
	 * @return	Whether the provided key has the specified status.
	 */
	public function checkStatus(button:MobileInputID, state:ButtonsStates = JUST_PRESSED):Bool
	{
		switch (button)
		{
			case MobileInputID.ANY:
				for (button in trackedButtons.keys())
				{
					checkStatusUnsafe(button, state);
				}
			case MobileInputID.NONE:
				return false;

			default:
				if (trackedButtons.exists(button))
					return checkStatusUnsafe(button, state);
		}
		return false;
	}

	/**
	 * Helper function to check the status of an array of buttons
	 *
	 * @param	Buttons	An array of buttons as Strings
	 * @param	state		The button state to check for
	 * @return	Whether at least one of the buttons has the specified status
	 */
	function checkButtonArrayState(Buttons:Array<MobileInputID>, state:ButtonsStates = JUST_PRESSED):Bool
	{
		if (Buttons == null)
			return false;

		for (button in Buttons)
			if (checkStatus(button, state))
				return true;

		return false;
	}

	function checkStatusUnsafe(button:MobileInputID, state:ButtonsStates = JUST_PRESSED):Bool
	{
		return switch (state)
		{
			case RELEASED: trackedButtons.get(button).released;
			case JUST_RELEASED: trackedButtons.get(button).justReleased;
			case PRESSED: trackedButtons.get(button).pressed;
			case JUST_PRESSED: trackedButtons.get(button).justPressed;
		}
	}

	public function updateTrackedButtons()
	{
		trackedButtons.clear();
		forEachExists(function(button:TouchButton)
		{
			if (button.IDs != null)
			{
				for (id in button.IDs)
				{
					if (!trackedButtons.exists(id))
					{
						trackedButtons.set(id, button);
					}
				}
			}
		});
	}
}

enum ButtonsStates
{
	PRESSED;
	JUST_PRESSED;
	RELEASED;
	JUST_RELEASED;
}
