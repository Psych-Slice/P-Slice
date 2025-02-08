package mikolka.vslice.freeplay;

import mikolka.vslice.freeplay.obj.CapsuleOptionsMenu;
import mikolka.compatibility.FunkinControls;
import mikolka.vslice.charSelect.CharSelectSubState;
import openfl.filters.ShaderFilter;
import mikolka.vslice.freeplay.backcards.PicoCard;
import mikolka.vslice.freeplay.backcards.NewCharacterCard;
import mikolka.vslice.freeplay.backcards.PicoCard;
import mikolka.funkin.freeplay.FreeplayStyleRegistry;
import mikolka.vslice.freeplay.backcards.BoyfriendCard;
import shaders.BlueFade;
import mikolka.funkin.freeplay.FreeplayStyle;
import mikolka.vslice.freeplay.backcards.BackingCard;
import mikolka.vslice.freeplay.DJBoyfriend.FreeplayDJ;
import mikolka.compatibility.ModsHelper;
import mikolka.compatibility.VsliceOptions;
import mikolka.compatibility.FunkinCamera;
import mikolka.vslice.freeplay.pslice.BPMCache;
import mikolka.vslice.freeplay.pslice.FreeplayColorTweener;
import mikolka.compatibility.FreeplaySongData;
import mikolka.compatibility.FreeplayHelpers;
import mikolka.compatibility.FunkinPath as Paths;
import mikolka.funkin.custom.VsliceSubState as MusicBeatSubstate;
import openfl.utils.AssetCache;
import mikolka.funkin.AtlasText;
import shaders.PureColor;
import shaders.HSVShader;
import shaders.StrokeShader;
import shaders.AngleMask;
import mikolka.funkin.IntervalShake;
import substates.StickerSubState;
import mikolka.funkin.Scoring.ScoringRank;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import openfl.display.BlendMode;
import flixel.system.debug.watch.Tracker.TrackerProfile;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using mikolka.funkin.custom.FunkinTools;
using mikolka.funkin.utils.ArrayTools;

/**
 * Parameters used to initialize the FreeplayState.
 */
typedef FreeplayStateParams =
{
	?fromCharSelect:Bool,

	?fromResults:FromResultsParams,
};

/**
 * A set of parameters for transitioning to the FreeplayState from the ResultsState.
 */
typedef FromResultsParams =
{
	/**
	 * The previous rank the song hand, if any. Null if it had no score before.
	 */
	var ?oldRank:ScoringRank;

	/**
	 * Whether or not to play the rank animation on returning to freeplay.
	 */
	var playRankAnim:Bool;

	/**
	 * The new rank the song has.
	 */
	var newRank:ScoringRank;

	/**
	 * The song ID to play the animation on.
	 */
	var songId:String;

	/**
	 * The difficulty ID to play the animation on.
	 */
	var difficultyId:String;
};

/**
 * The state for the freeplay menu, allowing the player to select any song to play.
 */
class FreeplayState extends MusicBeatSubstate
{
	//
	// Params
	//

	/**
	 * The current character for this FreeplayState.
	 * You can't change this without transitioning to a new FreeplayState.
	 */
	final currentCharacterId:String;

	final currentCharacter:PlayableCharacter;

	/**
	 * For the audio preview, the duration of the fade-in effect.
	 */
	public static final FADE_IN_DURATION:Float = 2;

	/**
	 * For the audio preview, the duration of the fade-out effect.
	 *
	 */
	public static final FADE_OUT_DURATION:Float = 0.25;

	/**
	 * For the audio preview, the volume at which the fade-in starts.
	 */
	public static final FADE_IN_START_VOLUME:Float = 0;

	/**
	 * For the audio preview, the volume at which the fade-in ends.
	 */
	public static final FADE_IN_END_VOLUME:Float = 0.8;

	/**
	 * For the audio preview, the time to wait before attempting to load a song preview.
	 */
	public static final FADE_IN_DELAY:Float = 0.25;

	/**
	 * For the audio preview, the volume at which the fade-out starts.
	 */
	public static final FADE_OUT_END_VOLUME:Float = 0.0;

	var songs:Array<Null<FreeplaySongData>> = [];

	var diffIdsCurrent:Array<String> = [];
	// List of available difficulties for the total song list, without `-variation` at the end (no duplicates or nulls).
	var diffIdsTotal:Array<String> = ['easy', "normal", "hard"]; // ? forcing this diff order

	var curSelected:Int = 0;
	var currentDifficulty:String = Constants.DEFAULT_DIFFICULTY;

	var fp:FreeplayScore;
	var txtCompletion:AtlasText;
	var lerpCompletion:Float = 0;
	var intendedCompletion:Float = 0;
	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

	var grpDifficulties:FlxTypedSpriteGroup<DifficultySprite>;
	var grpFallbackDifficulty:FlxText;

	var coolColors:Array<Int> = [
		0xFF9271FD,
		0xFF9271FD,
		0xFF223344,
		0xFF941653,
		0xFFFC96D7,
		0xFFA0D1FF,
		0xFFFF78BF,
		0xFFF6B604
	];

	var grpSongs:FlxTypedGroup<Alphabet>;
	var grpCapsules:FlxTypedGroup<SongMenuItem>;
	var curCapsule:SongMenuItem;
	var curPlaying:Bool = false;

	var dj:Null<FreeplayDJ> = null;
	var djTouchHitbox:FlxSprite = new FlxSprite(78, 308);

	var ostName:FlxText;
	var albumRoll:AlbumRoll;

	var charSelectHint:FlxText;

	var letterSort:LetterSort;
	var exitMovers:ExitMoverData = new Map();

	var exitMoversCharSel:ExitMoverData = new Map();

	var diffSelLeft:DifficultySelector;
	var diffSelRight:DifficultySelector;

	var stickerSubState:Null<StickerSubState> = null;

	/**
	 * The difficulty we were on when this menu was last accessed.
	 */
	public static var rememberedDifficulty:String = Constants.DEFAULT_DIFFICULTY;

	/**
	 * The song we were on when this menu was last accessed.
	 * NOTE: `null` if the last song was `Random`.
	 */
	public static var rememberedSongId:Null<String> = 'tutorial';

	var funnyCam:FunkinCamera;
	var rankCamera:FunkinCamera;
	var rankBg:FunkinSprite;
	var rankVignette:FlxSprite;

	var backingCard:Null<BackingCard> = null;

	public var bgDad:FlxSprite;

	var fromResultsParams:Null<FromResultsParams> = null;

	var prepForNewRank:Bool = false;

	var styleData:Null<FreeplayStyle> = null;

	var fromCharSelect:Null<Bool> = null;

	public function new(?params:FreeplayStateParams, ?stickers:StickerSubState)
	{
		controls.isInSubstate = true;
		super();
		var saveBox = VsliceOptions.LAST_MOD;
		currentCharacterId = saveBox.char_name;
		// switch to the character's mod to load her registry
		if (ModsHelper.isModDirEnabled(saveBox.mod_dir))
			ModsHelper.loadModDir(saveBox.mod_dir);

		var result = PlayerRegistry.instance.fetchEntry(currentCharacterId);
		if (result == null)
		{
			currentCharacterId = Constants.DEFAULT_CHARACTER;
			result = PlayerRegistry.instance.fetchEntry(Constants.DEFAULT_CHARACTER);
		}
		currentCharacter = result;

		styleData = FreeplayStyleRegistry.instance.fetchEntry(currentCharacter.getFreeplayStyleID());
		if (styleData == null)
			styleData = FreeplayStyleRegistry.instance.fetchEntry("bf");

		fromCharSelect = params?.fromCharSelect;

		fromResultsParams = params?.fromResults;

		if (fromResultsParams?.playRankAnim == true)
		{
			prepForNewRank = true;
		}

		super();

		if (stickers?.members != null)
		{
			stickerSubState = stickers;
		}
	}

	var fadeShader:BlueFade = new BlueFade();

	public var angleMaskShader:AngleMask = new AngleMask();

	override function create():Void
	{
		// ? Psych might've reloaded the mod list. Make sure we select current character's mod for the style
		var saveBox = VsliceOptions.LAST_MOD;
		if (ModsHelper.isModDirEnabled(saveBox.mod_dir))
			ModsHelper.loadModDir(saveBox.mod_dir);
		// We build a bunch of sprites BEFORE create() so we can guarantee they aren't null later on.
		// ? but doing it here, because psych 0.6.3 can destroy graphics created in the constructor
		if (VsliceOptions.FP_CARDS)
		{
			switch (currentCharacterId)
			{
				case(PlayerRegistry.instance.hasNewCharacter()) => true:
					backingCard = new NewCharacterCard(currentCharacter);
				case 'bf':
					backingCard = new BoyfriendCard(currentCharacter);
				case 'pico':
					backingCard = new PicoCard(currentCharacter);
				default:
					backingCard = new BoyfriendCard(currentCharacter); // new BackingCard(currentCharacter);
			}
		}
		else
			backingCard = new BoyfriendCard(currentCharacter);

		albumRoll = new AlbumRoll();
		fp = new FreeplayScore(460, 60, 7, 100, styleData);
		rankCamera = new FunkinCamera('rankCamera', 0, 0, FlxG.width, FlxG.height);
		funnyCam = new FunkinCamera('freeplayFunny', 0, 0, FlxG.width, FlxG.height);
		grpCapsules = new FlxTypedGroup<SongMenuItem>();
		grpDifficulties = new FlxTypedSpriteGroup<DifficultySprite>(-300, 80);
		letterSort = new LetterSort(400, 75);
		grpSongs = new FlxTypedGroup<Alphabet>();
		rankBg = new FunkinSprite(0, 0);
		rankVignette = new FlxSprite(0, 0).loadGraphic(Paths.image('freeplay/rankVignette'));
		sparks = new FlxSprite(0, 0);
		sparksADD = new FlxSprite(0, 0);
		txtCompletion = new AtlasText(1185, 87, '69', AtlasFont.FREEPLAY_CLEAR);

		ostName = new FlxText(8, 8, FlxG.width - 8 - 8, 'OFFICIAL OST', 48);
		charSelectHint = new FlxText(-40, 18, FlxG.width - 8 - 8, 'Press [ LOL ] to change characters', 32);

		bgDad = new FlxSprite(backingCard.pinkBack.width * 0.74, 0).loadGraphic(styleData == null ? 'freeplay/freeplayBGdad' : styleData.getBgAssetGraphic());

		BPMCache.instance.clearCache(); // for good measure
		// ? end of init

		super.create();
		var diffIdsTotalModBinds:Map<String, String> = ["easy" => "", "normal" => "", "hard" => ""];

		FlxG.state.persistentUpdate = false;

		FlxTransitionableState.skipNextTransIn = true;

		var fadeShaderFilter:ShaderFilter = new ShaderFilter(fadeShader);
		ModsHelper.setFiltersOnCam(funnyCam, [fadeShaderFilter]);

		if (stickerSubState != null)
		{
			this.persistentUpdate = true;
			this.persistentDraw = true;

			openSubState(stickerSubState);
			stickerSubState.degenStickers();
		}

		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence('In the Menus', null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// Block input until the intro finishes.
		busy = true;

		// Add a null entry that represents the RANDOM option
		songs.push(null);
		// ? Init psych's weeks
		PlayState.isStoryMode = false;
		for (sngCard in FreeplayHelpers.loadSongs())
		{
			if (currentCharacter.shouldShowUnownedChars())
			{
				if (sngCard.songPlayer != '' && sngCard.songPlayer != currentCharacterId)
					continue;
			}
			else
			{
				if (sngCard.songPlayer == '' || sngCard.songPlayer != currentCharacterId)
					continue;
			}
			songs.push(sngCard);
			for (difficulty in sngCard.songDifficulties)
			{
				diffIdsTotal.pushUnique(difficulty);
				if (!diffIdsTotalModBinds.exists(difficulty))
					diffIdsTotalModBinds.set(difficulty, sngCard.folder);
			}
		}
		// TODO put the method
		//

		// LOAD MUSIC

		// LOAD CHARACTERS

		trace(FlxG.width);
		trace(FlxG.camera.zoom);
		trace(FlxG.camera.initialZoom);
		trace(FlxCamera.defaultZoom);

		if (backingCard != null)
		{
			add(backingCard);
			backingCard.init();
			backingCard.applyExitMovers(exitMovers, exitMoversCharSel);
			backingCard.instance = this;
		}

		if (currentCharacter?.getFreeplayDJData() != null)
		{
			ModsHelper.loadModDir(VsliceOptions.LAST_MOD.mod_dir); // ? make sure to load a mod dir of this character!
			dj = new FreeplayDJ(640, 366, currentCharacter);
			exitMovers.set([dj], {
				x: -dj.width * 1.6,
				speed: 0.5
			});
			add(dj);
			exitMoversCharSel.set([dj], {
				y: -175,
				speed: 0.8,
				wait: 0.1
			});
		}

		djTouchHitbox = djTouchHitbox.makeGraphic(250, 250, FlxColor.TRANSPARENT);
		djTouchHitbox.cameras = dj.cameras;
		djTouchHitbox.active = false;
		add(djTouchHitbox);

		bgDad.shader = angleMaskShader;
		bgDad.visible = false;

		var blackOverlayBullshitLOLXD:FlxSprite = new FlxSprite(FlxG.width, 0, Paths.image("back"));
		blackOverlayBullshitLOLXD.alpha = 1; // ? graphic because shareds are shit
		add(blackOverlayBullshitLOLXD); // used to mask the text lol!

		// this makes the texture sizes consistent, for the angle shader
		bgDad.setGraphicSize(0, FlxG.height);
		blackOverlayBullshitLOLXD.setGraphicSize(0, FlxG.height);

		bgDad.updateHitbox();
		blackOverlayBullshitLOLXD.updateHitbox();

		exitMovers.set([blackOverlayBullshitLOLXD, bgDad], {
			x: FlxG.width * 1.5,
			speed: 0.4,
			wait: 0
		});

		exitMoversCharSel.set([blackOverlayBullshitLOLXD, bgDad], {
			y: -100,
			speed: 0.8,
			wait: 0.1
		});

		add(bgDad);
		// ? changed offset
		FlxTween.tween(blackOverlayBullshitLOLXD, {x: (backingCard.pinkBack.width * 0.74)}, 0.7, {ease: FlxEase.quintOut});

		blackOverlayBullshitLOLXD.shader = bgDad.shader;

		rankBg.makeSolidColor(FlxG.width, FlxG.height, 0xD3000000);
		add(rankBg);

		add(grpSongs);

		add(grpCapsules);

		grpFallbackDifficulty = new FlxText(70, 90, 250, "AAAAAAAAAAAAAA");
		grpFallbackDifficulty.setFormat("VCR OSD Mono", 60, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		grpFallbackDifficulty.borderSize = 2;
		add(grpFallbackDifficulty);

		grpDifficulties = new FlxTypedSpriteGroup<DifficultySprite>(-300, 80);
		add(grpDifficulties);

		exitMovers.set([grpDifficulties], {
			x: -300,
			speed: 0.25,
			wait: 0
		});

		exitMoversCharSel.set([grpDifficulties], {
			y: -270,
			speed: 0.8,
			wait: 0.1
		});

		for (diffId in diffIdsTotal)
		{
			ModsHelper.loadModDir(diffIdsTotalModBinds.get(diffId));
			var diffSprite:DifficultySprite = new DifficultySprite(diffId);
			diffSprite.difficultyId = diffId;
			grpDifficulties.add(diffSprite);
		}
		ModsHelper.loadModDir(VsliceOptions.LAST_MOD.mod_dir); // ? load stuff for this Char's mod

		grpDifficulties.group.forEach(function(spr)
		{
			spr.visible = false;
		});

		for (diffSprite in grpDifficulties.group.members)
		{
			if (diffSprite == null)
				continue;
			if (diffSprite.difficultyId == currentDifficulty)
				diffSprite.visible = true;
		}

		albumRoll.albumId = null;
		add(albumRoll);

		var overhangStuff:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 164, FlxColor.BLACK);
		overhangStuff.y -= overhangStuff.height;

		var black_X = 387.76;
		// ? changed offsets
		if (fromCharSelect == true)
		{
			blackOverlayBullshitLOLXD.x = black_X + 220;
			overhangStuff.y = -100;
			backingCard?.skipIntroTween();
		}
		else
		{
			albumRoll.applyExitMovers(exitMovers, exitMoversCharSel);
			FlxTween.tween(overhangStuff, {y: -100}, 0.3, {ease: FlxEase.quartOut});
			var target = black_X - 30;
			FlxTween.tween(blackOverlayBullshitLOLXD, {x: target}, 0.7, {ease: FlxEase.quintOut});
		}

		var fnfFreeplay:FlxText = new FlxText(8, 8, 0, 'FREEPLAY', 48);
		fnfFreeplay.font = 'VCR OSD Mono';
		fnfFreeplay.visible = false;

		ostName.font = 'VCR OSD Mono';
		ostName.alignment = RIGHT;
		ostName.visible = false;

		charSelectHint.alignment = CENTER;
		charSelectHint.font = "5by7";
		charSelectHint.color = 0xFF5F5F5F;
		charSelectHint.text = controls.mobileC ? 'Touch on the DJ to change characters' : 'Press [ TAB ] to change characters'; // ?! ${controls.getDialogueNameFromControl(FREEPLAY_CHAR_SELECT, true)}
		charSelectHint.y -= 100;
		FlxTween.tween(charSelectHint, {y: charSelectHint.y + 100}, 0.8, {ease: FlxEase.quartOut});

		exitMovers.set([overhangStuff, fnfFreeplay, ostName, charSelectHint], {
			y: -overhangStuff.height,
			x: 0,
			speed: 0.2,
			wait: 0
		});

		exitMoversCharSel.set([overhangStuff, fnfFreeplay, ostName, charSelectHint], {
			y: -300,
			speed: 0.8,
			wait: 0.1
		});

		// FlxG.debugger.addTrackerProfile(new TrackerProfile(FlxSprite, ["x", "y", "alpha", "scale", "blend"]));
		// FlxG.debugger.track(overhangStuff);

		var sillyStroke:StrokeShader = new StrokeShader(0xFFFFFFFF, 2, 2);
		fnfFreeplay.shader = sillyStroke;
		ostName.shader = sillyStroke;

		var fnfHighscoreSpr:FlxSprite = new FlxSprite(860, 70);
		fnfHighscoreSpr.frames = Paths.getSparrowAtlas('freeplay/highscore');
		fnfHighscoreSpr.animation.addByPrefix('highscore', 'highscore small instance 1', 24, false);
		fnfHighscoreSpr.visible = false;
		fnfHighscoreSpr.setGraphicSize(0, Std.int(fnfHighscoreSpr.height * 1));
		fnfHighscoreSpr.updateHitbox();
		add(fnfHighscoreSpr);

		new FlxTimer().start(FlxG.random.float(12, 50), function(tmr)
		{
			fnfHighscoreSpr.animation.play('highscore');
			tmr.time = FlxG.random.float(20, 60);
		}, 0);

		fp.visible = false;
		add(fp);

		var clearBoxSprite:FlxSprite = new FlxSprite(1165, 65).loadGraphic(Paths.image('freeplay/clearBox'));
		clearBoxSprite.visible = false;
		add(clearBoxSprite);

		txtCompletion.visible = false;
		add(txtCompletion);

		add(letterSort);
		letterSort.visible = false;

		exitMovers.set([letterSort], {
			y: -100,
			speed: 0.3
		});

		exitMoversCharSel.set([letterSort], {
			y: -270,
			speed: 0.8,
			wait: 0.1
		});

		letterSort.changeSelectionCallback = (str) ->
		{
			switch (str)
			{
				case 'fav':
					generateSongList({filterType: FAVORITE}, true);
				case 'ALL':
					generateSongList(null, true);
				case '#':
					generateSongList({filterType: REGEXP, filterData: '0-9'}, true);
				default:
					generateSongList({filterType: REGEXP, filterData: str}, true);
			}

			// We want to land on the first song of the group, rather than random song when changing letter sorts
			// that is, only if there's more than one song in the group!
			if (grpCapsules.members.length > 0)
			{
				FunkinSound.playOnce(Paths.sound('scrollMenu'), 0.4);
				curSelected = 1;
				changeSelection();
			}
		};

		exitMovers.set([fp, txtCompletion, fnfHighscoreSpr, clearBoxSprite], {
			x: FlxG.width,
			speed: 0.3
		});

		exitMoversCharSel.set([fp, txtCompletion, fnfHighscoreSpr, clearBoxSprite], {
			y: -270,
			speed: 0.8,
			wait: 0.1
		});

		diffSelLeft = new DifficultySelector(this, 20, grpDifficulties.y - 10, false, controls, styleData);
		diffSelRight = new DifficultySelector(this, 325, grpDifficulties.y - 10, true, controls, styleData);
		diffSelLeft.visible = false;
		diffSelRight.visible = false;
		add(diffSelLeft);
		add(diffSelRight);

		// putting these here to fix the layering
		add(overhangStuff);
		add(fnfFreeplay);
		add(ostName);

		if (PlayerRegistry.instance.hasNewCharacter() == true)
		{
			add(charSelectHint);
		}

		// be careful not to "add()" things in here unless it's to a group that's already added to the state
		// otherwise it won't be properly attatched to funnyCamera (relavent code should be at the bottom of create())
		var onDJIntroDone = function()
		{
			busy = false;

			// when boyfriend hits dat shiii

			if (curCapsule != null) // ? prevent "random" song from stealing our albums!
			{
				albumRoll.playIntro();
				var daSong = grpCapsules.members[curSelected].songData;
				albumRoll.albumId = daSong?.albumId;
			}
			else
				albumRoll.albumId = '';

			if (fromCharSelect == null)
			{
				// render optimisation
				if (_parentState != null)
					_parentState.persistentDraw = false;

				FlxTween.color(bgDad, 0.6, 0xFF000000, 0xFFFFFFFF, {
					ease: FlxEase.expoOut,
					onUpdate: function(_)
					{
						angleMaskShader.extraColor = bgDad.color;
					}
				});
			}

			FlxTween.tween(grpDifficulties, {x: 90}, 0.6, {ease: FlxEase.quartOut});

			diffSelLeft.visible = true;
			diffSelRight.visible = true;
			letterSort.visible = true;

			exitMovers.set([diffSelLeft, diffSelRight], {
				x: -diffSelLeft.width * 2,
				speed: 0.26
			});

			exitMoversCharSel.set([diffSelLeft, diffSelRight], {
				y: -270,
				speed: 0.8,
				wait: 0.1
			});

			new FlxTimer().start(1 / 24, function(handShit)
			{
				fnfHighscoreSpr.visible = true;
				fnfFreeplay.visible = true;
				ostName.visible = true;
				fp.visible = true;
				fp.updateScore(0);

				clearBoxSprite.visible = true;
				txtCompletion.visible = true;
				intendedCompletion = 0;

				new FlxTimer().start(1.5 / 24, function(bold)
				{
					sillyStroke.width = 0;
					sillyStroke.height = 0;
					changeSelection();
				});
			});

			bgDad.visible = true;
			backingCard?.introDone();

			if (prepForNewRank && fromResultsParams != null)
			{
				rankAnimStart(fromResultsParams);
			}
		};

		if (dj != null)
		{
			dj.onIntroDone.add(onDJIntroDone);
		}
		else
		{
			onDJIntroDone();
		}
		currentDifficulty = rememberedDifficulty; // ? use last difficulty to create this list
		generateSongList(null, false);

		// dedicated camera for the state so we don't need to fuk around with camera scrolls from the mainmenu / elsewhere
		funnyCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(funnyCam, false);

		rankVignette.scale.set(2, 2);
		rankVignette.updateHitbox();
		rankVignette.blend = BlendMode.ADD;
		// rankVignette.cameras = [rankCamera];
		add(rankVignette);
		rankVignette.alpha = 0;

		forEach(function(bs)
		{
			bs.cameras = [funnyCam];
		});

		rankCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(rankCamera, false);
		rankBg.cameras = [rankCamera];
		rankBg.alpha = 0;

		if (prepForNewRank)
		{
			rankCamera.fade(0xFF000000, 0, false, null, true);
		}

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('UP_DOWN', 'A_B_F_X_Y');
		addTouchPadCamera();
		if (prepForNewRank)
		{
			final lastAlpha:Float = touchPad.alpha;
			touchPad.alpha = 0;
			FlxTween.tween(touchPad, {alpha: lastAlpha}, 1.6, {ease: FlxEase.circOut});
		}
		else if (!fromCharSelect)
		{
			touchPad.forEachAlive(function(button:TouchButton)
			{
				if (button.tag == 'UP' || button.tag == 'DOWN')
				{
					button.x -= 350;
					FlxTween.tween(button, {x: button.x + 350}, 0.6, {ease: FlxEase.backInOut});
				}
				else
				{
					button.x += 450;
					FlxTween.tween(button, {x: button.x - 450}, 0.6, {ease: FlxEase.backInOut});
				}
			});
		}
		#end

		if (fromCharSelect == true)
		{
			enterFromCharSel();
			onDJIntroDone();
		}
	}

	var currentFilter:SongFilter = null;
	var currentFilteredSongs:Array<FreeplaySongData> = [];

	/**
	 * Given the current filter, rebuild the current song list.
	 *
	 * @param filterStuff A filter to apply to the song list (regex, startswith, all, favorite)
	 * @param force Whether the capsules should "jump" back in or not using their animation
	 * @param onlyIfChanged Only apply the filter if the song list has changed
	 */
	public function generateSongList(filterStuff:Null<SongFilter>, force:Bool = false, onlyIfChanged:Bool = true):Void
	{
		var tempSongs:Array<Null<FreeplaySongData>> = songs;

		if (filterStuff != null)
			tempSongs = sortSongs(tempSongs, filterStuff);

		// Filter further by current selected difficulty.
		if (currentDifficulty != null)
		{
			tempSongs = tempSongs.filter(song ->
			{
				if (song == null)
					return true; // Random
				return song.songDifficulties.contains(currentDifficulty);
			});
		}

		if (onlyIfChanged)
		{
			// == performs equality by reference
			if (tempSongs.isEqualUnordered(currentFilteredSongs))
				return;
		}

		// Only now do we know that the filter is actually changing.

		// If curSelected is 0, the result will be null and fall back to the rememberedSongId.
		rememberedSongId = grpCapsules.members[curSelected]?.songData?.songId ?? rememberedSongId;

		for (cap in grpCapsules.members)
		{
			cap.songText.resetText();
			cap.kill();
		}

		currentFilter = filterStuff;

		currentFilteredSongs = tempSongs;
		curSelected = 0;

		var hsvShader:HSVShader = new HSVShader();

		var randomCapsule:SongMenuItem = grpCapsules.recycle(SongMenuItem);
		randomCapsule.init(FlxG.width, 0, null, styleData);
		randomCapsule.onConfirm = function()
		{
			capsuleOnConfirmRandom(randomCapsule);
		};
		randomCapsule.y = randomCapsule.intendedY(0) + 10;
		randomCapsule.targetPos.x = randomCapsule.x;
		randomCapsule.alpha = 0;
		randomCapsule.songText.visible = false;
		randomCapsule.favIcon.visible = false;
		randomCapsule.favIconBlurred.visible = false;
		randomCapsule.ranking.visible = false;
		randomCapsule.blurredRanking.visible = false;
		if (fromCharSelect == false)
		{
			randomCapsule.initJumpIn(0, force);
		}
		else
		{
			randomCapsule.forcePosition();
		}
		randomCapsule.hsvShader = hsvShader;
		grpCapsules.add(randomCapsule);

		for (i in 0...tempSongs.length)
		{
			var tempSong = tempSongs[i];
			if (tempSong == null)
				continue;

			var funnyMenu:SongMenuItem = grpCapsules.recycle(SongMenuItem);

			funnyMenu.init(FlxG.width, 0, tempSong, styleData);
			funnyMenu.onConfirm = function()
			{
				capsuleOnOpenDefault(funnyMenu);
			};
			funnyMenu.y = funnyMenu.intendedY(i + 1) + 10;
			funnyMenu.targetPos.x = funnyMenu.x;
			funnyMenu.ID = i;
			funnyMenu.capsule.alpha = 0.5;
			funnyMenu.songText.visible = false;
			funnyMenu.favIcon.visible = tempSong.isFav;
			funnyMenu.favIconBlurred.visible = tempSong.isFav;
			funnyMenu.hsvShader = hsvShader;

			funnyMenu.newText.animation.curAnim.curFrame = 45 - ((i * 4) % 45);
			funnyMenu.checkClip();
			funnyMenu.forcePosition();

			grpCapsules.add(funnyMenu);
		}

		FlxG.console.registerFunction('changeSelection', changeSelection);

		rememberSelection();

		changeSelection();
		changeDiff(0, true);
	}

	/**
	 * Filters an array of songs based on a filter
	 * @param songsToFilter What data to use when filtering
	 * @param songFilter The filter to apply
	 * @return Array<FreeplaySongData>
	 */
	public function sortSongs(songsToFilter:Array<Null<FreeplaySongData>>, songFilter:SongFilter):Array<Null<FreeplaySongData>>
	{
		var filterAlphabetically = function(a:Null<FreeplaySongData>, b:Null<FreeplaySongData>):Int
		{
			return SortUtil.alphabetically(a?.songName ?? '', b?.songName ?? '');
		};

		switch (songFilter.filterType)
		{
			case REGEXP:
				// filterStuff.filterData has a string with the first letter of the sorting range, and the second one
				// this creates a filter to return all the songs that start with a letter between those two

				// if filterData looks like "A-C", the regex should look something like this: ^[A-C].*
				// to get every song that starts between A and C
				var filterRegexp:EReg = new EReg('^[' + songFilter.filterData + '].*', 'i');
				songsToFilter = songsToFilter.filter(str ->
				{
					if (str == null)
						return true; // Random
					return filterRegexp.match(str.songName);
				});

				songsToFilter.sort(filterAlphabetically);

			case STARTSWITH:
				// extra note: this is essentially a "search"

				songsToFilter = songsToFilter.filter(str ->
				{
					if (str == null)
						return true; // Random
					return str.songName.toLowerCase().startsWith(songFilter.filterData ?? '');
				});
			case ALL:
				// no filter!
			case FAVORITE:
				songsToFilter = songsToFilter.filter(str ->
				{
					if (str == null)
						return true; // Random
					return str.isFav;
				});

				songsToFilter.sort(filterAlphabetically);

			default:
				// return all on default
		}

		return songsToFilter;
	}

	var sparks:FlxSprite;
	var sparksADD:FlxSprite;

	function rankAnimStart(fromResults:FromResultsParams):Void
	{
		busy = true;
		grpCapsules.members[curSelected].sparkle.alpha = 0;
		// grpCapsules.members[curSelected].forcePosition();

		rememberedSongId = fromResults.songId;
		rememberedDifficulty = fromResults.difficultyId;
		changeSelection();
		changeDiff();

		if (fromResultsParams?.newRank == SHIT)
		{
			if (dj != null)
				dj.fistPumpLossIntro();
		}
		else
		{
			if (dj != null)
				dj.fistPumpIntro();
		}

		// rankCamera.fade(FlxColor.BLACK, 0.5, true);
		rankCamera.fade(0xFF000000, 0.5, true, null, true);
		if (FlxG.sound.music != null)
			FlxG.sound.music.volume = 0;
		rankBg.alpha = 0.6;

		if (fromResults.oldRank != null)
		{
			grpCapsules.members[curSelected].fakeRanking.rank = fromResults.oldRank;
			grpCapsules.members[curSelected].fakeBlurredRanking.rank = fromResults.oldRank;

			sparks.frames = Paths.getSparrowAtlas('freeplay/sparks');
			sparks.animation.addByPrefix('sparks', 'sparks', 24, false);
			sparks.visible = false;
			sparks.blend = BlendMode.ADD;
			sparks.setPosition(517, 134);
			sparks.scale.set(0.5, 0.5);
			add(sparks);
			sparks.cameras = [rankCamera];

			sparksADD.visible = false;
			sparksADD.frames = Paths.getSparrowAtlas('freeplay/sparksadd');
			sparksADD.animation.addByPrefix('sparks add', 'sparks add', 24, false);
			sparksADD.setPosition(498, 116);
			sparksADD.blend = BlendMode.ADD;
			sparksADD.scale.set(0.5, 0.5);
			add(sparksADD);
			sparksADD.cameras = [rankCamera];

			switch (fromResults.oldRank)
			{
				case SHIT:
					sparksADD.color = 0xFF6044FF;
				case GOOD:
					sparksADD.color = 0xFFEF8764;
				case GREAT:
					sparksADD.color = 0xFFEAF6FF;
				case EXCELLENT:
					sparksADD.color = 0xFFFDCB42;
				case PERFECT:
					sparksADD.color = 0xFFFF58B4;
				case PERFECT_GOLD:
					sparksADD.color = 0xFFFFB619;
			}
			// sparksADD.color = sparks.color;
		}

		grpCapsules.members[curSelected].doLerp = false;

		// originalPos.x = grpCapsules.members[curSelected].x;
		// originalPos.y = grpCapsules.members[curSelected].y;

		originalPos.x = 320.488;
		originalPos.y = 235.6;
		trace(originalPos);

		grpCapsules.members[curSelected].ranking.visible = false;
		grpCapsules.members[curSelected].blurredRanking.visible = false;

		rankCamera.zoom = 1.85;
		FlxTween.tween(rankCamera, {"zoom": 1.8}, 0.6, {ease: FlxEase.sineIn});

		funnyCam.zoom = 1.15;
		FlxTween.tween(funnyCam, {"zoom": 1.1}, 0.6, {ease: FlxEase.sineIn});

		grpCapsules.members[curSelected].cameras = [rankCamera];
		// grpCapsules.members[curSelected].targetPos.set((FlxG.width / 2) - (grpCapsules.members[curSelected].width / 2),
		//  (FlxG.height / 2) - (grpCapsules.members[curSelected].height / 2));

		grpCapsules.members[curSelected].setPosition((FlxG.width / 2) - (grpCapsules.members[curSelected].width / 2),
			(FlxG.height / 2) - (grpCapsules.members[curSelected].height / 2));

		new FlxTimer().start(0.5, _ ->
		{
			rankDisplayNew(fromResults);
		});
	}

	function rankDisplayNew(fromResults:Null<FromResultsParams>):Void
	{
		grpCapsules.members[curSelected].ranking.visible = true;
		grpCapsules.members[curSelected].blurredRanking.visible = true;
		grpCapsules.members[curSelected].ranking.scale.set(20, 20);
		grpCapsules.members[curSelected].blurredRanking.scale.set(20, 20);

		if (fromResults != null && fromResults.newRank != null)
		{
			grpCapsules.members[curSelected].ranking.animation.play(fromResults.newRank.getFreeplayRankIconAsset(), true);
		}

		FlxTween.tween(grpCapsules.members[curSelected].ranking, {"scale.x": 1, "scale.y": 1}, 0.1);

		if (fromResults != null && fromResults.newRank != null)
		{
			grpCapsules.members[curSelected].blurredRanking.animation.play(fromResults.newRank.getFreeplayRankIconAsset(), true);
		}
		FlxTween.tween(grpCapsules.members[curSelected].blurredRanking, {"scale.x": 1, "scale.y": 1}, 0.1);

		new FlxTimer().start(0.1, _ ->
		{
			if (fromResults?.oldRank != null)
			{
				grpCapsules.members[curSelected].fakeRanking.visible = false;
				grpCapsules.members[curSelected].fakeBlurredRanking.visible = false;

				sparks.visible = true;
				sparksADD.visible = true;
				sparks.animation.play('sparks', true);
				sparksADD.animation.play('sparks add', true);

				sparks.animation.finishCallback = anim ->
				{
					sparks.visible = false;
					sparksADD.visible = false;
				};
			}

			switch (fromResultsParams?.newRank)
			{
				case SHIT:
					FunkinSound.playOnce(Paths.sound('ranks/rankinbad'));
				case PERFECT:
					FunkinSound.playOnce(Paths.sound('ranks/rankinperfect'));
				case PERFECT_GOLD:
					FunkinSound.playOnce(Paths.sound('ranks/rankinperfect'));
				default:
					FunkinSound.playOnce(Paths.sound('ranks/rankinnormal'));
			}
			rankCamera.zoom = 1.3;

			FlxTween.tween(rankCamera, {"zoom": 1.5}, 0.3, {ease: FlxEase.backInOut});

			grpCapsules.members[curSelected].x -= 10;
			grpCapsules.members[curSelected].y -= 20;

			FlxTween.tween(funnyCam, {"zoom": 1.05}, 0.3, {ease: FlxEase.elasticOut});

			grpCapsules.members[curSelected].capsule.angle = -3;
			FlxTween.tween(grpCapsules.members[curSelected].capsule, {angle: 0}, 0.5, {ease: FlxEase.backOut});

			IntervalShake.shake(grpCapsules.members[curSelected].capsule, 0.3, 1 / 30, 0.1, 0, FlxEase.quadOut);
		});

		new FlxTimer().start(0.4, _ ->
		{
			FlxTween.tween(funnyCam, {"zoom": 1}, 0.8, {ease: FlxEase.sineIn});
			FlxTween.tween(rankCamera, {"zoom": 1.2}, 0.8, {ease: FlxEase.backIn});
			FlxTween.tween(grpCapsules.members[curSelected], {x: originalPos.x - 7, y: originalPos.y - 80}, 0.8 + 0.5, {ease: FlxEase.quartIn});
		});

		new FlxTimer().start(0.6, _ ->
		{
			rankAnimSlam(fromResults);
		});
	}

	function rankAnimSlam(fromResultsParams:Null<FromResultsParams>)
	{
		// FlxTween.tween(rankCamera, {"zoom": 1.9}, 0.5, {ease: FlxEase.backOut});
		FlxTween.tween(rankBg, {alpha: 0}, 0.5, {ease: FlxEase.expoIn});

		// FlxTween.tween(grpCapsules.members[curSelected], {angle: 5}, 0.5, {ease: FlxEase.backIn});

		switch (fromResultsParams?.newRank)
		{
			case SHIT:
				FunkinSound.playOnce(Paths.sound('ranks/loss'));
			case GOOD:
				FunkinSound.playOnce(Paths.sound('ranks/good'));
			case GREAT:
				FunkinSound.playOnce(Paths.sound('ranks/great'));
			case EXCELLENT:
				FunkinSound.playOnce(Paths.sound('ranks/excellent'));
			case PERFECT:
				FunkinSound.playOnce(Paths.sound('ranks/perfect'));
			case PERFECT_GOLD:
				FunkinSound.playOnce(Paths.sound('ranks/perfect'));
			default:
				FunkinSound.playOnce(Paths.sound('ranks/loss'));
		}

		FlxTween.tween(grpCapsules.members[curSelected], {"targetPos.x": originalPos.x, "targetPos.y": originalPos.y}, 0.5, {ease: FlxEase.expoOut});
		new FlxTimer().start(0.5, _ ->
		{
			funnyCam.shake(0.0045, 0.35);

			if (fromResultsParams?.newRank == SHIT)
			{
				if (dj != null)
					dj.fistPumpLoss();
			}
			else
			{
				if (dj != null)
					dj.fistPump();
			}

			rankCamera.zoom = 0.8;
			funnyCam.zoom = 0.8;
			#if TOUCH_CONTROLS_ALLOWED
			IntervalShake.shake(touchPad, 0.6, 1 / 24, 0.24, 0, FlxEase.quadOut);
			#end
			FlxTween.tween(rankCamera, {"zoom": 1}, 1, {ease: FlxEase.elasticOut});
			FlxTween.tween(funnyCam, {"zoom": 1}, 0.8, {ease: FlxEase.elasticOut});

			for (index => capsule in grpCapsules.members)
			{
				var distFromSelected:Float = Math.abs(index - curSelected) - 1;

				if (distFromSelected < 5)
				{
					if (index == curSelected)
					{
						FlxTween.cancelTweensOf(capsule);
						// capsule.targetPos.x += 50;
						capsule.fadeAnim();

						rankVignette.color = capsule.getTrailColor();
						rankVignette.alpha = 1;
						FlxTween.tween(rankVignette, {alpha: 0}, 0.6, {ease: FlxEase.expoOut});

						capsule.doLerp = false;
						capsule.setPosition(originalPos.x, originalPos.y);
						IntervalShake.shake(capsule, 0.6, 1 / 24, 0.12, 0, FlxEase.quadOut, function(_)
						{
							capsule.doLerp = true;
							capsule.cameras = [funnyCam];

							// NOW we can interact with the menu
							busy = false;
							capsule.sparkle.alpha = 0.7;
							playCurSongPreview(capsule);
						}, null);

						// FlxTween.tween(capsule, {"targetPos.x": capsule.targetPos.x - 50}, 0.6,
						//   {
						//     ease: FlxEase.backInOut,
						//     onComplete: function(_) {
						//       capsule.cameras = [funnyCam];
						//     }
						//   });
						FlxTween.tween(capsule, {angle: 0}, 0.5, {ease: FlxEase.backOut});
					}
					if (index > curSelected)
					{
						// capsule.color = FlxColor.RED;
						new FlxTimer().start(distFromSelected / 20, _ ->
						{
							capsule.doLerp = false;

							capsule.capsule.angle = FlxG.random.float(-10 + (distFromSelected * 2), 10 - (distFromSelected * 2));
							FlxTween.tween(capsule.capsule, {angle: 0}, 0.5, {ease: FlxEase.backOut});

							IntervalShake.shake(capsule, 0.6, 1 / 24, 0.12 / (distFromSelected + 1), 0, FlxEase.quadOut, function(_)
							{
								capsule.doLerp = true;
							});
						});
					}

					if (index < curSelected)
					{
						// capsule.color = FlxColor.BLUE;
						new FlxTimer().start(distFromSelected / 20, _ ->
						{
							capsule.doLerp = false;

							capsule.capsule.angle = FlxG.random.float(-10 + (distFromSelected * 2), 10 - (distFromSelected * 2));
							FlxTween.tween(capsule.capsule, {angle: 0}, 0.5, {ease: FlxEase.backOut});

							IntervalShake.shake(capsule, 0.6, 1 / 24, 0.12 / (distFromSelected + 1), 0, FlxEase.quadOut, function(_)
							{
								capsule.doLerp = true;
							});
						});
					}
				}

				index += 1;
			}
		});

		new FlxTimer().start(2, _ ->
		{
			// dj.fistPump();
			prepForNewRank = false;
		});
	}

	override function closeSubState()
	{
		super.closeSubState();
		
		controls.isInSubstate = true;
		#if TOUCH_CONTROLS_ALLOWED
		backend.MusicBeatSubstate.instance = this;
		persistentUpdate = true;
		removeTouchPad();
		addTouchPad('UP_DOWN', 'A_B_F_X_Y');
		addTouchPadCamera();
		#end
	}

	function tryOpenCharSelect():Void
	{
		// Check if we have ACCESS to character select!
		trace('Is Pico unlocked? ${PlayerRegistry.instance.fetchEntry('pico')?.isUnlocked()}');
		trace('Number of characters: ${PlayerRegistry.instance.countUnlockedCharacters()}');

		if (PlayerRegistry.instance.countUnlockedCharacters() > 1)
		{
			trace('Opening character select!');
		}
		else
		{
			trace('Not enough characters unlocked to open character select!');
			FunkinSound.playOnce(Paths.sound('cancelMenu'));
			return;
		}

		busy = true;

		FunkinSound.playOnce(Paths.sound('confirmMenu'));

		if (dj != null)
		{
			dj.toCharSelect();
		}

		// Get this character's transition delay, with a reasonable default.
		var transitionDelay:Float = currentCharacter.getFreeplayDJData()?.getCharSelectTransitionDelay() ?? 0.25;

		new FlxTimer().start(transitionDelay, _ ->
		{
			transitionToCharSelect();
		});
	}

	function transitionToCharSelect():Void
	{
		var transitionGradient = new FlxSprite(0, 720).loadGraphic(Paths.image('freeplay/transitionGradient'));
		transitionGradient.scale.set(1280, 1);
		transitionGradient.updateHitbox();
		transitionGradient.cameras = [rankCamera];
		exitMoversCharSel.set([transitionGradient], {
			y: -720,
			speed: 0.8,
			wait: 0.1
		});
		add(transitionGradient);
		for (index => capsule in grpCapsules.members)
		{
			var distFromSelected:Float = Math.abs(index - curSelected) - 1;
			if (distFromSelected < 5)
			{
				capsule.doLerp = false;
				exitMoversCharSel.set([capsule], {
					y: -250,
					speed: 0.8,
					wait: 0.1
				});
			}
		}
		fadeShader.fade(1.0, 0.0, 0.8, {ease: FlxEase.quadIn});
		FlxG.sound.music.fadeOut(0.9, 0);
		new FlxTimer().start(0.9, _ ->
		{
			FlxG.switchState(new CharSelectSubState());
		});
		for (grpSpr in exitMoversCharSel.keys())
		{
			var moveData:Null<MoveData> = exitMoversCharSel.get(grpSpr);
			if (moveData == null)
				continue;

			for (spr in grpSpr)
			{
				if (spr == null)
					continue;

				var funnyMoveShit:MoveData = moveData;

				var moveDataY = funnyMoveShit.y ?? spr.y;
				var moveDataSpeed = funnyMoveShit.speed ?? 0.2;
				var moveDataWait = funnyMoveShit.wait ?? 0.0;

				FlxTween.tween(spr, {y: moveDataY + spr.y}, moveDataSpeed, {ease: FlxEase.backIn});
			}
		}
		#if TOUCH_CONTROLS_ALLOWED
		FlxTween.tween(touchPad, {alpha: 0}, 0.6, {ease: FlxEase.backIn});
		#end
		backingCard?.enterCharSel();
	}

	function enterFromCharSel():Void
	{
		busy = true;
		if (_parentState != null)
			_parentState.persistentDraw = false;

		var transitionGradient = new FlxSprite(0, 720).loadGraphic(Paths.image('freeplay/transitionGradient'));
		transitionGradient.scale.set(1280, 1);
		transitionGradient.updateHitbox();
		transitionGradient.cameras = [rankCamera];
		exitMoversCharSel.set([transitionGradient], {
			y: -720,
			speed: 1.5,
			wait: 0.1
		});
		add(transitionGradient);
		changeDiff(0, true);
		// FlxTween.tween(transitionGradient, {alpha: 0}, 1, {ease: FlxEase.circIn});
		// for (index => capsule in grpCapsules.members)
		// {
		//   var distFromSelected:Float = Math.abs(index - curSelected) - 1;
		//   if (distFromSelected < 5)
		//   {
		//     capsule.doLerp = false;
		//     exitMoversCharSel.set([capsule],
		//       {
		//         y: -250,
		//         speed: 0.8,
		//         wait: 0.1
		//       });
		//   }
		// }
		fadeShader.fade(0.0, 1.0, 0.8, {ease: FlxEase.quadIn});
		for (grpSpr in exitMoversCharSel.keys())
		{
			var moveData:Null<MoveData> = exitMoversCharSel.get(grpSpr);
			if (moveData == null)
				continue;

			for (spr in grpSpr)
			{
				if (spr == null)
					continue;

				var funnyMoveShit:MoveData = moveData;

				var moveDataY = funnyMoveShit.y ?? spr.y;
				var moveDataSpeed = funnyMoveShit.speed ?? 0.2;
				var moveDataWait = funnyMoveShit.wait ?? 0.0;

				spr.y += moveDataY;
				FlxTween.tween(spr, {y: spr.y - moveDataY}, moveDataSpeed * 1.2, {
					ease: FlxEase.expoOut,
					onComplete: function(_)
					{
						for (index => capsule in grpCapsules.members)
						{
							capsule.doLerp = true;
							fromCharSelect = false;
							busy = false;
							albumRoll.applyExitMovers(exitMovers, exitMoversCharSel);
						}
					}
				});
			}
			#if TOUCH_CONTROLS_ALLOWED
			touchPad.alpha = 0;
			FlxTween.tween(touchPad, {alpha: ClientPrefs.data.controlsAlpha}, 0.8, {ease: FlxEase.backIn});
			#end
		}
	}

	var touchY:Float = 0;
	var touchX:Float = 0;
	var dxTouch:Float = 0;
	var dyTouch:Float = 0;
	var velTouch:Float = 0;

	var touchTimer:Float = 0;

	var initTouchPos:FlxPoint = new FlxPoint();

	var spamTimer:Float = 0;
	var spamming:Bool = false;

	/**
	 * If true, disable interaction with the interface.
	 */
	public var busy:Bool = false;

	var originalPos:FlxPoint = new FlxPoint();

	var hintTimer:Float = 0;

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (charSelectHint != null)
		{
			hintTimer += elapsed * 2;
			var targetAmt:Float = (Math.sin(hintTimer) + 1) / 2;
			charSelectHint.alpha = FlxMath.lerp(0.3, 0.9, targetAmt);
		}

		#if FEATURE_DEBUG_FUNCTIONS
		if (FlxG.keys.justPressed.P)
		{
			FlxG.switchState(() -> FreeplayState.build({
				{
					character: currentCharacterId == "pico" ? Constants.DEFAULT_CHARACTER : "pico",
				}
			}));
		}

		if (FlxG.keys.justPressed.T)
		{
			rankAnimStart(fromResultsParams ?? {
				playRankAnim: true,
				newRank: PERFECT_GOLD,
				songId: "tutorial",
				difficultyId: "hard"
			});
		}

		if (FlxG.keys.justPressed.H)
		{
			rankDisplayNew(fromResultsParams);
		}

		if (FlxG.keys.justPressed.G)
		{
			rankAnimSlam(fromResultsParams);
		}
		#end // ^<-- FEATURE_DEBUG_FUNCTIONS

		if (!busy)
		{
			if ((FunkinControls.FREEPLAY_CHAR
				|| (TouchUtil.overlapsComplex(djTouchHitbox) && TouchUtil.justReleased && !SwipeUtil.swipeAny)))
			{
				tryOpenCharSelect();
			} //? Those are new too
			else if (FlxG.keys.justPressed.CONTROL #if TOUCH_CONTROLS_ALLOWED || touchPad?.buttonX.justPressed #end)
			{
				persistentUpdate = false;
				#if TOUCH_CONTROLS_ALLOWED
				removeTouchPad();
				#end
				FreeplayHelpers.openGameplayChanges(this);
			}
			else if (controls.RESET #if TOUCH_CONTROLS_ALLOWED || touchPad?.buttonY.justPressed #end && curSelected != 0)
			{
				persistentUpdate = false;
				var curSng = grpCapsules.members[curSelected];
				#if TOUCH_CONTROLS_ALLOWED
				removeTouchPad();
				#end

				FreeplayHelpers.openResetScoreState(this,curSng.songData,() -> {
					curSng.songData.scoringRank = null;
					intendedScore = 0;
					intendedCompletion = 0;
					curSng.songData.updateIsNewTag();
					curSng.refreshDisplay();
				});
				FunkinSound.playOnce(Paths.sound('scrollMenu'), 0.4);
			} //? //!
		}

		if (controls.FAVORITE #if TOUCH_CONTROLS_ALLOWED || touchPad?.buttonF.justPressed #end && !busy) // ? change control binding
		{
			var targetSong = grpCapsules.members[curSelected]?.songData;
			if (targetSong != null)
			{
				var realShit:Int = curSelected;
				var isFav = targetSong.toggleFavorite();
				if (isFav)
				{
					grpCapsules.members[realShit].favIcon.visible = true;
					grpCapsules.members[realShit].favIconBlurred.visible = true;
					grpCapsules.members[realShit].favIcon.animation.play('fav');
					grpCapsules.members[realShit].favIconBlurred.animation.play('fav');
					FunkinSound.playOnce(Paths.sound('fav'), 1);
					grpCapsules.members[realShit].checkClip();
					grpCapsules.members[realShit].selected = grpCapsules.members[realShit].selected; // set selected again, so it can run it's getter function to initialize movement
					busy = true;

					grpCapsules.members[realShit].doLerp = false;
					FlxTween.tween(grpCapsules.members[realShit], {y: grpCapsules.members[realShit].y - 5}, 0.1, {ease: FlxEase.expoOut});

					FlxTween.tween(grpCapsules.members[realShit], {y: grpCapsules.members[realShit].y + 5}, 0.1, {
						ease: FlxEase.expoIn,
						startDelay: 0.1,
						onComplete: function(_)
						{
							grpCapsules.members[realShit].doLerp = true;
							busy = false;
						}
					});
				}
				else
				{
					grpCapsules.members[realShit].favIcon.animation.play('fav', true, true, 9);
					grpCapsules.members[realShit].favIconBlurred.animation.play('fav', true, true, 9);
					FunkinSound.playOnce(Paths.sound('unfav'), 1);
					new FlxTimer().start(0.2, _ ->
					{
						grpCapsules.members[realShit].favIcon.visible = false;
						grpCapsules.members[realShit].favIconBlurred.visible = false;
						grpCapsules.members[realShit].checkClip();
					});

					busy = true;
					grpCapsules.members[realShit].doLerp = false;
					FlxTween.tween(grpCapsules.members[realShit], {y: grpCapsules.members[realShit].y + 5}, 0.1, {ease: FlxEase.expoOut});

					FlxTween.tween(grpCapsules.members[realShit], {y: grpCapsules.members[realShit].y - 5}, 0.1, {
						ease: FlxEase.expoIn,
						startDelay: 0.1,
						onComplete: function(_)
						{
							grpCapsules.members[realShit].doLerp = true;
							busy = false;
						}
					});
				}
			}
		}

		lerpScore = MathUtil.smoothLerp(lerpScore, intendedScore, elapsed, 0.5);
		lerpCompletion = MathUtil.smoothLerp(lerpCompletion, intendedCompletion, elapsed, 0.5);

		if (Math.isNaN(lerpScore))
		{
			lerpScore = intendedScore;
		}

		if (Math.isNaN(lerpCompletion))
		{
			lerpCompletion = intendedCompletion;
		}

		fp.updateScore(Std.int(lerpScore));

		txtCompletion.text = '${Math.floor(lerpCompletion * 100)}';

		// Right align the completion percentage
		switch (txtCompletion.text.length)
		{
			case 3:
				txtCompletion.offset.x = 10;
			case 2:
				txtCompletion.offset.x = 0;
			case 1:
				txtCompletion.offset.x = -24;
			default:
				txtCompletion.offset.x = 0;
		}

		handleInputs(elapsed);

		if (dj != null)
			FlxG.watch.addQuick('dj-anim', dj.getCurrentAnimation());
	}

	function handleInputs(elapsed:Float):Void
	{
		if (busy)
			return;

		var upP:Bool = controls.UI_UP_P #if TOUCH_CONTROLS_ALLOWED || touchPad?.buttonUp.justPressed #end;
		var downP:Bool = controls.UI_DOWN_P #if TOUCH_CONTROLS_ALLOWED || touchPad?.buttonDown.justPressed #end;
		var accepted:Bool = controls.ACCEPT #if TOUCH_CONTROLS_ALLOWED || touchPad?.buttonA.justPressed #end;
		//? new tags
		var up = controls.UI_UP #if TOUCH_CONTROLS_ALLOWED || touchPad?.buttonUp.pressed #end;
		var down = controls.UI_DOWN #if TOUCH_CONTROLS_ALLOWED || touchPad?.buttonDown.pressed #end;
		if ((up || down))
		{
			if (spamming)
			{
				if (spamTimer >= 0.07)
				{
					spamTimer = 0;

					if (up)
					{
						changeSelection(-1);
					}
					else
					{
						changeSelection(1);
					}
				}
			}
			else if (spamTimer >= 0.9)
			{
				spamming = true;
			}
			else if (spamTimer <= 0)
			{
				if (up)
				{
					changeSelection(-1);
				}
				else
				{
					changeSelection(1);
				}
			}

			spamTimer += elapsed;
			if (dj != null)
				dj.resetAFKTimer();
		}
		else
		{
			spamming = false;
			spamTimer = 0;
		}

		#if !html5
		if (FlxG.mouse.wheel != 0)
		{
			if (dj != null)
				dj.resetAFKTimer();
			changeSelection(-Math.round(FlxG.mouse.wheel));
		}
		#else
		if (FlxG.mouse.wheel < 0)
		{
			if (dj != null)
				dj.resetAFKTimer();
			changeSelection(-Math.round(FlxG.mouse.wheel / 8));
		}
		else if (FlxG.mouse.wheel > 0)
		{
			if (dj != null)
				dj.resetAFKTimer();
			changeSelection(-Math.round(FlxG.mouse.wheel / 8));
		}
		#end

		if (controls.UI_LEFT_P || (TouchUtil.overlapsComplex(diffSelLeft) && TouchUtil.justPressed))
		{
			if (dj != null)
				dj.resetAFKTimer();
			changeDiff(-1);
			rememberedDifficulty = currentDifficulty; // ? make sure to remember it, because otherwise we'll forget about it
			generateSongList(currentFilter, true);
			if (diffSelLeft != null)
				diffSelLeft.setPress(true);
		}
		if (controls.UI_RIGHT_P || (TouchUtil.overlapsComplex(diffSelRight) && TouchUtil.justPressed))
		{
			if (dj != null)
				dj.resetAFKTimer();
			changeDiff(1);
			rememberedDifficulty = currentDifficulty; // ? make sure to remember it, because otherwise we'll forget about it
			generateSongList(currentFilter, true);
			if (diffSelLeft != null)
				diffSelRight.setPress(true);
		}

		if (diffSelLeft != null && diffSelRight != null && TouchUtil.justReleased)
		{
			diffSelRight.setPress(false);
			diffSelLeft.setPress(false);
		}

		if (controls.BACK #if TOUCH_CONTROLS_ALLOWED || touchPad?.buttonB.justPressed #end && !busy)
		{
			busy = true;
			FlxTween.globalManager.clear();
			FlxTimer.globalManager.clear();
			if (dj != null)
				dj.onIntroDone.removeAll();

			FunkinSound.playOnce(Paths.sound('cancelMenu'));
			FreeplayHelpers.exitFreeplay();

			var longestTimer:Float = 0;

			// //? edited so that freeplay color works
			// FlxTween.color(pinkBack, 0.25, pinkBack.color, 0xFFFFD0D5, {ease: FlxEase.quadOut});
			// FlxTween.color(bgDad, 0.33, 0xFFFFFFFF, 0xFF555555, {ease: FlxEase.quadOut});
			backingCard?.disappear();

			#if TOUCH_CONTROLS_ALLOWED
			touchPad.forEachAlive(function(button:TouchButton)
			{
				if (button.tag == 'UP' || button.tag == 'DOWN')
					FlxTween.tween(button, {x: button.x - 350}, 1.2, {ease: FlxEase.backOut});
				else
					FlxTween.tween(button, {x: button.x + 450}, 1.2, {ease: FlxEase.backOut});
			});
			#end

			for (grpSpr in exitMovers.keys())
			{
				var moveData:Null<MoveData> = exitMovers.get(grpSpr);
				if (moveData == null)
					continue;

				for (spr in grpSpr)
				{
					if (spr == null)
						continue;

					var funnyMoveShit:MoveData = moveData;

					var moveDataX = funnyMoveShit.x ?? spr.x;
					var moveDataY = funnyMoveShit.y ?? spr.y;
					var moveDataSpeed = funnyMoveShit.speed ?? 0.2;
					var moveDataWait = funnyMoveShit.wait ?? 0.0;

					FlxTween.tween(spr, {x: moveDataX, y: moveDataY}, moveDataSpeed, {ease: FlxEase.expoIn});

					longestTimer = Math.max(longestTimer, moveDataSpeed + moveDataWait);
				}
			}

			for (caps in grpCapsules.members)
			{
				caps.doJumpIn = false;
				caps.doLerp = false;
				caps.doJumpOut = true;
			}

			if (Type.getClass(_parentState) == MainMenuState)
			{
				_parentState.persistentUpdate = false;
				_parentState.persistentDraw = true;
			}

			new FlxTimer().start(longestTimer, (_) ->
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if (Type.getClass(_parentState) == MainMenuState)
				{
					FunkinSound.playMusic('freakyMenu', {
						overrideExisting: true,
						restartTrack: false
					});
					FlxG.sound.music.fadeIn(4.0, 0.0, 1.0);
					close();
				}
				else
				{
					FlxG.switchState(new MainMenuState());
				}
			});
		}
		else if (accepted) // ? bugfix
		{
			grpCapsules.members[curSelected].onConfirm();
		}
	}

	override function beatHit()
	{
		backingCard?.beatHit(curBeat);

		super.beatHit();
	}

	public override function destroy():Void
	{
		controls.isInSubstate = false;
		super.destroy();
		var daSong:Null<FreeplaySongData> = currentFilteredSongs[curSelected];
		if (daSong != null)
		{
			clearDaCache(daSong.songName);
		}
		// remove and destroy freeplay camera
		FlxG.cameras.remove(funnyCam);
	}

	function changeDiff(change:Int = 0, force:Bool = false):Void
	{
		touchTimer = 0;

		var currentDifficultyIndex:Int = diffIdsCurrent.indexOf(currentDifficulty);

		if (currentDifficultyIndex == -1)
			currentDifficultyIndex = diffIdsCurrent.indexOf(Constants.DEFAULT_DIFFICULTY);

		currentDifficultyIndex += change;

		if (currentDifficultyIndex < 0)
			currentDifficultyIndex = diffIdsCurrent.length - 1;
		if (currentDifficultyIndex >= diffIdsCurrent.length)
			currentDifficultyIndex = 0;

		currentDifficulty = diffIdsCurrent[currentDifficultyIndex];

		var daSong:Null<FreeplaySongData> = grpCapsules.members[curSelected].songData;
		if (daSong != null)
		{
			// ? changed how this loads score
			daSong.currentDifficulty = currentDifficulty;
			var diffId = daSong.loadAndGetDiffId(); // 12
			var songScore:Int = Highscore.getScore(daSong.songId,
				diffId); // Save.instance.getSongScore(grpCapsules.members[curSelected].songData.songId, suffixedDifficulty);
			intendedScore = songScore ?? 0;
			intendedCompletion = Highscore.getRating(daSong.songId, diffId);
			rememberedDifficulty = currentDifficulty;
		}
		else
		{
			intendedScore = 0;
			intendedCompletion = 0.0;
		}

		if (intendedCompletion == Math.POSITIVE_INFINITY || intendedCompletion == Math.NEGATIVE_INFINITY || Math.isNaN(intendedCompletion))
		{
			intendedCompletion = 0;
		}

		grpDifficulties.group.forEach(function(diffSprite)
		{
			diffSprite.visible = false;
		});

		for (diffSprite in grpDifficulties.group.members)
		{
			if (diffSprite == null)
				continue;
			if (diffSprite.difficultyId == currentDifficulty)
			{
				grpFallbackDifficulty.text = "";
				if (diffSprite.hasValidTexture)
				{
					if (change != 0)
					{
						diffSprite.visible = true;
						diffSprite.offset.y += 5;
						diffSprite.alpha = 0.5;
						new FlxTimer().start(1 / 24, function(swag)
						{
							diffSprite.alpha = 1;
							diffSprite.updateHitbox();
						});
					}
					else
					{
						diffSprite.visible = true;
					}
				}
				else
				{
					grpFallbackDifficulty.text = diffSprite.difficultyId;
					grpFallbackDifficulty.updateHitbox();
				}
			}
		}

		if (change != 0 || force)
		{
			// Update the song capsules to reflect the new difficulty info.
			for (songCapsule in grpCapsules.members)
			{
				if (songCapsule == null)
					continue;
				if (songCapsule.songData != null)
				{
					songCapsule.songData.currentDifficulty = currentDifficulty;
					songCapsule.init(null, null, songCapsule.songData);
					songCapsule.checkClip();
				}
				else
				{
					songCapsule.init(null, null, null);
				}
			}
		}

		// Set the album graphic and play the animation if relevant.
		var newAlbumId:Null<String> = daSong?.albumId;
		if (albumRoll.albumId != newAlbumId)
		{
			albumRoll.albumId = newAlbumId;
			albumRoll.skipIntro();
		}

		// Set difficulty star count.
		albumRoll.setDifficultyStars(daSong?.difficultyRating);
	}

	// Clears the cache of songs, frees up memory, they' ll have to be loaded in later tho function clearDaCache(actualSongTho:String)
	function clearDaCache(actualSongTho:String):Void
	{
		// ? changed implementation of this
		trace("Purging song previews!");
		var cacheObj = cast(openfl.Assets.cache, AssetCache);
		@:privateAccess
		var list = cacheObj.sound.keys();
		for (song in list)
		{
			if (song == null)
				continue;
			if (!song.contains(actualSongTho) && song.contains(".partial")) // .partial
			{
				trace('trying to remove: ' + song);
				openfl.Assets.cache.clear(song);
			}
		}
	}

	function capsuleOnConfirmRandom(randomCapsule:SongMenuItem):Void
	{
		trace('RANDOM SELECTED');

		busy = true;
		letterSort.inputEnabled = false;

		var availableSongCapsules:Array<SongMenuItem> = grpCapsules.members.filter(function(cap:SongMenuItem)
		{
			// Dead capsules are ones which were removed from the list when changing filters.
			return cap.alive && cap.songData != null;
		});

		trace('Available songs: ${availableSongCapsules.map(function(cap) {
      return cap?.songData?.songName;
    })}');

		if (availableSongCapsules.length == 0)
		{
			trace('No songs available!');
			busy = false;
			letterSort.inputEnabled = true;
			FunkinSound.playOnce(Paths.sound('cancelMenu'));
			return;
		}

		var targetSong:SongMenuItem = FlxG.random.getObject(availableSongCapsules);

		// Seeing if I can do an animation...
		curSelected = grpCapsules.members.indexOf(targetSong);
		changeSelection(0); // Trigger an update.

		// Act like we hit Confirm on that song.
		capsuleOnConfirmDefault(targetSong);
	}

	/**
	 * Called when hitting ENTER to open the instrumental list.
	 * ! this implements vocal lists
	 */
	function capsuleOnOpenDefault(cap:SongMenuItem):Void
	{
		// We don't have a good way to do this in psych
		// ? yet instVariants

		if (cap.songData.instVariants.length > 0 && cap.songData.instVariants[0] != "")
		{
			var instrumentalIds = ["default"].concat(cap.songData.instVariants);
			openInstrumentalList(cap, instrumentalIds);
		}
		else
		{
			trace('NO ALTS');
			capsuleOnConfirmDefault(cap);
		}
	}

	public function getControls():Controls
	{
		return controls;
	}

	function openInstrumentalList(cap:SongMenuItem, instrumentalIds:Array<String>):Void
	{
		busy = true;

		capsuleOptionsMenu = new CapsuleOptionsMenu(this, cap.x + 175, cap.y + 115, instrumentalIds);
		capsuleOptionsMenu.cameras = [funnyCam];
		capsuleOptionsMenu.zIndex = 10000;
		add(capsuleOptionsMenu);

		capsuleOptionsMenu.onConfirm = function(targetInstId:String)
		{
			capsuleOnConfirmDefault(cap, targetInstId);
		};
	}

	var capsuleOptionsMenu:Null<CapsuleOptionsMenu> = null;

	public function cleanupCapsuleOptionsMenu():Void
	{
		this.busy = false;

		if (capsuleOptionsMenu != null)
		{
			remove(capsuleOptionsMenu);
			capsuleOptionsMenu = null;
		}
	}

	/**
	 * Called when hitting ENTER to play the song.
	 */
	function capsuleOnConfirmDefault(cap:SongMenuItem, ?targetInstId:String):Void
	{
		busy = true;
		letterSort.inputEnabled = false;

		PlayState.isStoryMode = false;

		var targetSong = cap.songData;
		if (targetSong == null)
		{
			FlxG.log.warn('WARN: could not find song with id (${cap.songData.songId})');
			return;
		}

		// colorTween = null;
		var targetDifficultyId:String = currentDifficulty;
		PlayState.storyWeek = cap.songData.levelId;

		// Find current difficulty sprite
		PlayState.storyDifficultyColor = FlxColor.GRAY;
		for (diffSprite in grpDifficulties.group.members)
		{
			if (diffSprite == null)
				continue;
			if (diffSprite.difficultyId == currentDifficulty)
			{
				PlayState.storyDifficultyColor = diffSprite.difficultyColor;
				break;
			}
		}

		// Visual and audio effects.
		FunkinSound.playOnce(Paths.sound('confirmMenu'));
		if (dj != null)
			dj.confirm();

		grpCapsules.members[curSelected].forcePosition();
		grpCapsules.members[curSelected].confirm();

		backingCard?.confirm();
		// FlxTween.color(bgDad, 0.33, 0xFFFFFFFF, 0xFF555555, {ease: FlxEase.quadOut});
		// FlxTween.color(pinkBack, 0.33, 0xFFFFD0D5, 0xFF171831, {ease: FlxEase.quadOut});

		new FlxTimer().start(styleData?.getStartDelay(), function(tmr:FlxTimer)
		{
			FreeplayHelpers.moveToPlaystate(this, cap.songData, currentDifficulty, targetInstId);
		});
	}

	function rememberSelection():Void
	{
		if (rememberedSongId != null)
		{
			curSelected = currentFilteredSongs.findIndex(function(song)
			{
				if (song == null)
					return false;
				return song.songId == rememberedSongId;
			});

			if (curSelected == -1)
				curSelected = 0;
		}

		if (rememberedDifficulty != null)
		{
			currentDifficulty = rememberedDifficulty;
		}
	}

	function changeSelection(change:Int = 0):Void
	{
		var prevSelected:Int = curSelected;

		curSelected += change;

		if (!prepForNewRank && curSelected != prevSelected)
			FunkinSound.playOnce(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = grpCapsules.countLiving() - 1;
		if (curSelected >= grpCapsules.countLiving())
			curSelected = 0;

		var daSongCapsule:SongMenuItem = grpCapsules.members[curSelected];
		if (daSongCapsule.songData != null)
		{
			// ? This part is buggy
			// var songScore:Int = Highscore.getScore(daSongCapsule.songData.songId, diffId);
			// intendedScore = songScore ?? 0;
			// intendedCompletion = Highscore.getRating(daSongCapsule.songData.songId, diffId);
			diffIdsCurrent = daSongCapsule.songData.songDifficulties;
			rememberedSongId = daSongCapsule.songData.songId;
			changeDiff();
		}
		else
		{
			intendedScore = 0;
			intendedCompletion = 0.0;
			diffIdsCurrent = diffIdsTotal;
			rememberedSongId = null;
			rememberedDifficulty = Constants.DEFAULT_DIFFICULTY;
			albumRoll.albumId = null;
		}

		for (index => capsule in grpCapsules.members)
		{
			index += 1;

			capsule.selected = index == curSelected + 1;

			capsule.targetPos.y = capsule.intendedY(index - curSelected);
			capsule.targetPos.x = 270 + (60 * (Math.sin(index - curSelected)));

			if (index < curSelected)
				capsule.targetPos.y -= 100; // another 100 for good measure
		}

		if (grpCapsules.countLiving() > 0 && !prepForNewRank)
		{
			if (daSongCapsule.songData != null)
				FreeplayHelpers.loadDiffsFromWeek(daSongCapsule.songData);

			FlxG.sound.music.pause(); // muting previous track must be done NOW
			FlxTimer.wait(FADE_IN_DELAY, playCurSongPreview.bind(daSongCapsule)); // Wait a little before trying to pull a Inst file

			tweenCurSongColor(daSongCapsule);
			grpCapsules.members[curSelected].selected = true;
		}
		else if (prepForNewRank)
			tweenCurSongColor(daSongCapsule);
	}

	public function playCurSongPreview(?daSongCapsule:SongMenuItem):Void
	{
		if (daSongCapsule == null)
			daSongCapsule = grpCapsules.members[curSelected];

		if (curSelected == 0)
		{
			FunkinSound.playMusic('freeplayRandom', {
				startingVolume: 0.0,
				overrideExisting: true,
				restartTrack: false
			});
			FlxG.sound.music.fadeIn(2, 0, 0.8);
		}
		else
		{
			if (!daSongCapsule.selected)
				return; // ? make sure we actually have to load preview
			var potentiallyErect:String = (currentDifficulty == "erect") || (currentDifficulty == "nightmare") ? "-erect" : "";
			// ? psych dir setting
			var songData = daSongCapsule.songData;
			ModsHelper.loadModDir(songData.folder);
			FunkinSound.playMusic(daSongCapsule.songData.songId, {
				startingVolume: 0.0,
				overrideExisting: true,
				restartTrack: false,
				pathsFunction: INST,
				suffix: potentiallyErect,
				partialParams: {
					loadPartial: true,
					start: songData.freeplayPrevStart,
					end: songData.freeplayPrevEnd
				},
				onLoad: function()
				{
					// ? onLoad doesn't start plaing music automatically here
					var endVolume = dj.playingCartoon ? 0.1 : FADE_IN_END_VOLUME;
					FlxG.sound.music.fadeIn(FADE_IN_DURATION, FADE_IN_START_VOLUME, endVolume);
					// ? set BPMs
					var newBPM = daSongCapsule.songData.songStartingBpm;
					FreeplayHelpers.BPM = newBPM; // ? reimplementing
				}
			});
		}
	}

	public function tweenCurSongColor(daSongCapsule:SongMenuItem)
	{ // H1
		if (Std.isOfType(backingCard, BoyfriendCard))
		{
			var newColor:FlxColor = (curSelected == 0) ? 0xFFFFD863 : daSongCapsule.songData.color;
			var bfCard = cast(backingCard, BoyfriendCard);
			bfCard.colorEngine?.tweenColor(newColor);
		}
	}

	/**
	 * Build an instance of `FreeplayState` that is above the `MainMenuState`.
	 * @return The MainMenuState with the FreeplayState as a substate.
	 */
	public static function build(?params:FreeplayStateParams, ?stickers:StickerSubState):MusicBeatState
	{
		var result:MainMenuState;
		if (params?.fromResults?.playRankAnim)
			result = new MainMenuState(true);
		else
			result = new MainMenuState(false);
		result.openSubState(new FreeplayState(params, stickers));
		result.persistentUpdate = false;
		result.persistentDraw = true;
		return result;
	}
}

/**
 * The difficulty selector arrows to the left and right of the difficulty.
 */
class DifficultySelector extends FlxSprite
{
	var controls:Controls;
	var whiteShader:PureColor;

	var parent:FreeplayState;

	public function new(parent:FreeplayState, x:Float, y:Float, flipped:Bool, controls:Controls, ?styleData:FreeplayStyle = null)
	{
		super(x, y);

		this.parent = parent;
		this.controls = controls;

		frames = Paths.getSparrowAtlas(styleData == null ? 'freeplay/freeplaySelector' : styleData.getSelectorAssetKey());
		animation.addByPrefix('shine', 'arrow pointer loop', 24);
		animation.play('shine');

		whiteShader = new PureColor(FlxColor.WHITE);

		shader = whiteShader;

		flipX = flipped;
	}

	override function update(elapsed:Float):Void
	{
		if (flipX && controls.UI_RIGHT_P && !parent.busy)
			moveShitDown();
		if (!flipX && controls.UI_LEFT_P && !parent.busy)
			moveShitDown();

		super.update(elapsed);
	}

	public function setPress(press:Bool):Void
	{
		if (!press)
		{
			scale.x = scale.y = 1;
			whiteShader.colorSet = false;
			updateHitbox();
		}
		else
		{
			offset.y -= 5;
			whiteShader.colorSet = true;
			scale.x = scale.y = 0.5;
		}
	}

	function moveShitDown():Void
	{
		offset.y -= 5;

		whiteShader.colorSet = true;

		scale.x = scale.y = 0.5;

		new FlxTimer().start(2 / 24, function(tmr)
		{
			scale.x = scale.y = 1;
			whiteShader.colorSet = false;
			updateHitbox();
		});
	}
}

/**
 * Structure for the current song filter.
 */
typedef SongFilter =
{
	var filterType:FilterType;
	var ?filterData:Dynamic;
}

/**
 * Possible types to use for the song filter.
 */
enum abstract FilterType(String)
{
	/**
	 * Filter to songs which start with a string
	 */
	public var STARTSWITH;

	/**
	 * Filter to songs which match a regular expression
	 */
	public var REGEXP;

	/**
	 * Filter to songs which are favorited
	 */
	public var FAVORITE;

	/**
	 * Filter to all songs
	 */
	public var ALL;
}

/**
 * The map storing information about the exit movers.
 */
typedef ExitMoverData = Map<Array<FlxSprite>, MoveData>;

/**
 * The data for an exit mover.
 */
typedef MoveData =
{
	var ?x:Float;
	var ?y:Float;
	var ?speed:Float;
	var ?wait:Float;
}
