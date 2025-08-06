package mikolka.vslice.freeplay.obj;

import mikolka.funkin.Scoring.ScoringRank;

abstract class SngCapsuleData{
    	/**
	 * Whether or not the song has been favorited.
	 */
	public var isFav:Bool = false;

	public var allowErect:Bool = false;
	public var metaSngId:String = "";

	public var isNew:Bool = false;
	public var metaAllowNew:Bool = false;
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
	public var songWeekName(default, null):String = '';

	public var freeplayPrevStart(default, null):Float = 0;
	public var freeplayPrevEnd(default, null):Float = 0;
	public var currentDifficulty(default, set):String = "normal";
	public var instVariants:Array<String>;

	public var scoringRank:Null<ScoringRank> = null;

	function set_currentDifficulty(value:String):String
	{
		currentDifficulty = value;
		updateValues();
		updateMeta();
		return value;
	}

	public function new(levelId:Int, songId:String, songCharacter:String, color:FlxColor)
	{
		this.levelId = levelId;
		this.songName = songId.replace("-", " ");
		this.songCharacter = songCharacter;
		this.color = color;
		this.songId = songId;
		updateMeta();
		updateValues();

		
	}

	/**
	 * Toggle whether or not the song is favorited, then flush to save data.
	 * @return Whether or not the song is now favorited.
	 */
	public abstract function toggleFavorite():Bool;

	function updateMeta()
	{
		var potentiallyErect:String = (allowErect && (currentDifficulty == "erect") || (currentDifficulty == "nightmare")) ? "-erect" : "";
		var newSngId = songId + potentiallyErect;
		if (metaSngId == newSngId)
			return;
		metaSngId = newSngId;
		var meta = FreeplayMeta.getMeta(metaSngId);
		difficultyRating = meta.songRating;

		metaAllowNew = meta.allowNewTag;
		allowErect = meta.allowErectVariants;
		freeplayPrevStart = meta.freeplayPrevStart / meta.freeplaySongLength;
		freeplayPrevEnd = meta.freeplayPrevEnd / meta.freeplaySongLength;
		albumId = meta.albumId;
		instVariants = meta.altInstrumentalSongs.split(",");
		songPlayer = meta.freeplayCharacter;
		songWeekName = meta.freeplayWeekName;
	}

	abstract function updateValues():Void;

	public abstract function updateIsNewTag():Void;

	public abstract function loadAndGetDiffId():Int;

	// Gets real song id (potenctally to erect variant)
	public function getNativeSongId():String
	{
		if (!allowErect)
			return songId;
		var potentiallyErect:String = (currentDifficulty == "erect") || (currentDifficulty == "nightmare") ? "-erect" : "";
		return songId + potentiallyErect;
	}
    public abstract function hasErectSong():Bool;
} 