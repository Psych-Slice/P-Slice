package mikolka.editors;

import mikolka.editors.editorProps.AnimPreview;
import mikolka.editors.editorProps.CharIconGrid;
import mikolka.vslice.charSelect.CharSelectPlayer;
import mikolka.compatibility.FreeplayHelpers;
import mikolka.compatibility.ModsHelper;
import mikolka.funkin.players.PlayerData.PlayerCharSelectGFData;
import states.editors.MasterEditorMenu;
import mikolka.compatibility.FunkinPath;
import mikolka.vslice.charSelect.CharSelectGF;
import mikolka.vslice.charSelect.Nametag;
import mikolka.vslice.charSelect.Lock;
import mikolka.vslice.freeplay.obj.PixelatedIcon;

using mikolka.funkin.custom.FunkinTools;

class CharSelectEditor extends MusicBeatState
{
	var activePlayer:PlayableCharacter;

	var playerId:String;

	var input_playerName:PsychUIInputText;
	var btn_reload:PsychUIButton;
	var input_playerId:PsychUIInputText;
	var step_charSlot:PsychUINumericStepper;
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
		playerChill.switchChar(playerId); //? Set to current character
		add(playerChill);

		var curtains:FlxSprite = new FlxSprite(-47, -49);
		curtains.loadGraphic(Paths.image('charSelect/curtains'));
		curtains.scrollFactor.set(1.4, 1.4);
		add(curtains);

		icons = new CharIconGrid();
		icons.initLocks(activePlayer._data.charSelect.position,playerId);
		add(icons);
		addEditorBox();

		animPreview = new AnimPreview(100,100);
		add(animPreview);

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('NONE', 'B');
		#end
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(PsychUIInputText.focusOn == null)
            {
                ClientPrefs.toggleVolumeKeys(true);
                var b_tapped = false;
                
                #if TOUCH_CONTROLS_ALLOWED
                b_tapped = touchPad.buttonB.justPressed;
                #end

                if(controls.BACK || b_tapped){
                    FlxG.sound.playMusic(Paths.music('freakyMenu'));
                    FlxG.mouse.visible = false;
                    MusicBeatState.startTransition(new MasterEditorMenu());
                }
            }
        else ClientPrefs.toggleVolumeKeys(false);
		
		if(animPreview.activeSprite != null){
			if(controls.UI_DOWN_P) animPreview.selectAnim(1);
			if(controls.UI_UP_P) animPreview.selectAnim(-1);
			if(FlxG.keys.justPressed.SPACE) animPreview.playAnim();
			if(controls.UI_LEFT_P) animPreview.selectFrame(-1);
			if(controls.UI_RIGHT_P) animPreview.selectFrame(1);
			
		}
	}

	

	public function switchEditorGF(gf:PlayerCharSelectGFData):Void
	{
		var gfData = activePlayer?.getCharSelectData()?.gf;
		currentGFPath = gfData?.assetPath != null ? FunkinPath.animateAtlas(gfData?.assetPath) : null;

		// We don't need to update any anims if we didn't change GF
		trace('currentGFPath(${currentGFPath})');
		if (currentGFPath == null)
		{
			gfChill.visible = false;
			return;
		}
		else
		{
			gfChill.visible = true;
			gfChill.loadAtlas(currentGFPath);

			@:privateAccess
			gfChill.enableVisualizer = gfData?.visualizer ?? false;

			var animInfoPath = FunkinPath.file('images/${gfData?.animInfoPath}');
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
		UI_box = new PsychUIBox(FlxG.width, FlxG.height, 250, 200, ['General', "Player", 'Girlfriend']);
		UI_box.x -= UI_box.width;
		UI_box.y -= UI_box.height;
		UI_box.scrollFactor.set();
		add(UI_box);

		// GENERAL
		input_playerId = new PsychUIInputText(20, 20, 100, playerId);
		input_playerId.onChange = (prev,cur)->{
			playerId = cur;

			icons.updateCharId(playerId);
			var nametagName = playerId == "bf" ? "boyfriend" : playerId;
			if(Paths.fileExists('images/charSelect/' + nametagName + "Nametag.png",TEXT)){
				nametag.switchChar(playerId);
				validTag = true;
			}
			else{
				if (validTag) nametag.switchChar("locked");
				validTag = false;
			}
			if(Paths.fileExists('images/charSelect/' + playerId + "Chill/Animation.json",TEXT)){
				playerChill.switchChar(playerId);
				validChar = true;
			}
			else{
				if (validChar) {
					playerChill.switchChar("locked");
					if(playerChill == animPreview.activeSprite) animPreview.attachSprite(null);
				}
				validChar = false;
			}
		}

		btn_reload = new PsychUIButton(150, 20, "Reload", () ->
		{
			MusicBeatState.startTransition(new CharSelectEditor(input_playerId.text));
		});

		input_playerName = new PsychUIInputText(20, 60, 100, activePlayer._data.name);
		input_playerName.onChange = (prev,cur)->{
			activePlayer._data.name = cur;
		}
		step_charSlot = new PsychUINumericStepper(20, 120, 1, 4, 0, 8);
		step_charSlot.onValueChange = () ->
		{
			var index = Math.floor(step_charSlot.value);
			icons.updateCharHead(index);
			activePlayer._data.charSelect.position = index;
		};

		var btn_save:PsychUIButton = new PsychUIButton(20, 150, "Save", ()->
		{
		});
		//BF
		
		var btn_player_prev:PsychUIButton = new PsychUIButton(20, 20, "Anims preview", ()->
			{
				animPreview.attachSprite(playerChill); 
				PsychUIInputText.focusOn = null;
			});
		//GF
		var btn_gf_prev:PsychUIButton = new PsychUIButton(20, 20, "Anims preview", ()->
			{
				animPreview.attachSprite(gfChill); 
				PsychUIInputText.focusOn = null;
			});
		var btn_gf_reload:PsychUIButton = new PsychUIButton(120, 20, "Reload", ()->
			{
				switchEditorGF(activePlayer._data.charSelect.gf);
			});
		input_gfAssetPath = new PsychUIInputText(20, 60, 100, activePlayer._data.charSelect.gf.assetPath);
		input_gfAssetPath.onChange = (p,next) -> {
			activePlayer._data.charSelect.gf.assetPath = next;
		};
		input_gfAnimInfoPath = new PsychUIInputText(20, 120, 100, activePlayer._data.charSelect.gf.animInfoPath);
		input_gfAnimInfoPath.onChange = (prev,next) ->{
			activePlayer._data.charSelect.gf.animInfoPath = next;
		};
		chkBox_visualiser = new PsychUICheckBox(20,150,"Use visualiser",100,() -> {
			activePlayer._data.charSelect.gf.visualizer = chkBox_visualiser.checked;
		});
		chkBox_visualiser.checked = activePlayer._data.charSelect.gf.visualizer;
		//?

		//GENERAL
		UI_box.selectedName = 'General';
		var tab = UI_box.getTab('General').menu;
		add(UI_box);

		tab.add(newLabel(input_playerId, 'Name:'));
		tab.add(input_playerId);
		tab.add(btn_reload);

		tab.add(newLabel(input_playerName, "Readable name:"));
		tab.add(input_playerName);

		tab.add(newLabel(step_charSlot, "Position:"));
		tab.add(step_charSlot);

		tab.add(btn_save);
		//BF

		var tab = UI_box.getTab("Player").menu;
		tab.add(btn_player_prev);

		//GF
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
		return new FlxText(ref.x, ref.y - 10, 100, text);
	}
}
