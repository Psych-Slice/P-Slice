package mikolka.funkin.sound;

/**
 * Assists in caching metadata for partial sounds.
 * This is useful for when you want to play a sound with a specific kbps or intro offset, we can use this to get the data.
 * If you want to get info from this cache, we save it as `path + startRange` from `FlxPartialSound`
 */
class PartialSoundMetadata
{
	public static var instance(get, never):PartialSoundMetadata;
	static var _instance:Null<PartialSoundMetadata> = null;

	public var cache:Map<String, SoundMetadata>;

	function new()
	{
		this.cache = new Map<String, SoundMetadata>();
	}

	/**
	 * Return metadata from the cache
	 * @param sound
	 * @return SoundMetadata
	 */
	public function get(sound:String):SoundMetadata
	{
		return this.cache.get(sound);
	}

	public function set(sound:String, metadata:SoundMetadata):Void
	{
		this.cache.set(sound, metadata);
	}

	public function getKbps(sound:String):Int
	{
		if (!this.cache.exists(sound))
			return 0;
		return this.cache.get(sound).kbps;
	}

	public function getIntroOffset(sound:String):Int
	{
		if (!this.cache.exists(sound))
			return 0;
		return this.cache.get(sound).introOffsetMs;
	}

	public function setKbps(sound:String, kbps:Int):Void
	{
		if (!this.cache.exists(sound))
		{
			this.cache.set(sound, {kbps: kbps, introOffsetMs: 0});
		}
		else
		{
			this.cache.get(sound).kbps = kbps;
		}
	}

	public function setIntroOffset(sound:String, introOffsetMs:Int):Void
	{
		if (!this.cache.exists(sound))
		{
			this.cache.set(sound, {kbps: 0, introOffsetMs: introOffsetMs});
		}
		else
		{
			this.cache.get(sound).introOffsetMs = introOffsetMs;
		}
	}

	static function get_instance():PartialSoundMetadata
	{
		if (PartialSoundMetadata._instance == null)
			set_instance(new PartialSoundMetadata());
		if (PartialSoundMetadata._instance == null)
			throw "Error: Could not instantiate PartialSoundMetadata";

		return PartialSoundMetadata._instance;
	}

	static function set_instance(instance:PartialSoundMetadata):PartialSoundMetadata
	{
		PartialSoundMetadata._instance = instance;

		return PartialSoundMetadata._instance;
	}
}

typedef SoundMetadata =
{
	var kbps:Int;
	var introOffsetMs:Int;
}
