package options;

import mobile.objects.TouchZone;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;
import objects.CheckboxThingie;
import objects.AttachedText;
import options.Option;
import backend.InputFormatter;
import mobile.options.MobileOptionsSubState;

class BaseOptionsMenu extends MusicBeatSubstate
{
	private var curOption:Option = null;
	private var curSelected:Int = 0;
	private var curSelectedPartial:Float = 0;
	private var optionsArray:Array<Option>;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	private var grpTexts:FlxTypedGroup<AttachedText>;

	private var descBox:FlxSprite;
	private var descText:FlxText;

	public var title:String;
	public var rpcTitle:String;

	public var bg:FlxSprite;

	public function new()
	{
		controls.isInSubstate = true;

		super();

		if (title == null)
			title = 'Options';
		if (rpcTitle == null)
			rpcTitle = 'Options Menu';

		#if DISCORD_ALLOWED
		DiscordClient.changePresence(rpcTitle, null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		// avoids lagspikes while scrolling through menus!
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

		descBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		descBox.alpha = 0.6;
		add(descBox);

		var titleText:Alphabet = new Alphabet(75, 45, title, true);
		titleText.setScale(0.6);
		titleText.alpha = 0.4;
		add(titleText);

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		for (i in 0...optionsArray.length)
		{
			var optionText:Alphabet = new Alphabet(220, 260, optionsArray[i].name, false);
			optionText.isMenuItem = true;
			/*optionText.forceX = 300;
				optionText.yMult = 90; */
			optionText.targetY = i;
			grpOptions.add(optionText);

			if (optionsArray[i].type == BOOL)
			{
				var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, Std.string(optionsArray[i].getValue()) == 'true');
				checkbox.sprTracker = optionText;
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
			}
			else
			{
				optionText.x -= 80;
				optionText.startPosition.x -= 80;
				// optionText.xAdd -= 80;
				var valueText:AttachedText = new AttachedText('' + optionsArray[i].getValue(), optionText.width + 60);
				valueText.sprTracker = optionText;
				valueText.copyAlpha = true;
				valueText.ID = i;
				grpTexts.add(valueText);
				optionsArray[i].child = valueText;
			}
			// optionText.snapToPosition(); //Don't ignore me when i ask for not making a fucking pull request to uncomment this line ok
			updateTextFrom(optionsArray[i]);
		}

		changeSelection(0, true);
		reloadCheckboxes();

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('LEFT_FULL', 'A_B_C');

		var button = new TouchZone(85, 300, 1070, 100, FlxColor.PURPLE);

		var scroll = new ScrollableObject(-0.008, 100, 0, FlxG.width - 200, FlxG.height, button);
		scroll.onPartialScroll.add(delta -> changeSelection(delta, false));
		// scroll.onFullScroll.add(delta ->
		// {
		// });
		scroll.onFullScrollSnap.add(() -> changeSelection(0, true));
		scroll.onTap.add(() ->
		{
			onAcceptPress();
		});
		add(scroll);
		add(button);
		#end
	}

	public function addOption(option:Option)
	{
		if (optionsArray == null || optionsArray.length < 1)
			optionsArray = [];
		optionsArray.push(option);
		return option;
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	var holdValue:Float = 0;

	var bindingKey:Bool = false;
	var holdingEsc:Float = 0;
	var bindingBlack:FlxSprite;
	var bindingText:Alphabet;
	var bindingText2:Alphabet;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (bindingKey)
		{
			bindingKeyUpdate(elapsed);
			return;
		}

		if (controls.UI_UP_P)
		{
			changeSelection(-1,true);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1,true);
		}

		if (controls.BACK)
		{
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		if (nextAccept <= 0)
		{
			switch (curOption.type)
			{
				case BOOL | KEYBIND:
					if (controls.ACCEPT)
						onAcceptPress();
				default:
					if (controls.UI_LEFT || controls.UI_RIGHT)
					{
						var pressed = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
						if (holdTime > 0.5 || pressed)
						{
							if (pressed)
							{
								var add:Dynamic = null;
								if (curOption.type != STRING)
									add = controls.UI_LEFT ? -curOption.changeValue : curOption.changeValue;

								switch (curOption.type)
								{
									case INT, FLOAT, PERCENT:
										holdValue = curOption.getValue() + add;
										if (holdValue < curOption.minValue)
											holdValue = curOption.minValue;
										else if (holdValue > curOption.maxValue)
											holdValue = curOption.maxValue;

										if (curOption.type == INT)
										{
											holdValue = Math.round(holdValue);
											curOption.setValue(holdValue);
										}
										else
										{
											holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
											curOption.setValue(holdValue);
										}

									case STRING:
										var num:Int = curOption.curOption; // lol
										if (controls.UI_LEFT_P)
											--num;
										else
											num++;

										if (num < 0)
											num = curOption.options.length - 1;
										else if (num >= curOption.options.length)
											num = 0;

										curOption.curOption = num;
										curOption.setValue(curOption.options[num]);
									// trace(curOption.options[num]);

									default:
								}
								updateTextFrom(curOption);
								curOption.change();
								FlxG.sound.play(Paths.sound('scrollMenu'));
							}
							else if (curOption.type != STRING)
							{
								holdValue += curOption.scrollSpeed * elapsed * (controls.UI_LEFT ? -1 : 1);
								if (holdValue < curOption.minValue)
									holdValue = curOption.minValue;
								else if (holdValue > curOption.maxValue)
									holdValue = curOption.maxValue;

								switch (curOption.type)
								{
									case INT:
										curOption.setValue(Math.round(holdValue));

									case PERCENT:
										curOption.setValue(FlxMath.roundDecimal(holdValue, curOption.decimals));

									default:
								}
								updateTextFrom(curOption);
								curOption.change();
							}
						}

						if (curOption.type != STRING)
							holdTime += elapsed;
					}
					else if (controls.UI_LEFT_R || controls.UI_RIGHT_R)
					{
						if (holdTime > 0.5)
							FlxG.sound.play(Paths.sound('scrollMenu'));
						holdTime = 0;
					}
			}

			if (controls.RESET #if TOUCH_CONTROLS_ALLOWED || touchPad.buttonC.justPressed #end)
			{
				var leOption:Option = optionsArray[curSelected];
				if (leOption.type != KEYBIND)
				{
					leOption.setValue(leOption.defaultValue);
					if (leOption.type != BOOL)
					{
						if (leOption.type == STRING)
							leOption.curOption = leOption.options.indexOf(leOption.getValue());
						updateTextFrom(leOption);
					}
				}
				else
				{
					leOption.setValue(!Controls.instance.controllerMode ? leOption.defaultKeys.keyboard : leOption.defaultKeys.gamepad);
					updateBind(leOption);
				}
				leOption.change();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				reloadCheckboxes();
			}
		}

		if (nextAccept > 0)
		{
			nextAccept -= 1;
		}
	}

	function onAcceptPress()
	{
		switch (curOption.type)
		{
			case BOOL:
				FlxG.sound.play(Paths.sound('scrollMenu'));
				curOption.setValue((curOption.getValue() == true) ? false : true);
				curOption.change();
				reloadCheckboxes();

			case KEYBIND:
				bindingBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
				bindingBlack.scale.set(FlxG.width, FlxG.height);
				bindingBlack.updateHitbox();
				bindingBlack.alpha = 0;
				FlxTween.tween(bindingBlack, {alpha: 0.6}, 0.35, {ease: FlxEase.linear});
				add(bindingBlack);

				bindingText = new Alphabet(FlxG.width / 2, 160, Language.getPhrase('controls_rebinding', 'Rebinding {1}', [curOption.name]), false);
				bindingText.alignment = CENTERED;
				add(bindingText);

				final escape:String = (controls.mobileC) ? "B" : "ESC";
				final backspace:String = (controls.mobileC) ? "C" : "Backspace";

				bindingText2 = new Alphabet(FlxG.width / 2, 340,
					Language.getPhrase('controls_rebinding2', 'Hold {1} to Cancel\nHold {2} to Delete', [escape, backspace]), true);
				bindingText2.alignment = CENTERED;
				add(bindingText2);

				bindingKey = true;
				holdingEsc = 0;
				ClientPrefs.toggleVolumeKeys(false);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			default:
				return;
		}
	}

	function bindingKeyUpdate(elapsed:Float)
	{
		if (#if TOUCH_CONTROLS_ALLOWED touchPad.buttonB.pressed || #end FlxG.keys.pressed.ESCAPE || FlxG.gamepads.anyPressed(B))
		{
			holdingEsc += elapsed;
			if (holdingEsc > 0.5)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				closeBinding();
			}
		}
		else if (#if TOUCH_CONTROLS_ALLOWED touchPad.buttonC.pressed || #end FlxG.keys.pressed.BACKSPACE || FlxG.gamepads.anyPressed(BACK))
		{
			holdingEsc += elapsed;
			if (holdingEsc > 0.5)
			{
				if (!controls.controllerMode)
					curOption.keys.keyboard = NONE;
				else
					curOption.keys.gamepad = NONE;
				updateBind(!controls.controllerMode ? InputFormatter.getKeyName(NONE) : InputFormatter.getGamepadName(NONE));
				FlxG.sound.play(Paths.sound('cancelMenu'));
				closeBinding();
			}
		}
		else
		{
			holdingEsc = 0;
			var changed:Bool = false;
			if (!controls.controllerMode)
			{
				if (FlxG.keys.justPressed.ANY || FlxG.keys.justReleased.ANY)
				{
					var keyPressed:FlxKey = cast(FlxG.keys.firstJustPressed(), FlxKey);
					var keyReleased:FlxKey = cast(FlxG.keys.firstJustReleased(), FlxKey);

					if (keyPressed != NONE && keyPressed != ESCAPE && keyPressed != BACKSPACE)
					{
						changed = true;
						curOption.keys.keyboard = keyPressed;
					}
					else if (keyReleased != NONE && (keyReleased == ESCAPE || keyReleased == BACKSPACE))
					{
						changed = true;
						curOption.keys.keyboard = keyReleased;
					}
				}
			}
			else if (FlxG.gamepads.anyJustPressed(ANY)
				|| FlxG.gamepads.anyJustPressed(LEFT_TRIGGER)
				|| FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER)
				|| FlxG.gamepads.anyJustReleased(ANY))
			{
				var keyPressed:FlxGamepadInputID = NONE;
				var keyReleased:FlxGamepadInputID = NONE;
				if (FlxG.gamepads.anyJustPressed(LEFT_TRIGGER))
					keyPressed = LEFT_TRIGGER; // it wasnt working for some reason
				else if (FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER))
					keyPressed = RIGHT_TRIGGER; // it wasnt working for some reason
				else
				{
					for (i in 0...FlxG.gamepads.numActiveGamepads)
					{
						var gamepad:FlxGamepad = FlxG.gamepads.getByID(i);
						if (gamepad != null)
						{
							keyPressed = gamepad.firstJustPressedID();
							keyReleased = gamepad.firstJustReleasedID();
							if (keyPressed != NONE || keyReleased != NONE)
								break;
						}
					}
				}

				if (keyPressed != NONE && keyPressed != FlxGamepadInputID.BACK && keyPressed != FlxGamepadInputID.B)
				{
					changed = true;
					curOption.keys.gamepad = keyPressed;
				}
				else if (keyReleased != NONE && (keyReleased == FlxGamepadInputID.BACK || keyReleased == FlxGamepadInputID.B))
				{
					changed = true;
					curOption.keys.gamepad = keyReleased;
				}
			}

			if (changed)
			{
				var key:String = null;
				if (!controls.controllerMode)
				{
					if (curOption.keys.keyboard == null)
						curOption.keys.keyboard = 'NONE';
					curOption.setValue(curOption.keys.keyboard);
					key = InputFormatter.getKeyName(FlxKey.fromString(curOption.keys.keyboard));
				}
				else
				{
					if (curOption.keys.gamepad == null)
						curOption.keys.gamepad = 'NONE';
					curOption.setValue(curOption.keys.gamepad);
					key = InputFormatter.getGamepadName(FlxGamepadInputID.fromString(curOption.keys.gamepad));
				}
				updateBind(key);
				FlxG.sound.play(Paths.sound('confirmMenu'));
				closeBinding();
			}
		}
	}

	final MAX_KEYBIND_WIDTH = 320;

	function updateBind(?text:String = null, ?option:Option = null)
	{
		if (option == null)
			option = curOption;
		if (text == null)
		{
			text = option.getValue();
			if (text == null)
				text = 'NONE';

			if (!controls.controllerMode)
				text = InputFormatter.getKeyName(FlxKey.fromString(text));
			else
				text = InputFormatter.getGamepadName(FlxGamepadInputID.fromString(text));
		}

		var bind:AttachedText = cast option.child;
		var attach:AttachedText = new AttachedText(text, bind.offsetX);
		attach.sprTracker = bind.sprTracker;
		attach.copyAlpha = true;
		attach.ID = bind.ID;
		playstationCheck(attach);
		attach.scaleX = Math.min(1, MAX_KEYBIND_WIDTH / attach.width);
		attach.x = bind.x;
		attach.y = bind.y;

		option.child = attach;
		grpTexts.insert(grpTexts.members.indexOf(bind), attach);
		grpTexts.remove(bind);
		bind.destroy();
	}

	function playstationCheck(alpha:Alphabet)
	{
		if (!controls.controllerMode)
			return;

		var gamepad:FlxGamepad = FlxG.gamepads.firstActive;
		var model:FlxGamepadModel = gamepad != null ? gamepad.detectedModel : UNKNOWN;
		var letter = alpha.letters[0];
		if (model == PS4)
		{
			switch (alpha.text)
			{
				case '[', ']': // Square and Triangle respectively
					letter.image = 'alphabet_playstation';
					letter.updateHitbox();

					letter.offset.x += 4;
					letter.offset.y -= 5;
			}
		}
	}

	function closeBinding()
	{
		bindingKey = false;
		bindingBlack.destroy();
		remove(bindingBlack);

		bindingText.destroy();
		remove(bindingText);

		bindingText2.destroy();
		remove(bindingText2);
		ClientPrefs.toggleVolumeKeys(true);
	}

	function updateTextFrom(option:Option)
	{
		if (option.type == KEYBIND)
		{
			updateBind(option);
			return;
		}

		var text:String = option.displayFormat;
		var val:Dynamic = option.getValue();
		if (option.type == PERCENT)
			val *= 100;
		var def:Dynamic = option.defaultValue;
		option.text = text.replace('%v', val).replace('%d', def);
	}

	function changeSelection(delta:Float, usePrecision:Bool = false)
	{
		if (usePrecision)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected = FlxMath.wrap(curSelected + Std.int(delta), 0, optionsArray.length - 1);
			curSelectedPartial = curSelected;
		}
		else
		{
			curSelectedPartial = FlxMath.bound(curSelectedPartial + delta, 0, optionsArray.length - 1);
			if(curSelected != Math.round(curSelectedPartial)) FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected = Math.round(curSelectedPartial);
		}
		descText.text = optionsArray[curSelected].description;
		descText.screenCenter(Y);
		descText.y += 270;

		for (num => item in grpOptions.members)
		{
			item.targetY = num - curSelectedPartial;
			item.alpha = 0.6;
			if (num == curSelected)
				item.alpha = 1;
		}
		for (text in grpTexts)
		{
			text.alpha = 0.6;
			if (text.ID == curSelected)
				text.alpha = 1;
		}

		descBox.setPosition(descText.x - 10, descText.y - 10);
		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();

		curOption = optionsArray[curSelected]; // shorter lol
	}

	function reloadCheckboxes()
		for (checkbox in checkboxGroup)
			checkbox.daValue = Std.string(optionsArray[checkbox.ID].getValue()) == 'true'; // Do not take off the Std.string() from this, it will break a thing in Mod Settings Menu
}
