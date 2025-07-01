package states.editors;

#if TOUCH_CONTROLS_ALLOWED
import mobile.objects.ScrollableObject;
#end
import flixel.math.FlxRect;
import openfl.events.UncaughtErrorEvent;
import mikolka.compatibility.VsliceOptions;
import flixel.math.FlxRandom;
import backend.WeekData;
import mikolka.vslice.results.ResultState;
import objects.Character;

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

	private var curSelected:Int = 0;
	private var curSelectedPartial:Float = 0;

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
		bg.scrollFactor.set();
		add(bg);

		#if TOUCH_CONTROLS_ALLOWED
		var scroll = new ScrollableObject(-0.01,FlxRect.weak(100,0,FlxG.width-200,FlxG.height));
		scroll.onPartialScroll.add(delta -> changeSelection(delta,false));
		scroll.onFullScroll.add(delta -> {
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		});
		scroll.onTap.add(point ->{
			if(point.overlaps(grpTexts.members[curSelected])) onAccept();
		});
		add(scroll);
		#end

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
		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad("UP_DOWN", "A_B");
		#end
		super.create();
		changeSelection(0,true);
	}

	override function update(elapsed:Float)
	{
		FlxG.watch.addQuick("curSelected", curSelected);
		FlxG.watch.addQuick("curSelectedPartial", curSelectedPartial);
		if (controls.UI_UP_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			changeSelection(-1,true);
		}
		if (controls.UI_DOWN_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			changeSelection(1,true);
		}

		if (controls.BACK)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			MusicBeatState.switchState(new MasterEditorMenu());
		}

		if (controls.ACCEPT) onAccept();

		super.update(elapsed);
	}

	function onAccept() {
		switch (options[curSelected])
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

	function changeSelection(delta:Float,usePrecision:Bool = false) {
		if(usePrecision) {
			curSelected =  FlxMath.wrap(curSelected + Std.int(delta), 0, options.length - 1);
			curSelectedPartial = curSelected;
		}
		else {
			curSelectedPartial = FlxMath.bound(curSelectedPartial + delta, 0, options.length - 1);
			curSelected =  Math.round(curSelectedPartial);
		}
		for (num => item in grpTexts.members)
			{
				item.targetY = num - curSelectedPartial;
				item.alpha = 0.6;
				if (num == curSelected)
					item.alpha = 1;
			}
	}
}
