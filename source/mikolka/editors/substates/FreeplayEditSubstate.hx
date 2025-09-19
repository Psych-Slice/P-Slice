package mikolka.editors.substates;

import mikolka.vslice.freeplay.FreeplayState;
import mikolka.funkin.custom.mobile.MobileScaleMode;
import mikolka.compatibility.funkin.FunkinPath;
import mikolka.editors.forms.FreeplayDialogBox;
import mikolka.editors.editorProps.DJAnimPreview;
import mikolka.compatibility.funkin.FunkinControls;
import mikolka.vslice.freeplay.BGScrollingText;
import mikolka.funkin.freeplay.FreeplayStyle;
import mikolka.funkin.freeplay.FreeplayStyleRegistry;
import shaders.AngleMask;
import mikolka.vslice.freeplay.backcards.BoyfriendCard;



class FreeplayEditSubstate extends MusicBeatSubstate
{

	/**
	 * For positioning the DJ on wide displays.
	 */
	public static final DJ_POS_MULTI:Float = 0.44;

	public static var instance:FreeplayEditSubstate;

	public var data:PlayableCharacter;
	var style:Null<FreeplayStyle>;
	var animsList:Array<AnimationData>;
	var loaded:Bool = false;

	public var dj:FlxAtlasSprite;
	public var dj_anim:DJAnimPreview;

	public var backingCard:BoyfriendCard;
	var angleMaskShader:AngleMask = new AngleMask();
	var bgDad:FlxSprite;
	var ostName:FlxText;

	var UI_box:FreeplayDialogBox;


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
		final CUTOUT_WIDTH:Float = MobileScaleMode.gameCutoutSize.x / 1.5;
		FreeplayState.CUTOUT_WIDTH = CUTOUT_WIDTH;
		backingCard = new BoyfriendCard(data);
		backingCard.init();
		add(backingCard);

		bgDad = new FlxSprite(backingCard.pinkBack.width * 0.74, 0);
		bgDad.shader = angleMaskShader;
		bgDad.visible = false;


		var blackOverlayBullshitLOLXD:FlxSprite = new FlxSprite(FlxG.width).makeGraphic(Std.int(bgDad.width), Std.int(bgDad.height), FlxColor.BLACK);
    	add(blackOverlayBullshitLOLXD); // used to mask the text lol!
		blackOverlayBullshitLOLXD.shader = bgDad.shader;
		
		setDadBG();
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

		try{
			dj = new FlxAtlasSprite((CUTOUT_WIDTH * DJ_POS_MULTI) + 640, 366, data.getFreeplayDJData().getAtlasPath());
		}
		catch(x){
			trace(x);
			dj = new FlxAtlasSprite((CUTOUT_WIDTH * DJ_POS_MULTI) + 640, 366, "freeplay/freeplay-boyfriend");
		}
		add(dj);
		dj.playAnimation(data.getFreeplayDJData().getAnimationPrefix("idle"));
		dj_anim = new DJAnimPreview(true,100, 100);
		dj_anim.visible = false;
		dj_anim.dj = data;
		dj_anim.attachSprite(dj);
		add(dj_anim);

		@:privateAccess
		animsList = data.getFreeplayDJData().animations;
		// anims = new AnimPreview(200,200);
		// anims.attachSprite(dj);
		UI_box = new FreeplayDialogBox(this);
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

	public function dj_selectAnim(diff:Int) {
		dj_anim.input_selectAnim(diff);
		UI_box.list_animations.selectedIndex = dj_anim.selectedIndex;
		UI_box.input_animName.text = dj_anim.curAnimName;
		UI_box.input_animPrefix.text = dj_anim.curAnimPrefix;
		UI_box.stepper_offset_x.value = dj_anim.curOffset[0];
		UI_box.stepper_offset_y.value = dj_anim.curOffset[1];
	}

	function dj_changeOffset(xOff:Int, yOff:Int) {
		dj_anim.input_changeOffset(xOff,yOff);
		UI_box.stepper_offset_x.value = dj.offset.x;
		UI_box.stepper_offset_y.value = dj.offset.y;
	}

	function setDadBG()
	{
		var graphic = style.getBgAssetGraphic();
		bgDad.loadGraphic(graphic == null ? Paths.image('charEdit/freeplayBGmissing') : graphic);
	}
}
