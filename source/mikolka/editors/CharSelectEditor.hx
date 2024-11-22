package mikolka.editors;

import mikolka.compatibility.FreeplayHelpers;
import mikolka.compatibility.ModsHelper;
import mikolka.funkin.players.PlayerData.PlayerCharSelectGFData;
import states.editors.MasterEditorMenu;
import mikolka.compatibility.FunkinPath;
import mikolka.vslice.charSelect.CharSelectGF;
import mikolka.vslice.charSelect.Nametag;
import mikolka.vslice.charSelect.Lock;
import mikolka.vslice.freeplay.obj.PixelatedIcon;

class CharSelectEditor extends MusicBeatState
{
	var activePlayer:PlayableCharacter;

	var grpIcons:FlxTypedSpriteGroup<FlxSprite>;
	var charIcon:PixelatedIcon;
	var prevIndex:Int = 0;
	var grpXSpread:Float = 107;
	var grpYSpread:Float = 127;

	var playerId:String;

	var input_playerName:PsychUIInputText;
	var btn_reload:PsychUIButton;
	var input_playerId:PsychUIInputText;
	var step_charSlot:PsychUINumericStepper;

	var nametag:Nametag;
	var gfChill:CharSelectGF;
	var currentGFPath:String;

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

		var curtains:FlxSprite = new FlxSprite(-47, -49);
		curtains.loadGraphic(Paths.image('charSelect/curtains'));
		curtains.scrollFactor.set(1.4, 1.4);
		add(curtains);

		initLocks(activePlayer._data.charSelect.position);
		addEditorBox();

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('NONE', 'B');
		#end
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls.BACK)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.mouse.visible = false;
			MusicBeatState.startTransition(new MasterEditorMenu());
		}
	}

	function initLocks(index:Int):Void
	{
		grpIcons = new FlxSpriteGroup();
		add(grpIcons);

		charIcon = new PixelatedIcon(0, 0);
		charIcon.setCharacter(playerId);
		charIcon.setGraphicSize(128, 128);
		charIcon.updateHitbox();
		charIcon.ID = 0;

		for (i in 0...9)
		{
			var temp:Lock = new Lock(0, 0, i);
			temp.ID = 1;
			grpIcons.add(temp);
		}
		grpIcons.add(charIcon);

		grpIcons.x = 450;
		grpIcons.y = 120;
		for (index => member in grpIcons.members)
		{
			updateIconPosition(member, index);
		}
		updateCharHead(index);
		grpIcons.scrollFactor.set();
	}

	function updateCharHead(index:Int) {
		grpIcons.group.members[prevIndex].visible = true;
		updateIconPosition(charIcon, index);
		grpIcons.group.members[index].visible = false;
		prevIndex = index;

	}
	function updateIconPosition(member:FlxSprite, index:Int)
	{
		var posX:Float = (index % 3);
		var posY:Float = Math.floor(index / 3);

		member.x = posX * grpXSpread;
		member.y = posY * grpYSpread;

		member.x += grpIcons.x;
		member.y += grpIcons.y;
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
		UI_box = new PsychUIBox(FlxG.width, FlxG.height, 250, 200, ['General', "Player", 'Girlfrend']);
		UI_box.x -= UI_box.width;
		UI_box.y -= UI_box.height;
		UI_box.scrollFactor.set();
		add(UI_box);

		input_playerId = new PsychUIInputText(20, 20, 100, playerId);
		btn_reload = new PsychUIButton(150, 20, "Reload", () ->
		{
			MusicBeatState.startTransition(new CharSelectEditor(input_playerId.text));
		});

		input_playerName = new PsychUIInputText(20, 60, 100, activePlayer._data.name);
		step_charSlot = new PsychUINumericStepper(20, 120, 1, 4, 0, 8);
		step_charSlot.onValueChange = () ->
		{
			var index = Math.floor(step_charSlot.value);
			updateCharHead(index);
			activePlayer._data.charSelect.position = index;
		};

		var btn_save:PsychUIButton = new PsychUIButton(20, 150, "Save", function()
		{
		});

		///////////////
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
	}

	function newLabel(ref:FlxSprite, text:String)
	{
		return new FlxText(ref.x, ref.y - 10, 100, text);
	}
}
