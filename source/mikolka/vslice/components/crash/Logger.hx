package mikolka.vslice.components.crash;

import mikolka.compatibility.VsliceOptions;
#if sys
import haxe.PosInfos;
import openfl.display.Sprite;
import haxe.Log;

class Logger{
    private static var file:FileOutput;
    public static function startLogging() {
        file = File.write("latest.log");
        Log.trace = log;
    }
    private static function log(v:Dynamic, ?infos:PosInfos):Void {
        if(VsliceOptions.LOGGING == "None") return;
        var str = Log.formatOutput(v,infos);
        if(VsliceOptions.LOGGING == "Console") Sys.println(str);
        if(VsliceOptions.LOGGING == "File" && file != null) {
            file.writeString(str+"\n");
            file.flush();
        }
    }
}
#end