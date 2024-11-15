package mikolka.editors;

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
  var grpXSpread:Float = 107;
  var grpYSpread:Float = 127;

  var playerId:String;
  
	var input_playerName:PsychUIInputText;
	var btn_reload:PsychUIButton;
	var input_playerId:PsychUIInputText;
  
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

		var BG = new FlxSprite(0, 0, Paths.image("freeplay/freeplayBGdad"));
		BG.setGraphicSize(FlxG.width, FlxG.height);
		BG.updateHitbox();
		add(BG);
    
    initLocks(activePlayer._data.charSelect.position);

    nametag = new Nametag(0,0,playerId);//? Set to current char
    add(nametag);

    gfChill = new CharSelectGF();
    switchEditorGF(activePlayer._data.charSelect.gf);
    add(gfChill);
    
		addEditorBox();

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('NONE', 'B');
		#end
		super.create();
	}

  override function update(elapsed:Float) {
    super.update(elapsed);
    if(controls.BACK){
      FlxG.sound.playMusic(Paths.music('freakyMenu'));
                    FlxG.mouse.visible = false;
                    MusicBeatState.startTransition(new MasterEditorMenu());
    }
  }

	function initLocks(initIndex:Int):Void
	{
		grpIcons = new FlxSpriteGroup();
		add(grpIcons);

		// FlxG.debugger.track(grpIcons, "iconGrp");

		for (i in 0...9)
		{
			if (i == initIndex)
			{
				var temp:PixelatedIcon = new PixelatedIcon(0, 0);
				temp.setCharacter(playerId);
				temp.setGraphicSize(128, 128);
				temp.updateHitbox();
				temp.ID = 0;
				grpIcons.add(temp);
			}
			else
			{

				var temp:Lock = new Lock(0, 0, i);
				temp.ID = 1;

				// temp.onAnimationComplete.add(function(anim) {
				//   if (anim == "unlock") playerChill.playAnimation("unlock", true);
				// });

				grpIcons.add(temp);
			}
		}

		updateIconPositions();

		grpIcons.scrollFactor.set();
	}

  function updateIconPositions()
    {
      grpIcons.x = 450;
      grpIcons.y = 120;
      for (index => member in grpIcons.members)
      {
        var posX:Float = (index % 3);
        var posY:Float = Math.floor(index / 3);
  
        member.x = posX * grpXSpread;
        member.y = posY * grpYSpread;
  
        member.x += grpIcons.x;
        member.y += grpIcons.y;
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
          @:privateAccess{
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
		UI_box = new PsychUIBox(FlxG.width, FlxG.height, 250, 200, ['General']);
		UI_box.x -= UI_box.width;
		UI_box.y -= UI_box.height;
		UI_box.scrollFactor.set();
		add(UI_box);

		input_playerId = new PsychUIInputText(20, 15, 100, playerId);
    btn_reload = new PsychUIButton(120,15,"Reload",() -> {
      MusicBeatState.startTransition(new CharSelectEditor(input_playerId.text));
    });

		input_playerName = new PsychUIInputText(20, 100, 100, activePlayer._data.name);

    var loadWeekButton:PsychUIButton = new PsychUIButton(20, 150, "Play", function()
      {
  
      });

		UI_box.selectedName = 'General';
		var tab = UI_box.getTab('General').menu;
		add(UI_box);

		tab.add(newLabel(input_playerName,'Name:'));
		tab.add(input_playerName);

		tab.add(loadWeekButton);
	}
  function newLabel(ref:FlxSprite,text:String) {
    return new FlxText(ref.x, ref.y - 15, 100, text);
  }
}
