package mobile.substates;

import flixel.FlxObject;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxGradient;
import mobile.backend.TouchFunctions;
import flixel.input.touch.FlxTouch;
import flixel.ui.FlxButton as UIButton;

class MobileControlSelectSubState extends MusicBeatSubstate
{
	var options:Array<String> = ['Pad-Right', 'Pad-Left', 'Pad-Custom', 'Hitbox'];
	var control:MobileControls;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var itemText:Alphabet;
	var positionText:FlxText;
	var positionTextBg:FlxSprite;
	var bg:FlxBackdrop;
	var ui:FlxCamera;
	var curOption:Int = MobileData.mode;
	var buttonBinded:Bool = false;
	var bindButton:TouchButton;
	var reset:UIButton;
	var tweenieShit:Float = 0;

	public function new()
	{
		super();
		if (ClientPrefs.data.extraButtons != 'NONE')
			options.push('Pad-Extra');

		bg = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true,
			FlxColor.fromRGB(FlxG.random.int(0, 255), FlxG.random.int(0, 255), FlxG.random.int(0, 255)),
			FlxColor.fromRGB(FlxG.random.int(0, 255), FlxG.random.int(0, 255), FlxG.random.int(0, 255))));
		bg.velocity.set(40, 40);
		bg.alpha = 0;
		bg.antialiasing = ClientPrefs.data.antialiasing;
		FlxTween.tween(bg, {alpha: 0.45}, 0.3, {
			ease: FlxEase.quadOut,
			onComplete: (twn:FlxTween) ->
			{
				FlxTween.tween(ui, {alpha: 1}, 0.2, {ease: FlxEase.circOut});
			}
		});
		add(bg);

		FlxG.mouse.visible = !FlxG.onMobile;

		ui = new FlxCamera();
		ui.bgColor.alpha = 0;
		ui.alpha = 0;
		FlxG.cameras.add(ui, false);

		itemText = new Alphabet(0, 60, '');
		itemText.alignment = LEFT;
		itemText.cameras = [ui];
		add(itemText);

		leftArrow = new FlxSprite(0, itemText.y - 25);
		leftArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		leftArrow.animation.addByPrefix('idle', 'arrow left');
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.cameras = [ui];
		add(leftArrow);

		itemText.x = leftArrow.width + 70;
		leftArrow.x = itemText.x - 60;

		rightArrow = new FlxSprite().loadGraphicFromSprite(leftArrow);
		rightArrow.flipX = true;
		rightArrow.setPosition(itemText.x + itemText.width + 10, itemText.y - 25);
		rightArrow.cameras = [ui];
		add(rightArrow);

		positionText = new FlxText(0, FlxG.height, FlxG.width / 4, '');
		positionText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, FlxTextAlign.LEFT);
		positionText.visible = false;

		positionTextBg = FlxGradient.createGradientFlxSprite(250, 150, [FlxColor.BLACK, FlxColor.BLACK, FlxColor.BLACK, FlxColor.TRANSPARENT], 1, 360);
		positionTextBg.setPosition(0, FlxG.height - positionTextBg.height);
		positionTextBg.visible = false;
		positionTextBg.alpha = 0.8;
		add(positionTextBg);
		positionText.cameras = [ui];
		add(positionText);

		var exit = new UIButton(0, itemText.y - 25, "Exit & Save", () ->
		{
			if (options[curOption].toLowerCase().contains('pad'))
				control.touchPad.setExtrasDefaultPos();
			if (options[curOption] == 'Pad-Extra')
			{
				var nuhuh = new FlxText(0, 0, FlxG.width / 2, 'Pad-Extra Is Just A Binding Option\nPlease Select A Different Option To Exit.');
				nuhuh.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, FlxTextAlign.CENTER);
				nuhuh.screenCenter();
				nuhuh.cameras = [ui];
				add(nuhuh);
				FlxTween.tween(nuhuh, {alpha: 0}, 3.4, {
					ease: FlxEase.circOut,
					onComplete: (twn:FlxTween) ->
					{
						nuhuh.destroy();
						remove(nuhuh);
					}
				});
				return;
			}
			MobileData.mode = curOption;
			if (options[curOption] == 'Pad-Custom')
				MobileData.setTouchPadCustom(control.touchPad);
			controls.isInSubstate = FlxG.mouse.visible = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MobileData.forcedMode = null;
			close();
		});
		exit.color = FlxColor.LIME;
		exit.setGraphicSize(Std.int(exit.width) * 3);
		exit.updateHitbox();
		exit.x = FlxG.width - exit.width - 70;
		exit.label.setFormat(Paths.font('vcr.ttf'), 28, FlxColor.WHITE, FlxTextAlign.CENTER);
		exit.label.fieldWidth = exit.width;
		exit.label.x = ((exit.width - exit.label.width) / 2) + exit.x;
		exit.label.offset.y = -10; // WHY THE FUCK I CAN'T CHANGE THE LABEL Y
		exit.cameras = [ui];
		add(exit);

		reset = new UIButton(exit.x, exit.height + exit.y + 20, "Reset", () ->
		{
			changeOption(0); // realods the current control mode ig?
			FlxG.sound.play(Paths.sound('cancelMenu'));
		});
		reset.color = FlxColor.RED;
		reset.setGraphicSize(Std.int(reset.width) * 3);
		reset.updateHitbox();
		reset.label.setFormat(Paths.font('vcr.ttf'), 28, FlxColor.WHITE, FlxTextAlign.CENTER);
		reset.label.fieldWidth = reset.width;
		reset.label.x = ((reset.width - reset.label.width) / 2) + reset.x;
		reset.label.offset.y = -10;
		reset.cameras = [ui];
		add(reset);

		changeOption(0);
	}

	override function update(elapsed:Float)
	{
		checkArrowButton(leftArrow, () ->
		{
			changeOption(-1);
		});

		checkArrowButton(rightArrow, () ->
		{
			changeOption(1);
		});

		if (options[curOption] == 'Pad-Custom' || options[curOption] == 'Pad-Extra')
		{
			if (buttonBinded)
			{
				if (TouchFunctions.touchJustReleased)
				{
					bindButton = null;
					buttonBinded = false;
				}
				else
					moveButton(TouchFunctions.touch, bindButton);
			}
			else
			{
				control.touchPad.forEachAlive((button:TouchButton) ->
				{
					if (button.justPressed)
						moveButton(TouchFunctions.touch, button);
				});
			}
			control.touchPad.forEachAlive((button:TouchButton) ->
			{
				if (button != bindButton && buttonBinded)
				{
					bindButton.centerBounds();
					button.bounds.immovable = true;
					bindButton.bounds.immovable = false;
					button.centerBounds();
					FlxG.overlap(bindButton.bounds, button.bounds, function(a:Dynamic, b:Dynamic)
					{ // these args dosen't work fuck them :/
						bindButton.centerInBounds();
						button.centerBounds();
						bindButton.bounds.immovable = true;
						button.bounds.immovable = false;
						// trace('button${bindButton.tag} & button${button.tag} collided');
					}, function(a:Dynamic, b:Dynamic)
					{
						if (!bindButton.bounds.immovable)
						{
							if (bindButton.bounds.x > button.bounds.x)
								bindButton.bounds.x = button.bounds.x + button.bounds.width;
							else
								bindButton.bounds.x = button.bounds.x - button.bounds.width;

							if (bindButton.bounds.y > button.bounds.y)
								bindButton.bounds.y = button.bounds.y + button.bounds.height;
							else if (bindButton.bounds.y != button.bounds.y)
								bindButton.bounds.y = button.bounds.y - button.bounds.height;
						}
						return true;
					});
					/*FlxG.collide(bindButton.bounds, button.bounds, function(a:Dynamic, b:Dynamic) { // these args dosen't work fuck them :/
						bindButton.centerInBounds();
						button.centerBounds();
						bindButton.bounds.immovable = true;
						button.bounds.immovable = false;
						trace('button${bindButton.tag} & button${button.tag} collided');
					});*/
				}
			});
		}

		tweenieShit += 180 * elapsed;

		super.update(elapsed);
	}

	function changeControls(?type:Int, ?extraMode:Bool = false)
	{
		if (type == null)
			type = curOption;
		if (control != null)
			control.destroy();
		if (members.contains(control))
			remove(control);
		control = new MobileControls(type, extraMode);
		add(control);
		control.cameras = [ui];
	}

	function changeOption(change:Int)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		curOption += change;

		if (curOption < 0)
			curOption = options.length - 1;
		if (curOption >= options.length)
			curOption = 0;

		switch (curOption)
		{
			case 0 | 1 | 3:
				reset.visible = false;
				changeControls();
			case 2:
				reset.visible = true;
				changeControls();
			case 5:
				reset.visible = true;
				changeControls(0, true);
				control.touchPad.forEachAlive((button:TouchButton) ->
				{
					var ignore = ['G', 'S'];
					if (!ignore.contains(button.tag.toUpperCase()))
						button.visible = button.active = false;
				});
		}
		updatePosText();
		setOptionText();
	}

	function setOptionText()
	{
		itemText.text = options[curOption].replace('-', ' ');
		itemText.updateHitbox();
		itemText.offset.set(0, 15);
		FlxTween.tween(rightArrow, {x: itemText.x + itemText.width + 10}, 0.1, {ease: FlxEase.quintOut});
	}

	function updatePosText()
	{
		var optionName = options[curOption];
		if (optionName == 'Pad-Custom' || optionName == 'Pad-Extra')
		{
			positionText.visible = positionTextBg.visible = true;
			if (optionName == 'Pad-Custom')
			{
				positionText.text = 'LEFT X: ${control.touchPad.buttonLeft.x} - Y: ${control.touchPad.buttonLeft.y}\nDOWN X: ${control.touchPad.buttonDown.x} - Y: ${control.touchPad.buttonDown.y}\n\nUP X: ${control.touchPad.buttonUp.x} - Y: ${control.touchPad.buttonUp.y}\nRIGHT X: ${control.touchPad.buttonRight.x} - Y: ${control.touchPad.buttonRight.y}';
			}
			else
			{
				positionText.text = 'S X: ${control.touchPad.buttonExtra.x} - Y: ${control.touchPad.buttonExtra.y}\n\n\n\nG X: ${control.touchPad.buttonExtra2.x} - Y: ${control.touchPad.buttonExtra2.y}';
			}
			positionText.setPosition(0, (((positionTextBg.height - positionText.height) / 2) + positionTextBg.y));
		}
		else
			positionText.visible = positionTextBg.visible = false;
	}

	function checkArrowButton(button:FlxSprite, func:Void->Void)
	{
		if (TouchFunctions.touchOverlapObject(button))
		{
			if (TouchFunctions.touchPressed)
				button.animation.play('press');
			if (TouchFunctions.touchJustPressed)
			{
				if (options[curOption] == "Pad-Extra" && control.touchPad != null)
					control.touchPad.setExtrasDefaultPos();
				func();
			}
		}
		if (TouchFunctions.touchJustReleased && button.animation.curAnim.name == 'press')
			button.animation.play('idle');
		if (FlxG.keys.justPressed.LEFT && button == leftArrow || FlxG.keys.justPressed.RIGHT && button == rightArrow)
			func();
	}

	function moveButton(touch:FlxTouch, button:TouchButton):Void
	{
		bindButton = button;
		buttonBinded = bindButton == null ? false : true;
		bindButton.x = touch.x - Std.int(bindButton.width / 2);
		bindButton.y = touch.y - Std.int(bindButton.height / 2);
		updatePosText();
	}
}
