package mikolka.compatibility;

import mikolka.vslice.freeplay.pslice.BPMCache;
import mikolka.funkin.Scoring.ScoringRank;
import backend.Highscore;
import backend.WeekData;

using mikolka.funkin.custom.FunkinTools;
using mikolka.funkin.utils.ArrayTools;

/**
 * Data about a specific song in the freeplay menu. Very heaviely dependent on exact engine
 */
 class FreeplaySongData
 {
     /**
      * Whether or not the song has been favorited.
      */
     public var isFav:Bool = false;
 
     public var isNew:Bool = false;
     public var folder:String = "";
     public var color:Int = -7179779;
 
     public var levelId(default, null):Int = 0;
     public var levelName(default, null):String = "";
     public var songId(default, null):String = '';
 
     public var songDifficulties(default, null):Array<String> = [];
 
     public var songName(default, null):String = '';
     public var songCharacter(default, null):String = '';
     public var songStartingBpm(default, null):Float = 0;
     public var difficultyRating(default, null):Int = 0;
     public var albumId(default, null):Null<String> = null;
     public var songPlayer(default, null):String = '';
 
     public var freeplayPrevStart(default, null):Float = 0;
     public var freeplayPrevEnd(default, null):Float = 0;
     public var currentDifficulty(default, set):String = "normal";
     public var instVariants:Array<String>;
 
     public var scoringRank:Null<ScoringRank> = null;
 
     function set_currentDifficulty(value:String):String
     {
         currentDifficulty = value;
         updateValues();
         return value;
     }
 
     public function new(levelId:Int, songId:String, songCharacter:String, color:FlxColor)
     {
         this.levelId = levelId;
         this.songName = songId.replace("-", " ");
         this.songCharacter = songCharacter;
         this.color = color;
         this.songId = songId;
 
         var meta = FreeplayMeta.getMeta(songId);
         difficultyRating = meta.songRating;
            

         isNew = meta.allowNewTag;
         freeplayPrevStart = meta.freeplayPrevStart/meta.freeplaySongLength;
         freeplayPrevEnd = meta.freeplayPrevEnd/meta.freeplaySongLength;
         albumId = meta.albumId;
         instVariants = meta.altInstrumentalSongs.split(",");
         songPlayer = meta.freeplayCharacter;
 
         updateValues();
 
         this.isFav = ClientPrefs.data.favSongIds.contains(songId+this.levelName);//Save.instance.isSongFavorited(songId);
     }
 
     /**
      * Toggle whether or not the song is favorited, then flush to save data.
      * @return Whether or not the song is now favorited.
      */
     public function toggleFavorite():Bool
     {
         isFav = !isFav;
         if (isFav)
         {
             ClientPrefs.data.favSongIds.pushUnique(this.songId+this.levelName);
         }
         else
         {
             ClientPrefs.data.favSongIds.remove(this.songId+this.levelName);
         }
         ClientPrefs.saveSettings();
         return isFav;
     }
 
     function updateValues():Void
     {
         var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[levelId]);
 
         levelName = leWeek.weekName;
         this.songDifficulties = leWeek.difficulties.extractWeeks();
         this.folder = leWeek.folder;
 
         Mods.currentModDirectory = this.folder;
         var fileSngName = Paths.formatToSongPath(songId);
         var sngDataPath = Paths.getSharedPath("data/"+fileSngName);
 
         #if MODS_ALLOWED
         var mod_path = Paths.modFolders("data/"+fileSngName);
         if(FileSystem.exists(mod_path)) sngDataPath = mod_path;
         #end
         
         //if(sngDataPath == null) return;
         
         if(this.songDifficulties.length == 0){
             if(NativeFileSystem.exists(sngDataPath)){
                 var chartFiles = NativeFileSystem.readDirectory(sngDataPath)
                 .filter(s -> s.toLowerCase().startsWith(fileSngName) && s.endsWith(".json"));
 
                 var diffNames = chartFiles.map(s -> s.substring(fileSngName.length+1,s.length-5));
                 // Regrouping difficulties
                 if(diffNames.remove(".")) diffNames.insert(1,"normal");
                 if(diffNames.remove("easy")) diffNames.insert(0,"easy");
                 if(diffNames.remove("hard")) diffNames.insert(2,"hard");
                 this.songDifficulties = diffNames;
             }
             else{
                 this.songDifficulties = ['normal'];
                 trace('Directory $sngDataPath does not exist! $songName has no charts (difficulties)!');
                 trace('Forcing "normal" difficulty. Expect issues!!');
             }
             
         }
         if (!this.songDifficulties.contains(currentDifficulty)){
             @:bypassAccessor
             currentDifficulty = songDifficulties[0]; // TODO
         }
         
         songStartingBpm = BPMCache.instance.getBPM(sngDataPath,fileSngName);
         
         // this.songStartingBpm = songDifficulty.getStartingBPM();
         // this.songName = songDifficulty.songName;
         // this.difficultyRating = songDifficulty.difficultyRating;
         this.scoringRank = Scoring.calculateRankForSong(Highscore.formatSong(songId, loadAndGetDiffId()));
         updateIsNewTag();
         
     }
     public function updateIsNewTag() {
        var wasCompleted = false;
         var saveSongName = Paths.formatToSongPath(songId);
         for (x in Highscore.songScores.keys()){
            if(x.startsWith(saveSongName) && Highscore.songScores[x] > 0){
                wasCompleted = true;
                break;
            }
         }
         isNew = (( ClientPrefs.data.vsliceForceNewTag || isNew) && !wasCompleted); 
     }
     public function loadAndGetDiffId() {
         var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[levelId]);
         Difficulty.loadFromWeek(leWeek);
         return Difficulty.list.findIndex(s -> s.trim().toLowerCase() == currentDifficulty);
     }
 }