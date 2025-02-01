package mikolka.compatibility;

import flixel.graphics.FlxGraphic;
import openfl.media.Sound;
import flixel.graphics.frames.FlxAtlasFrames;

class FunkinPath {

    public static function animateAtlas(path:String,lib:String = "preload"):String {
        return getPath("images/"+path);
    }
    public static function getPath(path:String,forceNative:Bool = false):String {
        if(forceNative) return Paths.getSharedPath(path);
        
        var curMod = Mods.currentModDirectory;
        var modsToCheck = Mods.getGlobalMods().copy();
        if(curMod != null && curMod != '') modsToCheck.insert(0,curMod);

        for (name in modsToCheck){
            var testPath = #if mobile Sys.getCwd() + #end 'mods/$name/$path';
            if(FileSystem.exists(testPath))
                return testPath;
        }
        if (FileSystem.exists(#if mobile Sys.getCwd() + #end 'mods/$path')) return #if mobile Sys.getCwd() + #end 'mods/$path';
        else return Paths.getSharedPath(path);
    }

    public static function sound(key:String):String {
        return key;//Paths.getPath("sounds/"+Language.getFileTranslation(key) + '.ogg', SOUND, null, true);
        //We'll handle this later in FunkinSound
    }
    public static function music(key:String):Sound {
        
        return Paths.music(key);
    }

    public static function image(s:String) {
        return Paths.image(s);
    }

    public static function getSparrowAtlas(s:String):FlxAtlasFrames {
        return Paths.getSparrowAtlas(s);
    }

    public static function noGpuImage(s:String):FlxGraphic {
        return Paths.image(s,null,false);
    }

    public static function exists(s:String):Bool {
        // Check if a file exists somethere
        return Paths.fileExists(s,TEXT);
    }
    public static function stripLibrary(path:String):String
        {
          var parts:Array<String> = path.split(':');
          if (parts.length < 2) return path;
          return parts[1];
        }

    public static function clearUnusedMemory() { 
        Paths.clearUnusedMemory();
    }
}