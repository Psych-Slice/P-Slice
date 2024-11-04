package;

import haxe.Json;

typedef ModsList = {
	enabled:Array<String>,
	disabled:Array<String>,
	all:Array<String>
};
class Mods{

    public static var updatedOnState:Bool = false;
	inline public static function parseList():ModsList {
		if(!updatedOnState) updateModList();
		var list:ModsList = {enabled: [], disabled: [], all: []};

		#if MODS_ALLOWED
		try {
			for (mod in CoolUtil.coolTextFile('modsList.txt'))
			{
				//trace('Mod: $mod');
				if(mod.trim().length < 1) continue;

				var dat = mod.split("|");
				list.all.push(dat[0]);
				if (dat[1] == "1")
					list.enabled.push(dat[0]);
				else
					list.disabled.push(dat[0]);
			}
		} catch(e) {
			trace(e);
		}
		#end
		return list;
	}
    public static function updateModList()
        {
            #if MODS_ALLOWED
            // Find all that are already ordered
            var list:Array<Array<Dynamic>> = [];
            var added:Array<String> = [];
            try {
                for (mod in CoolUtil.coolTextFile('modsList.txt'))
                {
                    var dat:Array<String> = mod.split("|");
                    var folder:String = dat[0];
                    if(folder.trim().length > 0 && FileSystem.exists(Paths.mods(folder)) && FileSystem.isDirectory(Paths.mods(folder)) && !added.contains(folder))
                    {
                        added.push(folder);
                        list.push([folder, (dat[1] == "1")]);
                    }
                }
            } catch(e) {
                trace(e);
            }
            
            // Scan for folders that aren't on modsList.txt yet
            for (folder in Paths.getModDirectories())
            {
                if(!added.contains(folder))
                {
                    added.push(folder);
                    list.push([folder, true]); //i like it false by default. -bb //Well, i like it True! -Shadow Mario (2022)
                    //Shadow Mario (2023): What the fuck was bb thinking
                }
            }
    
            // Now save file
            var fileStr:String = '';
            for (values in list)
            {
                if(fileStr.length > 0) fileStr += '\n';
                fileStr += values[0] + '|' + (values[1] ? '1' : '0');
            }
    
            File.saveContent('modsList.txt', fileStr);
            updatedOnState = true;
            //trace('Saved modsList.txt');
            #end
        }

    public static function getPack(?folder:String = null):Dynamic
        {
            #if MODS_ALLOWED
            if(folder == null) folder = Paths.currentModDirectory;
    
            var path = Paths.mods(folder + '/pack.json');
            if(FileSystem.exists(path)) {
                try {
                    #if sys
                    var rawJson:String = File.getContent(path);
                    #else
                    var rawJson:String = Assets.getText(path);
                    #end
                    if(rawJson != null && rawJson.length > 0) return cast Json.parse(rawJson);
                } catch(e:Dynamic) {
                    trace(e);
                }
            }
            #end
            return null;
        }
    
    public static function loadTopMod() {
        WeekData.loadTheFirstEnabledMod();
    }
}