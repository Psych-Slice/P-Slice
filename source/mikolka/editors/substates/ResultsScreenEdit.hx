package mikolka.editors.substates;

import mikolka.compatibility.FunkinControls;
import flixel.util.FlxGradient;
import mikolka.compatibility.FunkinCamera;
import mikolka.funkin.custom.VsliceSubState;

class ResultsScreenEdit extends VsliceSubState {
	var loaded:Bool = false;
	var resultsDialogBox:PsychUIBox;
	final cameraBG:FlxCamera;
	final cameraEverything:FlxCamera;

	var rankBg:FunkinSprite;  
	final resultsAnim:FunkinSprite;
	var bgFlash:FlxSprite;

	public function new(activePlayer:PlayableCharacter) {
		cameraBG = new FunkinCamera('resultsBG', 0, 0, FlxG.width, FlxG.height);
    	cameraEverything = new FunkinCamera('resultsEverything', 0, 0, FlxG.width, FlxG.height);
		resultsAnim = FunkinSprite.createSparrow(-200, -10, "resultScreen/results");
		bgFlash = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFFFFF1A6, 0xFFFFF1BE], 90);
		super();
	}

    override function create() {
        
		cameraBG.bgColor = FlxColor.MAGENTA;
		cameraEverything.bgColor = FlxColor.TRANSPARENT;

		FlxG.cameras.add(cameraBG, false);
		FlxG.cameras.add(cameraEverything, false);

		FlxG.cameras.setDefaultDrawTarget(cameraEverything, true);
		this.camera = cameraEverything;

		// Reset the camera zoom on the results screen.
		FlxG.camera.zoom = 1.0;

		var bg:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFFFECC5C, 0xFFFDC05C], 90);
		bg.scrollFactor.set();
		bg.visible = false;
		bg.zIndex = 10;
		//bg.cameras = [cameraBG];
		add(bg);
	
		bgFlash.scrollFactor.set();
		bgFlash.visible = false;
		bgFlash.zIndex = 20;
		// bgFlash.cameras = [cameraBG];
		add(bgFlash);
	
		// The sound system which falls into place behind the score text. Plays every time!
		var soundSystem:FlxSprite = FunkinSprite.createSparrow(-15, -180, 'resultScreen/soundSystem');
		soundSystem.animation.addByPrefix("idle", "sound system", 24, false);
		soundSystem.visible = false;
		new FlxTimer().start(8 / 24, _ -> {
		  soundSystem.animation.play("idle");
		  soundSystem.visible = true;
		});
		soundSystem.zIndex = 1100;
		add(soundSystem);
		
		var blackTopBar:FlxSprite = new FlxSprite().loadGraphic(Paths.image("resultScreen/topBarBlack"));
		blackTopBar.y = -blackTopBar.height;
		FlxTween.tween(blackTopBar, {y: 0}, 7 / 24, {ease: FlxEase.quartOut, startDelay: 3 / 24});
		blackTopBar.zIndex = 1010;
		add(blackTopBar);

		resultsAnim.animation.addByPrefix("result", "results instance 1", 24, false);
		resultsAnim.visible = false;
		resultsAnim.zIndex = 1200;
		add(resultsAnim);
		new FlxTimer().start(6 / 24, _ -> {
			resultsAnim.visible = true;
			resultsAnim.animation.play("result");
		});

		refresh();

        #if TOUCH_CONTROLS_ALLOWED
		addTouchPad("LEFT_FULL", "A_B_C_F");
		touchPad.visible = false;
		#end

		var helpTxt = HelpSubstate.makeLabel();
		helpTxt.visible = false;
		helpTxt.zIndex = 800;
		add(helpTxt);
		addEditorBox();
		new FlxTimer().start(24 / 24,t ->{
			bg.visible = true;
			bgFlash.visible = true;
		    FlxTween.tween(bgFlash, {alpha: 0}, 5 / 24);
			loaded = true;
			helpTxt.visible = true;
			resultsDialogBox.visible = true;
			touchPad.visible = true;
		});
        super.create();
		
    }
	function addEditorBox()
		{
			resultsDialogBox = new PsychUIBox(FlxG.width - 500, FlxG.height, 300, 250, ['General', "Properties"]);
			resultsDialogBox.x -= resultsDialogBox.width;
			resultsDialogBox.y -= resultsDialogBox.height;
			resultsDialogBox.scrollFactor.set();
			resultsDialogBox.visible = false;

			var rankSelector = new PsychUIDropDownMenu(20,20,["PERFECT_GOLD","PERFECT","EXCELLENT","GREAT","GOOD","BAD","SHIT"],(index, name) -> {

			});

			resultsDialogBox.selectedName = 'General';
			var tab = resultsDialogBox.getTab('General').menu;
			tab.add(rankSelector);
			tab.add(newLabel(rankSelector,"Rank"));

			add(resultsDialogBox);
		}

    override function update(elapsed:Float) {
        controls.isInSubstate = true;
		super.update(elapsed);
		if (!loaded)
			return;
		if (PsychUIInputText.focusOn == null)
		{
			FunkinControls.enableVolume();
			var timeScale = Math.floor(elapsed * 100);
            if(#if TOUCH_CONTROLS_ALLOWED touchPad.buttonB.justPressed || #end controls.BACK){
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
		else FunkinControls.disableVolume();
		
    }
	#if TOUCH_CONTROLS_ALLOWED
	override function closeSubState() {
		super.closeSubState();
		addTouchPad("LEFT_FULL", "A_B_C_F");
		controls.isInSubstate = true;
	}
	#end
	inline function newLabel(ref:FlxSprite, text:String)
		{
			return new FlxText(ref.x, ref.y - 13, 100, text);
		}
	
}