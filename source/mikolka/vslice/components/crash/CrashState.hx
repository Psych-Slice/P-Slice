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
	var screenBelow:BitmapData = BitmapData.fromImage(FlxG.stage.window.readPixels());
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
		var previousScreen = new FlxSprite(0, 0, screenBelow);
		previousScreen.setGraphicSize(FlxG.width,FlxG.height);
		previousScreen.updateHitbox();
		add(previousScreen);
		openSubState(new UserErrorSubstate(this.EMessage,callstack));
		
		#if DISCORD_ALLOWED
		DiscordClient.shutdown();
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

}