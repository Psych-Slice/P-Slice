package mikolka.vslice.freeplay.pslice;

import mikolka.vslice.freeplay.backcards.BoyfriendCard;


// ? P-Slice class
// Made this static so that it isn't tied with freeplay as much
class FreeplayColorTweener
{
	private var targetState:BoyfriendCard;
	private var intendedColor:Null<FlxColor>;
	var tweens:List<FlxTween>;

	public function new(state:BoyfriendCard)
	{
		targetState = state;
		intendedColor = null;
		tweens = new List<FlxTween>();
	}

	public function cancelTween()
	{
		for (tw in tweens)
		{
			tw.cancel();
		}
		tweens = new List<FlxTween>();
	}

	public function tweenColor(newColor:FlxColor)
	{
		if (newColor != intendedColor && targetState != null)
		{
			cancelTween();
			intendedColor = newColor;
			@:privateAccess {
				tweens.add(twnSprite(targetState.pinkBack, [0, 0, 0])); // DEF) FF D8 63 (255 216 99)
				tweens.add(twnText(targetState.funnyScroll, [-20, -63, -20])); // FF 99 63;
				tweens.add(twnText(targetState.funnyScroll2, [-20, -63, -20])); // FF 99 63;

				tweens.add(twnText(targetState.funnyScroll3, [-21, -52, -99])); // FE A4 00

				tweens.add(twnSprite(targetState.orangeBackShit, [4, -20, -70])); // FE DA 00 (-99)
				tweens.add(twnSprite(targetState.alsoOrangeLOL, [5, -14, -70])); // FF D4 00
				tweens.add(twnText(targetState.txtNuts, [20, 39, 156]));

				tweens.add(twnText(targetState.moreWays, [0, 27, 32])); // FF F3 83
				tweens.add(twnText(targetState.moreWays2, [0, 27, 32])); // FF F3 83
			}
		}
	}

	private function twnSprite(sprite:FlxSprite, offset:Array<Int>)
	{
		var realColor = FlxColor.fromRGB(addClrComp(intendedColor.red, offset[0]), addClrComp(intendedColor.green, offset[1]),
			addClrComp(intendedColor.blue, offset[2]));
		return FlxTween.color(sprite, 1, sprite.color, realColor);
	}

	private function twnText(sprite:BGScrollingText, offset:Array<Int>)
	{
		var textCurColor = sprite.funnyColor;
		var realColor = FlxColor.fromRGB(addClrComp(intendedColor.red, offset[0]), addClrComp(intendedColor.green, offset[1]),
			addClrComp(intendedColor.blue, offset[2]));
		return FlxTween.num(0, 1, 1, null, f ->
		{
			sprite.funnyColor = FlxColor.interpolate(textCurColor, realColor, f);
		});
	}

	private function addClrComp(clr1:Int, clr2:Int)
	{
		var rawResult = clr1 + clr2;
		// s if(!FlxMath.inBounds(0,255,rawResult)) rawResult = clr1-clr2;
		return Std.int(FlxMath.bound(0, 255, rawResult));
	}
}
