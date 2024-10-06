package mikolka.compatibility;

import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.io.Path;

class ModsHelper {
	public inline static function isModDirEnabled(directory:String) {
		return Mods.parseList().enabled.contains(directory);
	}
    public inline static function loadModDir(directory:String) {
		Mods.currentModDirectory = directory;
	}
	public static function getModsWithPlayersRegistry():Array<String> {
		return Mods.parseList().enabled.filter(s ->FileSystem.exists(Paths.mods(s)+'/registry/players'));
	}
	public inline static function loadabsoluteGraphic(path:String):FlxGraphic {
		if(!Paths.currentTrackedAssets.exists(path)) {
			Paths.cacheBitmap(path,null,BitmapData.fromFile(path));
		}
		return Paths.currentTrackedAssets.get(path);
	}
}