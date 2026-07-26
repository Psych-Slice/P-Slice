package mikolka.editors.editorProps.sprites;

import mikolka.editors.editorProps.sprites.IResultsSprite;
import mikolka.funkin.players.PlayerData.PlayerResultsAnimationData;
import mikolka.compatibility.funkin.FunkinPath;

class ResultsAtlasSprite extends FunkinSprite implements IResultsSprite
{
	var data:PlayerResultsAnimationData;
	var timer:Null<FlxTimer>;
	var sound:FlxSound = new FlxSound();
	var resetTriggered:Bool = false;

	public function new(animData:PlayerResultsAnimationData)
	{
		data = animData;
		var offsets = animData.offsets ?? [0, 0];
		var l_scale = animData.scale ?? 1.0;
		var xDiff = -(offsets[0] - (offsets[0] * l_scale)) * 1.8;
		var yDiff = -(offsets[1] - (offsets[1] * l_scale)) * 1.8;

		super(offsets[0]+xDiff, offsets[1]+yDiff, FunkinPath.stripLibrary(animData.assetPath));
		zIndex = animData.zIndex ?? 500;
		scale.set(animData.scale ?? 1.0, animData.scale ?? 1.0);

		// Animation is not looped.
		anim.onFinish.add((_name:String) ->
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
				anim.play(animData.loopFrameLabel ?? '', true, false); // unpauses this anim, since it's on PlayOnce!
				anim.curAnim.looped = true;
			}
			else if (animData.loopFrame != null)
			{
				anim.play("", true, false, animData.loopFrame ?? 0);// unpauses this anim, since it's on PlayOnce!
			}
		});
		// Hide until ready to play.
		// visible = false;
	}

	public function getSpriteType():SpriteType
	{
		return ATLAS;
	}

	public function pauseAnimation() {
		sound?.pause();
		anim.pause();
		if (timer != null) timer.active = false;
	}
	public function resumeAnimation() {
		anim.resume();
		sound?.resume();
		if (timer != null) timer.active = true;
	}
	public function startAnimation(activeFilter:String)
	{
		var canShow = data.filter == null || data.filter == "" || data.filter == "both";
		if(data.filter == activeFilter) canShow = true;
		timer?.cancel();
		visible = false;

		if(!canShow) return;
		timer = FlxTimer.wait(data.delay ?? 0,() ->{
			anim.play(data.startFrameLabel ?? '',true); 
			sound?.play();
			visible = true;
		});
	}

	public function resetAnimation(activeFilter:String)
	{
		if(data.sound != "" && data.sound != null) sound.loadEmbedded(Paths.sound(FunkinPath.stripLibrary(data.sound)));
		timer?.cancel();
		timer = null;
		//animation.curAnim = animation.getByName("");
		var canShow = data.filter == null || data.filter == "" || data.filter == "both";
		if(data.filter == activeFilter) canShow = true;
		resetTriggered = true;
		if(canShow){

			visible = true;
			if (data.loopFrame != null && data.looped)
				anim.frameIndex = data.loopFrame;
			else
				anim.frameIndex = anim.numFrames-1;//animation.curAnim.numFrames - 1;
		} else visible = false;
	}

	public function set_offset(x:Float,y:Float) {
		var offsets = [x,y];
		// ? Scaling offsets because Pico decided to be annoying
		var l_scale = data.scale ?? 1.0;
		var xDiff = -(offsets[0] - (offsets[0] * l_scale)) * 1.8;
		var yDiff = -(offsets[1] - (offsets[1] * l_scale)) * 1.8;
		setPosition(offsets[0]+xDiff,offsets[1]+yDiff);
	}
}
