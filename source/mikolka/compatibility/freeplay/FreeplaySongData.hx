package mikolka.compatibility.freeplay;

import mikolka.vslice.freeplay.obj.SngCapsuleData;
import mikolka.vslice.freeplay.pslice.BPMCache;
import mikolka.funkin.Scoring.ScoringRank;

using mikolka.funkin.custom.FunkinTools;
using mikolka.funkin.utils.ArrayTools;

/**
 * Data about a specific song in the freeplay menu.
 */
 class FreeplaySongData extends SngCapsuleData{

 
    public function toggleFavorite():Bool {
        isFav = !isFav;
        if (isFav)
        {
            ClientPrefs.favSongIds.pushUnique(this.songId+this.levelName);
        }
        else
        {
            ClientPrefs.favSongIds.remove(this.songId+this.levelName);
        }
        ClientPrefs.saveSettings();
        return isFav;
    }

 
 function updateValues() {
    this.isFav = ClientPrefs.favSongIds.contains(songId + this.levelName); // Save.instance.isSongFavorited(songId);
    var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[levelId]);
 
    levelName = leWeek.weekName;
    this.songDifficulties = leWeek.difficulties.extractWeeks();
    this.folder = leWeek.folder;

    Paths.currentModDirectory = this.folder;
    var fileSngName = Paths.formatToSongPath(songId);
    var sngDataPath = Paths.getLibraryPath("data/"+fileSngName);

    #if MODS_ALLOWED
    var mod_path = Paths.modFolders("data/"+fileSngName);
    if(FileSystem.exists(mod_path)) sngDataPath = mod_path;
    #end
    
    //if(sngDataPath == null) return;
    
    if(this.songDifficulties.length == 0){
        if(FileSystem.exists(sngDataPath)){
            var chartFiles = FileSystem.readDirectory(sngDataPath)
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
    var fileSngName = Paths.formatToSongPath(getNativeSongId());
		if (allowErect && !hasErectSong())
		{
			trace('$songName is missing variant in $sngDataPath');
			this.songDifficulties.remove("erect");
			this.songDifficulties.remove("nightmare");

		}
    if (!this.songDifficulties.contains(currentDifficulty) && songDifficulties.length>0)
        currentDifficulty = songDifficulties[0]; // TODO
    
    songStartingBpm = BPMCache.instance.getBPM(sngDataPath,fileSngName);
    
    // this.songStartingBpm = songDifficulty.getStartingBPM();
    // this.songName = songDifficulty.songName;
    // this.difficultyRating = songDifficulty.difficultyRating;
    this.scoringRank = Scoring.calculateRankForSong(Highscore.formatSong(songId, loadAndGetDiffId()));

    var wasCompleted = false;
    var saveSongName = Paths.formatToSongPath(songId);
    for (x in Highscore.songScores.keys()){
       if(x.startsWith(saveSongName) && Highscore.songScores[x] > 0){
           wasCompleted = true;
           break;
       }
    }
    isNew = (( ClientPrefs.vsliceForceNewTag || isNew) && !wasCompleted); 
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
    isNew = (( ClientPrefs.vsliceForceNewTag || isNew) && !wasCompleted); 
 }
 
 public function loadAndGetDiffId() {
    var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[levelId]);
 
    CoolUtil.difficulties = leWeek.difficulties.extractWeeks();
    if(CoolUtil.difficulties.length == 0) CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();

    return CoolUtil.difficulties.findIndex(s -> s.trim().toLowerCase() == currentDifficulty);
 }
 
 public function hasErectSong():Bool {
    var fileSngName = Paths.formatToSongPath(songId+"-erect");
    var sngDataPath = Paths.getLibraryPath("data/"+fileSngName);
    return NativeFileSystem.exists(sngDataPath);
 }
 }
 