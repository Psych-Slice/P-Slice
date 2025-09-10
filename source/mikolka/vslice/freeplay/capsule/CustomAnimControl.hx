package mikolka.vslice.freeplay.capsule;

import mikolka.funkin.custom.mobile.MobileScaleMode;

class CustomAnimControl {
   	public var doLerp:Bool = false;
	public var doJumpIn:Bool = false;
	public var doJumpOut:Bool = false;
	public var realScaled:Float = 0.8;
	///// Anim DATA
	var frameInTicker:Float = 0;
	var frameInTypeBeat:Int = 0;

	var frameOutTicker:Float = 0;
	var frameOutTypeBeat:Int = 0;

	var xFrames:Array<Float> = [1.7, 1.8, 0.85, 0.85, 0.97, 0.97, 1];
	var xPosLerpLol:Array<Float> = [0.9, 0.4, 0.16, 0.16, 0.22, 0.22, 0.245]; // NUMBERS ARE JANK CUZ THE SCALING OR WHATEVER
	var xPosOutLerpLol:Array<Float> = [0.245, 0.75, 0.98, 0.98, 1.2]; // NUMBERS ARE JANK CUZ THE SCALING OR WHATEVER

    var host:SongMenuItem;
    public function new(host:SongMenuItem) {
        this.host = host;
    }

	public function initJumpIn(maxTimer:Float, ?force:Bool):Void
	{
		frameInTypeBeat = 0;

		new FlxTimer().start((1 / 24) * maxTimer, function(doShit)
		{
			doJumpIn = true;
			doLerp = true;
		});

		if (force)
		{
			host.visible = true;
			host.capsule.alpha = 1;
			host.setVisibleGrp(true);
		}
		else
		{
			new FlxTimer().start((xFrames.length / 24) * 2.5, function(_)
			{
				host.visible = true;
				host.capsule.alpha = 1;
				host.setVisibleGrp(true);
			});
		}
	}

	

	public function forcePosition():Void
	{
		host.visible = true;
		host.capsule.alpha = 1;
        @:privateAccess
		host.updateSelected();
		doLerp = true;
		doJumpIn = false;
		doJumpOut = false;

		frameInTypeBeat = xFrames.length;
		frameOutTypeBeat = 0;

		host.capsule.scale.x = xFrames[frameInTypeBeat - 1];
		host.capsule.scale.y = 1 / xFrames[frameInTypeBeat - 1];
		// x = FlxG.width * xPosLerpLol[Std.int(Math.min(frameInTypeBeat - 1, xPosLerpLol.length - 1))];

		host.x = host.targetPos.x;
		host.y = host.targetPos.y;

		host.capsule.scale.x *= realScaled;
		host.capsule.scale.y *= realScaled;

		host.setVisibleGrp(true);
	}

    
	public function update(elapsed:Float):Void
	{
		var capsule = host.capsule;

		if (doJumpIn)
		{
			frameInTicker += elapsed;

			if (frameInTicker >= 1 / 24 && frameInTypeBeat < xFrames.length)
			{
				frameInTicker = 0;

				capsule.scale.x = xFrames[frameInTypeBeat];
				capsule.scale.y = 1 / xFrames[frameInTypeBeat];
				host.targetPos.x = FlxG.width * xPosLerpLol[Std.int(Math.min(frameInTypeBeat, xPosLerpLol.length - 1))];
				capsule.scale.x *= realScaled;
				capsule.scale.y *= realScaled;

				frameInTypeBeat += 1;
				final shiftx:Float = MobileScaleMode.wideScale.x * 320;
				final widescreenMult:Float = (MobileScaleMode.gameCutoutSize.x / 1.5) * 0.75;
				// Move the targetPos set to the if statement below if you want them to shift to their target positions after jumping in instead
				// I have no idea why this if instead of frameInTypeBeat == xFrames.length works even though they're the same thing
				 if (host.targetPos.x <= shiftx)
                    @:privateAccess
				 	host.targetPos.x = host.intendedX(host.ID+1-FreeplayState.instance.curSelectedFractal) + widescreenMult;
			}
			else if (frameInTypeBeat == xFrames.length)
			{
				doJumpIn = false;
			}
		}

		if (doJumpOut)
		{
			frameOutTicker += elapsed;

			if (frameOutTicker >= 1 / 24 && frameOutTypeBeat < xFrames.length)
			{
				frameOutTicker = 0;

				capsule.scale.x = xFrames[frameOutTypeBeat];
				capsule.scale.y = 1 / xFrames[frameOutTypeBeat];
				host.x = FlxG.width * xPosOutLerpLol[Std.int(Math.min(frameOutTypeBeat, xPosOutLerpLol.length - 1))];

				capsule.scale.x *= realScaled;
				capsule.scale.y *= realScaled;

				frameOutTypeBeat += 1;
			}
			else if (frameOutTypeBeat == xFrames.length)
			{
				doJumpOut = false;
			}
		}

		if (doLerp)
		{
			host.x = MathUtil.smoothLerp(host.x, host.targetPos.x, elapsed, 0.3); // ? update lerping for lower FPS
			host.y = MathUtil.smoothLerp(host.y, host.targetPos.y, elapsed, 0.4); // ? kinda cool tbh
			// TODO capsule.visible = songData?.isFav;
		}

	}
}