package mikolka.vslice.ui.obj;

import mikolka.compatibility.ModsHelper;
import mikolka.vslice.charSelect.CharSelectSubState;

class ModSelector extends FlxTypedSpriteGroup<FlxSprite> {

    public var curMod(get,never):String;
    function get_curMod() {
        return directories[curDirectory] ?? '';
    }
    public var hasModsAvailable(get,never):Bool;
    function get_hasModsAvailable() {
        return directories.length > 1;
    }
    private var directoryTxt:FlxText;
    private var curDirectory = 0;
    private var directories:Array<String> = [null];
    private var parent:CharSelectSubState;
    public var allowInput:Bool = false;

    public function new(parent:CharSelectSubState) {
        super();
        this.parent = parent;
        var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 42).makeGraphic(FlxG.width, 70, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		directoryTxt = new FlxText(textBG.x, textBG.y + 4, FlxG.width, '', 32);
		directoryTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		directoryTxt.scrollFactor.set();
		add(directoryTxt);

        if(parent == null){
            #if !LEGACY_PSYCH
            for (folder in Mods.parseList().enabled)
            #else
            for (folder in ModsHelper.getEnabledMods())
            #end
                directories.push(folder);
        }
        else{ // char select
            var globalMods = ModsHelper.getGlobalMods();
            for (folder in ModsHelper.getModsWithPlayersRegistry().filter(s -> !globalMods.contains(s)))
                directories.push(folder);
        }
		

		var found:Int = directories.indexOf(ModsHelper.getActiveMod());
		if (found > -1){

			curDirectory = found;
        }
		changeDirectory(0,true);
    }
    
    public function changeDirectory(change:Int = 0,ignoreInputBlock:Bool = false)
        {
            //FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
            if(!allowInput && !ignoreInputBlock) return;
            curDirectory += change;
    
            if (curDirectory < 0)
                curDirectory = directories.length - 1;
            if (curDirectory >= directories.length)
                curDirectory = 0;
    
            if (directories[curDirectory] == null || directories[curDirectory].length < 1){
                if(parent != null) visible = false;
                ModsHelper.loadModDir("");
                var nxtArrow = directories.length==1 ? '  ' : '=>';
                var prvArrow = directories.length==1 ? '  ' : '<=';
                directoryTxt.text = '$prvArrow No Mod Directory Loaded $nxtArrow';
            }
            else
            {
                if(parent != null) visible = true;
                var curModDir = directories[curDirectory];
                ModsHelper.loadModDir(curModDir);
                directoryTxt.text = '<= Loaded Mod Directory: ' + curModDir + " =>";
            }
            directoryTxt.text = directoryTxt.text.toUpperCase();
            @:privateAccess{
                if(change != 0 && directories.length != 1 && parent != null) {
                    parent.remove(parent.grpIcons);
                    //parent.grpIcons.destroy();
                    parent.availableChars.clear();
                    
                    parent.loadAvailableCharacters();
                    parent.initLocks();
                }
            }
        }
}