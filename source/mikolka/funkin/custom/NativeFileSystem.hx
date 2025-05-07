package mikolka.funkin.custom;

#if (!NATIVE_LOOKUP && !OPENFL_LOOKUP )
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
class NativeFileSystem {
    public static function getContent(path:String) {
        #if OPENFL_LOOKUP
        var openfl_content = (OpenFlAssets.exists(path, TEXT)) ? Assets.getText(path) : null;
		if (openfl_content != null) return openfl_content;
		#end

        #if NATIVE_LOOKUP
		var sys_res = (FileSystem.exists(path)) ? File.getContent(path) : null;
        if(sys_res != null) return sys_res;
		#end
        return null; 
    }
    public static function exists(path:String) {
        #if NATIVE_LOOKUP
		if(FileSystem.exists(addCwd(path))) return true;
		#end

        #if OPENFL_LOOKUP
		var isFile = OpenFlAssets.exists(path, TEXT);
        if(!isFile){
            var isDir = Assets.list().filter(folder -> folder.startsWith(path)).length>0;
            return isDir;
        }
        return isFile;
        #else 
        return false;
        #end
    }
    #if MODS_ALLOWED
    private static function readDirectory_sys(directory:String):Null<Array<String>>{
        
        if(!FileSystem.exists(addCwd(directory))) return null;
        return FileSystem.readDirectory(addCwd(directory));
    }
    #end
    /**
        Adds the current root dir to the path.

        Depends a lot on the target system!
    **/
    public inline static function addCwd(directory:String):String{
        var cwd = StorageUtil.getStorageDirectory();
        var test_cwd = haxe.io.Path.removeTrailingSlashes(cwd);
        if(directory.startsWith(test_cwd)) return directory;
        return haxe.io.Path.addTrailingSlash(cwd)+directory;
    }
    public static function readDirectory(directory:String):Array<String>
        {
            #if NATIVE_LOOKUP
            var result = readDirectory_sys(directory);
            if(result != null ) return result;
            #end

            #if OPENFL_LOOKUP
            var dirs:Array<String> = [];
            if(!directory.endsWith("/")) directory += '/';
            for(dir in Assets.list().filter(folder -> folder.startsWith(directory)))
            {
                @:privateAccess
                for(library in lime.utils.Assets.libraries.keys())
                {
                    if(library != 'default' && Assets.exists('$library:$dir') && (!dirs.contains('$library:$dir') || !dirs.contains(dir)))
                        dirs.push('$library:$dir');
                    else if(Assets.exists(dir) && !dirs.contains(dir)){
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

    public static function isDirectory(directory:String) {
        var result = false;
        #if OPENFL_LOOKUP
        if (!result) result = Assets.list().filter(folder -> 
            folder.startsWith(directory) && folder != directory).length > 0;
        #end
        #if NATIVE_LOOKUP
        if (!result) result = sys.FileSystem.isDirectory(addCwd(directory));
        #end
        return result;
    }

    // Not avaliable without sys
    public static function createDirectory(modFolder:String) {
        #if NATIVE_LOOKUP
        sys.FileSystem.createDirectory(addCwd(modFolder));
        #else
        trace("We have no FileSystem under us! We can't make new dirs!");
        #end
    }
    // Not avaliable without sys
    public static function deleteFile(s:String) {
        #if NATIVE_LOOKUP
        sys.FileSystem.deleteFile(addCwd(s));
        #else
        trace("We have no FileSystem under us! We can't delete this!");
        #end
    }
}