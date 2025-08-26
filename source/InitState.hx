package;

import mikolka.vslice.ui.title.TitleState;
import flixel.input.keyboard.FlxKey;
import mikolka.vslice.ui.disclaimer.TextWarnings.FlashingState;
import mikolka.vslice.ui.disclaimer.TextWarnings.OutdatedState;
import mikolka.vslice.components.ScreenshotPlugin;
import lime.app.Application;
import openfl.Assets;


class InitState extends MusicBeatState
{
    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

    var mustUpdate:Bool = false;
	public static var updateVersion:String = '';

	override function create()
	{
		super.create();
		persistentUpdate = true;
		persistentDraw = true;
		FlxG.mouse.visible = false;

		FlxG.game.focusLostFramerate = 60;
		FlxG.mouse.load(Assets.getBitmapData(Paths.getPreloadPath("images/cursor-default.png")).clone());
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		trace("Loading game settings");
		PlayerSettings.init();

		trace("ACTUALLY load saves");
		FlxG.save.bind('funkin', 'ninjamuffin99');

		ClientPrefs.loadPrefs();
		
		trace("Setting some save related values");
		if (FlxG.save.data != null && FlxG.save.data.fullscreen)
		{
			FlxG.fullscreen = FlxG.save.data.fullscreen;
			// trace('LOADED FULLSCREEN SETTING!!');
		}
		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}
		#if TOUCH_CONTROLS_ALLOWED
		trace("Loading mobile data");
		MobileData.init();
		#end

		//* FIRST INIT! iNITIALISE IMPORTED PLUGINS
		ScreenshotPlugin.initialize();

		if (FlxG.save.data.flashing == null)
		{
			controls.isInSubstate = false;
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState(new TitleState()));
		}
        #if CHECK_FOR_UPDATES
        else if (mustUpdate){
            MusicBeatState.switchState(new OutdatedState(updateVersion,new TitleState()));
        }
        #end
		else
		{
			#if desktop
			if (!Discord.DiscordClient.isInitialized)
			{
				Discord.DiscordClient.initialize();
				Application.current.onExit.add(function(exitCode)
				{
					Discord.DiscordClient.shutdown();
				});
			}
			#end
			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				#if FREEPLAY
				MusicBeatState.switchState(new FreeplayState());
				#elseif CHARTING
				MusicBeatState.switchState(new ChartingState());
				#else
				MusicBeatState.switchState(new TitleState());
				#end
			});
		}
	}

	#if CHECK_FOR_UPDATES
	function fetchUpdateData()
	{
		if (ClientPrefs.checkForUpdates)
		{
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/mikolka9144/P-Slice/pe-0.6.3/gitVersion.txt");

			http.onData = function(data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.pSliceVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if (updateVersion != curVersion)
				{
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function(error)
			{
				trace('error: $error');
			}

			http.request();
		}
	}
	#end
}