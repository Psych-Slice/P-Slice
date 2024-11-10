package mikolka.compatibility;

import openfl.filters.BitmapFilter;
import flixel.system.FlxSound;
import flixel.util.FlxSort;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.io.Path;

using mikolka.funkin.utils.ArrayTools;

class ModsHelper {
	public inline static function isModDirEnabled(directory:String) {
		return Mods.parseList().enabled.contains(directory);
	}
    public inline static function loadModDir(directory:String) {
		Mods.currentModDirectory = directory;
	}
	public inline static function getActiveMod():String {
		return Mods.currentModDirectory;
	}
	public static function getModsWithPlayersRegistry():Array<String> {
		#if MODS_ALLOWED
		return Mods.parseList().enabled.filter(s ->FileSystem.exists(Paths.mods(s)+'/registry/players'));
		#else
		return [];
		#end
	}
	public inline static function loadabsoluteGraphic(path:String):FlxGraphic {
		if(!Paths.currentTrackedAssets.exists(path)) {
			Paths.cacheBitmap(path,null,BitmapData.fromFile(path));
		}
		return Paths.currentTrackedAssets.get(path);
	}
	public inline static function getSoundChannel(sound:FlxSound){
		@:privateAccess
		return sound._channel.__audioSource;
	}
	public inline static function setFiltersOnCam(camera:FlxCamera,value:Array<BitmapFilter>){
		camera.filters = value;
		camera.filtersEnabled = true;
	}
	public static function clearStoredWithoutStickers() {
		@:privateAccess
		var cache = FlxG.bitmap._cache;
		Paths.currentTrackedAssets.clear();
		for (key => val in cache){
		if(	key.toLowerCase().contains("transitionswag") || 
			key.contains("bg_graphic_") ||
			key == "images/justBf.png"
		) Paths.currentTrackedAssets.set(key,val);
		}
		Paths.clearStoredMemory();
	}
	#if sys
	public inline static function collectVideos():String{
		var dirsToList = new Array<String>();
		dirsToList.push('assets/videos/commercials/');
		if(FileSystem.exists('mods/videos/commercials'))dirsToList.push('mods/videos/commercials/');
		Mods.loadTopMod();
		var modsToSearch = Mods.getGlobalMods();
		modsToSearch.pushUnique(Mods.currentModDirectory);
		modsToSearch = modsToSearch.filter(s -> FileSystem.exists('mods/$s/videos/commercials')).map(s -> 'mods/$s/videos/commercials');
		
		dirsToList = dirsToList.concat(modsToSearch);
		var commercialsToSelect = new Array<String>();
		for(potencialComercials in dirsToList){
		  for (file in FileSystem.readDirectory(potencialComercials).filter(s -> s.endsWith(".mp4"))) {
			commercialsToSelect.push(potencialComercials + '/'+file);
		  }
		}
		return FlxG.random.getObject(commercialsToSelect);
	  }
	#end
}