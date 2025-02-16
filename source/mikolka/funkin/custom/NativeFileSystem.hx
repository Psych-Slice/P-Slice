package mikolka.funkin.custom;

import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

class NativeFileSystem {
    public static inline function getContent(path:String) {
        #if sys
		return (FileSystem.exists(path)) ? File.getContent(path) : null;
		#else
		return (OpenFlAssets.exists(path, TEXT)) ? Assets.getText(path) : null;
		#end
    }
    public static inline function exists(path:String) {
        #if sys
		return FileSystem.exists(path);
		#else
		return OpenFlAssets.exists(path, TEXT);
		#end
    }
    public static function readDirectory(directory:String):Array<String>
        {
            #if MODS_ALLOWED
            return FileSystem.readDirectory(directory);
            #else
            var dirs:Array<String> = [];
            for(dir in Assets.list().filter(folder -> folder.startsWith(directory)))
            {
                @:privateAccess
                for(library in lime.utils.Assets.libraries.keys())
                {
                    if(library != 'default' && Assets.exists('$library:$dir') && (!dirs.contains('$library:$dir') || !dirs.contains(dir)))
                        dirs.push('$library:$dir');
                    else if(Assets.exists(dir) && !dirs.contains(dir))
                        dirs.push(dir);
                }
            }
            return dirs;
            #end
        }
}