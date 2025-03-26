package mikolka.editors.editorProps;

import mikolka.funkin.players.PlayerData.PlayerResultsAnimationData;
import mikolka.compatibility.funkin.FunkinPath;

class ResultsAtlasSprite extends FlxAtlasSprite
{
	public function new(animData:PlayerResultsAnimationData)
	{
		var offsets = animData.offsets ?? [0, 0];
		// ? Scaling offsets because Pico decided to be annoying
		var xDiff = offsets[0] - (offsets[0] * (animData.scale ?? 1.0));
		var yDiff = offsets[1] - (offsets[1] * (animData.scale ?? 1.0));
		offsets[0] -= xDiff * 1.8;
		offsets[1] -= yDiff * 1.8;

		super(offsets[0], offsets[1], FunkinPath.animateAtlas(FunkinPath.stripLibrary(animData.assetPath)));
		zIndex = animData.zIndex ?? 500;
		scale.set(animData.scale ?? 1.0, animData.scale ?? 1.0);

		if (!(animData.looped ?? true))
		{
			// Animation is not looped.
			onAnimationComplete.add((_name:String) ->
			{
				trace("AHAHAH 2");
				if (animation != null)
				{
					anim.pause();
				}
			});
		}
		else if (animData.loopFrameLabel != null)
		{
			onAnimationComplete.add((_name:String) ->
			{
				trace("AHAHAH 2");
				if (animation != null)
				{
					playAnimation(animData.loopFrameLabel ?? '', true, false, true); // unpauses this anim, since it's on PlayOnce!
				}
			});
		}
		else if (animData.loopFrame != null)
		{
			onAnimationComplete.add((_name:String) ->
			{
				if (animation != null)
				{
					trace("AHAHAH");
					anim.curFrame = animData.loopFrame ?? 0;
					anim.play(); // unpauses this anim, since it's on PlayOnce!
				}
			});
		}

		// Hide until ready to play.
		visible = false;
	}
}
