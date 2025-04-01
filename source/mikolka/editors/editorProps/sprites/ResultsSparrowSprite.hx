package mikolka.editors.editorProps.sprites;

import mikolka.editors.editorProps.sprites.IResultsSprite.SpriteType;
import mikolka.compatibility.funkin.FunkinPath;
import mikolka.compatibility.VsliceOptions;
import mikolka.funkin.players.PlayerData.PlayerResultsAnimationData;

class ResultsSparrowSprite extends FlxSprite implements IResultsSprite
{
	var data:PlayerResultsAnimationData;
	var timer:FlxTimer;

	public function new(animData:PlayerResultsAnimationData)
	{
		var offsets = animData.offsets ?? [0, 0];
		super(offsets[0], offsets[1]);
		antialiasing = VsliceOptions.ANTIALIASING;
		frames = Paths.getSparrowAtlas(FunkinPath.stripLibrary(animData.assetPath));
		data = animData;
		animation.addByPrefix('idle', '', 24, false, false, false);

		animation.finishCallback = (_name:String) ->
		{
			if (animation != null && animData.looped)
			{
				animation.play('idle', true, false, animData.loopFrame ?? 0);
			}
		}
		// Hide until ready to play.
		visible = false;
	}

	public function getSpriteType():SpriteType
	{
		return SPARROW;
	}

	public function startAnimation()
	{
		timer?.cancel();
		visible = false;
		timer = FlxTimer.wait(data.delay,() ->{
			visible = true;
			animation.play('idle', true);
		});
	}

	public function pauseAnimation()
	{
		animation.pause();
		timer.active = false;
	}

	public function resetAnimation()
	{
		timer?.cancel();
		visible = true;
		animation.curAnim = animation.getByName("idle");
		if (data.loopFrame != null && data.looped)
			animation.frameIndex = data.loopFrame;
		else
			animation.frameIndex = animation.curAnim.numFrames - 1;
	}

	public function resumeAnimation()
	{
		animation.resume();
		timer.active = true;
	}

	public function set_offset(x:Float, y:Float)
	{
		setPosition(x, y);
	}
}
