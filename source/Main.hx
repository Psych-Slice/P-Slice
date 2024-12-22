package;

import mikolka.GameBorder;
import mikolka.vslice.components.MemoryCounter;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;

import vlc.MP4Handler;

#if COPYSTATE_ALLOWED
import mobile.states.CopyState;
#end
#if mobile
import mobile.backend.MobileScaleMode;
#end

using StringTools;

#if linux
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fpsVar:FPS;
	public static var memoryCounter:MemoryCounter;
	public static var border:GameBorder;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();
		#if mobile
		#if android
		StorageUtil.requestPermissions();
		#end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end

		CrashHandler.init();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		#if (openfl <= "9.2.0")
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}
		#else
		if (zoom == -1)
			zoom = 1;
		#end
	
		ClientPrefs.loadDefaultKeys();
		var game = new FlxGame(gameWidth, gameHeight, #if COPYSTATE_ALLOWED !CopyState.checkExistingFiles() ? CopyState : #end initialState, framerate, framerate, skipSplash, startFullscreen);

		// FlxG.game._customSoundTray wants just the class, it calls new from
    	// create() in there, which gets called when it's added to stage
    	// which is why it needs to be added before addChild(game) here
    	@:privateAccess
    	game._customSoundTray = mikolka.vslice.components.FunkinSoundTray;
		addChild(game);
		
		fpsVar = new FPS(10, 3, 0xFFFFFF);
		#if mobile
		FlxG.game.addChild(fpsVar);
	  	#else
		var border = new GameBorder();
		addChild(border);
		Lib.current.stage.window.onResize.add(border.updateGameSize);
		addChild(fpsVar);
		#end
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if (fpsVar != null)
		{
			fpsVar.visible = ClientPrefs.showFPS;
		}

		#if !html5
		// TODO: disabled on HTML5 (todo: find another method that works?)
		memoryCounter = new MemoryCounter(10, 13, 0xFFFFFF);
		#if mobile
		FlxG.game.addChild(memoryCounter);
	  	#else
		addChild(memoryCounter);
		#end
		if (memoryCounter != null)
		{
			memoryCounter.visible = ClientPrefs.showFPS;
		}
		#end
		
		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		#if android FlxG.android.preventDefaultKeys = [BACK]; #end

		#if mobile
		lime.system.System.allowScreenTimeout = ClientPrefs.screensaver;
		FlxG.scaleMode = new MobileScaleMode();
		#end
	}
}
