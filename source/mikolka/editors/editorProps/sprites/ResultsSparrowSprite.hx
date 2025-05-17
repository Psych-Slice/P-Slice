package mikolka.editors.editorProps.sprites;

import shaders.ColorSwap;
import mikolka.editors.editorProps.sprites.IResultsSprite.SpriteType;
import mikolka.compatibility.funkin.FunkinPath;
import mikolka.compatibility.VsliceOptions;
import mikolka.funkin.players.PlayerData.PlayerResultsAnimationData;

class ResultsSparrowSprite extends FlxSprite implements IResultsSprite
{
	var data:PlayerResultsAnimationData;
	var timer:Null<FlxTimer>;
	var sound:FlxSound = new FlxSound();

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

	public function startAnimation(activeFilter:String):Void
	{
		var canShow = data.filter == null || data.filter == "" || data.filter == "both";
		if(data.filter == activeFilter) canShow = true;
		timer?.cancel();
		visible = false;

		if(!canShow) return;
		timer = FlxTimer.wait(data.delay,() ->{
			animation.play('idle', true);
			sound?.play();
			visible = true;
		});
	}

	public function pauseAnimation()
	{
		animation.pause();
		sound?.pause();
		if (timer != null) timer.active = false;
	}

	public function resetAnimation(activeFilter:String)
	{
		timer?.cancel();
		timer = null;

		if(data.sound != "" && data.sound != null) sound.loadEmbedded(Paths.sound(FunkinPath.stripLibrary(data.sound)));

		var canShow = data.filter == null || data.filter == "" || data.filter == "both";
		if(data.filter == activeFilter) canShow = true;
		if(canShow){
			visible = true;
			animation.curAnim = animation.getByName("idle");
			if (data.loopFrame != null && data.looped)
				animation.frameIndex = data.loopFrame;
			else
				animation.frameIndex = animation.curAnim.numFrames - 1;
		}
		else visible = false;
	}

	public function resumeAnimation()
	{
		animation.resume();
		sound?.resume();
		if (timer != null) timer.active = true;
	}

	public function set_offset(x:Float, y:Float)
	{
		setPosition(x, y);
	}
}
