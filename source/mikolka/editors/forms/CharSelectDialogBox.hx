package mikolka.editors.forms;

import mikolka.vslice.components.crash.UserErrorSubstate;
#if !LEGACY_PSYCH  import states.editors.content.FileDialogHandler; #end
import mikolka.editors.editorProps.CharJson;
import mikolka.editors.substates.ResultsScreenEdit;
import mikolka.editors.substates.FreeplayEditSubstate;

#if !LEGACY_PSYCH  
import states.editors.content.FileDialogHandler; 
#else
import openfl.net.FileReference;
import openfl.events.IOErrorEvent;
#end

using mikolka.editors.PsychUIUtills;

class CharSelectDialogBox extends PsychUIBox
{
    #if !LEGACY_PSYCH var fileDialog = new FileDialogHandler(); #end

	public var input_playerName:PsychUIInputText;
	public var btn_reload:PsychUIButton;
	public var input_playerId:PsychUIInputText;
	public var step_charSlot:PsychUINumericStepper;
	public var chkBox_showUnownedChars:PsychUICheckBox;

	public var input_gfAssetPath:PsychUIInputText;
	public var input_gfAnimInfoPath:PsychUIInputText;
	public var chkBox_visualiser:PsychUICheckBox;

	var validTag = true;
	var validChar = true;
    var playerId:String;

	public function new(parent:CharSelectEditor)
	{
		super(FlxG.width - 450, FlxG.height, 250, 200, ["Player", 'Girlfriend']);
		var activePlayer = parent.activePlayer;
        playerId = parent.initPlayerId;

		x -= width;
		y -= height;
		scrollFactor.set();

		// GENERAL
		input_playerId = new PsychUIInputText(20, 20, 100, playerId);
		input_playerId.onChange = (prev, cur) ->
		{
			playerId = cur;

			parent.icons.updateCharId(playerId);
			var nametagName = playerId == "bf" ? "boyfriend" : playerId;
			if (Paths.fileExists('images/charSelect/' + nametagName + "Nametag.png", TEXT))
			{
				parent.nametag.switchChar(playerId);
				validTag = true;
			}
			else
			{
				if (validTag)
					parent.nametag.switchChar("locked");
				validTag = false;
			}
			if (Paths.fileExists('images/charSelect/' + playerId + "Chill/Animation.json", TEXT))
			{
				parent.playerChill.switchChar(playerId);
				validChar = true;
			}
			else
			{
				if (validChar)
				{
					parent.playerChill.switchChar("locked");
					if (parent.playerChill == parent.animPreview.activeSprite)
						parent.animPreview.attachSprite(null);
				}
				validChar = false;
			}
		}

		btn_reload = new PsychUIButton(150, 20, "Reload", () -> {
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

		chkBox_showUnownedChars = new PsychUICheckBox(20, 85, "Show unasigned songs", 100, () ->
		{
			activePlayer._data.showUnownedChars = chkBox_showUnownedChars.checked;
		});
		chkBox_showUnownedChars.checked = activePlayer.shouldShowUnownedChars();

		step_charSlot = new PsychUINumericStepper(20, 120, 1, 4, 0, 8);
		step_charSlot.onValueChange = () ->
		{
			var index = Math.floor(step_charSlot.value);
			parent.icons.updateCharHead(index);
			activePlayer._data.charSelect.position = index;
		};

		var btn_save:PsychUIButton = new PsychUIButton(20, 150, "Save", saveCharacter.bind(parent.activePlayer));

		var btn_player_prev:PsychUIButton = new PsychUIButton(150, 50, "Anims preview", () ->
		{
			parent.animPreview.attachSprite(parent.playerChill);
			PsychUIInputText.focusOn = null;
		});
		var btn_dj:PsychUIButton = new PsychUIButton(150, 120, "Edit Freeplay", () ->
		{
			parent.persistentUpdate = false;
			parent.openSubState(new FreeplayEditSubstate(activePlayer));
		});
		var btn_result:PsychUIButton = new PsychUIButton(150, 90, "Edit Results", () ->
		{
			parent.persistentUpdate = false;
			parent.openSubState(new ResultsScreenEdit(activePlayer));
		});

		// GF
		var btn_gf_prev:PsychUIButton = new PsychUIButton(20, 20, "Anims preview", () ->
		{
			parent.animPreview.attachSprite(parent.gfChill);
			PsychUIInputText.focusOn = null;
		});
		var btn_gf_reload:PsychUIButton = new PsychUIButton(120, 20, "Reload", () ->
		{
			parent.switchEditorGF(activePlayer._data.charSelect.gf);
			if (parent.gfChill == parent.animPreview.activeSprite)
				parent.animPreview.attachSprite(null);
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
		selectedName = 'Player';
		var tab = getTab('Player').menu;

		tab.add(input_playerId.makeLabel('Name:'));
		tab.add(input_playerId);
		tab.add(btn_reload);

		tab.add(input_playerName.makeLabel("Readable name:"));
		tab.add(input_playerName);

		tab.add(chkBox_showUnownedChars);

		tab.add(step_charSlot.makeLabel("Position:"));
		tab.add(step_charSlot);

		tab.add(btn_player_prev);
		tab.add(btn_dj);
		tab.add(btn_result);

		tab.add(btn_save);

		// GF
		var tab = getTab("Girlfriend").menu;
		tab.add(btn_gf_prev);
		tab.add(btn_gf_reload);
		tab.add(input_gfAssetPath.makeLabel("Asset path:"));
		tab.add(input_gfAssetPath);
		tab.add(input_gfAnimInfoPath.makeLabel("JSFL anim folder:"));
		tab.add(input_gfAnimInfoPath);
		tab.add(chkBox_visualiser);
		//
	}

    function saveCharacter(activePlayer:PlayableCharacter)
        {
            var charData = CharJson.saveCharacter(activePlayer);
            #if mobile
            StorageUtil.saveContent('${playerId}.json', charData);
            #elseif LEGACY_PSYCH
                var file = new FileReference();
                file.addEventListener(IOErrorEvent.IO_ERROR, function(x) UserErrorSubstate.makeMessage('Error on saving character!',""));
                file.save(charData, '${playerId}.json');
            #else
            fileDialog.save('${playerId}.json', charData, null, null, function() UserErrorSubstate.makeMessage('Error on saving character!',''));
            #end
        }
}
