package mikolka.vslice.components.crash;

import haxe.Exception;
import flixel.system.debug.log.LogStyle;
import mikolka.compatibility.VsliceOptions;
#if sys
import haxe.PosInfos;
import openfl.display.Sprite;
import haxe.Log;

class Logger{
    private static var file:FileOutput;
    public static var enforceLogSettings:Bool = false;
    public static function startLogging() {
        #if LEGACY_PSYCH
        file = File.write("latest.log");
        #else
        try{
            file = File.write(StorageUtil.getStorageDirectory()+"/latest.log");
        }
        catch(x:Exception){
            #if (LEGACY_PSYCH)
            FlxG.stage.window.alert(x.message, "File logging failed to init");
            #else
            #if macos
            if(StorageUtil.getStorageDirectory().contains("AppTranslocation"))
                CoolUtil.showPopUp("MacOS decided to isolate P-Slice from the rest of your system!"+
                "As such, you need to move P-Slice away from the \"Downloads\" folder into either your applications, or another folder.","File logging failed to init");
            else
            #end
            CoolUtil.showPopUp(x.message,"File logging failed to init");
            #end
        }
        LogStyle.WARNING.onLog.add(log);
        LogStyle.ERROR.onLog.add(log);
        #end
        Log.trace = log;
    }
    
    private static function log(v:Dynamic, ?infos:PosInfos):Void {
        var str = Log.formatOutput(v,infos);
        if(enforceLogSettings){
            if(VsliceOptions.LOGGING == "None") return;
            if(VsliceOptions.LOGGING == "Console") Sys.println(str);
            if(VsliceOptions.LOGGING == "File" && file != null) {
                file.writeString(str+"\n");
                file.flush();
            }
        }
        else{
            #if debug
            Sys.println(str);
            #else
            if( file != null) {
                file.writeString(str+"\n");
                file.flush();
            }
            #end
        }
    }
}
#end