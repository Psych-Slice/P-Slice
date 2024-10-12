package mikolka.compatibility;

import mikolka.vslice.freeplay.pslice.FreeplayColorTweener;
import mikolka.vslice.freeplay.pslice.BPMCache;
import mikolka.vslice.freeplay.FreeplayState;

class FreeplayHelpers
{
	public static var BPM(get,set):Float;
	public static function set_BPM(value:Float) {
		Conductor.changeBPM(value);
		return value;
	}
	public static function get_BPM() {
		return Conductor.bpm;
	}

	public static function loadSongs()
	{
		var songs = [];
		WeekData.reloadWeekFiles(false);
		// programmatically adds the songs via LevelRegistry and SongRegistry
		for (i in 0...WeekData.weeksList.length)
		{
			if (weekIsLocked(WeekData.weeksList[i]))
				continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]); // TODO tweak this

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				// trace("pushing "+song);
				var colors:Array<Int> = song[2];
				if (colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				var sngCard = new FreeplaySongData(i, song[0], song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
				// songName, weekNum, songCharacter, color
				if (sngCard.songDifficulties.length == 0)
					continue;

				songs.push(sngCard);
			}
		}
		return songs;
	}

	public static function moveToPlaystate(state:FreeplayState, cap:FreeplaySongData, currentDifficulty:String)
	{
		// FunkinSound.emptyPartialQueue();

		// Paths.setCurrentLevel(cap.songData.levelId);
		state.persistentUpdate = false;
		ModsHelper.loadModDir(cap.folder);

		var diffId = cap.loadAndGetDiffId();
		if (diffId == -1)
		{
			trace("SELECTED DIFFICULTY IS MISSING: " + currentDifficulty);
			diffId = 0;
		}

		var songLowercase:String = Paths.formatToSongPath(cap.songId);
		var poop:String = Highscore.formatSong(songLowercase, diffId); // TODO //currentDifficulty);
		/*#if MODS_ALLOWED
			if(!FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
		}*/
		trace(poop);

		try
		{
			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = diffId;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
		}
		catch (e:Dynamic)
		{
			trace('ERROR! $e');
			@:privateAccess {
				state.busy = false;
				state.letterSort.inputEnabled = true;
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}
		LoadingState.loadAndSwitchState(new PlayState());

		FlxG.sound.music.volume = 0;

		#if (MODS_ALLOWED && DISCORD_ALLOWED)
		DiscordClient.loadModRPC();
		#end
	}

	static function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	public static function exitFreeplay()
	{
		BPMCache.instance.clearCache();
		WeekData.loadTheFirstEnabledMod();
		FlxG.signals.postStateSwitch.dispatch(); // ? for the screenshot plugin to clean itself

	}

	public static function loadDiffsFromWeek(songData:FreeplaySongData)
	{
		Paths.currentModDirectory = songData.folder;
		PlayState.storyWeek = songData.levelId; // TODO
		CoolUtil.difficulties = songData.songDifficulties;
	}
	public static function getDifficultyName(){
		//Difficulty.list[PlayState.storyDifficulty].toUpperCase()
		return CoolUtil.difficultyString();
	}
	public static function updateConductorSongTime(time:Float) {
		Conductor.songPosition = time;
	}
}
