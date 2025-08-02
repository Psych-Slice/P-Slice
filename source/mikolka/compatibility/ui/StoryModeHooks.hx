package mikolka.compatibility.ui;

import backend.StageData;
import backend.Song;
using mikolka.funkin.custom.FunkinTools;

class StoryModeHooks {
	public static var DEFAULT_DIFFICULTIES(get,null):Array<String>;
    public static function get_DEFAULT_DIFFICULTIES() {
        return Difficulty.defaultList.copy();
    }
    public static var DEFAULT_DIFF(get,null):String;
    public static function get_DEFAULT_DIFF() {
        return Difficulty.getDefault();
    }
    public static var DIFFICULTIES(get,null):Array<String>;
    public static function get_DIFFICULTIES() {
        return Difficulty.list;
    }
    public static inline function resetDiffList() {
        Difficulty.resetList();
    }
    public static inline function getDifficultyString(curDifficulty:Int):String {
        return Difficulty.getString(curDifficulty, false);
    }
    public static function loadDifficultiesFromWeek() {
        Difficulty.loadFromWeek();
    }
    public static function moveWeekToPlayState(){
        var directory = StageData.forceNextDirectory;
			LoadingState.loadNextDirectory();
			StageData.forceNextDirectory = directory;

			@:privateAccess
			if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
			{
				trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
				Paths.freeGraphicsFromMemory();
			}
			LoadingState.prepareToSong();
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
                var diffic = Difficulty.getFilePath(host.curDifficulty);
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
	
	
				Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
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