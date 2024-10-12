package mikolka.compatibility;

import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.io.Path;

class ModsHelper {
	public inline static function isModDirEnabled(directory:String) {
		return getEnabledMods().contains(directory);
	}
    public inline static function loadModDir(directory:String) {
		Paths.currentModDirectory = directory;
	}
	public static function getModsWithPlayersRegistry():Array<String> {
		return getEnabledMods().filter(s ->FileSystem.exists(Paths.mods(s)+'/registry/players'));
	}
	public inline static function loadabsoluteGraphic(path:String):FlxGraphic {
		if(!Paths.currentTrackedAssets.exists(path)) {
			Paths.cacheBitmap(path,null,BitmapData.fromFile(path));
		}
		return Paths.currentTrackedAssets.get(path);
	}
	private static function getEnabledMods(){
		var folders = [];
		var path:String = 'modsList.txt';
		if(FileSystem.exists(path))
		{
			var list:Array<String> = CoolUtil.coolTextFile(path);
			for (i in list)
			{
				var dat = i.split("|");
				if (dat[1] == "1")
				{
					if(!folders.contains(dat[0])) folders.push(dat[0]);
				}
			}
		}
		return folders;
	}
}