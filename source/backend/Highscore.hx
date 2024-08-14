package backend;

class Highscore
{
	public static var weekScores:Map<String, Int> = new Map();
	public static var weekRating:Map<String, Float> = new Map<String, Float>();
	public static var weekFCState:Map<String, Bool> = new Map<String, Bool>();

	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songFCState:Map<String, Bool> = new Map<String, Bool>();
	public static var songRating:Map<String, Float> = new Map<String, Float>();

	public static function resetSong(song:String, diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		setScore(daSong, 0);
		setRating(daSong, 0);
	}

	public static function resetWeek(week:String, diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);
		setWeekScore(daWeek, 0);
		setWeekRating(daWeek, 0);
		setWeekFC(daWeek, false);
	}

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0, ?rating:Float = -1,?FC:Bool = false):Void
	{
		var daSong:String = formatSong(song, diff);

		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
			{
				setScore(daSong, score);
				setFC(daSong,FC);
				if (rating >= 0)
					setRating(daSong, rating);
			}
		}
		else
		{
			setScore(daSong, score);
			setFC(daSong,FC);
			if (rating >= 0)
				setRating(daSong, rating);
		}
	}

	public static function saveWeekScore(week:String, score:Int = 0, ?diff:Int = 0, ?rating:Float = -1,?FC:Bool = false):Void
	{
		var daWeek:String = formatSong(week, diff);

		if (weekScores.exists(daWeek))
		{
			if (weekScores.get(daWeek) < score){
				setWeekScore(daWeek, score);
				setWeekRating(daWeek,rating);
				setWeekFC(daWeek,FC);
			}
		}
		else{
			setWeekScore(daWeek, score);
			setWeekRating(daWeek,rating);
			setWeekFC(daWeek,FC);
		}
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	static function setWeekScore(week:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		weekScores.set(week, score);
		FlxG.save.data.weekScores = weekScores;
		FlxG.save.flush();
	}

	static function setWeekRating(week:String, rating:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		weekRating.set(week, rating);
		FlxG.save.data.weekRating = weekRating;
		FlxG.save.flush();
	}

	static function setWeekFC(week:String, isFC:Bool):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		weekFCState.set(week, isFC);
		FlxG.save.data.weekFCState = weekFCState;
		FlxG.save.flush();
	}

	static function setRating(song:String, rating:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songRating.set(song, rating);
		FlxG.save.data.songRating = songRating;
		FlxG.save.flush();
	}

	static function setFC(song:String, isFC:Bool):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songFCState.set(song, isFC);
		FlxG.save.data.songFCState = songFCState;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		return Paths.formatToSongPath(song) + Difficulty.getFilePath(diff);
	}

	public static function getScore(song:String, diff:Int):Int
	{
		var daSong:String = formatSong(song, diff);
		if (!songScores.exists(daSong))
			setScore(daSong, 0);

		return songScores.get(daSong);
	}

	public static function getFCState(song:String, diff:Int):Bool
	{
		var daSong:String = formatSong(song, diff);
		if (!songFCState.exists(daSong))
			setFC(daSong, false);

		return songFCState.get(daSong);
	}

	public static function getRating(song:String, diff:Int):Float
	{
		var daSong:String = formatSong(song, diff);
		if (!songRating.exists(daSong))
			setRating(daSong, 0);

		return songRating.get(daSong);
	}

	public static function getWeekScore(week:String, diff:Int):Int
	{
		var daWeek:String = formatSong(week, diff);
		if (!weekScores.exists(daWeek))
			setWeekScore(daWeek, 0);

		return weekScores.get(daWeek);
	}

	public static function getWeekAccuracy(week:String, diff:Int):Float
	{
		var daWeek:String = formatSong(week, diff);
		if (!weekRating.exists(daWeek))
			setWeekRating(daWeek, 0);

		return weekRating.get(daWeek);
	}

	public static function getWeekFC(week:String, diff:Int):Bool
	{
		var daWeek:String = formatSong(week, diff);
		if (!weekScores.exists(daWeek))
			setWeekFC(daWeek, false);

		return weekFCState.get(daWeek);
	}

	public static function load():Void
	{
		if (FlxG.save.data.weekScores != null)
		{
			weekScores = FlxG.save.data.weekScores;
		}
		if (FlxG.save.data.weekRating != null)
		{
			weekRating = FlxG.save.data.weekRating;
		}
		if (FlxG.save.data.weekFCState != null)
		{
			weekFCState = FlxG.save.data.weekFCState;
		}
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
		if (FlxG.save.data.songRating != null)
		{
			songRating = FlxG.save.data.songRating;
		}
		if (FlxG.save.data.songFCState != null)
		{
			songFCState = FlxG.save.data.songFCState;
		}
	}
}
