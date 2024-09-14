package mikolka.funkin;

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
		sort(byZIndex, FlxSort.ASCENDING);
	}

	/**
	 * You can use this function in FlxTypedGroup.sort() to sort FlxObjects by their z-index values.
	 * The value defaults to 0, but by assigning it you can easily rearrange objects as desired.
	 *
	 * @param order Either `FlxSort.ASCENDING` or `FlxSort.DESCENDING`
	 * @param a The first FlxObject to compare.
	 * @param b The second FlxObject to compare.
	 * @return 1 if `a` has a higher z-index, -1 if `b` has a higher z-index.
	 */
	static inline function byZIndex(order:Int, a:FlxBasic, b:FlxBasic):Int
	{
		if (a == null || b == null)
			return 0;
		return FlxSort.byValues(order, a.zIndex, b.zIndex);
	}
}
