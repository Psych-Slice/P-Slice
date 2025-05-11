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
		#if OPENFL_LOOKUP
		var openfl_content = (OpenFlAssets.exists(path, TEXT)) ? Assets.getText(path) : null;
		if (openfl_content != null)
			return openfl_content;
		#end

		#if NATIVE_LOOKUP
		var sys_path = getPathLike(path);
		var sys_res = sys_path != null ? File.getContent(sys_path) : null;
		if (sys_res != null)
			return sys_res;
		trace("Text file doesn't exist!! ",path);
		#end
		return null;
	}

	// Loads a given bitmap. Returns null if it doesn't exist
    public static function getBitmap(path:String):Null<BitmapData> {

		#if NATIVE_LOOKUP
		var sys_path = getPathLike(path);
		if (sys_path != null)
			return BitmapData.fromFile(sys_path); 
		#end

		#if OPENFL_LOOKUP
		if ( OpenFlAssets.exists(path, IMAGE))
			return OpenFlAssets.getBitmapData(path);
		#end
		return null;
    }

	public static function getSound(path:String):Null<Sound> {
		#if NATIVE_LOOKUP
		var sys_path = getPathLike(path);
		if (sys_path != null)
			return Sound.fromFile(sys_path);
		
		#end
		#if OPENFL_LOOKUP
		if(OpenFlAssets.exists(path, SOUND))
			return OpenFlAssets.getSound(path);
			
		#end
		return null;
    }
    //Check if the file exists
	public static function exists(path:String)
	{
		#if NATIVE_LOOKUP
        if (getPathLike(path) != null)
            return true;
		#end

		#if OPENFL_LOOKUP
		var isFile = OpenFlAssets.exists(path, TEXT);
		if (!isFile)
		{
			var isDir = Assets.list().filter(folder -> folder.startsWith(path)).length > 0;
			return isDir;
		}
		return isFile;
		#else
		return false;
		#end
	}

	#if NATIVE_LOOKUP
	private static function readDirectory_sys(directory:String):Null<Array<String>>
	{
        var testdir = getPathLike(directory);
		if (testdir == null)
			return null;

		return FileSystem.readDirectory(testdir);
	}
	#end

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

	public static function readDirectory(directory:String):Array<String>
	{
		#if NATIVE_LOOKUP
		var result = readDirectory_sys(directory);
		if (result != null)
			return result;
		#end

		#if OPENFL_LOOKUP
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
		return dirs;
		#else
		return null;
		#end
	}

    // Checks if the given path is a valid directory
	public static function isDirectory(directory:String)
	{
		var result = false;
		#if OPENFL_LOOKUP
		if (!result)
			result = Assets.list().filter(folder -> folder.startsWith(directory) && folder != directory).length > 0;
		#end
		#if NATIVE_LOOKUP
		if (!result)
			result = sys.FileSystem.isDirectory(addCwd(directory));
		#end
		return result;
	}

	// Not avaliable without sys
	public static function createDirectory(modFolder:String)
	{
		#if NATIVE_LOOKUP
		sys.FileSystem.createDirectory(addCwd(modFolder));
		#else
		trace("We have no FileSystem under us! We can't make new dirs!");
		#end
	}

	// Not avaliable without sys
	public static function deleteFile(s:String)
	{
		#if NATIVE_LOOKUP
		sys.FileSystem.deleteFile(addCwd(s));
		#else
		trace("We have no FileSystem under us! We can't delete this!");
		#end
	}

	#if linux
		/**
	 * Returns a path to the existing file similar to the given one.
	 * (For instance "mod/firelight" and  "Mod/FireLight" are *similar* paths)
	 * @param path
	 * @return Null<String>
	 */
	public static function getPathLike(path:String):Null<String> {

		if(sys.FileSystem.exists(path)) return path;

		var baseParts:Array<String> = path.replace('\\', '/').split('/');
		var keyParts = [];
		if (baseParts.length == 0) return null;

		while(!sys.FileSystem.exists(baseParts.join("/")) && baseParts.length != 0)
			keyParts.insert(0, baseParts.pop());


		return findFile(baseParts.join("/"),keyParts);
	}

	private static function findFile(base_path:String,keys:Array<String>):Null<String> {
		var nextDir:String = base_path;
		for (part in keys) {
			if (part == '') continue;

			var foundNode = findNode(nextDir, part);

			if (foundNode == null) {
				return null;
			}
			nextDir = nextDir+"/"+foundNode;
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
	private static function findNode(dir:String, key:String):Null<String> {
		try {
			var allFiles:Array<String> = sys.FileSystem.readDirectory(dir);
			var fileMap:Map<String, String> = new Map();

			for (file in allFiles) {
				fileMap.set(file.toLowerCase(), file);
			}

			return fileMap.get(key.toLowerCase());
		} catch (e:Dynamic) {
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
	 public static function getPathLike(path:String):Null<String> {
		var cwd_path = addCwd(path);
		if(sys.FileSystem.exists(cwd_path)) return cwd_path;
		return null;
	}
	#end
}
