package mikolka.vslice.components.crash;

import mikolka.compatibility.VsliceOptions;
import mikolka.compatibility.ModsHelper;
import flixel.FlxState;
#if !LEGACY_PSYCH
import states.TitleState;
#end
import openfl.events.ErrorEvent;
import openfl.display.BitmapData;
// crash handler stuff
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;

using StringTools;

class CrashState extends FlxState
{
	var screenBelow:BitmapData;
	var EMessage:String;
    var callstack:Array<StackItem>;

	public function new(EMessage:String,callstack:Array<StackItem>)
	{
		this.EMessage = EMessage;
		this.callstack = callstack;
		super();
	}

	override function create()
	{
		if (Main.fpsVar != null)
			Main.fpsVar.visible = false;
		if (Main.memoryCounter != null)
			Main.memoryCounter.visible = false;
		super.create();
		#if DISCORD_ALLOWED
		DiscordClient.shutdown();
		#end
		var crash = UserErrorSubstate.collectErrorData(EMessage,callstack);
		#if sys saveError(crash); #end
		var previousScreen = new FlxSprite(0, 0, BitmapData.fromImage(FlxG.stage.window.readPixels()));
		previousScreen.setGraphicSize(FlxG.width,FlxG.height);
		previousScreen.updateHitbox();
		add(previousScreen);
		openSubState(new UserErrorSubstate(crash,true));
		
	}
	#if sys
        static function saveError(error:mikolka.vslice.components.crash.UserErrorSubstate.CrashData)
        {
            var errMsg = "";
            var dateNow:String = error.date;
            var star = #if CHECK_FOR_UPDATES "" #else "*" #end;
            dateNow = dateNow.replace(' ', '_');
            dateNow = dateNow.replace(':', "'");
            errMsg += 'P-Slice ${MainMenuState.pSliceVersion}$star\n';
            errMsg += '\nUncaught Error: ' + error.message + "\n";
            for (x in error.extendedTrace)
            {
                errMsg += x + "\n";
            }
            errMsg += '----------\n';
            errMsg += 'Active mod: ${error.activeMod}\n';
            errMsg += 'Platform: ${error.systemName}\n';
            errMsg += '\n';
            errMsg += '\nPlease report this error to the GitHub page: https://github.com/Psych-Slice/P-Slice\n\n> Crash Handler written by: sqirra-rng';
    
            #if !LEGACY_PSYCH
            @:privateAccess // lazy
            backend.CrashHandler.saveErrorMessage(errMsg + '\n');
            #else
            var path = './crash/' + 'PSlice_' + dateNow + '.txt';
            File.saveContent(path, errMsg + '\n');
            #end
            Sys.println(errMsg);
        }
    #end
	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

}