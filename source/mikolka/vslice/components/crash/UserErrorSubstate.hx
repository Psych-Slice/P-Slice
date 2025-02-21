package mikolka.vslice.components.crash;

#if !LEGACY_PSYCH
import states.TitleState;
#end
import mikolka.compatibility.ModsHelper;
import haxe.CallStack.StackItem;
import flixel.util.typeLimit.OneOfTwo;

class UserErrorSubstate extends MusicBeatSubstate 
    {
        var textBg:FlxSprite;
    
        var EMessage:String;
        var callstack:OneOfTwo<Array<StackItem>,String>;
        var isCritical:Bool;
        var allowClosing:Bool = false;

        var camOverlay:FlxCamera;
    
        public function new(EMessage:String,callstack:OneOfTwo<Array<StackItem>,String>)
        {
            this.EMessage = EMessage;
            this.callstack = callstack;
            isCritical = Std.isOfType(callstack,Array);
            camOverlay = new FlxCamera();
            camOverlay.bgColor = FlxColor.TRANSPARENT;
            FlxG.cameras.add(camOverlay);
            super();
        }
    
        override function create()
        {
            super.create();
            _parentState.persistentUpdate = false;
            textBg = new FlxSprite();
            FunkinTools.makeSolidColor(textBg, Math.floor(FlxG.width * 0.73), FlxG.height, 0x86000000);
            textBg.screenCenter();
            textBg.camera = camOverlay;
            add(textBg);
            var error:CrashData;
            if(Std.isOfType(callstack,Array)){
                error = collectErrorData();
            }else{
                var message = cast (callstack,String);
                var tbl = new Array<Array<String>>();
                for (x in message.split("\n")){
                    tbl.push([x]);
                }
                error = {
                    logToFile: false,
                    extendedTrace: [],
                    trace: tbl,
                    message: EMessage,
                    date: Date.now().toString(),
                    systemName: #if android 'Android' #elseif linux 'Linux' #elseif mac 'macOS' #elseif windows 'Windows' #else 'iOS' #end,
                    activeMod: ModsHelper.getActiveMod()
                };
            }
            
            printError(error);
            #if sys if(isCritical) saveError(error); #end
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
                                #if sys Sys.println #else trace #end(stackItem); 
                        }
                        line.push("Line:" + pos_line);
                        errMsg.push(line);
                        errExtended.push('In file ${file}: ${line.join("  ")}');
                    default:
                        #if sys Sys.println #else trace #end(stackItem);
                }
            }
            return {
                logToFile: true,
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
            if(!allowClosing) return;
            if (TouchUtil.justPressed || FlxG.keys.justPressed.ENTER)
            {
                FlxG.cameras.remove(camOverlay);
                if(!isCritical) {
                    _parentState.persistentUpdate = true;
                    close();
                    return;
                }
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
            #if sys
            else if(FlxG.keys.justPressed.ESCAPE && isCritical){
                Sys.exit(1);
            }
            #end
        }
    
        function printError(error:CrashData)
        {
            var star = #if CHECK_FOR_UPDATES "" #else "*" #end;
            printToTrace('P-SLICE ${MainMenuState.pSliceVersion}$star  (${error.message})');
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
                if(isCritical) printToTrace('REPORT TO GITHUB.COM/MIKOLKA9144/P-SLICE');
                else printToTrace('');
                if(isCritical){
                    if(controls.mobileC) printToTrace('TAP ANYWHERE TO RESTART');
                    else printToTrace('PRESS ENTER TO RESTART | ESC TO QUIT');
                }
                else{
                    if(controls.mobileC) printToTrace('TAP ANYWHERE TO CONTINUE');
                    else printToTrace('PRESS ENTER TO CONTINUE');
                }
                allowClosing = true;
            });
        }
    
        #if sys
        static function saveError(error:CrashData)
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
    
        var textNextY = 5;
    
        function printToTrace(text:String):FlxText
        {
            var test_text = new FlxText(180, textNextY, 920, text.toUpperCase());
            test_text.setFormat(Paths.font('vcr.ttf'), 35, FlxColor.WHITE, LEFT);
            test_text.updateHitbox();
            test_text.camera = camOverlay;
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
        logToFile:Bool,
        message:String,
        trace:Array<Array<String>>,
        extendedTrace:Array<String>,
        date:String,
        systemName:String,
        activeMod:String
    }