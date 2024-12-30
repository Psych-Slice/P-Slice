package mikolka.editors;

import mikolka.vslice.components.crash.UserErrorSubstate;
#if LEGACY_PSYCH
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import editors.MasterEditorMenu;
#else
import states.editors.content.FileDialogHandler;
import states.editors.MasterEditorMenu;
#end

import mikolka.compatibility.FunkinControls;
import mikolka.editors.editorProps.CharJson;
import haxe.Json;
import lime.ui.FileDialog;
import mikolka.editors.editorProps.FreeplayEditSubstate;
import mikolka.editors.editorProps.AnimPreview;
import mikolka.editors.editorProps.HelpSubstate;
import mikolka.editors.editorProps.CharIconGrid;
import mikolka.vslice.charSelect.CharSelectPlayer;
import mikolka.compatibility.FreeplayHelpers;
import mikolka.compatibility.ModsHelper;
import mikolka.funkin.players.PlayerData.PlayerCharSelectGFData;
import mikolka.compatibility.FunkinPath;
import mikolka.vslice.charSelect.CharSelectGF;
import mikolka.vslice.charSelect.Nametag;
import mikolka.vslice.charSelect.Lock;
import mikolka.vslice.freeplay.obj.PixelatedIcon;

using mikolka.funkin.custom.FunkinTools;

class CharSelectEditor extends MusicBeatState
{
	var activePlayer:PlayableCharacter;
	#if !LEGACY_PSYCH
	var fileDialog = new FileDialogHandler();
	#end
	
	var playerId:String;

	var input_playerName:PsychUIInputText;
	var btn_reload:PsychUIButton;
	var input_playerId:PsychUIInputText;
	var step_charSlot:PsychUINumericStepper;
	var chkBox_showUnownedChars:PsychUICheckBox;

	var input_gfAssetPath:PsychUIInputText;
	var input_gfAnimInfoPath:PsychUIInputText;
	var chkBox_visualiser:PsychUICheckBox;

	var nametag:Nametag;
	var gfChill:CharSelectGF;
	var currentGFPath:String;
	var playerChill:CharSelectPlayer;
	var icons:CharIconGrid;
	var animPreview:AnimPreview;

	var validTag = true;
	var validChar = true;

	public function new(playerId:String = "bf")
	{
		super();
		this.playerId = playerId;
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

		var bg:FlxSprite = new FlxSprite(-153, -140);
		bg.loadGraphic(Paths.image('charSelect/charSelectBG'));
		bg.scrollFactor.set(0.1, 0.1);
		add(bg);

		var stageSpr:FlxSprite = new FlxSprite(-40, 391);
		stageSpr.frames = Paths.getSparrowAtlas("charSelect/charSelectStage");
		stageSpr.animation.addByPrefix("idle", "stage full instance 1", 24, true);
		stageSpr.animation.play("idle");
		add(stageSpr);

		nametag = new Nametag(0, 0, playerId); // ? Set to current char
		add(nametag);

		gfChill = new CharSelectGF();
		switchEditorGF(activePlayer._data.charSelect.gf);
		add(gfChill);
		playerChill = new CharSelectPlayer(0, 0);
		playerChill.switchChar(playerId); // ? Set to current character
		playerChill.onAnimationComplete.removeAll(); // ? clear imposed triggers
		add(playerChill);

		var curtains:FlxSprite = new FlxSprite(-47, -49);
		curtains.loadGraphic(Paths.image('charSelect/curtains'));
		curtains.scrollFactor.set(1.4, 1.4);
		add(curtains);

		icons = new CharIconGrid();
		icons.initLocks(activePlayer._data.charSelect.position, playerId);
		add(icons);
		addEditorBox();

		animPreview = new AnimPreview(100, 100);
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
		currentGFPath = gfData?.assetPath != null ? FunkinPath.animateAtlas(gfData?.assetPath) : null;

		// We don't need to update any anims if we didn't change GF
		trace('currentGFPath(${currentGFPath})');
		if (currentGFPath == null || !FunkinPath.exists('images/${gfData?.assetPath}/Animation.json'))
		{
			openSubState(new UserErrorSubstate("Couldn't find GF's Atlas sprite!",
			'Failed to read the following file:\n\nimages/${gfData?.assetPath}/Animation.json'
			));
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
				openSubState(new UserErrorSubstate("Couldn't find JSFL Data files!",
				'Make sure that in:\n${animInfoPath}\n\nFollowing files are present:\nIn.txt\nOut.txt'
				));
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

	var UI_box:PsychUIBox;

	function addEditorBox()
	{
		UI_box = new PsychUIBox(FlxG.width - 450, FlxG.height, 250, 200, ["Player", 'Girlfriend']);
		UI_box.x -= UI_box.width;
		UI_box.y -= UI_box.height;
		UI_box.scrollFactor.set();
		add(UI_box);

		// GENERAL
		input_playerId = new PsychUIInputText(20, 20, 100, playerId);
		input_playerId.onChange = (prev, cur) ->
		{
			playerId = cur;

			icons.updateCharId(playerId);
			var nametagName = playerId == "bf" ? "boyfriend" : playerId;
			if (Paths.fileExists('images/charSelect/' + nametagName + "Nametag.png", TEXT))
			{
				nametag.switchChar(playerId);
				validTag = true;
			}
			else
			{
				if (validTag)
					nametag.switchChar("locked");
				validTag = false;
			}
			if (Paths.fileExists('images/charSelect/' + playerId + "Chill/Animation.json", TEXT))
			{
				playerChill.switchChar(playerId);
				validChar = true;
			}
			else
			{
				if (validChar)
				{
					playerChill.switchChar("locked");
					if (playerChill == animPreview.activeSprite)
						animPreview.attachSprite(null);
				}
				validChar = false;
			}
		}

		btn_reload = new PsychUIButton(150, 20, "Reload", () ->
		{
			#if LEGACY_PSYCH
			MusicBeatState.switchState(new CharSelectEditor(input_playerId.text));
			#else
			MusicBeatState.startTransition(new CharSelectEditor(input_playerId.text));
			#end
		});

		input_playerName = new PsychUIInputText(20, 60, 100, activePlayer._data.name);
		input_playerName.onChange = (prev, cur) ->
		{
			activePlayer._data.name = cur;
		}

		chkBox_showUnownedChars = new PsychUICheckBox(20, 85, "Show unasigned songs",100,() -> {
			activePlayer._data.showUnownedChars = chkBox_showUnownedChars.checked;
		});
		chkBox_showUnownedChars.checked = activePlayer.shouldShowUnownedChars();

		step_charSlot = new PsychUINumericStepper(20, 120, 1, 4, 0, 8);
		step_charSlot.onValueChange = () ->
		{
			var index = Math.floor(step_charSlot.value);
			icons.updateCharHead(index);
			activePlayer._data.charSelect.position = index;
		};

		var btn_save:PsychUIButton = new PsychUIButton(20, 150, "Save", saveCharacter);

		var btn_player_prev:PsychUIButton = new PsychUIButton(150, 50, "Anims preview", () ->
		{
			animPreview.attachSprite(playerChill);
			PsychUIInputText.focusOn = null;
		});
		var btn_dj:PsychUIButton = new PsychUIButton(150, 120, "Edit Freeplay", () ->
		{
			persistentUpdate = false;
			openSubState(new FreeplayEditSubstate(activePlayer));
		});


		// GF
		var btn_gf_prev:PsychUIButton = new PsychUIButton(20, 20, "Anims preview", () ->
		{
			animPreview.attachSprite(gfChill);
			PsychUIInputText.focusOn = null;
		});
		var btn_gf_reload:PsychUIButton = new PsychUIButton(120, 20, "Reload", () ->
		{
			switchEditorGF(activePlayer._data.charSelect.gf);
			if (gfChill == animPreview.activeSprite)
				animPreview.attachSprite(null);
		});
		input_gfAssetPath = new PsychUIInputText(20, 60, 100, activePlayer._data.charSelect.gf.assetPath);
		input_gfAssetPath.onChange = (p, next) ->
		{
			activePlayer._data.charSelect.gf.assetPath = next;
		};
		input_gfAnimInfoPath = new PsychUIInputText(20, 120, 100, activePlayer._data.charSelect.gf.animInfoPath);
		input_gfAnimInfoPath.onChange = (prev, next) ->
		{
			activePlayer._data.charSelect.gf.animInfoPath = next;
		};
		chkBox_visualiser = new PsychUICheckBox(20, 150, "Use visualiser", 100, () ->
		{
			activePlayer._data.charSelect.gf.visualizer = chkBox_visualiser.checked;
		});
		chkBox_visualiser.checked = activePlayer._data.charSelect.gf.visualizer;
		// ?

		// GENERAL
		UI_box.selectedName = 'Player';
		var tab = UI_box.getTab('Player').menu;
		add(UI_box);

		tab.add(newLabel(input_playerId, 'Name:'));
		tab.add(input_playerId);
		tab.add(btn_reload);

		tab.add(newLabel(input_playerName, "Readable name:"));
		tab.add(input_playerName);

		tab.add(chkBox_showUnownedChars);

		tab.add(newLabel(step_charSlot, "Position:"));
		tab.add(step_charSlot);

		tab.add(btn_player_prev);
		tab.add(btn_dj);
		
		tab.add(btn_save);

		// GF
		var tab = UI_box.getTab("Girlfriend").menu;
		tab.add(btn_gf_prev);
		tab.add(btn_gf_reload);
		tab.add(newLabel(input_gfAssetPath, "Asset path:"));
		tab.add(input_gfAssetPath);
		tab.add(newLabel(input_gfAnimInfoPath, "JSFL anim folder:"));
		tab.add(input_gfAnimInfoPath);
		tab.add(chkBox_visualiser);
		//
	}

	function newLabel(ref:FlxSprite, text:String)
	{
		return new FlxText(ref.x, ref.y - 13, 100, text);
	}

	function saveCharacter()
	{
		var charData = CharJson.saveCharacter(activePlayer);
		#if mobile
		StorageUtil.saveContent('${playerId}.json', charData);
		#elseif LEGACY_PSYCH
			var file = new FileReference();
			file.addEventListener(IOErrorEvent.IO_ERROR, function(x) openSubState(new UserErrorSubstate('Error on saving character!',"")));
			file.save(charData, '${playerId}.json');
		#else
		fileDialog.save('${playerId}.json', charData, null, null, function() openSubState(new UserErrorSubstate('Error on saving character!','')));
		#end
	}

}
