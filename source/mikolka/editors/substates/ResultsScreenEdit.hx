package mikolka.editors.substates;

import mikolka.funkin.Scoring.ScoringRank;
import mikolka.compatibility.funkin.FunkinControls;
import flixel.util.FlxGradient;
import mikolka.compatibility.funkin.FunkinCamera;
import mikolka.editors.editorProps.ResultsPropsGrp;
import mikolka.funkin.custom.VsliceSubState;

using mikolka.editors.PsychUIUtills;

class ResultsScreenEdit extends VsliceSubState
{
	var loaded:Bool = false;
	var activePlayer:PlayableCharacter;
	var activeRank:ScoringRank;

	var resultsDialogBox:PsychUIBox;
	var resultsObjectControls_empty:FlxText;
	var resultsObjectControls:FlxSpriteGroup;
	var resultsObjectControls_labels:FlxSpriteGroup;

	var rankBg:FunkinSprite;
	final resultsAnim:FunkinSprite;
	var bgFlash:FlxSprite;
	var propSystem:ResultsPropsGrp;

	// GENERAL
	var list_objSelector:PsychUIDropDownMenu;
	var input_musicPath:PsychUIInputText;

	public function new(activePlayer:PlayableCharacter)
	{
		this.activePlayer = activePlayer;
		resultsAnim = FunkinSprite.createSparrow(-200, -10, "resultScreen/results");
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
		var soundSystem:FlxSprite = FunkinSprite.createSparrow(-15, -180, 'resultScreen/soundSystem');
		soundSystem.animation.addByPrefix("idle", "sound system", 24, false);
		soundSystem.visible = false;
		new FlxTimer().start(8 / 24, _ ->
		{
			soundSystem.animation.play("idle");
			soundSystem.visible = true;
		});
		propSystem.addStaticProp(soundSystem,"soundSystem", 1100);

		var blackTopBar:FlxSprite = new FlxSprite().loadGraphic(Paths.image("resultScreen/topBarBlack"));
		blackTopBar.y = -blackTopBar.height;
		FlxTween.tween(blackTopBar, {y: 0}, 7 / 24, {ease: FlxEase.quartOut, startDelay: 3 / 24});
		propSystem.addStaticProp(blackTopBar,"blackTopBar", 1010);

		resultsAnim.animation.addByPrefix("result", "results instance 1", 24, false);
		resultsAnim.visible = false;
		propSystem.addStaticProp(resultsAnim,"resultsAnim", 1200);
		new FlxTimer().start(6 / 24, _ ->
		{
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
		reloadprops(ScoringRank.PERFECT_GOLD);
		new FlxTimer().start(24 / 24, t ->
		{
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

	function addEditorBox()
	{
		resultsDialogBox = new PsychUIBox(FlxG.width - 500, FlxG.height, 270, 250, ['General', "Properties"]);
		resultsDialogBox.x -= resultsDialogBox.width;
		resultsDialogBox.y -= resultsDialogBox.height;
		resultsDialogBox.scrollFactor.set();
		resultsDialogBox.visible = false;

		var rankSelector = new PsychUIDropDownMenu(10, 20, ["PERFECT_GOLD", "PERFECT", "EXCELLENT", "GREAT", "GOOD", "SHIT"], (index, name) ->
		{
			reloadprops([PERFECT_GOLD, PERFECT, EXCELLENT, GREAT, GOOD, SHIT][index]);
		});

		list_objSelector = new PsychUIDropDownMenu(140, 20, [], (index, name) -> {
			var selected_prop = propSystem.sprites[index];
			if(selected_prop.data == null){
				resultsObjectControls.visible = false;
				resultsObjectControls_labels.visible = false;
				resultsObjectControls_empty.visible = true;
				return;
			}
			else if(selected_prop.data.renderType == "animateatlas"){
				resultsObjectControls_labels.visible = true;
			}
			else resultsObjectControls_labels.visible = false;
			resultsObjectControls.visible = true;
			resultsObjectControls_empty.visible = false;
		});

		input_musicPath = new PsychUIInputText(10, 60, 240);
		input_musicPath.onChange = (prevText, text) ->
		{
			var data = activePlayer._data.results.music;
			switch (activeRank)
			{
				case PERFECT_GOLD:
					data.PERFECT_GOLD = text;
				case PERFECT:
					data.PERFECT = text;
				case EXCELLENT:
					data.EXCELLENT = text;
				case GREAT:
					data.GREAT = text;
				case GOOD:
					data.GOOD = text;
				case SHIT:
					data.SHIT = text;
			}
		};

		var btn_moveUp = new PsychUIButton(140, 90, "Move up", () -> {}, 100);
		var btn_moveDown = new PsychUIButton(140, 120, "Move down", () -> {}, 100);
		var btn_newSparrow = new PsychUIButton(10, 90, "New sparrow", () -> {}, 100);
		var btn_newAtlas = new PsychUIButton(10, 120, "New atlas", () -> {}, 100);
		var btn_removeObject = new PsychUIButton(10, 150, "Remove object", () -> {}, 100);
		resultsDialogBox.selectedName = 'General';
		var tab = resultsDialogBox.getTab('General').menu;
		tab.add(input_musicPath.makeLabel("Rank music path:"));
		tab.add(input_musicPath);
		tab.add(btn_moveUp);
		tab.add(btn_moveDown);
		tab.add(btn_newSparrow);
		tab.add(btn_newAtlas);
		tab.add(btn_removeObject);
		tab.add(rankSelector.makeLabel("Rank"));
		tab.add(rankSelector);
		tab.add(list_objSelector.makeLabel("Object:"));
		tab.add(list_objSelector);

		resultsDialogBox.selectedName = 'Properties';
		var tab = resultsDialogBox.getTab('Properties').menu;
		resultsObjectControls_labels = new FlxSpriteGroup();
		resultsObjectControls = new FlxSpriteGroup();
		var input_imagePath = new PsychUIInputText(20,20,250);
		var stepper_scale = new PsychUINumericStepper(50,60);
		var stepper_offsetX = new PsychUINumericStepper(30,60);
		var stepper_offsetY = new PsychUINumericStepper(30,90);
		resultsObjectControls.add(input_imagePath);
		resultsObjectControls.add(input_imagePath.makeLabel("Image path"));
		resultsObjectControls.add(new FlxText(10, 47, 100, "Scale"));
		resultsObjectControls.add(stepper_scale);
		resultsObjectControls.add(new FlxText(10, 60, 100, "x:"));
		resultsObjectControls.add(stepper_offsetX);
		resultsObjectControls.add(new FlxText(10, 90, 100, "y:"));
		resultsObjectControls.add(stepper_offsetY);
		//resultsObjectControls.add(stepper_offsetX);

		resultsObjectControls_empty = new FlxText(0, 80, 270, "You cannot edit properties for this object");
		resultsObjectControls_empty.alignment = CENTER;
		resultsObjectControls_empty.size = 10;

		tab.add(resultsObjectControls);
		tab.add(resultsObjectControls_empty);
		tab.add(resultsObjectControls_labels);
		add(resultsDialogBox);
	}

	function reloadprops(rank:ScoringRank)
	{
		activeRank = rank;
		var data = activePlayer.getResultsAnimationDatas(rank);
		input_musicPath.text = activePlayer.getResultsMusicPath(rank);
		propSystem.clearProps();
		list_objSelector.list = [];

		for (prop in data) propSystem.addProp(prop);
		propSystem.refresh();
		@:privateAccess
		for(prop in propSystem.sprites) list_objSelector.addOption(prop.get_name());
		
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
			if (#if TOUCH_CONTROLS_ALLOWED touchPad.buttonB.justPressed || #end controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				close();
				controls.isInSubstate = false;
			}
			else if (#if TOUCH_CONTROLS_ALLOWED touchPad.buttonF.justPressed || #end FlxG.keys.justPressed.F1)
			{
				persistentUpdate = false;
				#if TOUCH_CONTROLS_ALLOWED removeTouchPad(); #end
				openSubState(new HelpSubstate(controls.mobileC ? HelpSubstate.FREEPLAY_EDIT_TEXT_MOBILE : HelpSubstate.FREEPLAY_EDIT_TEXT));
			}
		}
		else
			FunkinControls.disableVolume();
	}

	#if TOUCH_CONTROLS_ALLOWED
	override function closeSubState()
	{
		super.closeSubState();
		addTouchPad("LEFT_FULL", "A_B_C_F");
		controls.isInSubstate = true;
	}
	#end
}
