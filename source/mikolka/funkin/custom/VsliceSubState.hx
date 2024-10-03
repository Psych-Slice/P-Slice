package mikolka.funkin.custom;

import mikolka.compatibility.FreeplayHelpers;
import flixel.FlxBasic;
import flixel.util.FlxSort;

// V-Slice substate
class VsliceSubState extends MusicBeatSubstate
{
	/**
	 * Refreshes the state, by redoing the render order of all sprites.
	 * It does this based on the `zIndex` of each prop.
	 */
	public function refresh()
	{
		sort(SortUtil.byZIndex, FlxSort.ASCENDING);
	}
	override function update(elapsed:Float) {
		if(FlxG.sound.music != null)  FreeplayHelpers.updateConductorSongTime(FlxG.sound.music.time); //? update song position
		super.update(elapsed);
	}
}
