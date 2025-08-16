package states.editors;


import objects.AlphabetMenu;
import mikolka.compatibility.VsliceOptions;
import mikolka.vslice.results.ResultState;

class ResultPreviewMenu extends MusicBeatState
{
	var options:Array<String> = [
		'Preview results (perfect)', 
		'Preview results (excellent)', 
		'Preview results (great)', 
		'Preview results (good)', 
		'Preview results (shit)'
	];
	var menu:AlphabetMenu;


	override function create()
	{
		FlxG.mouse.visible = true;
		FlxG.sound.playMusic(Paths.music('breakfast'));

		FlxG.camera.bgColor = FlxColor.BLACK;
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Result Preview Menu", null);
		#end
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.screenCenter();
		bg.scrollFactor.set();
		add(bg);

		menu = new AlphabetMenu(options);
		menu.onSelect.add(onAccept);
		add(menu);

		FlxG.mouse.visible = false;
		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad("UP_DOWN", "A_B");
		#end
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			MusicBeatState.switchState(new MasterEditorMenu());
		}

		super.update(elapsed);
	}

	function onAccept(option:String) {
		switch (option)
			{
				case 'Preview results (perfect)':
					runResults(200);
				case 'Preview results (excellent)':
					runResults(190);
				case 'Preview results (great)':
					runResults(160);
				case 'Preview results (good)':
					runResults(120);
				case 'Preview results (shit)':
					runResults(30);
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
