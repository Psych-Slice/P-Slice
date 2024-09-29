package mikolka.compatibility;

import haxe.io.Path;

class ModsHelper {
    public inline static function loadModDir(directory:String) {
		Mods.currentModDirectory = directory;
	}
	public static function getModsWithPlayersRegistry():Array<String> {
		return  Mods.getModDirectories().filter(s ->FileSystem.exists(Paths.mods(s)+'/registry/playableChars'));
	}
}