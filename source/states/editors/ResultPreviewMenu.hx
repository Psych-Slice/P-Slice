package states.editors;

import openfl.events.UncaughtErrorEvent;
import mikolka.compatibility.VsliceOptions;
import flixel.math.FlxRandom;
import backend.WeekData;
import mikolka.vslice.results.ResultState;
import objects.Character;
import states.MainMenuState;

class ResultPreviewMenu extends MusicBeatState
{
	var options:Array<String> = [
		'Preview results (perfect)', 
		'Preview results (excellent)', 
		'Preview results (great)', 
		'Preview results (good)', 
		'Preview results (shit)'
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
			leText.screenCenter();
		}

		FlxG.mouse.visible = false;
		
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
				case 'Preview results (perfect)':
					runResults(200);
				case 'Preview results (excellent)':
					runResults(190);
				case 'Preview results (great)':
					runResults(160);
				case 'Preview results (good)':
					runResults(110);
				case 'Preview results (shit)':
					runResults(30);
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
