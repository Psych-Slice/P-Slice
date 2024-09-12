package mikolka.funkin;

import openfl.media.SoundMixer;
import flixel.system.FlxAssets.FlxSoundAsset;

class FunkinSound extends FlxSound
{
	/**
	 * Play a sound effect once, then destroy it.
	 * @param key
	 * @param volume
	 * @return static function construct():FunkinSound
	 */
	public static function playOnce(key:String, volume:Float = 1.0, ?onComplete:Void->Void, ?onLoad:Void->Void):Void
	{
		var result = FunkinSound.load(key, volume, false, true, true, onComplete, onLoad);
	}

	/**
	 * Creates a new `FunkinSound` object synchronously.
	 *
	 * @param embeddedSound   The embedded sound resource you want to play.  To stream, use the optional URL parameter instead.
	 * @param volume          How loud to play it (0 to 1).
	 * @param looped          Whether to loop this sound.
	 * @param group           The group to add this sound to.
	 * @param autoDestroy     Whether to destroy this sound when it finishes playing.
	 *                          Leave this value set to `false` if you want to re-use this `FunkinSound` instance.
	 * @param autoPlay        Whether to play the sound immediately or wait for a `play()` call.
	 * @param onComplete      Called when the sound finished playing.
	 * @param onLoad          Called when the sound finished loading.  Called immediately for succesfully loaded embedded sounds.
	 * @return A `FunkinSound` object, or `null` if the sound could not be loaded.
	 */
	public static function load(embeddedSound:FlxSoundAsset, volume:Float = 1.0, looped:Bool = false, autoDestroy:Bool = false, autoPlay:Bool = false,
			?onComplete:Void->Void, ?onLoad:Void->Void):Null<FunkinSound>
	{
		@:privateAccess
		if (SoundMixer.__soundChannels.length >= SoundMixer.MAX_ACTIVE_CHANNELS)
		{
			FlxG.log.error('FunkinSound could not play sound, channels exhausted! Found ${SoundMixer.__soundChannels.length} active sound channels.');
			return null;
		}

		var sound:FunkinSound = new FunkinSound(); // pool.recycle(construct);

		// Load the sound.
		// Sets `exists = true` as a side effect.
		sound.loadEmbedded(embeddedSound, looped, autoDestroy, onComplete);

		//   if (embeddedSound is String)
		//   {
		//     sound._label = embeddedSound;
		//   }
		//   else
		//   {
		//     sound._label = 'unknown';
		//   }

		if (autoPlay)
			sound.play();
		sound.volume = volume;
		sound.group = FlxG.sound.defaultSoundGroup;
		sound.persist = true;

		// Make sure to add the sound to the list.
		// If it's already in, it won't get re-added.
		// If it's not in the list (it gets removed by FunkinSound.playMusic()),
		// it will get re-added (then if this was called by playMusic(), removed again)
		FlxG.sound.list.add(sound);

		// Call onLoad() because the sound already loaded
		if (onLoad != null && sound._sound != null)
			onLoad();

		return sound;
	}
}
