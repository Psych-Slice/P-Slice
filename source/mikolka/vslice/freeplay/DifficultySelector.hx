package mikolka.vslice.freeplay;

import mikolka.funkin.freeplay.FreeplayStyle;
import shaders.PureColor;

/**
 * The difficulty selector arrows to the left and right of the difficulty.
 */
class DifficultySelector extends FlxSprite
{
	var controls:Controls;
	var whiteShader:PureColor;

	var parent:FreeplayState;

	public function new(parent:FreeplayState, x:Float, y:Float, flipped:Bool, controls:Controls, ?styleData:FreeplayStyle = null)
	{
		super(x, y);

		this.parent = parent;
		this.controls = controls;

		frames = Paths.getSparrowAtlas(styleData == null ? 'freeplay/freeplaySelector' : styleData.getSelectorAssetKey());
		animation.addByPrefix('shine', 'arrow pointer loop', 24);
		animation.play('shine');

		whiteShader = new PureColor(FlxColor.WHITE);

		whiteShader.colorSet = true;

		flipX = flipped;
	}

	override function update(elapsed:Float):Void
	{
		if (flipX && controls.UI_RIGHT_P && !parent.busy)
			moveShitDown();
		if (!flipX && controls.UI_LEFT_P && !parent.busy)
			moveShitDown();

		super.update(elapsed);
	}

	public function setPress(press:Bool):Void
	{
		if (!press)
		{
			shader = null;
			scale.x = scale.y = 1;
			updateHitbox();
		}
		else
		{
			offset.y -= 5;
			shader = whiteShader;
			scale.x = scale.y = 0.5;
			
		}
	}

	function moveShitDown():Void
	{
		offset.y -= 5;

		scale.x = scale.y = 0.5;

		shader = whiteShader;

		new FlxTimer().start(2 / 24, function(tmr)
		{
			scale.x = scale.y = 1;
			shader = null;
			updateHitbox();
		});
	}
}