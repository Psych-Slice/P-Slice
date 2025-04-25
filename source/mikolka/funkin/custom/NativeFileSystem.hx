package mikolka.funkin.custom;

#if OPENFL_LOOKUP
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
#end
/**
    Basically FIleSystem, but we can emulate it on OpenFL
**/
class NativeFileSystem {
    public static function getContent(path:String) {
        #if OPENFL_LOOKUP
        var openfl_content = (OpenFlAssets.exists(path, TEXT)) ? Assets.getText(path) : null;
		if (openfl_content != null) return openfl_content;
		#end
        #if sys
		var sys_res = (FileSystem.exists(path)) ? File.getContent(path) : null;
        if(sys_res != null) return sys_res;
		#end
        return null; 
    }
    public static function exists(path:String) {
        #if sys
        var cwd = StorageUtil.getStorageDirectory();
		if(FileSystem.exists(cwd+path)) return true;
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
        var cwd = StorageUtil.getStorageDirectory();
        if(!FileSystem.exists(cwd+"/"+directory)) return null;
        return FileSystem.readDirectory(cwd+"/"+directory);
    }
    #end
    public static function readDirectory(directory:String):Array<String>
        {
            #if MODS_ALLOWED
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
}