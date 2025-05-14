package mikolka.compatibility.freeplay;

import mikolka.vslice.freeplay.obj.SngCapsuleData;
import mikolka.vslice.freeplay.pslice.BPMCache;
import mikolka.funkin.Scoring.ScoringRank;
import backend.Highscore;
import backend.WeekData;

using mikolka.funkin.custom.FunkinTools;
using mikolka.funkin.utils.ArrayTools;

/**
 * Data about a specific song in the freeplay menu. Very heaviely dependent on exact engine
 */
class FreeplaySongData extends SngCapsuleData
{

	public function new(levelId:Int, songId:String, songCharacter:String, color:FlxColor)
	{
		super(levelId,songId,songCharacter,color);
		this.isFav = ClientPrefs.data.favSongIds.contains(songId + this.levelName); // Save.instance.isSongFavorited(songId);
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
			ClientPrefs.data.favSongIds.pushUnique(this.songId + this.levelName);
		}
		else
		{
			ClientPrefs.data.favSongIds.remove(this.songId + this.levelName);
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
		var fileSngName = Paths.formatToSongPath(getNativeSongId());
		var sngDataPath = Paths.getPath("data/" + fileSngName);

		#if MODS_ALLOWED
		var mod_path = Paths.modFolders("data/" + fileSngName);
		if (NativeFileSystem.exists(mod_path))
			sngDataPath = mod_path;
		#end

		// if(sngDataPath == null) return;

		if (this.songDifficulties.length == 0)
		{
			if (NativeFileSystem.exists(sngDataPath))
			{
				var chartFiles = NativeFileSystem.readDirectory(sngDataPath).filter(s -> s.toLowerCase().startsWith(fileSngName)
					&& s.endsWith(".json"));

				var diffNames = chartFiles.map(s -> s.substring(fileSngName.length + 1, s.length - 5));
				// Regrouping difficulties
				if (diffNames.remove("."))
					diffNames.insert(1, "normal");
				if (diffNames.remove("easy"))
					diffNames.insert(0, "easy");
				if (diffNames.remove("hard"))
					diffNames.insert(2, "hard");
				this.songDifficulties = diffNames;
			}
			else
			{
				this.songDifficulties = ['normal'];
				trace('Directory $sngDataPath does not exist! $songName has no charts (difficulties)!');
				trace('Forcing "normal" difficulty. Expect issues!!');
			}
		}
        var fileSngName = Paths.formatToSongPath(getNativeSongId());
		var sngDataPath = Paths.getPath("data/" + fileSngName);
		if (allowErect && !hasErectSong())
		{
			//? nvm. it clutters logs a lot for no reason
			//trace('$songName is missing variant in $sngDataPath');
			this.songDifficulties.remove("erect");
			this.songDifficulties.remove("nightmare");
		}
		if (!this.songDifficulties.contains(currentDifficulty))
		{
			@:bypassAccessor
			currentDifficulty = songDifficulties[0]; // TODO
		}

		songStartingBpm = BPMCache.instance.getBPM(sngDataPath, fileSngName);

		// this.songStartingBpm = songDifficulty.getStartingBPM();
		// this.songName = songDifficulty.songName;
		// this.difficultyRating = songDifficulty.difficultyRating;
		this.scoringRank = Scoring.calculateRankForSong(Highscore.formatSong(getNativeSongId(), loadAndGetDiffId()));
		updateIsNewTag();
	}

	public function updateIsNewTag()
	{
		var wasCompleted = false;
		var saveSongName = Paths.formatToSongPath(getNativeSongId());
		for (x in Highscore.songScores.keys())
		{
			if (x.startsWith(saveSongName) && Highscore.songScores[x] > 0)
			{
				wasCompleted = true;
				break;
			}
		}
		isNew = ((ClientPrefs.data.vsliceForceNewTag || isNew) && !wasCompleted);
	}

	public function loadAndGetDiffId()
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[levelId]);
		Difficulty.loadFromWeek(leWeek);
		return Difficulty.list.findIndex(s -> s.trim().toLowerCase() == currentDifficulty);
	}


    public function hasErectSong():Bool
        {
            var fileSngName = Paths.formatToSongPath(songId+"-erect");
		    var sngDataPath = Paths.getPath("data/" + fileSngName);
            return NativeFileSystem.exists(sngDataPath);
        }
}
