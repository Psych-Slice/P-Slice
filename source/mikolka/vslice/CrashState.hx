package mikolka.vslice;

import flixel.FlxState;
import states.TitleState;
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

	var e:UncaughtErrorEvent;
	var errorMessage:String = '';

	public function new(error:UncaughtErrorEvent)
	{
		e = error;
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
		var errorMessage = "Unknown error";
		if (Std.isOfType(e.error, openfl.errors.Error))
		{
			var error = cast(e.error, openfl.errors.Error);
			errorMessage = error.message;
		}
		else if (Std.isOfType(e.error, ErrorEvent))
		{
			var error = cast(e.error, ErrorEvent);
			errorMessage = error.text;
		}
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
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
			extendedTrace: errExtended
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ENTER)
		{
			TitleState.initialized = false;
			TitleState.closedState = false;
			if (Main.fpsVar != null)
				Main.fpsVar.visible = ClientPrefs.data.showFPS;
			if (Main.memoryCounter != null)
				Main.memoryCounter.visible = ClientPrefs.data.showFPS;
			FlxG.sound.music = null;
			FlxG.resetGame();
		}
	}

	function printError(error:CrashData)
	{
		printToTrace('P-SLICE ${MainMenuState.pSliceVersion}  (${error.message.toUpperCase()})');
		printToTrace('PSYCH ${MainMenuState.psychEngineVersion.rpad(" ", 6)}   ' + 'SYS:${Sys.systemName().toUpperCase()}');
		FlxTimer.wait(1 / 24, () ->
		{
			printSpaceToTrace();
			for (line in error.trace)
			{
				switch (line.length)
				{
					case 1:
						printToTrace(line[0].toUpperCase());
					case 2:
						var first_line = line[0].toUpperCase().rpad(" ", 33);
						printToTrace('${first_line}${line[1].toUpperCase()}');
					default:
						printToTrace(" ");
				}
			}
			var remainingLines = 10 - error.trace.length;
			if (remainingLines > 0)
			{
				for (x in 0...remainingLines)
				{
					printToTrace(" ");
				}
			}
			// printToTrace('S8:00000000H   RA:80286034H   MM:86A20290H');
			printSpaceToTrace();
			printToTrace('MACHINE');
			printSpaceToTrace();
			printToTrace('TIME:${Date.now().toString().toUpperCase()}');
			printToTrace('F06:---------  F08:+1.000E+00 F10:+6.856E-01');
			printSpaceToTrace();
			printToTrace('REPORT TO GITHUB.COM/MIKOLKA9144/P-SLICE');
			printToTrace('PRESS ENTER TO RESTART');
		});
	}

	function saveError(error:CrashData)
	{
		var path:String;
		var errMsg = "";
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(' ', '_');
		dateNow = dateNow.replace(':', "'");

		path = './crash/' + 'PSlice_' + dateNow + '.txt';

		errMsg += '\nUncaught Error: ' + error.message + "\n";
		for (x in error.extendedTrace)
		{
			errMsg += x + "\n";
		}
		/*
		 * remove if you're modding and want the crash log message to contain the link
		 * please remember to actually modify the link for the github page to report the issues to.
		 */
		//
		errMsg += '\nPlease report this error to the GitHub page: https://github.com/mikolka9144/P-Slice\n\n> Crash Handler written by: sqirra-rng';

		if (!FileSystem.exists('./crash/'))
			FileSystem.createDirectory('./crash/');

		File.saveContent(path, errMsg + '\n');

		Sys.println(errMsg);
		Sys.println('Crash dump saved in ' + Path.normalize(path));
	}

	var textNextY = 5;

	function printToTrace(text:String)
	{
		var test_text = new FlxText(180, textNextY, 1500, text);
		test_text.setFormat(Paths.font('vcr.ttf'), 35, FlxColor.WHITE, LEFT);
		test_text.updateHitbox();
		add(test_text);
		textNextY += 35;
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
	extendedTrace:Array<String>
}
