package states.editors;

import mikolka.vslice.ui.obj.ModSelector;
import objects.AlphabetMenu;
import mikolka.vslice.components.crash.UserErrorSubstate;
import mikolka.editors.CharSelectEditor;
import mikolka.editors.StickerTest;
import mikolka.compatibility.VsliceOptions;
import backend.WeekData;
import mikolka.vslice.results.ResultState;
import objects.Character;

class MasterEditorMenu extends MusicBeatState
{
	var options:Array<String> = [
		'Chart Editor', 
		'Character Editor', 
		'Stage Editor', 
		'Week Editor', 
		'Test stickers', 
		'Menu Character Editor', 
		'Dialogue Editor', 
		'Dialogue Portrait Editor',
		'Player editor',
		#if PROFILE_BUILD
		'Crash the game',
		'Usermess the game',
		#end
		'Note Splash Editor', 
		'Result Preview Menu'
	];
	var menu:AlphabetMenu;
	private var modDir:ModSelector;

	override function create()
	{
		FlxG.camera.bgColor = FlxColor.BLACK;
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Editors Main Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.screenCenter();
		bg.color = 0xFF4CAF50;
		add(bg);

		menu = new AlphabetMenu(options);
		menu.onSelect.add(onAccept);
		add(menu);

		#if MODS_ALLOWED
		modDir = new ModSelector(null);
		modDir.allowInput = true;
		add(modDir);
		if(controls.mobileC){

			var btn_sharedY = (FlxG.height - 90);
            var prevBtn =  new PsychUIButton(40,btn_sharedY,"<=",() -> modDir.changeDirectory(-1),140,50);
            prevBtn.text.size = 30;
            prevBtn.text.y -= 10;
            prevBtn.normalStyle.bgColor = 0xFF888888;
            var nextBtn =  new PsychUIButton(((FlxG.width - 40) - 140),btn_sharedY,"=>", () -> modDir.changeDirectory(1),140,50);
            nextBtn.text.size = 30;
            nextBtn.text.y -= 10;
            nextBtn.normalStyle.bgColor = 0xFF888888;
            add(prevBtn);
            add(nextBtn);
		}
		#end

		FlxG.mouse.visible = false;
		
		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('NONE', 'B_TOP');
		#end
		super.create();
	}

	override function update(elapsed:Float)
	{
		#if MODS_ALLOWED
		if (controls.UI_LEFT_P)
		{
			modDir.changeDirectory(-1);
		}
		if (controls.UI_RIGHT_P)
		{
			modDir.changeDirectory(1);
		}
		#end

		if (controls.BACK)
		{
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	function onAccept(option:String) {
		switch (option)
			{
				case 'Chart Editor': // felt it would be cool maybe
					LoadingState.loadAndSwitchState(new ChartingState(), false);
				case 'Character Editor':
					LoadingState.loadAndSwitchState(new CharacterEditorState(Character.DEFAULT_CHARACTER, false));
				case 'Stage Editor':
					LoadingState.loadAndSwitchState(new StageEditorState());
				case 'Week Editor':
					MusicBeatState.switchState(new WeekEditorState());
				case 'Menu Character Editor':
					MusicBeatState.switchState(new MenuCharacterEditorState());
				case 'Dialogue Editor':
					LoadingState.loadAndSwitchState(new DialogueEditorState(), false);
				case 'Dialogue Portrait Editor':
					LoadingState.loadAndSwitchState(new DialogueCharacterEditorState(), false);
				case 'Note Splash Editor':
					MusicBeatState.switchState(new NoteSplashEditorState());
				case 'Test stickers':
					MusicBeatState.switchState(new StickerTest());
				case 'Player editor':
					MusicBeatState.switchState(new CharSelectEditor());
				#if PROFILE_BUILD
				case 'Crash the game':{
					trace("Break the the StackOverflow.com");
					var fnc = null;
					fnc = () -> {
						fnc();
					}
					fnc();
				}
				case 'Usermess the game':{
					UserErrorSubstate.makeMessage("The devs are too stupid and they write way too long errors","Skill issue :/");
				}
				#end
				case 'Result Preview Menu':
					MusicBeatState.switchState(new ResultPreviewMenu());
			}
			FlxG.sound.music.volume = 0;
	}

	function runResults(lol:Int)
	{
		PlayState.storyDifficultyColor = 0xFFFF0000;
		Difficulty.resetList();
		PlayState.storyDifficulty = 2;
		var results = new ResultState({
			storyMode: true,
			prevScoreRank: EXCELLENT,
			title: "Cum Song Erect by Kawai Sprite",
			songId: "cum",
			difficultyId: "nightmare",
			isNewHighscore: true,
			characterId: '',
			scoreData: {
				score: 1_234_567,
				accPoints: lol,
				sick: 199,
				good: 0,
				bad: 0,
				shit: 0,
				missed: 1,
				combo: 0,
				maxCombo: 69,
				totalNotesHit: 200,
				totalNotes: 200 // 0,
			},
		});
		@:privateAccess
		results.playerCharacterId = VsliceOptions.LAST_MOD.char_name;
		MusicBeatState.switchState(results);
	}
}
