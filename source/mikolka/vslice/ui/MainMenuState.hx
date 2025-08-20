package mikolka.vslice.ui;

import mikolka.funkin.custom.mobile.MobileScaleMode;
import mikolka.vslice.ui.obj.grid.OptionsButton;
import mikolka.vslice.ui.obj.grid.GridTileDonate;
import mikolka.vslice.ui.obj.GridButtons;
import mikolka.compatibility.ui.MainMenuHooks;
import mikolka.compatibility.VsliceOptions;
import mikolka.vslice.ui.title.TitleState;
#if !LEGACY_PSYCH
#if MODS_ALLOWED
import states.ModsMenuState;
#end
import states.AchievementsMenuState;
import states.CreditsState;
import states.editors.MasterEditorMenu;
#else
import editors.MasterEditorMenu;
#end
import mikolka.compatibility.ModsHelper;
import mikolka.vslice.freeplay.FreeplayState;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	#if !LEGACY_PSYCH
	public static var psychEngineVersion:String = '1.0.4'; // This is also used for Discord RPC
	#else
	public static var psychEngineVersion:String = '0.6.3'; // This is also used for Discord RPC
	#end
	public static var pSliceVersion:String = '3.2.1';
	public static var funkinVersion:String = '0.6.3'; // Version of funkin' we are emulationg
	public static var curSelected:Int = 0;

	var grid:GridButtons;

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	public function new(isDisplayingRank:Bool = false)
	{
		// TODO
		super();
	}

	override function create()
	{
		ModsHelper.clearStoredWithoutStickers();
		Paths.clearUnusedMemory();

		ModsHelper.resetActiveMods();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = VsliceOptions.ANTIALIASING;
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		// camFollow = new FlxObject(FlxG.initialWidth/2,FlxG.initialHeight/2, 1, 1);
		// add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.antialiasing = VsliceOptions.ANTIALIASING;
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = 0xFFfd719b;
		add(magenta);

		grid = new GridButtons(30, 20, 2,670);
		add(grid);
		grid.onItemSelect.add(s ->{
			FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;
				selectedSomethin = true;

				if (VsliceOptions.FLASHBANG)
					FlxFlicker.flicker(magenta, 1.1, 0.15, false);
		});
		var storyBtn = grid.makeButton('story_mode', 0, () ->
		{
			FlxG.mouse.visible = false;
			MusicBeatState.switchState(new StoryMenuState());
		});
		storyBtn.updateHitbox();

		grid.makeButton('freeplay', 0, () ->
		{
			FlxG.mouse.visible = false;
			persistentDraw = true;
			persistentUpdate = false;
			// Freeplay has its own custom transition
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			openSubState(new FreeplayState());
			subStateOpened.addOnce(state ->
			{
				grid.revealButtons();
				selectedSomethin = false;
				grid.selectButton();
			});
			subStateClosed.addOnce((x) ->{
				FlxG.mouse.visible = true;
			});
		});
		#if MODS_ALLOWED
		grid.makeButton('mods', 0, () ->
		{
			FlxG.mouse.visible = false;
			MusicBeatState.switchState(new ModsMenuState());
		});
		#end
		#if ACHIEVEMENTS_ALLOWED
		grid.makeButton('awards', 1, () ->
		{
			FlxG.mouse.visible = false;
			MusicBeatState.switchState(new AchievementsMenuState());
		});
		#end

		grid.makeButton('credits', 1, () ->
		{
			FlxG.mouse.visible = false;
			MusicBeatState.switchState(new CreditsState());
		});
		#if !switch
		grid.addButton(new GridTileDonate(grid), 1);
		#end
		var optionsBtn = new OptionsButton(grid,() ->
		{
			FlxG.mouse.visible = false;
			MusicBeatState.switchState(new OptionsState());
			#if !LEGACY_PSYCH OptionsState.onPlayState = false; #end
			if (PlayState.SONG != null)
			{
				PlayState.SONG.arrowSkin = null;
				PlayState.SONG.splashSkin = null;
				#if !LEGACY_PSYCH PlayState.stageUI = 'normal'; #end
			}
		});
		grid.addButton(optionsBtn,0);
		optionsBtn.setPosition((MobileScaleMode.gameCutoutSize.x/4)+35, FlxG.height - 200);

		var psychVer:FlxText = new FlxText(0, FlxG.height - 18, FlxG.width, "Psych Engine " + psychEngineVersion, 12);
		var fnfVer:FlxText = new FlxText(0, FlxG.height - 18, FlxG.width, 'v${funkinVersion} (P-slice ${pSliceVersion})', 12);

		psychVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		fnfVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		psychVer.scrollFactor.set();
		fnfVer.scrollFactor.set();
		add(psychVer);
		add(fnfVer);
		// var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' ", 12);

		grid.selectButton();

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			MainMenuHooks.unlockFriday();

		#if MODS_ALLOWED
		MainMenuHooks.reloadAchievements();
		#end
		#end

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('NONE', 'A_B_E');
		#end

		super.create();
		FlxG.mouse.visible = true;
		//FlxG.camera.follow(camFollow, null, 0.06);
		// FlxG.camera.bgColor = 0xfffde871;
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			// if (FreeplayState.vocals != null)
			// FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				grid.changeSelection(0, -1);

			if (controls.UI_DOWN_P)
				grid.changeSelection(0, 1);
			if (controls.UI_LEFT_P)
				grid.changeSelection(-1, 0);

			if (controls.UI_RIGHT_P)
				grid.changeSelection(1, 0);

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT) {
				selectedSomethin = true;
				grid.confirmCurrentButton();
			}
			if (#if TOUCH_CONTROLS_ALLOWED touchPad.buttonE.justPressed || #end#if LEGACY_PSYCH FlxG.keys.anyJustPressed(ClientPrefs.keyBinds.get('debug_1')
				.filter(s -> s != -1)) #else controls.justPressed('debug_1') #end)
			{
				selectedSomethin = true;
				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
		}

		super.update(elapsed);
	}
}
