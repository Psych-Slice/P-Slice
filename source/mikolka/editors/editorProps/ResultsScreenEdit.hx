package mikolka.editors.editorProps;

import flixel.util.FlxGradient;
import mikolka.compatibility.FunkinCamera;

class ResultsScreenEdit extends MusicBeatSubstate {
	var loaded:Bool = false;
	var resultsDialogBox:PsychUIBox;
	final cameraBG:FlxCamera;
	final cameraEverything:FlxCamera;

	var rankBg:FunkinSprite;  
	final resultsAnim:FunkinSprite;
	var bgFlash:FlxSprite;

	public function new() {
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
		bg.zIndex = 10;
		bg.cameras = [cameraBG];
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

        #if TOUCH_CONTROLS_ALLOWED
		addTouchPad("LEFT_FULL", "A_B");
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
	function addEditorBox()
		{
			resultsDialogBox = new PsychUIBox(FlxG.width - 500, FlxG.height, 300, 250, ['General', "DJ Editor", "Animation"]);
			resultsDialogBox.x -= resultsDialogBox.width;
			resultsDialogBox.y -= resultsDialogBox.height;
			resultsDialogBox.scrollFactor.set();
			resultsDialogBox.visible = false;
		}

    override function update(elapsed:Float) {
        controls.isInSubstate = true;
		super.update(elapsed);
		if (!loaded)
			return;
		if (PsychUIInputText.focusOn == null)
		{
            if(controls.BACK){
				close();
			}
        }
    }
	#if TOUCH_CONTROLS_ALLOWED
	override function closeSubState() {
		super.closeSubState();
		addTouchPad("LEFT_FULL", "A_B");
		controls.isInSubstate = true;
	}
	#end

	
}