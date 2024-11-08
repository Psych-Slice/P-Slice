package mikolka.vslice;

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
	var textBg:FlxSprite;

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

		textBg = new FlxSprite();
		FunkinTools.makeSolidColor(textBg, Math.floor(FlxG.width * 0.73), FlxG.height, 0x86000000);
		textBg.screenCenter();

		add(previousScreen);
		add(textBg);
		var error = collectErrorData();
		printError(error);
		saveError(error);
		#if DISCORD_ALLOWED
		DiscordClient.shutdown();
		#end
	}

	function collectErrorData():CrashData
	{
		var errorMessage = EMessage;

		var callStack:Array<StackItem> = callstack;
		var errMsg = new Array<Array<String>>();
		var errExtended = new Array<String>();
		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, pos_line, column):
					var line = new Array<String>();
					switch (s)
					{
						case Module(m):
							line.push("MD:" + m);
						case CFunction:
							line.push("Native function");
						case Method(classname, method):
							var regex = ~/(([A-Z]+[A-z]*)\.?)+/g;
							regex.match(classname);
							line.push("CLS:" + regex.matched(0)+":"+method+"()");
						default:
							Sys.println(stackItem);
					}
					line.push("Line:" + pos_line);
					errMsg.push(line);
					errExtended.push('In file ${file}: ${line.join("  ")}');
				default:
					Sys.println(stackItem);
			}
		}
		return {
			message: errorMessage,
			trace: errMsg,
			extendedTrace: errExtended,
			date: Date.now().toString(),
			systemName: #if android 'Android' #elseif linux 'Linux' #elseif mac 'macOS' #elseif windows 'Windows' #else 'iOS' #end,
			activeMod: ModsHelper.getActiveMod()
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (TouchUtil.justReleased || FlxG.keys.justPressed.ENTER)
		{
			TitleState.initialized = false;
			TitleState.closedState = false;
			#if LEGACY_PSYCH
			if (Main.fpsVar != null) Main.fpsVar.visible = ClientPrefs.showFPS;
			if (Main.memoryCounter != null) Main.memoryCounter.visible = ClientPrefs.showFPS;
			#else
			if (Main.fpsVar != null) Main.fpsVar.visible = ClientPrefs.data.showFPS;
			if (Main.memoryCounter != null) Main.memoryCounter.visible = ClientPrefs.data.showFPS;
			#end
			FlxG.sound.pause();
			FlxTween.globalManager.clear();
			FlxG.resetGame();
		}
	}

	function printError(error:CrashData)
	{
		printToTrace('P-SLICE ${MainMenuState.pSliceVersion}  (${error.message})');
		textNextY += 35;
		FlxTimer.wait(1 / 24, () ->
		{
			printSpaceToTrace();
			for (line in error.trace)
			{
				switch (line.length)
				{
					case 1:
						printToTrace(line[0]);
					case 2:
						var first_line = line[0].rpad(" ", 33).replace("_","");
						printToTrace('${first_line}${line[1]}');
					default:
						printToTrace(" ");
				}
			}
			var remainingLines = 12 - error.trace.length;
			if (remainingLines > 0)
			{
				for (x in 0...remainingLines)
				{
					printToTrace(" ");
				}
			}
			// printToTrace('S8:00000000H   RA:80286034H   MM:86A20290H');
			printSpaceToTrace();
			printToTrace('RUNTIME INFORMATION');
			var date_split = error.date.split(" ");
			printToTrace('TIME:${date_split[1].rpad(" ",9)} DATE:${date_split[0]}');
			printToTrace('MOD:${error.activeMod.rpad(" ",10)} PE:${MainMenuState.psychEngineVersion.rpad(" ", 5)} SYS:${error.systemName}');
			printSpaceToTrace();
			printToTrace('REPORT TO GITHUB.COM/MIKOLKA9144/P-SLICE');
			printToTrace('PRESS ENTER TO RESTART');
		});
	}

	static function saveError(error:CrashData)
	{
		var errMsg = "";
		var dateNow:String = error.date;

		dateNow = dateNow.replace(' ', '_');
		dateNow = dateNow.replace(':', "'");

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
		Sys.println(errMsg);
		Sys.println('Crash dump saved in ' + Path.normalize(path));
		#end
		Sys.println(errMsg);
	}

	var textNextY = 5;

	function printToTrace(text:String):FlxText
	{
		var test_text = new FlxText(180, textNextY, 920, text.toUpperCase());
		test_text.setFormat(Paths.font('vcr.ttf'), 35, FlxColor.WHITE, LEFT);
		test_text.updateHitbox();
		add(test_text);
		textNextY += 35;
		return test_text;
	}

	function printSpaceToTrace()
	{
		textNextY += 10;
	}

	// function styleTest() {
	// 	printToTrace('THREAD:4  (FLOATING POINT EXCEPTION)');
	//     printToTrace('PC:8O2B645CH   SR:2OOOFFO3H   VA:FFFFFFFFH');
	// 	printSpaceToTrace();
	// 	printToTrace('AT:FFFFOOFFH   VO:00000001H   V1:80000401H');
	// 	printToTrace('AO:8015A578H   A1:80268300H   A2:412028F6H');
	// 	printToTrace('A3:43AB25B1H   TO:0000FFOOH   T1:0000FF0OH');
	// 	printToTrace('T2:00000AAAH   T3:003FFF01H   T4:2000FF01H');
	// 	printToTrace('T5:00000003H   T6:802DAAAOH   T7:802DASAOH');
	// 	printToTrace('SO:8010EFC8H   S1:800F7C8CH   S2:8010C924H');
	// 	printToTrace('S3:80000000H   S4:8010EBBOH   S5:00000000H');
	// 	printToTrace('S6:00000000H   S7:00000000H   T8:802DA898H');
	// 	printToTrace('T9:802DAA9SH   GP:00000000H   SP:800AE580H');
	// 	printToTrace('S8:00000000H   RA:80286034H   MM:86A20290H');
	// 	printSpaceToTrace();
	// 	printToTrace('FPCSR:0100080CH');
	// 	printSpaceToTrace();
	// 	printToTrace('F00:+7.280E-01 F02:---------  F04:45.458E+02');
	// 	printToTrace('F06:---------  F08:+1.000E+00 F10:+6.856E-01');
	// 	printToTrace('F12:+7.280E-01 F14:+5.458E+02 F16:+5.493E+02');
	// 	printToTrace('F18:+5.458E+02 F20:+0.000E+00 F22:+0.000E+00');
	// 	printToTrace('F24:+0.000E+00 F26:+0.000E+00 F28:+0.000E+00');
	// 	printToTrace('F30:+0.000E+00');
	// }
	// function name() {
	// }
}

typedef CrashData =
{
	message:String,
	trace:Array<Array<String>>,
	extendedTrace:Array<String>,
	date:String,
	systemName:String,
	activeMod:String
}