package states.editors.boxes;

import flixel.addons.display.FlxGridOverlay;
import objects.Character.AnimArray;
import psychlua.ModchartSprite;
import flixel.FlxObject;
import states.editors.StageEditorState.StageEditorMetaSprite;
import flixel.addons.display.FlxBackdrop;

class StageEditorAnimationSubstate extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var originalZoom:Float;
	var originalCamPoint:FlxPoint;
	var originalPosition:FlxPoint;
	var originalCamTarget:FlxObject;
	var originalAlpha:Float = 1;

	public var target:StageEditorMetaSprite;

	var curAnim:Int = 0;
	var animsTxtGroup:FlxTypedGroup<FlxText>;

	var UI_animationbox:PsychUIBox;
	var camHUD:FlxCamera = cast(FlxG.state, StageEditorState).camHUD;

	public function new()
	{
		super();

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(50, 50, 100, 100, true, 0xFFAAAAAA, 0xFF666666));
		add(grid);

		animsTxtGroup = new FlxTypedGroup<FlxText>();
		animsTxtGroup.cameras = [camHUD];
		add(animsTxtGroup);

		UI_animationbox = new PsychUIBox(FlxG.width - 320, 20, 300, 250, ['Animations']);
		UI_animationbox.cameras = [camHUD];
		UI_animationbox.scrollFactor.set();
		add(UI_animationbox);
		addAnimationsUI();

		openCallback = function()
		{
			curAnim = 0;
			originalZoom = FlxG.camera.zoom;
			originalCamPoint = FlxPoint.weak(FlxG.camera.scroll.x, FlxG.camera.scroll.y);
			originalPosition = FlxPoint.weak(target.x, target.y);
			originalCamTarget = FlxG.camera.target;
			originalAlpha = target.alpha;
			FlxG.camera.zoom = 0.5;
			FlxG.camera.scroll.set(0, 0);

			target.alpha = 1;
			target.sprite.screenCenter();
			add(target.sprite);
			reloadAnimList();
			trace('Opened substate');
		};

		closeCallback = function()
		{
			FlxG.camera.zoom = originalZoom;
			FlxG.camera.scroll.set(originalCamPoint.x, originalCamPoint.y);
			FlxG.camera.target = originalCamTarget;

			target.x = originalPosition.x;
			target.y = originalPosition.y;
			target.alpha = originalAlpha;
			remove(target.sprite);

			if (target.animations.length > 0)
			{
				if (target.firstAnimation == null)
					target.firstAnimation = target.animations[0].anim;
				playAnim(target.firstAnimation);
			}
		};
	}

	var animationDropDown:PsychUIDropDownMenu;
	var animationInputText:PsychUIInputText;
	var animationNameInputText:PsychUIInputText;
	var animationIndicesInputText:PsychUIInputText;
	var animationFramerate:PsychUINumericStepper;
	var animationLoopCheckBox:PsychUICheckBox;
	var mainAnimTxt:FlxText;

	function addAnimationsUI()
	{
		var tab_group = UI_animationbox.getTab('Animations').menu;

		animationInputText = new PsychUIInputText(15, 85, 80, '', 8);
		animationNameInputText = new PsychUIInputText(animationInputText.x, animationInputText.y + 35, 150, '', 8);
		animationIndicesInputText = new PsychUIInputText(animationNameInputText.x, animationNameInputText.y + 40, 250, '', 8);
		animationFramerate = new PsychUINumericStepper(animationInputText.x + 170, animationInputText.y, 1, 24, 0, 240, 0);
		animationLoopCheckBox = new PsychUICheckBox(animationNameInputText.x + 170, animationNameInputText.y - 1, 'Should it Loop?', 100);

		animationDropDown = new PsychUIDropDownMenu(15, animationInputText.y - 55, [''], function(selectedAnimation:Int, pressed:String)
		{
			var anim:AnimArray = target.animations[selectedAnimation];
			if (anim == null)
				return;

			animationInputText.text = anim.anim;
			animationNameInputText.text = anim.name;
			animationLoopCheckBox.checked = anim.loop;
			animationFramerate.value = anim.fps;

			var indicesStr:String = anim.indices.toString();
			animationIndicesInputText.text = indicesStr.substr(1, indicesStr.length - 2);
		});

		mainAnimTxt = new FlxText(160, animationDropDown.y - 18, 0, 'Main Anim.: ');
		var initAnimButton:PsychUIButton = new PsychUIButton(160, animationDropDown.y, 'Main Animation', function()
		{
			var anim:AnimArray = target.animations[curAnim];
			if (anim == null)
				return;

			mainAnimTxt.text = 'Main Anim.: ${anim.anim}';
			target.firstAnimation = anim.anim;
		});
		tab_group.add(mainAnimTxt);
		tab_group.add(initAnimButton);

		var addUpdateButton:PsychUIButton = new PsychUIButton(40, animationIndicesInputText.y + 35, 'Add/Update', function()
		{
			if (animationInputText.text == '')
				return;

			var indices:Array<Int> = [];
			var indicesStr:Array<String> = animationIndicesInputText.text.trim().split(',');
			if (indicesStr.length > 1)
			{
				for (i in 0...indicesStr.length)
				{
					var index:Int = Std.parseInt(indicesStr[i]);
					if (indicesStr[i] != null && indicesStr[i] != '' && !Math.isNaN(index) && index > -1)
					{
						indices.push(index);
					}
				}
			}

			var lastAnim:String = (target.animations[curAnim] != null) ? target.animations[curAnim].anim : '';
			var lastOffsets:Array<Int> = null;
			for (anim in target.animations)
				if (animationInputText.text == anim.anim)
				{
					lastOffsets = anim.offsets;
					cast(target.sprite, ModchartSprite).animOffsets.remove(animationInputText.text);
					target.sprite.animation.remove(animationInputText.text);
					target.animations.remove(anim);
				}

			var addedAnim:AnimArray = {
				anim: animationInputText.text,
				name: animationNameInputText.text,
				fps: Math.round(animationFramerate.value),
				loop: animationLoopCheckBox.checked,
				indices: indices,
				offsets: lastOffsets
			};

			if (addedAnim.indices != null && addedAnim.indices.length > 0)
				target.sprite.animation.addByIndices(addedAnim.anim, addedAnim.name, addedAnim.indices, '', addedAnim.fps, addedAnim.loop);
			else
				target.sprite.animation.addByPrefix(addedAnim.anim, addedAnim.name, addedAnim.fps, addedAnim.loop);

			target.animations.push(addedAnim);
			reloadAnimList();
			playAnim(addedAnim.anim, true);

			curAnim = target.animations.length - 1;
			updateTextColors();
			trace('Added/Updated animation: ' + animationInputText.text);
		});

		var removeButton:PsychUIButton = new PsychUIButton(160, animationIndicesInputText.y + 35, 'Remove', function()
		{
			for (anim in target.animations)
			{
				if (animationInputText.text == anim.anim)
				{
					var targetSprite:ModchartSprite = cast(target.sprite, ModchartSprite);
					var resetAnim:Bool = false;
					if (targetSprite.animation.curAnim != null && anim.anim == targetSprite.animation.curAnim.name)
						resetAnim = true;

					if (targetSprite.animOffsets.exists(anim.anim))
						targetSprite.animOffsets.remove(anim.anim);

					target.animations.remove(anim);
					targetSprite.animation.remove(anim.anim);

					if (resetAnim && target.animations.length > 0)
					{
						curAnim = FlxMath.wrap(curAnim, 0, target.animations.length - 1);
						playAnim(target.animations[curAnim].anim, true);
						updateTextColors();
					}
					else if (target.animations.length < 1)
						target.sprite.animation.curAnim = null;

					trace('Removed animation: ' + animationInputText.text);
					reloadAnimList();
					break;
				}
			}
		});

		tab_group.add(new FlxText(animationDropDown.x, animationDropDown.y - 18, 0, 'Animations:'));
		tab_group.add(new FlxText(animationInputText.x, animationInputText.y - 18, 0, 'Animation name:'));
		tab_group.add(new FlxText(animationFramerate.x, animationFramerate.y - 18, 0, 'Framerate:'));
		tab_group.add(new FlxText(animationNameInputText.x, animationNameInputText.y - 18, 0, 'Animation Symbol Name/Tag:'));
		tab_group.add(new FlxText(animationIndicesInputText.x, animationIndicesInputText.y - 18, 0, 'ADVANCED - Animation Indices:'));

		tab_group.add(animationInputText);
		tab_group.add(animationNameInputText);
		tab_group.add(animationIndicesInputText);
		tab_group.add(animationFramerate);
		tab_group.add(animationLoopCheckBox);
		tab_group.add(addUpdateButton);
		tab_group.add(removeButton);
		tab_group.add(animationDropDown);
	}

	function reloadAnimList()
	{
		if (target.animations == null)
			target.animations = [];
		else if (target.animations.length > 0)
			playAnim(target.animations[0].anim, true);
		curAnim = 0;

		for (text in animsTxtGroup)
			text.kill();

		var spr:ModchartSprite = cast(target.sprite, ModchartSprite);
		if (target.animations.length > 0)
		{
			if (target.firstAnimation == null || !target.sprite.animation.exists(target.firstAnimation))
				target.firstAnimation = target.animations[0].anim;

			mainAnimTxt.text = 'Main Anim.: ${target.firstAnimation}';
		}
		else
		{
			target.firstAnimation = null;
			mainAnimTxt.text = '(No Main Animation)';
		}

		for (num => anim in target.animations)
		{
			var text:FlxText = animsTxtGroup.recycle(FlxText);
			text.x = 10;
			text.y = 32 + (20 * num);
			text.fieldWidth = 400;
			text.fieldHeight = 20;
			if (anim.offsets != null)
				text.text = '${anim.anim}: ${spr.animOffsets.get(anim.anim)}';
			else
				text.text = '${anim.anim}: No offsets';

			text.setFormat(null, 16, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.BLACK);
			text.scrollFactor.set();
			text.borderSize = 1;
			animsTxtGroup.add(text);
		}
		updateTextColors();
		reloadAnimationDropDown();
	}

	function reloadAnimationDropDown()
	{
		var animList:Array<String> = [];
		for (anim in target.animations)
			animList.push(anim.anim);
		if (animList.length < 1)
			animList.push('NO ANIMATIONS'); // Prevents crash

		animationDropDown.list = animList;
	}

	inline function updateTextColors()
	{
		for (num => text in animsTxtGroup)
		{
			text.color = FlxColor.WHITE;
			if (num == curAnim)
				text.color = FlxColor.LIME;
		}
	}

	function playAnim(name:String, force:Bool = false)
	{
		var spr:ModchartSprite = cast(target.sprite, ModchartSprite);
		spr.playAnim(name, force);
		if (!spr.animOffsets.exists(name))
			spr.updateHitbox();
	}

	final minZoom = 0.25;
	final maxZoom = 2;
	var holdingArrowsTime:Float = 0;
	var holdingArrowsElapsed:Float = 0;
	var holdingFrameTime:Float = 0;
	var holdingFrameElapsed:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		// ? pulling key presses

		var pressed_I = FlxG.keys.pressed.I;
		var pressed_J = FlxG.keys.pressed.J;
		var pressed_K = FlxG.keys.pressed.K;
		var pressed_L = FlxG.keys.pressed.L;

		var justPressed_W = FlxG.keys.justPressed.W;
		var justPressed_S = FlxG.keys.justPressed.S;
		var justPressed_R = FlxG.keys.justPressed.R;

		var pressed_E = FlxG.keys.pressed.E;
		var pressed_Q = FlxG.keys.pressed.Q;

		var pressed_SHIFT = FlxG.keys.pressed.SHIFT;
		#if TOUCH_CONTROLS_ALLOWED
		pressed_I = pressed_I || touchPad.buttonG.pressed && touchPad.buttonUp.pressed;
		pressed_J = pressed_J || touchPad.buttonG.pressed && touchPad.buttonLeft.pressed;
		pressed_K = pressed_K || touchPad.buttonG.pressed && touchPad.buttonDown.pressed;
		pressed_L = pressed_L || touchPad.buttonG.pressed && touchPad.buttonRight.pressed;

		justPressed_W = justPressed_W || touchPad.buttonUp.justPressed;
		justPressed_S = justPressed_S || touchPad.buttonDown.justPressed;
		justPressed_R = justPressed_R || touchPad.buttonZ.justPressed;

		pressed_E = pressed_E || touchPad.buttonX.pressed; 
		pressed_Q = pressed_Q || touchPad.buttonY.pressed;

		pressed_SHIFT = pressed_SHIFT || touchPad.buttonC.pressed;
		#end

		if (PsychUIInputText.focusOn != null)
			return;

		// ANIMATION SCROLLING
		if (target.animations.length > 1)
		{
			var changedAnim:Bool = false;
			if (justPressed_W && (changedAnim = true))
				curAnim--;
			else if (justPressed_S && (changedAnim = true))
				curAnim++;
			else if (FlxG.keys.justPressed.SPACE)
				changedAnim = true;

			if (changedAnim)
			{
				curAnim = FlxMath.wrap(curAnim, 0, target.animations.length - 1);
				playAnim(target.animations[curAnim].anim, true);
				updateTextColors();
			}
		}

		var shiftMult:Float = 1;
		var ctrlMult:Float = 1;
		var shiftMultBig:Float = 1;
		if (pressed_SHIFT)
		{
			shiftMult = 4;
			shiftMultBig = 10;
		}
		if (FlxG.keys.pressed.CONTROL)
			ctrlMult = 0.25;

		// OFFSET
		if (target.sprite.animation.curAnim != null)
		{
			var spr:ModchartSprite = cast(target.sprite, ModchartSprite);
			var anim:String = spr.animation.curAnim.name;
			var changedOffset = false;
			var not_G_pressed = true;
			var moveKeysP = [
				FlxG.keys.justPressed.LEFT,
				FlxG.keys.justPressed.RIGHT,
				FlxG.keys.justPressed.UP,
				FlxG.keys.justPressed.DOWN
			];
			var moveKeys = [
				FlxG.keys.pressed.LEFT,
				FlxG.keys.pressed.RIGHT,
				FlxG.keys.pressed.UP,
				FlxG.keys.pressed.DOWN
			];
			#if TOUCH_CONTROLS_ALLOWED
			if (controls.mobileC)
			{
				moveKeysP = [
					touchPad.buttonLeft.justPressed,
					touchPad.buttonRight.justPressed,
					touchPad.buttonUp.justPressed,
					touchPad.buttonDown.justPressed
				];
				moveKeys = [
					touchPad.buttonLeft.pressed,
					touchPad.buttonRight.pressed,
					touchPad.buttonUp.pressed,
					touchPad.buttonDown.pressed
				];
				not_G_pressed = !touchPad.buttonG.pressed;
			}
			#end
			if (moveKeysP.contains(true) && not_G_pressed)
			{
				if (spr.animOffsets.get(anim) != null)
				{
					spr.offset.x += ((moveKeysP[0] ? 1 : 0) - (moveKeysP[1] ? 1 : 0)) * shiftMultBig;
					spr.offset.y += ((moveKeysP[2] ? 1 : 0) - (moveKeysP[3] ? 1 : 0)) * shiftMultBig;
				}
				else
					spr.offset.x = spr.offset.y = 0;
				changedOffset = true;
			}

			if (moveKeys.contains(true) && not_G_pressed)
			{
				holdingArrowsTime += elapsed;
				if (holdingArrowsTime > 0.6)
				{
					holdingArrowsElapsed += elapsed;
					while (holdingArrowsElapsed > (1 / 60))
					{
						if (spr.animOffsets.get(anim) != null)
						{
							spr.offset.x += ((moveKeys[0] ? 1 : 0) - (moveKeys[1] ? 1 : 0)) * shiftMultBig;
							spr.offset.y += ((moveKeys[2] ? 1 : 0) - (moveKeys[3] ? 1 : 0)) * shiftMultBig;
						}
						else
							spr.offset.x = spr.offset.y = 0;
						holdingArrowsElapsed -= (1 / 60);
						changedOffset = true;
					}
				}
			}
			else
				holdingArrowsTime = 0;

			if (FlxG.mouse.pressedRight && (FlxG.mouse.deltaScreenX != 0 || FlxG.mouse.deltaScreenY != 0))
			{
				spr.offset.x -= FlxG.mouse.deltaScreenX;
				spr.offset.y -= FlxG.mouse.deltaScreenY;
				changedOffset = true;
			}

			if ((FlxG.keys.justPressed.R  && FlxG.keys.pressed.CONTROL) #if TOUCH_CONTROLS_ALLOWED || (touchPad.buttonZ.justPressed && touchPad.buttonC.pressed) #end)
			{
				target.animations[curAnim].offsets = null;
				spr.animOffsets.remove(anim);
				spr.updateHitbox();
				animsTxtGroup.members[curAnim].text = '${anim}: No offsets';
			}

			if (changedOffset)
			{
				var offX = Math.round(spr.offset.x);
				var offY = Math.round(spr.offset.y);

				spr.addOffset(anim, offX, offY);
				target.animations[curAnim].offsets = [offX, offY];
				animsTxtGroup.members[curAnim].text = '${anim}: ${spr.animOffsets.get(anim)}';
			}
		}
		else
		{
			holdingArrowsTime = 0;
			holdingArrowsElapsed = 0;
		}

		// CAMERA CONTROLS
		var camX:Float = 0;
		var camY:Float = 0;
		var camMove:Float = elapsed * 500 * shiftMult * ctrlMult;
		if (pressed_J)
			camX -= camMove;
		if (pressed_K)
			camY += camMove;
		if (pressed_L)
			camX += camMove;
		if (pressed_I)
			camY -= camMove;

		if (camX != 0 || camY != 0)
		{
			FlxG.camera.scroll.x += camX;
			FlxG.camera.scroll.y += camY;
		}

		var lastZoom = FlxG.camera.zoom;
		if (justPressed_R && !FlxG.keys.pressed.CONTROL)
			FlxG.camera.zoom = 0.5;
		else if (pressed_E && FlxG.camera.zoom < maxZoom)
			FlxG.camera.zoom = Math.min(maxZoom, FlxG.camera.zoom + elapsed * FlxG.camera.zoom * shiftMult * ctrlMult);
		else if (pressed_Q && FlxG.camera.zoom > minZoom)
			FlxG.camera.zoom = Math.max(minZoom, FlxG.camera.zoom - elapsed * FlxG.camera.zoom * shiftMult * ctrlMult);

		if (FlxG.keys.justPressed.ESCAPE #if android || FlxG.android.justReleased.BACK #end #if TOUCH_CONTROLS_ALLOWED || touchPad.buttonB.justPressed #end)
		{
			persistentDraw = true;
			close();
		}
	}
}
