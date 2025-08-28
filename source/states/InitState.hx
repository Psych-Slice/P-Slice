package states;

import mikolka.funkin.custom.mobile.MobileScaleMode;
import openfl.Assets;
import mikolka.vslice.ui.title.TitleState;
import flixel.input.keyboard.FlxKey;
import mikolka.vslice.ui.disclaimer.WarningState;
import mikolka.vslice.ui.disclaimer.TextWarnings.FlashingState;
import mikolka.vslice.ui.disclaimer.TextWarnings.OutdatedState;
import mikolka.vslice.components.ScreenshotPlugin;

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


		#if (cpp && windows)
		trace("Fixing DPI aware:");
		backend.Native.fixScaling();
		#end
		
		trace("Loading game settings");
		ClientPrefs.loadPrefs();

		trace("Loading translations");
		Language.reloadPhrases();

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

		FlxG.scaleMode = new MobileScaleMode(ClientPrefs.data.wideScreen); 

		trace("Init plugins:");
		//* FIRST INIT! iNITIALISE IMPORTED PLUGINS
		ScreenshotPlugin.initialize();

		#if android
		//* This is only for the 3.3 version
		var path = Path.join([lime.system.System.applicationStorageDirectory,backend.CoolUtil.getSavePath(),"funkin.sol"]);
		var exportPath = Path.join([mobile.backend.StorageUtil.getStorageDirectory(),"funkin.sol"]);

		#if !OLD_SIGN_KEYS
		if(FileSystem.exists(exportPath) && FlxG.save.data.flashing == null){
			var txt = "Save data found!!!\n\n"+
			"Press A to import it\n";
			MusicBeatState.switchState(new WarningState(txt,() ->{
				File.copy(exportPath,path);
				lime.system.System.exit(0);
			},() ->{},new TitleState()));
		}else
		#end
		#end
		if (FlxG.save.data.flashing == null)
		{
			#if OLD_SIGN_KEYS
			var txt = "You are using a build with old signing keys!\n\n"
			+ "Please download the regular android version instead!";
			MusicBeatState.switchState(new WarningState(txt,() ->{
				lime.system.System.exit(0);
			},() ->{
				lime.system.System.exit(0);
			},new TitleState()));
			#else
			controls.isInSubstate = false;
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState(new TitleState()));
			#end
		}
        #if (CHECK_FOR_UPDATES && !OLD_SIGN_KEYS)
        else if (mustUpdate){
            MusicBeatState.switchState(new OutdatedState(updateVersion,new TitleState()));
        }
        #end
		else
		{
			#if OLD_SIGN_KEYS
			var txt = "You are using a build with old signing keys!\n"
			+ "Due to the many factors, P-Slice will now use peoper signing keys on the Android.\n\n"+
			"Press A to export your save data and open the migration guide\n"+
			"Press B to ignore"
			;
			MusicBeatState.switchState(new WarningState(txt,() ->{
				File.copy(path,exportPath);
				CoolUtil.browserLoad("");
			},() ->{},new TitleState()));
			#else
			new FlxTimer().start(0.05, function(tmr:FlxTimer)
				{
					#if FREEPLAY
					MusicBeatState.switchState(new FreeplayState());
					#elseif CHARTING
					MusicBeatState.switchState(new ChartingState());
					#else
					MusicBeatState.switchState(new TitleState());
					#end
				});
			#end
		}
	}

	#if CHECK_FOR_UPDATES
	function fetchUpdateData()
	{
		if (ClientPrefs.data.checkForUpdates)
		{
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/mikolka9144/P-Slice/master/gitVersion.txt");

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
