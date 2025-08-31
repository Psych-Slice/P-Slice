package mikolka.vslice.freeplay;

import mikolka.funkin.custom.mobile.MobileScaleMode;
import flixel.math.FlxRect;
import mikolka.vslice.ui.MainMenuState;
import mikolka.vslice.freeplay.backcards.LuaCard;
import mikolka.vslice.freeplay.obj.CapsuleOptionsMenu;
import mikolka.compatibility.funkin.FunkinControls;
import mikolka.vslice.charSelect.CharSelectSubState;
import openfl.filters.ShaderFilter;
import mikolka.vslice.freeplay.backcards.PicoCard;
import mikolka.funkin.freeplay.FreeplayStyleRegistry;
import mikolka.vslice.freeplay.backcards.BoyfriendCard;
import shaders.BlueFade;
import mikolka.funkin.freeplay.FreeplayStyle;
import mikolka.vslice.freeplay.backcards.BackingCard;
import mikolka.vslice.freeplay.DJBoyfriend.FreeplayDJ;
import mikolka.compatibility.ModsHelper;
import mikolka.compatibility.VsliceOptions;
import mikolka.compatibility.funkin.FunkinCamera;
import mikolka.vslice.freeplay.pslice.BPMCache;
import mikolka.compatibility.freeplay.FreeplaySongData;
import mikolka.compatibility.freeplay.FreeplayHelpers;
import mikolka.compatibility.funkin.FunkinPath as Paths;
import mikolka.funkin.custom.VsliceSubState as MusicBeatSubstate;
import openfl.utils.AssetCache;
import mikolka.funkin.AtlasText;
import shaders.PureColor;
import shaders.HSVShader;
import shaders.StrokeShader;
import shaders.AngleMask;
import mikolka.funkin.IntervalShake;
import mikolka.vslice.StickerSubState;
import mikolka.funkin.Scoring.ScoringRank;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxPoint;
import openfl.display.BlendMode;
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
	public static final FADE_IN_END_VOLUME:Float = 0.7;

	/**
	 * For the audio preview, the time to wait before attempting to load a song preview.
	 */
	public static final FADE_IN_DELAY:Float = 0.25;

	/**
	 * For the audio preview, the volume at which the fade-out starts.
	 */
	public static final FADE_OUT_END_VOLUME:Float = 0.0;

	/**
	 * For scaling some sprites on wide displays.
	 */
	public static var CUTOUT_WIDTH:Float = MobileScaleMode.gameCutoutSize.x / 1.5;

	/**
	 * For positioning the DJ on wide displays.
	 */
	public static final DJ_POS_MULTI:Float = 0.44;

	/**
	 * For positioning the songs list on wide displays.
	 */
	public static final SONGS_POS_MULTI:Float = 0.75;

	var songs:Array<Null<FreeplaySongData>> = [];

	var diffIdsCurrent:Array<String> = [];
	// List of available difficulties for the total song list, without `-variation` at the end (no duplicates or nulls).
	var diffIdsTotal:Array<String> = ['easy', "normal", "hard"]; // ? forcing this diff order

	var curSelected:Int = 0;
	// This below track drag for the mobile
	var curSelectedFractal:Float = 0;
	var currentDifficulty:String = Constants.DEFAULT_DIFFICULTY;

	var fp:FreeplayScore;
	var txtCompletion:AtlasText;
	var lerpCompletion:Float = 0;
	var intendedCompletion:Float = 0;
	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

	var grpDifficulties:FlxTypedSpriteGroup<DifficultySprite>;
	var grpFallbackDifficulty:FlxText;

	var grpSongs:FlxTypedGroup<Alphabet>;
	var grpCapsules:SongCapsuleGroup;
	var curCapsule(get,never):SongMenuItem;
	function get_curCapsule() {
		return grpCapsules.activeSongItems[curSelected];
	}
	var curPlaying:Bool = false;

	var dj:Null<FreeplayDJ> = null;

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

	public var backingImage:FlxSprite;

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

		// Since CUTOUT_WIDTH is static it might retain some old inccrect values so we update it before loading freeplay
		CUTOUT_WIDTH = MobileScaleMode.gameCutoutSize.x / 1.5;

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
		SongMenuItem.reloadGlobalItemData();
		var saveBox = VsliceOptions.LAST_MOD;
		if (ModsHelper.isModDirEnabled(saveBox.mod_dir))
			ModsHelper.loadModDir(saveBox.mod_dir);
		// We build a bunch of sprites BEFORE create() so we can guarantee they aren't null later on.
		// ? but doing it here, because psych 0.6.3 can destroy graphics created in the constructor
		if (VsliceOptions.FP_CARDS)
		{
			switch (currentCharacterId)
			{
				case(VsliceOptions.LOW_QUALITY) => true:
					backingCard = null;
				#if (!LEGACY_PSYCH && HSCRIPT_ALLOWED)
				case(LuaCard.hasCustomCard(currentCharacterId)) => true:
					backingCard = new LuaCard(currentCharacter, currentCharacterId, stickerSubState == null);
				#end
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
		fp = new FreeplayScore(FlxG.width - (MobileScaleMode.gameNotchSize.x + 353), 60, 7, 100, styleData);
		rankCamera = new FunkinCamera('rankCamera', 0, 0, FlxG.width, FlxG.height);
		funnyCam = new FunkinCamera('freeplayFunny', 0, 0, FlxG.width, FlxG.height);
		grpCapsules = new SongCapsuleGroup();
		grpCapsules.onRandomSelected.add(capsuleOnConfirmRandom);
		grpCapsules.onSongSelected.add(capsuleOnOpenDefault);
		
		grpDifficulties = new FlxTypedSpriteGroup<DifficultySprite>(-300, 80);
		letterSort = new LetterSort((CUTOUT_WIDTH * SONGS_POS_MULTI) + 400, 75);
		grpSongs = new FlxTypedGroup<Alphabet>();
		rankBg = new FunkinSprite(0, 0);
		rankVignette = new FlxSprite(0, 0).loadGraphic(Paths.image('freeplay/rankVignette'));
		sparks = new FlxSprite(0, 0);
		sparksADD = new FlxSprite(0, 0);
		txtCompletion = new AtlasText(FlxG.width - (MobileScaleMode.gameNotchSize.x+95), 87, '69', AtlasFont.FREEPLAY_CLEAR);

		ostName = new FlxText(8-MobileScaleMode.gameNotchSize.x, 8, FlxG.width - 8 - 8, 'OFFICIAL OST', 48);
		charSelectHint = new FlxText(-40, 18, FlxG.width - 8 - 8, 'Press [ LOL ] to change characters', 32);

		backingImage = new FlxSprite((backingCard?.pinkBack.width ?? 0) * 0.74,
			0).loadGraphic(styleData == null ? 'freeplay/freeplayBGdad' : styleData.getBgAssetGraphic());

		BPMCache.instance.clearCache(); // for good measure
		// ? end of init

		super.create();
		var diffIdsTotalModBinds:Map<String, String> = ["easy" => "", "normal" => "", "hard" => ""];

		FlxG.state.persistentUpdate = false;

		FlxTransitionableState.skipNextTransIn = true;

		var fadeShaderFilter:ShaderFilter = new ShaderFilter(fadeShader);
		ModsHelper.setFiltersOnCam(funnyCam, [fadeShaderFilter]);
		funnyCam.filtersEnabled = false;

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
			// ? Low quality. why we need him again?
			if (!VsliceOptions.LOW_QUALITY)
			{
				dj = new FreeplayDJ((CUTOUT_WIDTH * DJ_POS_MULTI) + 640, 366, currentCharacter);
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
		}

		if (!VsliceOptions.LOW_QUALITY)
			backingImage.shader = angleMaskShader;
		backingImage.visible = false;

		var blackOverlayBullshitLOLXD:FlxSprite = new FlxSprite(FlxG.width).makeGraphic(Std.int(backingImage.width), Std.int(backingImage.height), FlxColor.BLACK);
    	add(blackOverlayBullshitLOLXD); // used to mask the text lol!
		blackOverlayBullshitLOLXD.shader = backingImage.shader;
		// this makes the texture sizes consistent, for the angle shader
		// ? For low quality it's the entire background
		if (VsliceOptions.LOW_QUALITY)
			backingImage.setGraphicSize(FlxG.width, FlxG.height);
		else
			backingImage.setGraphicSize(0, FlxG.height);
		blackOverlayBullshitLOLXD.setGraphicSize(0, FlxG.height);

		backingImage.updateHitbox();
		blackOverlayBullshitLOLXD.updateHitbox();

		exitMovers.set([blackOverlayBullshitLOLXD, backingImage], {
			x: FlxG.width * 1.5,
			speed: 0.4,
			wait: 0
		});

		exitMoversCharSel.set([blackOverlayBullshitLOLXD, backingImage], {
			y: -100,
			speed: 0.8,
			wait: 0.1
		});

		if(VsliceOptions.LOW_QUALITY) add(backingImage);

		grpDifficulties = new FlxTypedSpriteGroup<DifficultySprite>(-300, 80);
		add(grpDifficulties);

		if(!VsliceOptions.LOW_QUALITY) add(backingImage);
		// ? changed offset

		blackOverlayBullshitLOLXD.shader = backingImage.shader;

		rankBg.makeSolidColor(FlxG.width, FlxG.height, 0xD3000000);
		add(rankBg);

		add(grpSongs);

		add(grpCapsules);

		grpFallbackDifficulty = new FlxText(70, 90, 250, "");
		grpFallbackDifficulty.setFormat("VCR OSD Mono", 60, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		grpFallbackDifficulty.borderSize = 2;
		add(grpFallbackDifficulty);

		

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
		@:privateAccess // Force update the album
		albumRoll.updateAlbum();
		add(albumRoll);

		var overhangStuff:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 164, FlxColor.BLACK);
		overhangStuff.y -= overhangStuff.height;


		// ? changed offsets
		if (fromCharSelect == true)
		{
			blackOverlayBullshitLOLXD.visible = false;
			overhangStuff.y = -100;
			backingCard?.skipIntroTween();
		}
		else
		{
			albumRoll.applyExitMovers(exitMovers, exitMoversCharSel);
			FlxTween.tween(overhangStuff, {y: -100}, 0.3, {ease: FlxEase.quartOut});

			FlxTween.tween(blackOverlayBullshitLOLXD, {x: backingImage.x}, 0.7, {ease: FlxEase.quintOut});
		}

		var topLeftCornerText:FlxText = new FlxText(Math.max(MobileScaleMode.gameNotchSize.x, 8), 8, 0, 'FREEPLAY', 48);
		topLeftCornerText.font = 'VCR OSD Mono';
		topLeftCornerText.visible = false;

		var freeplayTxtBg:FlxSprite = new FlxSprite().makeGraphic(Math.round(topLeftCornerText.width + 16), Math.round(topLeftCornerText.height + 16),
		FlxColor.BLACK);
		freeplayTxtBg.x = topLeftCornerText.x - 8;
		freeplayTxtBg.visible = false;


		ostName.font = 'VCR OSD Mono';
		ostName.alignment = RIGHT;
		ostName.visible = false;

		charSelectHint.alignment = CENTER;
		charSelectHint.font = "5by7";
		charSelectHint.color = 0xFF5F5F5F;
		charSelectHint.text = controls.mobileC ? 'Touch [ X ] to change characters' : 'Press [ ${FunkinControls.FREEPLAY_CHAR_name()} ] to change characters'; // ?! ${controls.getDialogueNameFromControl(FREEPLAY_CHAR_SELECT, true)}
		charSelectHint.y -= 100;
		FlxTween.tween(charSelectHint, {y: charSelectHint.y + 100}, 0.8, {ease: FlxEase.quartOut});

		exitMovers.set([overhangStuff,freeplayTxtBg, topLeftCornerText, ostName, charSelectHint], {
			y: -overhangStuff.height,
			x: 0,
			speed: 0.2,
			wait: 0
		});

		exitMoversCharSel.set([overhangStuff,freeplayTxtBg, topLeftCornerText, ostName, charSelectHint], {
			y: -300,
			speed: 0.8,
			wait: 0.1
		});

		// FlxG.debugger.addTrackerProfile(new TrackerProfile(FlxSprite, ["x", "y", "alpha", "scale", "blend"]));
		// FlxG.debugger.track(overhangStuff);

		var sillyStroke:StrokeShader = new StrokeShader(0xFFFFFFFF, 2, 2);
		topLeftCornerText.shader = sillyStroke;
		ostName.shader = sillyStroke;

		var fnfHighscoreSpr:FlxSprite = new FlxSprite(FlxG.width-MobileScaleMode.gameNotchSize.x-420, 70);
		fnfHighscoreSpr.frames = Paths.getSparrowAtlas('freeplay/highscore');
		fnfHighscoreSpr.animation.addByPrefix('highscore', 'highscore small instance 1', 24, false);
		fnfHighscoreSpr.visible = false;
		fnfHighscoreSpr.setGraphicSize(0, Std.int(fnfHighscoreSpr.height * 1));
		fnfHighscoreSpr.updateHitbox();
		add(fnfHighscoreSpr);

		new FlxTimer().start(FlxG.random.float(12, 50), function(tmr)
		{
			fnfHighscoreSpr?.animation?.play('highscore');
			tmr.time = FlxG.random.float(20, 60);
		}, 0);

		fp.visible = false;
		fp.camera = funnyCam;
		add(fp);

		var clearBoxSprite:FlxSprite = new FlxSprite(FlxG.width - MobileScaleMode.gameNotchSize.x -115, 65).loadGraphic(Paths.image('freeplay/clearBox'));
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
			if (grpCapsules.activeSongItems.length > 0)
			{
				FunkinSound.playOnce(Paths.sound('scrollMenu'), 0.4);
				curSelected = 1;
				curSelectedFractal = 1;
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

		diffSelLeft = new DifficultySelector(this, (CUTOUT_WIDTH * DJ_POS_MULTI) + 20, grpDifficulties.y - 10, false, controls, styleData);
		diffSelRight = new DifficultySelector(this, (CUTOUT_WIDTH * DJ_POS_MULTI) + 325, grpDifficulties.y - 10, true, controls, styleData);
		diffSelLeft.visible = false;
		diffSelRight.visible = false;
		add(diffSelLeft);
		add(diffSelRight);

		// putting these here to fix the layering
		add(overhangStuff);
		add(freeplayTxtBg);
		add(topLeftCornerText);
		add(ostName);

		#if (BASE_GAME_FILES || MODS_ALLOWED)
		add(charSelectHint);
		#end

		// be careful not to "add()" things in here unless it's to a group that's already added to the state
		// otherwise it won't be properly attatched to funnyCamera (relavent code should be at the bottom of create())
		var onDJIntroDone = function()
		{
			busy = false;

			// when boyfriend hits dat shiii

			if (curCapsule != null) // ? prevent "random" song from stealing our albums!
			{
				albumRoll.playIntro();
				var daSong = curCapsule.songData;
				albumRoll.albumId = daSong?.albumId;
			}
			else
				albumRoll.albumId = '';

			if (fromCharSelect == null)
			{
				// render optimisation
				if (_parentState != null)
					_parentState.persistentDraw = false;

				FlxTween.color(backingImage, 0.6, 0xFF000000, 0xFFFFFFFF, {
					ease: FlxEase.expoOut,
					onUpdate: function(_)
					{
						angleMaskShader.extraColor = backingImage.color;
					},
					onComplete: function(_) {
              			blackOverlayBullshitLOLXD.visible = false;
            		}
				});
			}

			FlxTween.cancelTweensOf(grpDifficulties);
			//? What's this?
			for (diff in grpDifficulties.group.members)
			{
				if (diff == null)
					continue;
				FlxTween.cancelTweensOf(diff);
				//? changed this
				FlxTween.tween(diff, {x: (CUTOUT_WIDTH * DJ_POS_MULTI) + 90 }, 0.6, {ease: FlxEase.quartOut});
				diff.y = 80;
				diff.visible = diff.difficultyId == currentDifficulty;
			}
			FlxTween.tween(grpDifficulties, {x: (CUTOUT_WIDTH * DJ_POS_MULTI) + 90}, 0.6, {ease: FlxEase.quartOut});

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
				freeplayTxtBg.visible = true;
				topLeftCornerText.visible = true;
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

			backingImage.visible = true;
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
			FlxTimer.wait(0.5, () -> onDJIntroDone());
		}
		currentDifficulty = rememberedDifficulty; // ? use last difficulty to create this list
		// Generates song list with the starter params (who our current character is, last remembered difficulty, etc.)
    	// Set this to false if you prefer the 50% transparency on the capsules when they first appear.
		generateSongList(null, false);

		// dedicated camera for the state so we don't need to fuk around with camera scrolls from the mainmenu / elsewhere
		funnyCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(funnyCam, false);

		rankVignette.scale.set(2 * MobileScaleMode.wideScale.x, 2 * MobileScaleMode.wideScale.y);
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
		addTouchPad('NONE', 'A_B_C_X_Y_F');
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
		#if !LEGACY_PSYCH
		var button = new TouchZone( (CUTOUT_WIDTH * SONGS_POS_MULTI) +420, 260, 450, 95);
		button.cameras = [funnyCam];

		var scroll = new ScrollableObject(-0.02, (CUTOUT_WIDTH * SONGS_POS_MULTI)+150, 100, FlxG.width - 400, FlxG.height, button);
		scroll.cameras = [funnyCam];
		scroll.onPartialScroll.add(delta ->
		{
			if (busy)
				return;
			changeSelectionFractal(delta);
		});
		scroll.onFullScrollSnap.add(() -> changeSelectionFractal(curSelected - curSelectedFractal));
		scroll.onFullScroll.add(delta ->
		{
			if (busy)
				return;
			changeSelection(delta, false);
		});
		scroll.onTap.add(() ->
		{
			if (busy)
				return;
			var daSongCapsule:SongMenuItem = curCapsule;
			daSongCapsule.onConfirm();
		});
		add(scroll);
		add(button);
		#end
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
		rememberedSongId = curCapsule?.songData?.songId ?? rememberedSongId;

		currentFilter = filterStuff;

		currentFilteredSongs = tempSongs;
		curSelected = 0;
		curSelectedFractal = 0;

		grpCapsules.generateFullSongList(tempSongs,currentDifficulty,fromCharSelect,force);

		FlxG.console.registerFunction('changeSelection', changeSelection);

		rememberSelection();

		changeSelection();
		changeDiff(0);
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
		curCapsule.sparkle.alpha = 0;
		// curCapsule.forcePosition();

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
			curCapsule.setFakeRanking(fromResults.oldRank);

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

		curCapsule.doLerp = false;

		// originalPos.x = curCapsule.x;
		// originalPos.y = curCapsule.y;

		originalPos.x = (CUTOUT_WIDTH * SONGS_POS_MULTI) + 320.488;
		originalPos.y = 235.6;
		trace(originalPos);

		curCapsule.ranking.visible = false;
		curCapsule.blurredRanking.visible = false;

		rankCamera.zoom = 1.85;
		FlxTween.tween(rankCamera, {"zoom": 1.8}, 0.6, {ease: FlxEase.sineIn});

		funnyCam.zoom = 1.15;
		FlxTween.tween(funnyCam, {"zoom": 1.1}, 0.6, {ease: FlxEase.sineIn});

		curCapsule.cameras = [rankCamera];
		// curCapsule.targetPos.set((FlxG.width / 2) - (curCapsule.width / 2),
		//  (FlxG.height / 2) - (curCapsule.height / 2));

		curCapsule.setPosition((FlxG.width / 2) - (curCapsule.width / 2),
			(FlxG.height / 2) - (curCapsule.height / 2));

		new FlxTimer().start(0.5, _ ->
		{
			rankDisplayNew(fromResults);
		});
	}

	function rankDisplayNew(fromResults:Null<FromResultsParams>):Void
	{
		curCapsule.ranking.visible = true;
		curCapsule.blurredRanking.visible = true;
		curCapsule.ranking.scale.set(20, 20);
		curCapsule.blurredRanking.scale.set(20, 20);

		if (fromResults != null && fromResults.newRank != null)
		{
			curCapsule.ranking.animation.play(fromResults.newRank.getFreeplayRankIconAsset(), true);
		}

		FlxTween.tween(curCapsule.ranking, {"scale.x": 1, "scale.y": 1}, 0.1);

		if (fromResults != null && fromResults.newRank != null)
		{
			curCapsule.blurredRanking.animation.play(fromResults.newRank.getFreeplayRankIconAsset(), true);
		}
		FlxTween.tween(curCapsule.blurredRanking, {"scale.x": 1, "scale.y": 1}, 0.1);

		new FlxTimer().start(0.1, _ ->
		{
			if (fromResults?.oldRank != null)
			{
				curCapsule.setFakeRanking(null);

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

			curCapsule.x -= 10;
			curCapsule.y -= 20;

			FlxTween.tween(funnyCam, {"zoom": 1.05}, 0.3, {ease: FlxEase.elasticOut});

			curCapsule.capsule.angle = -3;
			FlxTween.tween(curCapsule.capsule, {angle: 0}, 0.5, {ease: FlxEase.backOut});

			IntervalShake.shake(curCapsule.capsule, 0.3, 1 / 30, 0.1, 0, FlxEase.quadOut);
		});

		new FlxTimer().start(0.4, _ ->
		{
			FlxTween.tween(funnyCam, {"zoom": 1}, 0.8, {ease: FlxEase.sineIn});
			FlxTween.tween(rankCamera, {"zoom": 1.2}, 0.8, {ease: FlxEase.backIn});
			FlxTween.tween(curCapsule, {x: originalPos.x - 7, y: originalPos.y - 80}, 0.8 + 0.5, {ease: FlxEase.quartIn});
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

		// FlxTween.tween(curCapsule, {angle: 5}, 0.5, {ease: FlxEase.backIn});

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

		FlxTween.tween(curCapsule, {"targetPos.x": originalPos.x, "targetPos.y": originalPos.y}, 0.5, {ease: FlxEase.expoOut});
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

			for (index => capsule in grpCapsules.activeSongItems)
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
		#if LEGACY_PSYCH
		MusicBeatSubstate.instance = this;
		#else
		backend.MusicBeatSubstate.instance = this;
		#end
		persistentUpdate = true;
		removeTouchPad();
		addTouchPad('UP_DOWN', 'A_B_C_X_Y_F');
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
		for (index => capsule in grpCapsules.activeSongItems)
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
		funnyCam.filtersEnabled = true;

		//? The values are reversed here, otherwise it breaks because ????
    	fadeShader.fade(1.0, 0.0, 0.8, {ease: FlxEase.quadIn});
		FlxG.sound.music?.fadeOut(0.9, 0);
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
		// for (index => capsule in grpCapsules.activeSongItems)
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
		funnyCam.filtersEnabled = true;
		fadeShader.fade(0.0, 1.0, 0.8, {ease: FlxEase.quadIn,onComplete: (twn) -> funnyCam.filtersEnabled = false});
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
						for (index => capsule in grpCapsules.activeSongItems)
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
			#if LEGACY_PSYCH
			FlxTween.tween(touchPad, {alpha: ClientPrefs.controlsAlpha}, 0.8, {ease: FlxEase.backIn});
			#else
			FlxTween.tween(touchPad, {alpha: ClientPrefs.data.controlsAlpha}, 0.8, {ease: FlxEase.backIn});
			#end
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
		if (FlxG.keys.justPressed.T)
		{
			rankAnimStart(fromResultsParams ?? {
				playRankAnim: true,
				newRank: PERFECT_GOLD,
				songId: "tutorial",
				oldRank: SHIT,
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
			if (FunkinControls.FREEPLAY_CHAR #if TOUCH_CONTROLS_ALLOWED || touchPad?.buttonX.justPressed #end)
			{
				tryOpenCharSelect();
			} // ? Those are new too
			else if (FlxG.keys.justPressed.CONTROL #if TOUCH_CONTROLS_ALLOWED || touchPad?.buttonC.justPressed #end)
			{
				persistentUpdate = false;
				#if TOUCH_CONTROLS_ALLOWED
				removeTouchPad();
				#end
				FreeplayHelpers.openGameplayChanges(this);
			}
			else if ((controls.RESET #if TOUCH_CONTROLS_ALLOWED || touchPad?.buttonY.justPressed #end) && curSelected != 0)
			{
				persistentUpdate = false;
				var curSng = curCapsule;
				#if TOUCH_CONTROLS_ALLOWED
				removeTouchPad();
				#end

				FreeplayHelpers.openResetScoreState(this, curSng.songData, () ->
				{
					curSng.songData.scoringRank = null;
					intendedScore = 0;
					intendedCompletion = 0;
					curSng.songData.updateIsNewTag();
					curSng.refreshDisplayDifficulty();
				});
				FunkinSound.playOnce(Paths.sound('scrollMenu'), 0.4);
			} // ? //!
		}

		if (controls.FAVORITE #if TOUCH_CONTROLS_ALLOWED || touchPad?.buttonF.justPressed #end && !busy) // ? change control binding
		{
			var targetSong = curCapsule?.songData;
			if (targetSong != null)
			{
				var realShit:Int = curSelected;
				var isFav = targetSong.toggleFavorite();
				if (isFav)
				{
					curCapsule.favIcon.visible = true;
					curCapsule.favIconBlurred.visible = true;
					curCapsule.favIcon.animation.play('fav');
					curCapsule.favIconBlurred.animation.play('fav');
					FunkinSound.playOnce(Paths.sound('fav'), 1);
					curCapsule.checkClip();
					curCapsule.selected = curCapsule.selected; // set selected again, so it can run it's getter function to initialize movement
					busy = true;

					curCapsule.doLerp = false;
					FlxTween.tween(curCapsule, {y: curCapsule.y - 5}, 0.1, {ease: FlxEase.expoOut});

					FlxTween.tween(curCapsule, {y: curCapsule.y + 5}, 0.1, {
						ease: FlxEase.expoIn,
						startDelay: 0.1,
						onComplete: function(_)
						{
							curCapsule.doLerp = true;
							busy = false;
						}
					});
				}
				else
				{
					curCapsule.favIcon.animation.play('fav', true, true, 9);
					curCapsule.favIconBlurred.animation.play('fav', true, true, 9);
					FunkinSound.playOnce(Paths.sound('unfav'), 1);
					new FlxTimer().start(0.2, _ ->
					{
						curCapsule.favIcon.visible = false;
						curCapsule.favIconBlurred.visible = false;
						curCapsule.checkClip();
					});

					busy = true;
					curCapsule.doLerp = false;
					FlxTween.tween(curCapsule, {y: curCapsule.y + 5}, 0.1, {ease: FlxEase.expoOut});

					FlxTween.tween(curCapsule, {y: curCapsule.y - 5}, 0.1, {
						ease: FlxEase.expoIn,
						startDelay: 0.1,
						onComplete: function(_)
						{
							curCapsule.doLerp = true;
							busy = false;
						}
					});
				}
			}
		}
		// TODO We should bind those to global controls
		if (FlxG.keys.justPressed.HOME && !busy)
		{
			changeSelection(-curSelected);
		}

		if (FlxG.keys.justPressed.END && !busy)
		{
			changeSelection(grpCapsules.countLiving() - curSelected - 1);
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
		// ? new tags
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
			if (diffSelLeft != null)
				diffSelLeft.setPress(true);
		}
		if (controls.UI_RIGHT_P || (TouchUtil.overlapsComplex(diffSelRight) && TouchUtil.justPressed))
		{
			if (dj != null)
				dj.resetAFKTimer();
			changeDiff(1);
			rememberedDifficulty = currentDifficulty; // ? make sure to remember it, because otherwise we'll forget about it
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
			// FlxTween.color(backingImage, 0.33, 0xFFFFFFFF, 0xFF555555, {ease: FlxEase.quadOut});
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

			for (caps in grpCapsules.activeSongItems)
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
			curCapsule.onConfirm();
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

	function changeDiff(change:Int = 0, forceUpdateSongList:Bool = false):Void
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

		var didDifficultyChange = currentDifficulty != diffIdsCurrent[currentDifficultyIndex];

		if(didDifficultyChange) {
			busy = true;
			swipeDiffSpr(false,change);
		}
		if(change != 0){
			HapticUtil.vibrate(0, 0.01, 0.5, 0.1);
			FunkinSound.playOnce(Paths.sound('scrollMenu'), 0.4);
		}

		currentDifficulty = diffIdsCurrent[currentDifficultyIndex];

		var daSong:Null<FreeplaySongData> = curCapsule.songData;
		if (daSong != null)
		{
			// ? changed how this loads score
			daSong.currentDifficulty = currentDifficulty;
			var diffId = daSong.loadAndGetDiffId(); // 12
			var songScore:Int = Highscore.getScore(daSong.getNativeSongId(),
				diffId); // Save.instance.getSongScore(curCapsule.songData.songId, suffixedDifficulty);

			intendedScore = songScore ?? 0;
			intendedCompletion = Highscore.getRating(daSong.getNativeSongId(), diffId);
		}
		else
		{
			intendedScore = 0;
			intendedCompletion = 0.0;
		}
		rememberedDifficulty = currentDifficulty;
		if (intendedCompletion == Math.POSITIVE_INFINITY || intendedCompletion == Math.NEGATIVE_INFINITY || Math.isNaN(intendedCompletion))
			intendedCompletion = 0;
		

		// Hide all diffs
		if (didDifficultyChange) swipeDiffSpr(true,change);

		//
		if (change != 0 || forceUpdateSongList)
			updateCapsuleDifficulties();

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

	/**
	 * Update capsule's difficulties and refresh them accordingly
	 */
	function updateCapsuleDifficulties() {
		//? This is copied from the start of the "generateSongList"
		var tempSongs:Array<Null<FreeplaySongData>> = songs;

		if (currentFilter != null)
			tempSongs = sortSongs(tempSongs, currentFilter);

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
		var areSongsTheSame = tempSongs.isEqualUnordered(currentFilteredSongs);

		if(areSongsTheSame)
			grpCapsules.updateSongDifficulties(currentDifficulty);
		else // Refresh the songs
			generateSongList(currentFilter, true);
	}

	function swipeDiffSpr(transIn:Bool, change:Int)
	{
		var getCurrentDiff = () ->
		{
			for (diffSprite in grpDifficulties.group.members)
			{
				if (diffSprite != null && diffSprite.difficultyId == currentDifficulty)
					return diffSprite;
			}
			throw "NO DIFF! Something is VERY wrong!";
		}

		// ? This handles trans OUT
		var diffObj = getCurrentDiff(); //
		var diffSprite:FlxSprite = diffObj;
		if (!diffObj.hasValidTexture)
			diffSprite = grpFallbackDifficulty;

		if (transIn)
		{
			if (!diffObj.hasValidTexture)
			{
				grpFallbackDifficulty.text = diffObj.difficultyId;
				grpFallbackDifficulty.updateHitbox();
			}
			else {
				diffSprite.visible = true;
				grpFallbackDifficulty.text = "";
			}

			diffSprite.x = (change > 0) ? 500 : -320;
			diffSprite.x += (CUTOUT_WIDTH * DJ_POS_MULTI);

			FlxTween.tween(diffSprite, {x:  90 + (CUTOUT_WIDTH * DJ_POS_MULTI)}, 0.2, {
				ease: FlxEase.circInOut
			});

			diffSprite.offset.y += 5;
			diffSprite.alpha = 0.5;
			new FlxTimer().start(1 / 24, function(swag)
			{
				busy = false;
				diffSprite.alpha = 1;
				diffSprite.updateHitbox();
				diffSprite.visible = true;
				diffSprite.height *= 2.5;
			});
		}
		else
		{
			diffSprite.visible = true;
			final newX:Int = (change > 0) ? -320 : 500;

			FlxTween.tween(diffSprite, {x: newX + (CUTOUT_WIDTH * DJ_POS_MULTI)}, 0.2, {
				ease: FlxEase.circInOut,
				onComplete: function(_)
				{
					diffSprite.x = 90 + (CUTOUT_WIDTH * DJ_POS_MULTI);
					diffSprite.visible = false;
				}
			});
		}
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

		var availableSongCapsules:Array<SongMenuItem> = grpCapsules.activeSongItems.filter(function(cap:SongMenuItem)
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
		curSelected = grpCapsules.activeSongItems.indexOf(targetSong);
		curSelectedFractal = curSelected;
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

		curCapsule.forcePosition();
		curCapsule.confirm();

		backingCard?.confirm();

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
			curSelectedFractal = curSelected;
		}

		if (rememberedDifficulty != null)
		{
			currentDifficulty = rememberedDifficulty;
		}
	}

	// TODO

	function changeSelectionFractal(change:Float)
	{
		curSelectedFractal = FlxMath.bound(curSelectedFractal + change, 0, grpCapsules.countLiving() - 1);
		for (index => capsule in grpCapsules.activeSongItems)
		{
			index += 1;

			capsule.selected = index == curSelected + 1;

			var capsuleIndex = index - curSelected;
			var yOffset:Float = 0;

			// Small offset so edge capsules actually go offscreen enough to not require to be rendered.
			if (capsuleIndex < 0) yOffset += 50;
			else if (capsuleIndex > 4) yOffset -= 10;

			capsule.targetPos.y = capsule.intendedY(index - curSelectedFractal) - yOffset;
			capsule.targetPos.x = capsule.intendedX(index - curSelectedFractal) + (CUTOUT_WIDTH * SONGS_POS_MULTI);

			if (index < curSelected)
				capsule.targetPos.y -= 100; // another 100 for good measure
		}
	}

	function changeSelection(change:Int = 0, updateCardPosition:Bool = true):Void
	{
		var prevSelected:Int = curSelected;
		if (updateCardPosition)
			curSelectedFractal = curSelected;
		curSelected += change;

		// ? Added code here to handle drag changes
		if (curSelected < 0)
			if (updateCardPosition)
			{
				curSelected = grpCapsules.countLiving() - 1;
				change = 0;
				curSelectedFractal = curSelected;
			}
			else
			{
				curSelected = prevSelected;
				return;
			}
		if (curSelected >= grpCapsules.countLiving())
			if (updateCardPosition)
			{
				curSelected = 0;
				change = 0;
				curSelectedFractal = 0;
			}
			else
			{
				curSelected = prevSelected;
				return;
			}

		if (!prepForNewRank && curSelected != prevSelected && change != 0)
			FunkinSound.playOnce(Paths.sound('scrollMenu'), 0.4);

		var daSongCapsule:SongMenuItem = curCapsule;
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
		if (updateCardPosition)
			changeSelectionFractal(change);

		if (grpCapsules.countLiving() > 0 && !prepForNewRank)
		{
			if (daSongCapsule.songData != null)
				FreeplayHelpers.loadDiffsFromWeek(daSongCapsule.songData);

			FlxG.sound.music.pause(); // muting previous track must be done NOW
			FlxTimer.wait(FADE_IN_DELAY, playCurSongPreview.bind(daSongCapsule)); // Wait a little before trying to pull a Inst file

			tweenCurSongColor(daSongCapsule);
			curCapsule.selected = true;
		}
		else if (prepForNewRank)
			tweenCurSongColor(daSongCapsule);
	}

	public function playCurSongPreview(?daSongCapsule:SongMenuItem):Void
	{
		if (daSongCapsule == null)
			daSongCapsule = curCapsule;

		if (curSelected == 0 || daSongCapsule.songData == null)
		{
			FunkinSound.playMusic('freeplayRandom', {
				startingVolume: 0.0,
				overrideExisting: true,
				restartTrack: false
			});
			FlxG.sound.music.fadeIn(2, 0, 0.7);
		}
		else
		{
			if (!daSongCapsule.selected)
				return; // ? make sure we actually have to load preview
			var potentiallyErect:String = (currentDifficulty == "erect") || (currentDifficulty == "nightmare") ? "-erect" : "";
			// ? psych dir setting
			var songData = daSongCapsule.songData;
			ModsHelper.loadModDir(songData.folder);
			FunkinSound.playMusic(daSongCapsule.songData.getNativeSongId(), {
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
					var endVolume = dj?.playingCartoon ? 0.1 : FADE_IN_END_VOLUME;
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
		var result = new MainMenuState();
		result.openSubState(new FreeplayState(params, stickers));
		result.persistentUpdate = false;
		result.persistentDraw = true;
		return result;
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
