package mikolka.editors.substates;

import mikolka.funkin.Scoring.ScoringRank;
import mikolka.compatibility.FunkinControls;
import flixel.util.FlxGradient;
import mikolka.compatibility.FunkinCamera;
import mikolka.editors.editorProps.ResultsPropsGrp;
import mikolka.funkin.custom.VsliceSubState;

using mikolka.editors.PsychUIUtills;

class ResultsScreenEdit extends VsliceSubState {
	var loaded:Bool = false;
	var resultsDialogBox:PsychUIBox;

	var rankBg:FunkinSprite;  
	final resultsAnim:FunkinSprite;
	var bgFlash:FlxSprite;
	var propSystem:ResultsPropsGrp;
	var activePlayer:PlayableCharacter;

	// GENERAL
	var list_objSelector:PsychUIDropDownMenu;

	public function new(activePlayer:PlayableCharacter) {
		this.activePlayer = activePlayer;
		resultsAnim = FunkinSprite.createSparrow(-200, -10, "resultScreen/results");
		bgFlash = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFFFFF1A6, 0xFFFFF1BE], 90);
		super();
	}

    override function create() {

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
	
		//? All props after this point can be shadowed by user
		propSystem = new ResultsPropsGrp();
		propSystem.zIndex = 50;
		add(propSystem);
		// The sound system which falls into place behind the score text. Plays every time!
		var soundSystem:FlxSprite = FunkinSprite.createSparrow(-15, -180, 'resultScreen/soundSystem');
		soundSystem.animation.addByPrefix("idle", "sound system", 24, false);
		soundSystem.visible = false;
		new FlxTimer().start(8 / 24, _ -> {
		  soundSystem.animation.play("idle");
		  soundSystem.visible = true;
		});
		propSystem.addStaticProp(soundSystem,1100);
		
		var blackTopBar:FlxSprite = new FlxSprite().loadGraphic(Paths.image("resultScreen/topBarBlack"));
		blackTopBar.y = -blackTopBar.height;
		FlxTween.tween(blackTopBar, {y: 0}, 7 / 24, {ease: FlxEase.quartOut, startDelay: 3 / 24});
		propSystem.addStaticProp(blackTopBar,1010);

		resultsAnim.animation.addByPrefix("result", "results instance 1", 24, false);
		resultsAnim.visible = false;
		propSystem.addStaticProp(resultsAnim,1200);
		new FlxTimer().start(6 / 24, _ -> {
			resultsAnim.visible = true;
			resultsAnim.animation.play("result");
		});

		refresh();

        #if TOUCH_CONTROLS_ALLOWED
		addTouchPad("LEFT_FULL", "A_B_C_F");
		controls.isInSubstate = true;
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
	            #if TOUCH_CONTROLS_ALLOWED
			touchPad.visible = true;
	    		#end
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

			var rankSelector = new PsychUIDropDownMenu(20,20,["PERFECT_GOLD","PERFECT","EXCELLENT","GREAT","GOOD","SHIT"],(index, name) -> {
				reloadprops([PERFECT_GOLD,PERFECT,EXCELLENT,GREAT,GOOD,SHIT][index]);
			});

			list_objSelector = new PsychUIDropDownMenu(150,20,[],(index, name) -> {

			});

			resultsDialogBox.selectedName = 'General';
			var tab = resultsDialogBox.getTab('General').menu;
			tab.add(rankSelector);
			tab.add(rankSelector.makeLabel("Rank"));
			tab.add(list_objSelector);
			tab.add(list_objSelector.makeLabel("Object:"));

			add(resultsDialogBox);
		}

		function reloadprops(rank:ScoringRank) {
			var data = activePlayer.getResultsAnimationDatas(rank);
			propSystem.clearProps();
			//list_objSelector.list.
			for (prop in data){
				propSystem.addProp(prop);
				var parts = prop.assetPath.split("/");
				@:privateAccess
				list_objSelector.addOption(parts[parts.length-1].split(".")[0]);
			}
			propSystem.refresh();
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
	
}
