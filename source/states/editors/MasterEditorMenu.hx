package states.editors;

import mikolka.vslice.components.crash.UserErrorSubstate;
import mikolka.editors.CharSelectEditor;
import mikolka.editors.StickerTest;
import openfl.events.UncaughtErrorEvent;
import mikolka.compatibility.VsliceOptions;
import flixel.math.FlxRandom;
import backend.WeekData;
import mikolka.vslice.results.ResultState;
import objects.Character;
import states.MainMenuState;

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
		#if debug
		'Crash the game',
		'Usermess the game',
		#end
		'Note Splash Editor', 
		'Result Preview Menu'
	];
	private var grpTexts:FlxTypedGroup<Alphabet>;
	private var directories:Array<String> = [null];

	private var curSelected = 0;
	private var curDirectory = 0;
	private var directoryTxt:FlxText;

	override function create()
	{
		FlxG.camera.bgColor = FlxColor.BLACK;
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Editors Main Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF4CAF50;
		add(bg);

		grpTexts = new FlxTypedGroup<Alphabet>();
		add(grpTexts);

		for (i in 0...options.length)
		{
			var leText:Alphabet = new Alphabet(90, 320, options[i], true);
			leText.isMenuItem = true;
			leText.targetY = i;
			grpTexts.add(leText);
			leText.snapToPosition();
		}

		#if MODS_ALLOWED
		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 42).makeGraphic(FlxG.width, 42, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		directoryTxt = new FlxText(textBG.x, textBG.y + 4, FlxG.width, '', 32);
		directoryTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		directoryTxt.scrollFactor.set();
		add(directoryTxt);

		for (folder in Mods.getModDirectories())
		{
			directories.push(folder);
		}

		var found:Int = directories.indexOf(Mods.currentModDirectory);
		if (found > -1)
			curDirectory = found;
		changeDirectory();
		#end
		changeSelection();

		FlxG.mouse.visible = false;

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad(#if MODS_ALLOWED 'LEFT_FULL' #else 'UP_DOWN' #end, 'A_B');
		#end
		
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}
		#if MODS_ALLOWED
		if (controls.UI_LEFT_P)
		{
			changeDirectory(-1);
		}
		if (controls.UI_RIGHT_P)
		{
			changeDirectory(1);
		}
		#end

		if (controls.BACK)
		{
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			switch (options[curSelected])
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
				#if debug
				case 'Crash the game':{
					@:privateAccess
					openfl.Lib.current.loaderInfo.uncaughtErrorEvents.dispatchEvent(
						new UncaughtErrorEvent(
							openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR,
							true,true,new openfl.errors.Error("The devs are too stupid and they write way too long errors")));
				}
				case 'Usermess the game':{
					openSubState(new UserErrorSubstate("The devs are too stupid and they write way too long errors","Skill issue :/"));
				}
				#end
				case 'Result Preview Menu':
					MusicBeatState.switchState(new ResultPreviewMenu());
			}
			FlxG.sound.music.volume = 0;
		}

		for (num => item in grpTexts.members)
		{
			item.targetY = num - curSelected;
			item.alpha = 0.6;
			if (item.targetY == 0)
				item.alpha = 1;
		}
		super.update(elapsed);
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

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
	}

	#if MODS_ALLOWED
	function changeDirectory(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curDirectory += change;

		if (curDirectory < 0)
			curDirectory = directories.length - 1;
		if (curDirectory >= directories.length)
			curDirectory = 0;

		WeekData.setDirectoryFromWeek();
		if (directories[curDirectory] == null || directories[curDirectory].length < 1)
			directoryTxt.text = '< No Mod Directory Loaded >';
		else
		{
			Mods.currentModDirectory = directories[curDirectory];
			directoryTxt.text = '< Loaded Mod Directory: ' + Mods.currentModDirectory + ' >';
		}
		directoryTxt.text = directoryTxt.text.toUpperCase();
	}
	#end
}
