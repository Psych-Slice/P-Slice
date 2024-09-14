package mikolka.compatibility;

import openfl.media.Sound;
import flixel.graphics.frames.FlxAtlasFrames;

class FunkinPath {
    public static function animateAtlas(path:String,lib:String = "preload"):String {
        return Paths.getPreloadPath("images/"+path);
    }

    public static function sound(key:String):String {
        return key;//Paths.getPath("sounds/"+Language.getFileTranslation(key) + '.ogg', SOUND, null, true);
        //We'll handle this later in FunkinSound
    }
    public static function music(key:String):Sound {
        // V-Slice 
        return Paths.music(key);
    }

    public static function image(s:String) {
        return Paths.image(s);
    }

    //! Image, but NOT on GPU
    public static function noGpuImage(s:String) {
        return Paths.image(s);
    }

    public static function getSparrowAtlas(s:String):FlxAtlasFrames {
        return Paths.getSparrowAtlas(s);
    }
    public static function getPath(path:String){
        return Paths.getPreloadPath(path);
    }
}