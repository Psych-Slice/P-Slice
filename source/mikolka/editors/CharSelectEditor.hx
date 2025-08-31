package mikolka.editors;

import mikolka.funkin.custom.mobile.MobileScaleMode;
import mikolka.editors.forms.CharSelectDialogBox;
import mikolka.vslice.components.crash.UserErrorSubstate;
#if LEGACY_PSYCH
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import editors.MasterEditorMenu;
#else
import states.editors.MasterEditorMenu;
#end

import mikolka.compatibility.funkin.FunkinControls;
import mikolka.editors.editorProps.AnimPreview;
import mikolka.editors.substates.HelpSubstate;
import mikolka.editors.editorProps.CharIconGrid;
import mikolka.vslice.charSelect.CharSelectPlayer;
import mikolka.funkin.players.PlayerData.PlayerCharSelectGFData;
import mikolka.compatibility.funkin.FunkinPath;
import mikolka.vslice.charSelect.CharSelectGF;
import mikolka.vslice.charSelect.Nametag;

using mikolka.funkin.custom.FunkinTools;

class CharSelectEditor extends MusicBeatState
{
	var UI_box:PsychUIBox;
	public var activePlayer:PlayableCharacter;
	public var nametag:Nametag;
	public var gfChill:CharSelectGF;
	public var playerChill:CharSelectPlayer;
	public var icons:CharIconGrid;
	public var animPreview:AnimPreview;

	public var initPlayerId:String;
	public var currentGFPath:String;

	public function new(playerId:String = "bf")
	{
		super();
		this.initPlayerId = playerId;
		activePlayer = PlayerRegistry.instance.fetchEntry(playerId);
		if(activePlayer == null) activePlayer = PlayerRegistry.instance.fetchEntry("bf");
		if(activePlayer._data.charSelect.gf == null){
			activePlayer._data.charSelect.gf = {
				"assetPath": "charSelect/gfChill",
				"animInfoPath": "charSelect/gfAnimInfo",
				"visualizer": false
			}
		}
	}

	override function create()
	{
		FlxG.sound.music.pause();
		FlxG.mouse.visible = true;
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		var cutoutSize = MobileScaleMode.gameCutoutSize.x / 2;

		var bg:FlxSprite = new FlxSprite(cutoutSize + -153, -140);
		bg.loadGraphic(Paths.image('charSelect/charSelectBG'));
		bg.scrollFactor.set(0.1, 0.1);
		add(bg);

		var stageSpr:FlxAtlasSprite = new FlxAtlasSprite(cutoutSize + -2, 1, "charSelect/charSelectStage");
		stageSpr.anim.play("");
		stageSpr.anim.onComplete.add(function()
		{
			stageSpr.anim.play("");
		});
		add(stageSpr);

		nametag = new Nametag(0, 0, initPlayerId); // ? Set to current char
		nametag.midpointX += cutoutSize;
		add(nametag);

		gfChill = new CharSelectGF();
		gfChill.x += cutoutSize;
		switchEditorGF(activePlayer._data.charSelect.gf);
		add(gfChill);

		playerChill = new CharSelectPlayer(cutoutSize*2.5, 0);
		playerChill.switchChar(initPlayerId); // ? Set to current character
		playerChill.onAnimationComplete.removeAll(); // ? clear imposed triggers
		add(playerChill);

		var curtains:FlxSprite = new FlxSprite(cutoutSize + (-47 - 165), -49 - 50);
		curtains.loadGraphic(Paths.image('charSelect/curtains'));
		curtains.scrollFactor.set(1.4, 1.4);
		add(curtains);

		icons = new CharIconGrid();
		icons.initLocks(activePlayer._data.charSelect.position, initPlayerId);
		add(icons);
		UI_box = new CharSelectDialogBox(this);
		add(UI_box);

		animPreview = new AnimPreview(false,100, 100);
		add(animPreview);

		add(HelpSubstate.makeLabel());

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('LEFT_FULL', 'CHAR_SELECT');
		#end

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (PsychUIInputText.focusOn == null)
		{
			FunkinControls.enableVolume();
			var timeScale = Math.floor(elapsed * 100);

			if (controls.BACK)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.mouse.visible = false;
				persistentUpdate = false;
				#if LEGACY_PSYCH
				MusicBeatState.switchState(new MasterEditorMenu());
				#else
				MusicBeatState.startTransition(new MasterEditorMenu());
				#end
			}
			else if(#if TOUCH_CONTROLS_ALLOWED touchPad.buttonF.justPressed || #end FlxG.keys.justPressed.F1){
				persistentUpdate = false;
				#if TOUCH_CONTROLS_ALLOWED removeTouchPad(); #end
				openSubState(new HelpSubstate(controls.mobileC ? HelpSubstate.CHAR_EDIT_TEXT_MOBILE : HelpSubstate.CHAR_EDIT_TEXT));
			}
			if (animPreview.activeSprite != null)
			{
				if (controls.UI_DOWN_P)
					animPreview.input_selectAnim(1);
				if (controls.UI_UP_P)
					animPreview.input_selectAnim(-1);
				if (#if TOUCH_CONTROLS_ALLOWED touchPad.buttonX.justPressed || #end FlxG.keys.justPressed.SPACE)
					animPreview.input_playAnim();
				if (#if TOUCH_CONTROLS_ALLOWED touchPad.buttonC.pressed || #end FlxG.keys.pressed.SHIFT)
				{
					if (controls.UI_LEFT)
						animPreview.input_selectFrame(-1 * timeScale);
					if (controls.UI_RIGHT)
						animPreview.input_selectFrame(1 * timeScale);
				}
				else
				{
					if (controls.UI_LEFT_P)
						animPreview.input_selectFrame(-1);
					if (controls.UI_RIGHT_P)
						animPreview.input_selectFrame(1);
				}
			}
		}
		else
			FunkinControls.disableVolume();

	}

	override function closeSubState() {
		super.closeSubState();
		controls.isInSubstate = false;
		#if TOUCH_CONTROLS_ALLOWED
		removeTouchPad();
		addTouchPad('LEFT_FULL', 'CHAR_SELECT');
		#end
		persistentUpdate = true;
	}

	public function switchEditorGF(gf:PlayerCharSelectGFData):Void
	{
		var gfData = activePlayer?.getCharSelectData()?.gf;
		currentGFPath = gfData?.assetPath != null ? gfData?.assetPath : null;

		// We don't need to update any anims if we didn't change GF
		trace('currentGFPath(${currentGFPath})');
		if (currentGFPath == null || !FunkinPath.exists('images/${gfData?.assetPath}/Animation.json'))
		{
			UserErrorSubstate.makeMessage("Couldn't find GF's Atlas sprite!",
			'Failed to read the following file:\n\nimages/${gfData?.assetPath}/Animation.json'
			);
			gfChill.visible = false;
			return;
		}
		else
		{
			gfChill.visible = true;
			gfChill.loadAtlas(currentGFPath);

			@:privateAccess
			gfChill.enableVisualizer = gfData?.visualizer ?? false;

			var animInfoPath = 'images/${gfData?.animInfoPath}';
			if (!FunkinPath.exists(animInfoPath + '/In.txt') || !FunkinPath.exists(animInfoPath + '/Out.txt'))
			{
				UserErrorSubstate.makeMessage("Couldn't find JSFL Data files!",
				'Make sure that in:\n${animInfoPath}\n\nFollowing files are present:\nIn.txt\nOut.txt'
				);
				animInfoPath = 'images/charSelect/gfAnimInfo';
			}
			@:privateAccess {
				gfChill.animInInfo = FramesJSFLParser.parse(animInfoPath + '/In.txt');
				gfChill.animOutInfo = FramesJSFLParser.parse(animInfoPath + '/Out.txt');
			}
		}

		gfChill.playAnimation("idle", true, false, false);
		gfChill.updateHitbox();
	}
}
