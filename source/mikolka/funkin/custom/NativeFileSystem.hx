package mikolka.funkin.custom;

import openfl.media.Sound;
import openfl.display.BitmapData;
#if (!NATIVE_LOOKUP && !OPENFL_LOOKUP)
#error "You need to have enabled either OpenFL, or NativeFileSystem lookup to compile this app!"
#end
#if OPENFL_LOOKUP
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
#end
#if NATIVE_LOOKUP
import sys.FileSystem as FileSystem;
#end

/**
	**Works only on paths relative to game's root dorectory*

	Basically NativeFileSystem, but we can emulate it on OpenFL.
	It can either 
**/
class NativeFileSystem
{
	public static function getContent(path:String):Null<String>
	{
		var isModded = path.startsWith("mods");
		#if OPENFL_LOOKUP
		if (!isModded)
		{
			var openfl_content = (OpenFlAssets.exists(path, TEXT)) ? Assets.getText(path) : null;
			if (openfl_content != null)
				return openfl_content;
		}
		#end

		#if NATIVE_LOOKUP
		#if OPENFL_LOOKUP
		if (!isModded)
			return null;
		#end
		var sys_path = getPathLike(path);
		var sys_res = sys_path != null ? File.getContent(sys_path) : null;
		if (sys_res != null)
			return sys_res;
		trace("Text file doesn't exist!! ", path);
		#end
		return null;
	}

	// Loads a given bitmap. Returns null if it doesn't exist
	public static function getBitmap(path:String):Null<BitmapData>
	{
		#if nativesys_profile var timeStart = Sys.time(); #end
		var isModded = path.startsWith("mods");

		#if OPENFL_LOOKUP
		if (#if NATIVE_LOOKUP !isModded && #end OpenFlAssets.exists(path, IMAGE))
		{
			var result = OpenFlAssets.getBitmapData(path);
			#if nativesys_profile
			var timeEnd = Sys.cpuTime() - timeStart;
			if (timeEnd > 1.2)
				trace('Getting native bitmap ${path} took: $timeEnd');
			#end
			return result;
		}
		#end

		#if NATIVE_LOOKUP
		#if OPENFL_LOOKUP
		if (!isModded)
			return null;
		#end
		var sys_path = getPathLike(path);
		if (sys_path != null)
		{
			var result = BitmapData.fromFile(sys_path);
			#if nativesys_profile
			var timeEnd = Sys.cpuTime() - timeStart;
			if (timeEnd > 1.2)
				trace('Getting system bitmap ${path} took: $timeEnd');
			#end
			return result;
		}
		#end

		return null;
	}

	public static function getSound(path:String):Null<Sound>
	{
		var isModded = path.startsWith("mods");
		#if nativesys_profile var timeStart = Sys.time(); #end

		#if OPENFL_LOOKUP
		if (!isModded)
		{
			if (OpenFlAssets.exists(path, SOUND))
			{
				var result = OpenFlAssets.getSound(path);
				#if nativesys_profile
				var timeEnd = Sys.cpuTime() - timeStart;
				if (timeEnd > 1.2)
					trace('Getting native ${path} took: $timeEnd');
				#end
				return result;
			}
		}
		#end

		#if NATIVE_LOOKUP
		#if OPENFL_LOOKUP
		if (!isModded)
			return null;
		#end
		var sys_path = getPathLike(path);
		if (sys_path != null)
		{
			var result = Sound.fromFile(sys_path);
			#if nativesys_profile
			var timeEnd = Sys.cpuTime() - timeStart;
			if (timeEnd > 1.2)
				trace('Getting system sound ${path} took: $timeEnd');
			#end
			return result;
		}
		#end
		#if nativesys_profile
		var timeEnd = Sys.cpuTime() - timeStart;
		if (timeEnd > 1.2)
			trace('Getting failed sound ${path} took: $timeEnd');
		#end
		return null;
	}

	// Check if the file exists
	public static function exists(path:String)
	{
		var isModded = path.startsWith("mods");
		#if nativesys_profile var timeStart = Sys.time(); #end

		#if OPENFL_LOOKUP
		if (!isModded)
		{
			var isFile = OpenFlAssets.exists(path, TEXT);
			if (!isFile)
			{
				var isDir = Assets.list().filter(folder -> folder.startsWith(path)).length > 0;
				return isDir;
			}
			return isFile;
		}
		#end

		#if NATIVE_LOOKUP
		#if OPENFL_LOOKUP
		if (!isModded)
			return false;
		#end
		if (getPathLike(path) != null)
		{
			return true;
		}
		#end

		return false;
	}

	public static function readDirectory(directory:String):Array<String>
	{
		var isModded = directory.startsWith("mods");
		#if nativesys_profile
		var timeStart = Sys.time();
		#end

		#if OPENFL_LOOKUP
		if (#if NATIVE_LOOKUP !isModded #else true #end)
		{
			var dirs:Array<String> = [];
			if (!directory.endsWith("/"))
				directory += '/';
			for (dir in Assets.list().filter(folder -> folder.startsWith(directory)))
			{
				@:privateAccess
				for (library in lime.utils.Assets.libraries.keys())
				{
					if (library != 'default' && Assets.exists('$library:$dir') && (!dirs.contains('$library:$dir') || !dirs.contains(dir)))
						dirs.push('$library:$dir');
					else if (Assets.exists(dir) && !dirs.contains(dir))
					{
						var parts = dir.split("/");
						dirs.push(parts.pop());
					}
				}
			}
			#if nativesys_profile
			var timeEnd = Sys.cpuTime() - timeStart;
			if (timeEnd > 1.2)
				trace('Getting native directory ${directory} took: $timeEnd');
			#end
			if (dirs.length > 0)
				return dirs;
		}
		#end

		#if NATIVE_LOOKUP
		var testdir = getPathLike(directory);
		if (testdir != null)
		{
			var result = FileSystem.readDirectory(testdir);
			#if nativesys_profile
			var timeEnd = Sys.cpuTime() - timeStart;
			if (timeEnd > 1.2)
				trace('Getting system directory ${directory} took: $timeEnd');
			#end
			return result;
		}
		#end

		#if nativesys_profile
		var timeEnd = Sys.cpuTime() - timeStart;
		if (timeEnd > 1.2)
			trace('Getting (failed) directory ${directory} took: $timeEnd');
		#end
		return [];
	}

	/**
	 * Checks if the given path is a valid directory.
	 * @param directory A path **relative** to the working directory 
	 * @return Bool Is it a valid directory
	 */
	//
	public static function isDirectory(directory:String):Bool
	{
		var result = false;
		var isModded = directory.startsWith("mods");
		#if nativesys_profile
		var timeStart = Sys.cpuTime();
		#end

		#if OPENFL_LOOKUP
		if (!result && !isModded)
		{
			result = Assets.list().filter(folder -> folder.startsWith(directory) && folder != directory).length > 0;
			#if nativesys_profile
			var timeEnd = Sys.cpuTime() - timeStart;
			if (timeEnd > 1.2)
				trace('Checking native directory ${directory} took: $timeEnd');
			#end
		}
		#end

		#if NATIVE_LOOKUP
		#if OPENFL_LOOKUP
		if (!isModded)
			return false;
		#end
		if (!result)
		{
			result = sys.FileSystem.isDirectory(addCwd(directory));
			#if nativesys_profile
			var timeEnd = Sys.cpuTime() - timeStart;
			if (timeEnd > 1.2)
				trace('Checking system directory ${directory} took: $timeEnd');
			#end
		}
		#end
		return result;
	}

	// Not available without sys
	public static function createDirectory(modFolder:String)
	{
		#if NATIVE_LOOKUP
		sys.FileSystem.createDirectory(addCwd(modFolder));
		#else
		trace("We have no FileSystem under us! We can't make new dirs!");
		#end
	}

	// Not available without sys
	public static function deleteFile(s:String)
	{
		#if NATIVE_LOOKUP
		sys.FileSystem.deleteFile(addCwd(s));
		#else
		trace("We have no FileSystem under us! We can't delete this!");
		#end
	}

	/**
		Adds the current root dir to the path.

		Depends a lot on the target system!
	**/
	private static function addCwd(directory:String):String
	{
		#if desktop
		return directory;
		#else
		var cwd = StorageUtil.getStorageDirectory();
		var test_cwd = haxe.io.Path.removeTrailingSlashes(cwd);
		if (directory.startsWith(test_cwd))
			return directory;
		return haxe.io.Path.addTrailingSlash(cwd) + directory;
		#end
	}

	#if linux
	/**
	 * Returns a path to the existing file similar to the given one.
	 * (For instance "mod/firelight" and  "Mod/FireLight" are *similar* paths)
	 * @param path
	 * @return Null<String>
	 */
	public static function getPathLike(path:String):Null<String>
	{
		if (sys.FileSystem.exists(path))
			return path;

		var baseParts:Array<String> = path.replace('\\', '/').split('/');
		var keyParts = [];
		if (baseParts.length == 0)
			return null;

		while (!sys.FileSystem.exists(baseParts.join("/")) && baseParts.length != 0)
			keyParts.insert(0, baseParts.pop());

		return findFile(baseParts.join("/"), keyParts);
	}

	private static function findFile(base_path:String, keys:Array<String>):Null<String>
	{
		var nextDir:String = base_path;
		for (part in keys)
		{
			if (part == '')
				continue;

			var foundNode = findNode(nextDir, part);

			if (foundNode == null)
			{
				return null;
			}
			nextDir = nextDir + "/" + foundNode;
		}

		return nextDir;
	}

	/**
	 * Searches a given directory and returns a name of the existing file/directory
	 * *similar* to the **key**
	 * @param dir Base directory to search
	 * @param key The file/directory you want to find
	 * @return Either a file name, or null if the one doesn't exist
	 */
	private static function findNode(dir:String, key:String):Null<String>
	{
		try
		{
			var allFiles:Array<String> = sys.FileSystem.readDirectory(dir);
			var fileMap:Map<String, String> = new Map();

			for (file in allFiles)
			{
				fileMap.set(file.toLowerCase(), file);
			}

			return fileMap.get(key.toLowerCase());
		}
		catch (e:Dynamic)
		{
			return null;
		}
	}
	#else

	/**
	 * Returns a path to the existing file similar to the given one.
	 * (For instance "mod/firelight" and  "Mod/FireLight" are *similar* paths)
	 * @param path
	 * @return Null<String>
	 */
	public static function getPathLike(path:String):Null<String>
	{
		var cwd_path = addCwd(path);
		if (sys.FileSystem.exists(cwd_path))
			return cwd_path;
		return null;
	}
	#end
}
