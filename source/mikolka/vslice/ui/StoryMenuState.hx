package mikolka.vslice.ui;

import mikolka.compatibility.VsliceOptions;
import mikolka.vslice.components.crash.UserErrorSubstate;
import mikolka.compatibility.freeplay.FreeplayHelpers;
import mikolka.compatibility.ui.StoryModeHooks;
import mikolka.compatibility.ModsHelper;
import mikolka.vslice.StickerSubState;

import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;
#if !LEGACY_PSYCH
import states.editors.MasterEditorMenu;
import backend.WeekData;
import backend.Highscore;

import objects.MenuItem;
import objects.MenuCharacter;

import options.GameplayChangersSubstate;
import substates.ResetScoreSubState;
#else
import editors.MasterEditorMenu;
#end


class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';
	public var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	public static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	public var loadedWeeks:Array<WeekData> = [];

	var stickerSubState:StickerSubState;
	public function new(?stickers:StickerSubState = null)
	{
		super();
	  
		if (stickers != null)
		{
			stickerSubState = stickers;
		}
	}

	override function create()
	{
		Paths.clearUnusedMemory();

		if (stickerSubState != null)
			{
			  //this.persistentUpdate = true;
			  //this.persistentDraw = true;
		
			  openSubState(stickerSubState);
			  ModsHelper.clearStoredWithoutStickers();
			  stickerSubState.degenStickers();
			  FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		else Paths.clearStoredMemory();

		persistentUpdate = persistentDraw = true;
		PlayState.isStoryMode = true;
		PlayState.altInstrumentals = null; //? P-Slice
		WeekData.reloadWeekFiles(true);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		final accept:String = controls.mobileC ? "A" : "ACCEPT";
		final reject:String = controls.mobileC ? "B" : "BACK";

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			UserErrorSubstate.makeMessage("NO LEVELS ADDED FOR STORY MODE","\n\nPress " + accept + " to go to the Week Editor Menu.");
			subStateClosed.addOnce(s -> FlxG.switchState(new MasterEditorMenu()));
			return;
		}

		if(curWeek >= WeekData.weeksList.length) curWeek = 0;

		#if LEGACY_PSYCH
		scoreText = new FlxText(10, 10, 0, 'LEVEL SCORE: '+lerpScore, 36);
		#else
		scoreText = new FlxText(10, 10, 0, Language.getPhrase('week_score', 'LEVEL SCORE: {1}', [lerpScore]), 36);
		#end
		scoreText.setFormat(Paths.font("vcr.ttf"), 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var bgYellow:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);
		bgSprite = new FlxSprite(0, 56);
		bgSprite.antialiasing =  VsliceOptions.ANTIALIASING;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		var num:Int = 0;
		var itemTargetY:Float = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = FreeplayHelpers.weekIsLocked(WeekData.weeksList[i]);
			if((!isLocked || !weekFile.hiddenUntilUnlocked) && weekFile != null)
			{
				loadedWeeks.push(weekFile);
				ModsHelper.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem(0, bgSprite.y + 396, WeekData.weeksList[i]);
				weekThing.y += ((weekThing.height + 20) * num);
				weekThing.ID = num;
				weekThing.targetY = itemTargetY;
				itemTargetY += Math.max(weekThing.height, 110) + 10;
				grpWeekText.add(weekThing);

				weekThing.screenCenter(X);
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (isLocked)
				{
					var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
					lock.antialiasing = VsliceOptions.ANTIALIASING;
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					grpLocks.add(lock);
				}
				num++;
			}
		}

		ModsHelper.setDirectoryFromWeek(loadedWeeks[0]);
		var charArray:Array<String> = loadedWeeks[0].weekCharacters;
		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
			weekCharacterThing.y += 70;
			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(850, grpWeekText.members[0].y + 10);
		leftArrow.antialiasing = VsliceOptions.ANTIALIASING;
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		StoryModeHooks.resetDiffList();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = StoryModeHooks.DEFAULT_DIFF;
		}
		curDifficulty = Math.round(Math.max(0, StoryModeHooks.DEFAULT_DIFFICULTIES.indexOf(lastDifficultyName)));
		
		sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.antialiasing = VsliceOptions.ANTIALIASING;
		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.antialiasing = VsliceOptions.ANTIALIASING;
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		add(new FlxSprite(0, 0).makeGraphic(FlxG.width, 56, 0xFF000000));
		add(bgYellow);
		add(bgSprite);
		add(grpWeekCharacters);

		var tracksSprite:FlxSprite = new FlxSprite(FlxG.width * 0.07 + 100, bgSprite.y + 425).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = VsliceOptions.ANTIALIASING;
		tracksSprite.x -= tracksSprite.width/2;
		add(tracksSprite);

		txtTracklist = new FlxText(FlxG.width * 0.05, tracksSprite.y + 60, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = Paths.font("vcr.ttf");
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);

		changeWeek();
		changeDifficulty();

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('LEFT_FULL', 'A_B_X_Y');
		#end

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();

		#if TOUCH_CONTROLS_ALLOWED
		removeTouchPad();
		addTouchPad('LEFT_FULL', 'A_B_X_Y');
		#end
	}

	override function update(elapsed:Float)
	{
		if(WeekData.weeksList.length < 1)
		{
			if (controls.BACK && !movedBack && !selectedWeek)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				movedBack = true;
				MusicBeatState.switchState(new MainMenuState());
			}
			super.update(elapsed);
			return;
		}

		// scoreText.setFormat(Paths.font("vcr.ttf"), 32);
		if(intendedScore != lerpScore)
		{
			lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 30)));
			if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;
	
			#if LEGACY_PSYCH
			scoreText.text = 'LEVEL SCORE: ${lerpScore}';
			#else
			scoreText.text = Language.getPhrase('week_score', 'LEVEL SCORE: {1}', [lerpScore]);
			#end
		}

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek)
		{
			var changeDiff = false;
			if (controls.UI_UP_P)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeDiff = true;
			}

			if (controls.UI_DOWN_P)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeDiff = true;
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeWeek(-FlxG.mouse.wheel);
				changeDifficulty();
			}

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			else if (controls.UI_LEFT_P)
				changeDifficulty(-1);
			else if (changeDiff)
				changeDifficulty();

			if(FlxG.keys.justPressed.CONTROL #if TOUCH_CONTROLS_ALLOWED || touchPad.buttonX.justPressed #end)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
				#if TOUCH_CONTROLS_ALLOWED
				removeTouchPad();
				#end
			}
			else if(controls.RESET #if TOUCH_CONTROLS_ALLOWED || touchPad.buttonY.justPressed #end)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				#if TOUCH_CONTROLS_ALLOWED
				removeTouchPad();
				#end
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
				selectWeek();
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
		
		var offY:Float = grpWeekText.members[curWeek].targetY;
		for (num => item in grpWeekText.members)
			item.y = FlxMath.lerp(item.targetY - offY + 480, item.y, Math.exp(-elapsed * 10.2));

		for (num => lock in grpLocks.members)
			lock.y = grpWeekText.members[lock.ID].y + grpWeekText.members[lock.ID].height/2 - lock.height/2;
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!FreeplayHelpers.weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			var succsess = StoryModeHooks.prepareWeek(this);
			if(!succsess) return;
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].isFlashing = true;
				for (char in grpWeekCharacters.members)
				{
					if (char.character != '' && char.hasConfirmAnimation)
					{
						char.animation.play('confirm');
					}
				}
				stopspamming = true;
			}
			StoryModeHooks.moveWeekToPlayState();
		}
		else FlxG.sound.play(Paths.sound('cancelMenu'));
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = StoryModeHooks.DIFFICULTIES.length-1;
		if (curDifficulty >= StoryModeHooks.DIFFICULTIES.length)
			curDifficulty = 0;

		ModsHelper.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = StoryModeHooks.getDifficultyString(curDifficulty);//Difficulty.getString(curDifficulty, false);
		var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff));
		//trace(Mods.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));

		if(sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.x = leftArrow.x + 60;
			sprDifficulty.x += (308 - sprDifficulty.width) / 3;
			sprDifficulty.alpha = 0;
			sprDifficulty.y = leftArrow.y - sprDifficulty.height + 50;

			FlxTween.cancelTweensOf(sprDifficulty);
			FlxTween.tween(sprDifficulty, {y: sprDifficulty.y + 30, alpha: 1}, 0.07);
		}
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	var lerpScore:Int = 49324858;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		var leWeek:WeekData = loadedWeeks[curWeek];
		ModsHelper.setDirectoryFromWeek(leWeek);

		#if LEGACY_PSYCH
		var leName:String = leWeek.storyName;
		#else
		var leName:String = Language.getPhrase('storyname_${leWeek.fileName}', leWeek.storyName);
		#end
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		var unlocked:Bool = !FreeplayHelpers.weekIsLocked(leWeek.fileName);
		for (num => item in grpWeekText.members)
		{
			item.alpha = 0.6;
			if (num - curWeek == 0 && unlocked)
				item.alpha = 1;
		}

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = false;
		} else {
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
		}
		PlayState.storyWeek = curWeek;

		StoryModeHooks.loadDifficultiesFromWeek();
		difficultySelectors.visible = unlocked;

		if(StoryModeHooks.DIFFICULTIES.contains(StoryModeHooks.DEFAULT_DIFF))
			curDifficulty = Math.round(Math.max(0, StoryModeHooks.DEFAULT_DIFFICULTIES.indexOf(StoryModeHooks.DEFAULT_DIFF)));
		else
			curDifficulty = 0;

		var newPos:Int = StoryModeHooks.DIFFICULTIES.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		updateText();
	}

	function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}
}
