package mikolka.vslice.charSelect.pslice;

import mikolka.compatibility.ModsHelper;

class ModSelector extends FlxTypedSpriteGroup<FlxSprite> {

    public var curMod(get,never):String;
    function get_curMod() {
        return directories[curDirectory] ?? '';
    }
    private var directoryTxt:FlxText;
    private var curDirectory = 0;
    private var directories:Array<String> = [null];
    private var parent:CharSelectSubState;

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

		for (folder in ModsHelper.getModsWithPlayersRegistry())
		{
			directories.push(folder);
		}

		var found:Int = directories.indexOf(ModsHelper.getActiveMod());
		if (found > -1)
			curDirectory = found;
		changeDirectory();
    }
    
    public function changeDirectory(change:Int = 0)
        {
            //FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
    
            curDirectory += change;
    
            if (curDirectory < 0)
                curDirectory = directories.length - 1;
            if (curDirectory >= directories.length)
                curDirectory = 0;
    
            if (directories[curDirectory] == null || directories[curDirectory].length < 1){
                ModsHelper.loadModDir("");
                var nxtArrow = directories.length==1 ? '  ' : '=>';
                directoryTxt.text = '  No Mod Directory Loaded $nxtArrow';
            }
            else
            {
                var curModDir = directories[curDirectory];
                var nxtArrow = directories.length-1 == curDirectory ? '   ' : ' =>';
                ModsHelper.loadModDir(curModDir);
                directoryTxt.text = '<= Loaded Mod Directory: ' + curModDir + nxtArrow;
            }
            directoryTxt.text = directoryTxt.text.toUpperCase();
            @:privateAccess{
                if(change != 0 && directories.length != 1) {
                    parent.remove(parent.grpIcons);
                    //parent.grpIcons.destroy();
                    parent.availableChars.clear();
                    
                    parent.loadAvailableCharacters();
                    parent.initLocks();
                }
            }
        }
}