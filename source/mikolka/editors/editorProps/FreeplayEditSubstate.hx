package mikolka.editors.editorProps;

import mikolka.compatibility.FunkinControls;
import mikolka.vslice.freeplay.BGScrollingText;
import mikolka.funkin.freeplay.FreeplayStyle;
import mikolka.funkin.freeplay.FreeplayStyleRegistry;
import shaders.AngleMask;
import mikolka.vslice.freeplay.backcards.BoyfriendCard;

class FreeplayEditSubstate extends MusicBeatSubstate
{
	public static var instance:FreeplayEditSubstate;

	var data:PlayableCharacter;
	var style:Null<FreeplayStyle>;
	var animsList:Array<AnimationData>;
	var loaded:Bool = false;

	var dj:FlxAtlasSprite;
	var dj_anim:DJAnimPreview;

	var backingCard:BoyfriendCard;
	var angleMaskShader:AngleMask = new AngleMask();
	var bgDad:FlxSprite;
	var ostName:FlxText;

	var UI_box:PsychUIBox;
	// GENERAL
	var input_assetPath:PsychUIInputText;
	var btn_reload:PsychUIButton;
	var steper_charSelectDelay:PsychUINumericStepper;
	var input_text1:PsychUIInputText;
	var input_text2:PsychUIInputText;
	var input_text3:PsychUIInputText;
	// DJ EDITOR
	var steper_introStartFrame:PsychUINumericStepper;
	var steper_introEndFrame:PsychUINumericStepper;
	var steper_loopStartFrame:PsychUINumericStepper;
	var steper_loopEndFrame:PsychUINumericStepper;
	var steper_introBadStartFrame:PsychUINumericStepper;
	var steper_loopBadEndFrame:PsychUINumericStepper;
	var steper_loopBadStartFrame:PsychUINumericStepper;
	var steper_introBadEndFrame:PsychUINumericStepper;
	// ANIMATION
	var list_animations:PsychUIDropDownMenu;
	var input_animName:PsychUIInputText;
	var input_animPrefix:PsychUIInputText;
	var btn_newAnim:PsychUIButton;
	var btn_trashAnim:PsychUIButton;
	var stepper_offset_x:PsychUINumericStepper;
	var stepper_offset_y:PsychUINumericStepper;

	public function new(player:PlayableCharacter)
	{
		instance = this;
		controls.isInSubstate = true;
		super();
		data = player;
		style = FreeplayStyleRegistry.instance.fetchEntry(data.getFreeplayStyleID());
		if (style == null)
			style = FreeplayStyleRegistry.instance.fetchEntry("bf");
	}

	override function create()
	{
		backingCard = new BoyfriendCard(data);
		backingCard.init();
		add(backingCard);

		var blackOverlayBullshitLOLXD:FlxSprite = new FlxSprite(FlxG.width, 0, Paths.image("back"));
		blackOverlayBullshitLOLXD.alpha = 1; // ? graphic because shareds are shit
		add(blackOverlayBullshitLOLXD); // used to mask the text lol!

		bgDad = new FlxSprite(backingCard.pinkBack.width * 0.74, 0);
		setDadBG();
		bgDad.shader = angleMaskShader;
		bgDad.visible = false;
		add(bgDad);

		// this makes the texture sizes consistent, for the angle shader
		bgDad.setGraphicSize(0, FlxG.height);
		blackOverlayBullshitLOLXD.setGraphicSize(0, FlxG.height);

		bgDad.updateHitbox();
		blackOverlayBullshitLOLXD.updateHitbox();
		FlxTween.tween(blackOverlayBullshitLOLXD, {x: 350}, 0.75, {
			ease: FlxEase.quintOut
		});
		FlxTimer.wait(0.8, onLoadAnimDone);

		var overhangStuff:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 164, FlxColor.BLACK);
		overhangStuff.y -= overhangStuff.height;
		FlxTween.tween(overhangStuff, {y: -100}, 0.3, {ease: FlxEase.quartOut});
		add(overhangStuff);

		ostName = new FlxText(8, 8, FlxG.width - 8 - 8, 'CHARACTER EDITOR', 48);
		ostName.font = 'VCR OSD Mono';
		ostName.alignment = RIGHT;
		ostName.visible = false;
		add(ostName);

		dj = new FlxAtlasSprite(640, 366, data.getFreeplayDJData().getAtlasPath());
		add(dj);
		dj.playAnimation(data.getFreeplayDJData().getAnimationPrefix("idle"));
		dj_anim = new DJAnimPreview(100, 100);
		dj_anim.visible = false;
		dj_anim.dj = data;
		dj_anim.attachSprite(dj);
		add(dj_anim);

		@:privateAccess
		animsList = data.getFreeplayDJData().animations;
		// anims = new AnimPreview(200,200);
		// anims.attachSprite(dj);
		addEditorBox();
		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad("LEFT_FULL", "FREEPLAY_EDIT");
		touchPad.forEachAlive(function(button:TouchButton)
		{
			if (button.tag == 'UP' || button.tag == 'DOWN' || button.tag == 'LEFT' || button.tag == 'RIGHT')
			{
				button.x -= 450;
				FlxTween.tween(button, {x: button.x + 450}, 0.6, {ease: FlxEase.backInOut});
			}
			else
			{
				button.x += 550;
				FlxTween.tween(button, {x: button.x - 550}, 0.6, {ease: FlxEase.backInOut});
			}
		});
		#end
		add(HelpSubstate.makeLabel());
		super.create();
	}

	#if TOUCH_CONTROLS_ALLOWED
	override function closeSubState() {
		super.closeSubState();
		addTouchPad("LEFT_FULL", "FREEPLAY_EDIT");
		controls.isInSubstate = true;
	}
	#end
	
	function onLoadAnimDone()
	{
		add(UI_box);
		loaded = true;
		bgDad.visible = true;
		ostName.visible = true;
		dj_anim.visible = true;
		backingCard.introDone();
	}

	override function update(elapsed:Float)
	{
		controls.isInSubstate = true;
		super.update(elapsed);
		if (!loaded)
			return;
		if (PsychUIInputText.focusOn == null)
		{
			FunkinControls.enableVolume();
			var timeScale = Math.floor(elapsed * 100);

			if (dj_anim.activeSprite != null)
			{
				if (#if TOUCH_CONTROLS_ALLOWED !touchPad.buttonA.pressed && #end #if TOUCH_CONTROLS_ALLOWED touchPad.buttonDown.justPressed || #end controls.UI_DOWN_P)
					dj_selectAnim(1);
				else if (#if TOUCH_CONTROLS_ALLOWED !touchPad.buttonA.pressed && #end #if TOUCH_CONTROLS_ALLOWED touchPad.buttonUp.justPressed || #end controls.UI_UP_P)
					dj_selectAnim(-1);
				else if (#if TOUCH_CONTROLS_ALLOWED touchPad.buttonX.justPressed || #end FlxG.keys.justPressed.SPACE)
					dj_anim.input_playAnim();
				else if(#if TOUCH_CONTROLS_ALLOWED touchPad.buttonY.pressed || #end FlxG.keys.pressed.SHIFT){
					if (#if TOUCH_CONTROLS_ALLOWED !touchPad.buttonA.pressed && #end #if TOUCH_CONTROLS_ALLOWED touchPad.buttonLeft.pressed || #end controls.UI_LEFT)
						dj_anim.input_selectFrame(-1*timeScale);
					else if (#if TOUCH_CONTROLS_ALLOWED !touchPad.buttonA.pressed && #end #if TOUCH_CONTROLS_ALLOWED touchPad.buttonRight.pressed || #end controls.UI_RIGHT)
						dj_anim.input_selectFrame(1*timeScale);
					else if (#if TOUCH_CONTROLS_ALLOWED (touchPad.buttonA.pressed && touchPad.buttonUp.pressed) || #end FlxG.keys.pressed.I)
						dj_changeOffset(0,5*timeScale);
					else if (#if TOUCH_CONTROLS_ALLOWED (touchPad.buttonA.pressed && touchPad.buttonLeft.pressed) || #end FlxG.keys.pressed.J)
						dj_changeOffset(5*timeScale,0);
					else if (#if TOUCH_CONTROLS_ALLOWED (touchPad.buttonA.pressed && touchPad.buttonDown.pressed) || #end FlxG.keys.pressed.K)
						dj_changeOffset(0,-5*timeScale);
					else if (#if TOUCH_CONTROLS_ALLOWED (touchPad.buttonA.pressed && touchPad.buttonRight.pressed) || #end FlxG.keys.pressed.L)
						dj_changeOffset(-5*timeScale,0);
				}
				else{
					if (#if TOUCH_CONTROLS_ALLOWED !touchPad.buttonA.pressed && #end #if TOUCH_CONTROLS_ALLOWED touchPad.buttonLeft.justPressed || #end controls.UI_LEFT_P)
						dj_anim.input_selectFrame(-1);
					else if (#if TOUCH_CONTROLS_ALLOWED !touchPad.buttonA.pressed && #end #if TOUCH_CONTROLS_ALLOWED touchPad.buttonRight.justPressed || #end controls.UI_RIGHT_P)
						dj_anim.input_selectFrame(1);
					else if (#if TOUCH_CONTROLS_ALLOWED (touchPad.buttonA.pressed && touchPad.buttonUp.justPressed) || #end FlxG.keys.justPressed.I)
						dj_changeOffset(0,1);
					else if (#if TOUCH_CONTROLS_ALLOWED (touchPad.buttonA.pressed && touchPad.buttonLeft.justPressed) || #end FlxG.keys.justPressed.J)
						dj_changeOffset(1,0);
					else if (#if TOUCH_CONTROLS_ALLOWED (touchPad.buttonA.pressed && touchPad.buttonDown.justPressed) || #end FlxG.keys.justPressed.K)
						dj_changeOffset(0,-1);
					else if (#if TOUCH_CONTROLS_ALLOWED (touchPad.buttonA.pressed && touchPad.buttonRight.justPressed) || #end FlxG.keys.justPressed.L)
						dj_changeOffset(-1,0);
				}
			}

			if (#if TOUCH_CONTROLS_ALLOWED touchPad.buttonB.justPressed || #end controls.BACK && loaded)
			{
				dj_anim.saveAnimations();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				close();
				controls.isInSubstate = false;
			}
			else if(#if TOUCH_CONTROLS_ALLOWED touchPad.buttonF.justPressed || #end FlxG.keys.justPressed.F1){
				persistentUpdate = false;
				#if TOUCH_CONTROLS_ALLOWED removeTouchPad(); #end
				openSubState(new HelpSubstate(controls.mobileC ? HelpSubstate.FREEPLAY_EDIT_TEXT_MOBILE : HelpSubstate.FREEPLAY_EDIT_TEXT));
			}
		}
		else
			FunkinControls.disableVolume();
	}

	function dj_selectAnim(diff:Int) {
		dj_anim.input_selectAnim(diff);
		list_animations.selectedIndex = dj_anim.selectedIndex;
		input_animName.text = dj_anim.curAnimName;
		input_animPrefix.text = dj_anim.curAnimPrefix;
		stepper_offset_x.value = dj_anim.curOffset[0];
		stepper_offset_y.value = dj_anim.curOffset[1];
	}

	function dj_changeOffset(xOff:Int, yOff:Int) {
		dj_anim.input_changeOffset(xOff,yOff);
		stepper_offset_x.value = dj.offset.x;
		stepper_offset_y.value = dj.offset.y;
	}

	function addEditorBox()
	{
		UI_box = new PsychUIBox(FlxG.width - 500, FlxG.height, 300, 250, ['General', "DJ Editor", "Animation"]);
		UI_box.x -= UI_box.width;
		UI_box.y -= UI_box.height;
		UI_box.scrollFactor.set();

		// GENERAL
		@:privateAccess{
			input_assetPath = new PsychUIInputText(10, 20, 150, data._data.freeplayDJ.assetPath);
			input_assetPath.onChange = (prev, cur) -> {
				data._data.freeplayDJ.assetPath = cur;
			};
		}

		btn_reload = new PsychUIButton(180, 20, "Reload", () ->
		{
			dj_anim.saveAnimations();
			remove(dj);
			dj.destroy();
			dj = new FlxAtlasSprite(640, 366, data.getFreeplayDJData().getAtlasPath());
			dj_anim.attachSprite(dj);
			add(dj);
		});
		
		@:privateAccess {
			steper_charSelectDelay = new PsychUINumericStepper(10, 130, 0.1, data._data.freeplayDJ.charSelect.transitionDelay, 0, 15, 1, 100);
			steper_charSelectDelay.onValueChange = () -> {
				data._data.freeplayDJ.charSelect.transitionDelay = steper_charSelectDelay.value;
			};

			input_text1 = new PsychUIInputText(10, 50, 150, data._data.freeplayDJ.text1);
			input_text2 = new PsychUIInputText(10, 70, 150, data._data.freeplayDJ.text2);
			input_text3 = new PsychUIInputText(10, 90, 150, data._data.freeplayDJ.text3);

			var currentCharacter = data.getFreeplayDJData();
			input_text1.onChange = (prev, current) ->
			{
				data.getFreeplayDJData().text1 = current;
				backingCard.remove(backingCard.funnyScroll);
				backingCard.remove(backingCard.funnyScroll2);
				backingCard.remove(backingCard.funnyScroll3);
				backingCard.funnyScroll.destroy();
				backingCard.funnyScroll2.destroy();
				backingCard.funnyScroll3.destroy();
				backingCard.funnyScroll = new BGScrollingText(0, 220, currentCharacter.getFreeplayDJText(1), FlxG.width / 2, false, 60);
				backingCard.funnyScroll2 = new BGScrollingText(0, 335, currentCharacter.getFreeplayDJText(1), FlxG.width / 2, false, 60);
				backingCard.funnyScroll3 = new BGScrollingText(0, backingCard.orangeBackShit.y + 10, currentCharacter.getFreeplayDJText(1), FlxG.width / 2, 60);
				backingCard.funnyScroll.funnyColor = 0xFFFF9963;
				backingCard.funnyScroll2.funnyColor = 0xFFFF9963;
				backingCard.funnyScroll3.funnyColor = 0xFFFEA400;
				backingCard.funnyScroll.speed = backingCard.funnyScroll2.speed = backingCard.funnyScroll3.speed = -3.8;
				backingCard.add(backingCard.funnyScroll);
				backingCard.add(backingCard.funnyScroll2);
				backingCard.add(backingCard.funnyScroll3);

			};
			input_text2.onChange = (prev, current) ->
			{
				data.getFreeplayDJData().text2 = current;
				backingCard.remove(backingCard.moreWays);
				backingCard.remove(backingCard.moreWays2);
				backingCard.moreWays.destroy();
				backingCard.moreWays2.destroy();
				backingCard.moreWays = new BGScrollingText(0, 160, currentCharacter.getFreeplayDJText(2), FlxG.width, true, 43);
				backingCard.moreWays2 = new BGScrollingText(0, 397, currentCharacter.getFreeplayDJText(2), FlxG.width, true, 43);
				backingCard.moreWays.speed = backingCard.moreWays2.speed = 6.8;
				backingCard.moreWays.funnyColor = backingCard.moreWays2.funnyColor = 0xFFFFF383;
				backingCard.add(backingCard.moreWays);
				backingCard.add(backingCard.moreWays2);
				backingCard.moreWays.grpTexts.forEach(x -> x.text = currentCharacter.getFreeplayDJText(2));
				backingCard.moreWays2.grpTexts.forEach(x -> x.text = currentCharacter.getFreeplayDJText(2));
			}
			input_text3.onChange = (prev, current) ->
			{
				data.getFreeplayDJData().text3 = current;
				backingCard.remove(backingCard.txtNuts);
				backingCard.txtNuts.destroy();
				backingCard.txtNuts = new BGScrollingText(0, 285, currentCharacter.getFreeplayDJText(3), FlxG.width / 2, true, 43);
				backingCard.txtNuts.speed = 3.5;
				backingCard.add(backingCard.txtNuts);
			}
		}
		// DJ EDITOR
		var dj_editor_desc_txt = new FlxText(10, 10, 400, "Pick frames (start,end)");
		dj_editor_desc_txt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.BLACK);

		var txt_introStart = new FlxText(10, 50, 0, "Victory intro:", 10);
		steper_introStartFrame = new PsychUINumericStepper(100, 50, 1, data.getFreeplayDJData().getFistPumpIntroStartFrame(), 0, 100);
		steper_introEndFrame = new PsychUINumericStepper(170, 50, 1, data.getFreeplayDJData().getFistPumpIntroEndFrame(), -1, 100);

		var txt_introLoop = new FlxText(10, 90, 0, "Victory loop:", 10);
		steper_loopStartFrame = new PsychUINumericStepper(100, 90, 1, data.getFreeplayDJData().getFistPumpLoopStartFrame(), 0, 100);
		steper_loopEndFrame = new PsychUINumericStepper(170, 90, 1, data.getFreeplayDJData().getFistPumpLoopEndFrame(), -1, 100);

		var txt_introBadStart = new FlxText(10, 130, 0, "Loss intro:", 10);
		steper_introBadStartFrame = new PsychUINumericStepper(100, 130, 1, data.getFreeplayDJData().getFistPumpIntroBadStartFrame(), 0, 100);
		steper_introBadEndFrame = new PsychUINumericStepper(170, 130, 1, data.getFreeplayDJData().getFistPumpIntroBadEndFrame(), -1, 100);

		var txt_introBadLoop = new FlxText(10, 170, 0, "Loss loop:", 10);
		steper_loopBadStartFrame = new PsychUINumericStepper(100, 170, 1, data.getFreeplayDJData().getFistPumpLoopBadStartFrame(), 0, 100);
		steper_loopBadEndFrame = new PsychUINumericStepper(170, 170, 1, data.getFreeplayDJData().getFistPumpLoopBadEndFrame(), -1, 100);

		@:privateAccess {
			var fist = data.getFreeplayDJData().fistPump;
			steper_introStartFrame.onValueChange = () -> fist.introStartFrame = Math.floor(steper_introStartFrame.value);
			steper_introEndFrame.onValueChange = () -> fist.introEndFrame = Math.floor(steper_introEndFrame.value);
			steper_loopStartFrame.onValueChange = () -> fist.loopStartFrame = Math.floor(steper_loopStartFrame.value);
			steper_loopEndFrame.onValueChange = () -> fist.loopEndFrame = Math.floor(steper_loopEndFrame.value);

			steper_introBadStartFrame.onValueChange = () -> fist.introBadStartFrame = Math.floor(steper_introBadStartFrame.value);
			steper_introBadEndFrame.onValueChange = () -> fist.introBadEndFrame = Math.floor(steper_introBadEndFrame.value);
			steper_loopBadStartFrame.onValueChange = () -> fist.loopBadStartFrame = Math.floor(steper_loopBadStartFrame.value);
			steper_loopBadEndFrame.onValueChange = () -> fist.loopBadEndFrame = Math.floor(steper_loopBadEndFrame.value);
		}
		// Animation
		list_animations = new PsychUIDropDownMenu(10, 10, dj_anim.getAnimTitlesForSelector(), (index, name) ->
		{
			dj_anim.setAnimIndex(index);
			input_animName.text = dj_anim.curAnimName;
			input_animPrefix.text = dj_anim.curAnimPrefix;
			stepper_offset_x.value = dj_anim.curOffset[0];
			stepper_offset_y.value = dj_anim.curOffset[1];
		});
		btn_newAnim = new PsychUIButton(140, 10, "New", () -> {
			if(list_animations.list.length >=20){
				FlxG.sound.play(Paths.sound('cancelMenu'));
				return;
			}
			@:privateAccess{
				list_animations.addOption("newAnim");
				dj_anim.addAnim({
					readableName: "newAnim",
					anim: "prefix"
				});
			}
			dj_anim.offsets.push([0,0]);

		}, 50);
		btn_trashAnim = new PsychUIButton(200, 10, "Delete", () -> {
			var index = list_animations.selectedIndex;
			if(list_animations.list.length == 1){
				FlxG.sound.play(Paths.sound('cancelMenu'));
				return;
			}
			@:privateAccess{
				list_animations._items.remove(list_animations._items[index]);
				dj_anim.anims.remove(dj_anim.anims[index]);
				var label = dj_anim.labels[index];
				dj_anim.remove(label);
				dj_anim.labels.remove(label);
				for (x in index...dj_anim.labels.length){
					dj_anim.labels[x].y -= 20; 
				}
			}
			list_animations.list.remove(list_animations.list[index]);
			dj_anim.offsets.remove(dj_anim.offsets[index]);
			dj_selectAnim(index ==0 ? 0 : -1);
		}, 50);
		
		input_animName = new PsychUIInputText(10, 50, 150, dj_anim.curAnimName);
		input_animPrefix = new PsychUIInputText(10, 90, 150, dj_anim.curAnimPrefix);
		stepper_offset_x = new PsychUINumericStepper(20, 130, 1, dj_anim.curOffset[0],-9999,9999); // dirty lol
		stepper_offset_y = new PsychUINumericStepper(85, 130, 1, dj_anim.curOffset[1],-9999,9999);
		input_animName.onChange = (old,cur) ->{
			dj_anim.curAnimName = cur;
			list_animations.list[list_animations.selectedIndex] = cur;
			@:privateAccess
			list_animations._items[list_animations.selectedIndex].label = cur;
			list_animations.text = cur;
		}
		input_animPrefix.onChange = (old,cur) ->{
			dj_anim.curAnimPrefix = cur;
		}
		stepper_offset_x.onValueChange = ()->{
			dj_anim.setOffset(stepper_offset_x.value,stepper_offset_y.value);
		};
		stepper_offset_y.onValueChange = ()->{
			dj_anim.setOffset(stepper_offset_x.value,stepper_offset_y.value);
		};


		// ?

		// GENERAL
		UI_box.selectedName = 'General';
		var tab = UI_box.getTab('General').menu;

		tab.add(newLabel(input_assetPath, 'Asset path:'));
		tab.add(input_assetPath);
		tab.add(btn_reload);

		tab.add(newLabel(input_text1, "Scroll texts:"));
		tab.add(input_text1);
		tab.add(input_text2);
		tab.add(input_text3);
		
		tab.add(newLabel(steper_charSelectDelay, "Transition delay:"));
		tab.add(steper_charSelectDelay);

		// DJ EDITOR
		var tab = UI_box.getTab("DJ Editor").menu;
		tab.add(dj_editor_desc_txt);
		tab.add(txt_introStart);
		tab.add(steper_introStartFrame);
		tab.add(steper_introStartFrame);
		tab.add(txt_introLoop);
		tab.add(steper_loopStartFrame);
		tab.add(steper_loopEndFrame);
		tab.add(txt_introBadStart);
		tab.add(steper_introBadStartFrame);
		tab.add(steper_introBadEndFrame);
		tab.add(txt_introBadLoop);
		tab.add(steper_loopBadStartFrame);
		tab.add(steper_loopBadEndFrame);
		tab.add(steper_introEndFrame);
		// tab.add(btn_player_prev);

		// Animation
		var tab = UI_box.getTab("Animation").menu;
		tab.add(btn_newAnim);
		tab.add(btn_trashAnim);
		tab.add(newLabel(input_animName, "Name"));
		tab.add(input_animName);
		tab.add(newLabel(input_animPrefix, "Prefix"));
		tab.add(input_animPrefix);
		tab.add(new FlxText(10, 110, 100, "Offsets (x,y)"));
		tab.add(stepper_offset_x);
		tab.add(stepper_offset_y);
		tab.add(list_animations);
	}

	function newLabel(ref:FlxSprite, text:String)
	{
		return new FlxText(ref.x, ref.y - 13, 100, text);
	}

	function setDadBG()
	{
		var graphic = style.getBgAssetGraphic();
		bgDad.loadGraphic(graphic == null ? Paths.image('charEdit/freeplayBGmissing') : graphic);
	}
}
