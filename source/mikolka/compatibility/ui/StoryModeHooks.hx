package mikolka.compatibility.ui;

using mikolka.funkin.custom.FunkinTools;

class StoryModeHooks {
    public static var DEFAULT_DIFFICULTIES(get,null):Array<String>;
    public static function get_DEFAULT_DIFFICULTIES() {
        return CoolUtil.defaultDifficulties.copy();
    }
    public static var DEFAULT_DIFF(get,null):String;
    public static function get_DEFAULT_DIFF() {
        return CoolUtil.defaultDifficulty;
    }
    public static var DIFFICULTIES(get,null):Array<String>;
    public static function get_DIFFICULTIES() {
        return CoolUtil.difficulties;
    }
    public static inline function resetDiffList() {
        CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
    }
    public static inline function getDifficultyString(curDifficulty:Int):String {
        return CoolUtil.difficulties[curDifficulty];
    }
    public static function loadDifficultiesFromWeek() {
        var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
			else resetDiffList();
		}
		else resetDiffList();
    }
    public static function moveWeekToPlayState(){
        var directory = StageData.forceNextDirectory;
			StageData.forceNextDirectory = directory;


			trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
			//Paths.clearUnusedMemory();

			//LoadingState.prepareToSong();
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
			
			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
    } 
    // returns "true" is succsessful
    public static function prepareWeek(host:StoryMenuState):Bool{
        // We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = host.loadedWeeks[StoryMenuState.curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			try
			{
                var diffic = CoolUtil.getDifficultyFilePath(host.curDifficulty);
                if(diffic == null) diffic = '';
    
                PlayState.storyDifficulty = host.curDifficulty;
                
                //? We load erect songs (because yes)
                if(diffic == "-erect" || diffic == "-nightmare") PlayState.storyPlaylist = songArray.convertToErectVariants();
				else PlayState.storyPlaylist = songArray;

				PlayState.isStoryMode = true;
                @:privateAccess(){
                    PlayState.storyDifficultyColor = host.sprDifficulty.color;
                    PlayState.storyCampaignTitle = host.txtWeekTitle.text;
                    if(PlayState.storyCampaignTitle == "") PlayState.storyCampaignTitle = "Unnamed week";
                    host.selectedWeek = true;
                }
	
				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
                return true;
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');
				return false;
			}
    } 
}