package mikolka.editors.editorProps.sprites;

import mikolka.editors.editorProps.sprites.ResultsSprite;
import mikolka.funkin.players.PlayerData.PlayerResultsAnimationData;
import mikolka.compatibility.funkin.FunkinPath;

class ResultsAtlasSprite extends FlxAtlasSprite implements ResultsSprite
{
	var data:PlayerResultsAnimationData;

	public function new(animData:PlayerResultsAnimationData)
	{
		var offsets = animData.offsets ?? [0, 0];
		data = animData;
		// ? Scaling offsets because Pico decided to be annoying
		var xDiff = offsets[0] - (offsets[0] * (animData.scale ?? 1.0));
		var yDiff = offsets[1] - (offsets[1] * (animData.scale ?? 1.0));
		offsets[0] -= xDiff * 1.8;
		offsets[1] -= yDiff * 1.8;

		super(offsets[0], offsets[1], FunkinPath.animateAtlas(FunkinPath.stripLibrary(animData.assetPath)));
		zIndex = animData.zIndex ?? 500;
		scale.set(animData.scale ?? 1.0, animData.scale ?? 1.0);

		// Animation is not looped.
		onAnimationComplete.add((_name:String) ->
		{
			trace("Pausing atlas anim");
			if (animation == null)
				return;
			if (!(animData.looped ?? true))
			{
				anim.pause();
			}
			else if (animData.loopFrameLabel != null && animData.loopFrameLabel != "")
			{
				playAnimation(animData.loopFrameLabel ?? '', true, false, true); // unpauses this anim, since it's on PlayOnce!
			}
			else if (animData.loopFrame != null)
			{
				anim.curFrame = animData.loopFrame ?? 0;
				anim.play(); // unpauses this anim, since it's on PlayOnce!
			}
		});
		// Hide until ready to play.
		// visible = false;
	}

	public function getSpriteType():SpriteType
	{
		return ATLAS;
	}

	public function startAnimation()
	{
		playAnimation(''); 
	}

	public function resetAnimation()
	{
		animation.curAnim = animation.getByName("");
		if (data.loopFrame != null && data.looped)
			anim.curFrame = data.loopFrame;
		else
			anim.curFrame = animation.curAnim.numFrames - 1;
	}
}
