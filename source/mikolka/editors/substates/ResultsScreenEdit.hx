package mikolka.editors.substates;

import mikolka.funkin.custom.mobile.MobileScaleMode;
import mikolka.vslice.components.crash.UserErrorSubstate;
import mikolka.editors.forms.ResultsDialogBox;
import mikolka.funkin.Scoring.ScoringRank;
import mikolka.compatibility.funkin.FunkinControls;
import flixel.util.FlxGradient;
import mikolka.compatibility.funkin.FunkinCamera;
import mikolka.editors.editorProps.ResultsPropsGrp;
import mikolka.funkin.custom.VsliceSubState;

class ResultsScreenEdit extends VsliceSubState
{
	public var activePlayer:PlayableCharacter;
	public var activeRank:ScoringRank;
	public var propSystem:ResultsPropsGrp;

	final resultsAnim:FunkinSprite;
	var loaded:Bool = false;
	var playingAnimations:Bool = false;
	var wasReset:Bool = true;
	var rankBg:FunkinSprite;
	var bgFlash:FlxSprite;
	var resultsDialogBox:ResultsDialogBox;

	public function new(activePlayer:PlayableCharacter)
	{
		this.activePlayer = activePlayer;
		resultsAnim = FunkinSprite.createSparrow(FlxG.width -(1480 + (MobileScaleMode.gameCutoutSize.x / 2)), -10, "resultScreen/results");
		bgFlash = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFFFFF1A6, 0xFFFFF1BE], 90);
		super();
	}

	override function create()
	{
		// Reset the camera zoom on the results screen.
		FlxG.camera.zoom = 1.0;

		var bg:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFFFECC5C, 0xFFFDC05C], 90);
		bg.scrollFactor.set();
		bg.visible = false;
		bg.zIndex = 10;
		// bg.cameras = [cameraBG];
		add(bg);

		bgFlash.scrollFactor.set();
		bgFlash.visible = false;
		bgFlash.zIndex = 20;
		// bgFlash.cameras = [cameraBG];
		add(bgFlash);

		// ? All props after this point can be shadowed by user
		propSystem = new ResultsPropsGrp();
		propSystem.zIndex = 50;
		add(propSystem);
		// The sound system which falls into place behind the score text. Plays every time!
		var soundSystem:FlxSprite = FunkinSprite.createSparrow(-15+ MobileScaleMode.gameNotchSize.x, -180, 'resultScreen/soundSystem');
		soundSystem.animation.addByPrefix("idle", "sound system", 24, false);
		soundSystem.visible = false;
		new FlxTimer().start(8 / 24, _ ->
		{
			soundSystem.animation.play("idle");
			soundSystem.visible = true;
		});
		propSystem.addStaticProp(soundSystem, "soundSystem", 1100);

		var blackTopBar:FlxSprite = new FlxSprite().loadGraphic(BitmapUtil.createResultsBar());
		blackTopBar.y = -blackTopBar.height;
		FlxTween.tween(blackTopBar, {y: 0}, 7 / 24, {ease: FlxEase.quartOut, startDelay: 3 / 24});
		propSystem.addStaticProp(blackTopBar, "blackTopBar", 1010);

		resultsAnim.animation.addByPrefix("result", "results instance 1", 24, false);
		resultsAnim.visible = false;
		propSystem.addStaticProp(resultsAnim, "resultsAnim", 1200);
		new FlxTimer().start(6 / 24, _ ->
		{
			resultsAnim.visible = true;
			resultsAnim.animation.play("result");
		});

		refresh();

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad("LEFT_FULL", "RESULTS_EDITOR");
		controls.isInSubstate = true;
		touchPad.visible = false;
		#end

		var helpTxt = HelpSubstate.makeLabel();
		helpTxt.visible = false;
		helpTxt.zIndex = 800;
		add(helpTxt);
		resultsDialogBox = new ResultsDialogBox(this);
		add(resultsDialogBox);
		
		new FlxTimer().start(24 / 24, t ->
		{
			reloadprops(ScoringRank.PERFECT_GOLD);
			bg.visible = true;
			bgFlash.visible = true;
			FlxTween.tween(bgFlash, {alpha: 0}, 5 / 24);
			loaded = true;
			helpTxt.visible = true;
			resultsDialogBox.visible = true;
			#if TOUCH_CONTROLS_ALLOWED touchPad.visible = true; #end
		});
		super.create();
	}

	public function reloadprops(rank:ScoringRank)
	{
		activeRank = rank;
		var data = activePlayer.getResultsAnimationDatas(rank);
		resultsDialogBox.input_musicPath.text = activePlayer.getResultsMusicPath(rank);
		propSystem.clearProps();
		resultsDialogBox.list_objSelector.list = [];

		var succsessful = true;
		for (prop in data){
			if(succsessful) succsessful = propSystem.addProp(prop);
			else propSystem.addProp(prop);
		}
		propSystem.refresh();
		wasReset = true;
		@:privateAccess
		for (prop in propSystem.sprites)
			resultsDialogBox.list_objSelector.addOption(prop.get_name());

		if(!succsessful) UserErrorSubstate.makeMessage("Failed to load",'Some props failed to load\nMake sure all props have correct paths set');
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
			
			if (playingAnimations)
			{
				if (#if TOUCH_CONTROLS_ALLOWED touchPad.buttonA.justPressed || #end controls.ACCEPT)
					{
						#if TOUCH_CONTROLS_ALLOWED
						removeTouchPad();
						addTouchPad("LEFT_FULL", "RESULTS_EDITOR");
						#end
						playingAnimations = false;
						resultsDialogBox.revive();
						propSystem.pauseAll();
						FlxG.sound.music?.pause();
					}
			}
			else
			{
				if (#if TOUCH_CONTROLS_ALLOWED touchPad.buttonB.justPressed || #end controls.BACK)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					flushResultsData();
					close();
					controls.isInSubstate = false;
				}
				else if (#if TOUCH_CONTROLS_ALLOWED touchPad.buttonF.justPressed || #end FlxG.keys.justPressed.F1)
				{
					persistentUpdate = false;
					#if TOUCH_CONTROLS_ALLOWED removeTouchPad(); #end
					openSubState(new HelpSubstate(controls.mobileC ? HelpSubstate.RESULTS_EDIT_TEXT_MOBILE : HelpSubstate.RESULTS_EDIT_TEXT));
				}
				else if (#if TOUCH_CONTROLS_ALLOWED touchPad.buttonA.justPressed || #end controls.ACCEPT)
				{
					#if TOUCH_CONTROLS_ALLOWED
					removeTouchPad();
					addTouchPad("NONE", "A");
					#end
					playingAnimations = true;
					resultsDialogBox.kill();
					if(wasReset) {
						propSystem.playAll(resultsDialogBox.selected_filter);
						var key = resultsDialogBox.input_musicPath.text;
						if(Paths.fileExists("music/"+key+"/"+key+"."+Paths.SOUND_EXT,MUSIC)){
							FunkinSound.playMusic(key,
							{
								startingVolume: 1.0,
								overrideExisting: true,
								restartTrack: true
							});
						}
					}
					else {
						propSystem.resumeAll();
						FlxG.sound.music?.resume();
					}
					wasReset = false;
				}
				else if (#if TOUCH_CONTROLS_ALLOWED touchPad.buttonC.justPressed || #end controls.RESET)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					wasReset = true;
					propSystem.resetAll(resultsDialogBox.selected_filter);
					FlxG.sound.music?.pause();
				}
				else if(#if TOUCH_CONTROLS_ALLOWED touchPad.buttonZ.pressed || #end FlxG.keys.pressed.SHIFT){
					var timeScale = Math.floor(elapsed * 100);
					if (#if TOUCH_CONTROLS_ALLOWED  touchPad.buttonDown.pressed || #end controls.UI_DOWN)
						resultsDialogBox.addOffset(0,5*timeScale);
					else if (#if TOUCH_CONTROLS_ALLOWED  touchPad.buttonRight.pressed || #end controls.UI_RIGHT)
						resultsDialogBox.addOffset(5*timeScale,0);
					else if (#if TOUCH_CONTROLS_ALLOWED  touchPad.buttonUp.pressed || #end controls.UI_UP)
						resultsDialogBox.addOffset(0,-5*timeScale);
					else if (#if TOUCH_CONTROLS_ALLOWED  touchPad.buttonLeft.pressed || #end controls.UI_LEFT)
						resultsDialogBox.addOffset(-5*timeScale,0);
				}
				else{
					if (#if TOUCH_CONTROLS_ALLOWED  touchPad.buttonDown.justPressed || #end controls.UI_DOWN_P)
						resultsDialogBox.addOffset(0,1);
					else if (#if TOUCH_CONTROLS_ALLOWED  touchPad.buttonRight.justPressed || #end controls.UI_RIGHT_P)
						resultsDialogBox.addOffset(1,0);
					else if (#if TOUCH_CONTROLS_ALLOWED  touchPad.buttonUp.justPressed || #end controls.UI_UP_P)
						resultsDialogBox.addOffset(0,-1);
					else if (#if TOUCH_CONTROLS_ALLOWED  touchPad.buttonLeft.justPressed || #end controls.UI_LEFT_P)
						resultsDialogBox.addOffset(-1,0);
				}
			}
		}
		else
			FunkinControls.disableVolume();
	}

	private function flushResultsData() {
		//TODO
		for (prop in propSystem.sprites) if(prop.data != null) {
			prop.data.zIndex = prop.zIndex;
			prop.data.looped =  prop.data.looped ?? true;
			if(prop.data.looped){
				if(prop.data.loopFrameLabel == "") prop.data.loopFrameLabel = null;
				if(prop.data.startFrameLabel == "") prop.data.startFrameLabel = null;
				if(prop.data.loopFrame == 0) prop.data.loopFrame = null;		
			}
			else{
				prop.data.loopFrameLabel = null;
				prop.data.startFrameLabel = null;
				prop.data.loopFrame = null;
			}
		}
	}
	#if TOUCH_CONTROLS_ALLOWED
	override function closeSubState()
	{
		super.closeSubState();
		addTouchPad("LEFT_FULL", "RESULTS_EDITOR");
		controls.isInSubstate = true;
	}
	#end
}
