package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.group.FlxSpriteGroup;
import animateatlas.AtlasFrameMaker;
import flixel.util.FlxSort;

class CutsceneHandler extends FlxBasic
{
	public var timedEvents:Array<Dynamic> = [];
	public var finishCallback:Void->Void = null;
	public var finishCallback2:Void->Void = null;
	public var onStart:Void->Void = null;
	public var endTime:Float = 0;
	public var objects:Array<FlxSprite> = [];
	public var music:String = null;

	var musicObj:FlxSound = null;
	var pauseJustClosed:Bool = false;
	var pausedSounds:Array<FlxSound> = new Array<FlxSound>();

	public function new()
	{
		super();

		timer(0, function()
		{
			if (music != null)
			{
				FlxG.sound.playMusic(Paths.music(music), 0, false);
				musicObj = FlxG.sound.music;
				FlxG.sound.music.fadeIn();
			}
			if (onStart != null)
				onStart();
		});
		PlayState.instance.add(this);
	}

	private var cutsceneTime:Float = 0;
	private var firstFrame:Bool = false;

	override function update(elapsed)
	{
		super.update(elapsed);

		if (FlxG.state != PlayState.instance || !firstFrame)
		{
			firstFrame = true;
			return;
		}
		cutsceneTime += elapsed;

		if (cutsceneTime > 0.1)
		{
			if (PlayerSettings.player1.controls.PAUSE && !pauseJustClosed)
			{
				var game = PlayState.instance;
				//FlxG.camera.followLerp = 0;
				FlxG.state.persistentUpdate = false;
				FlxG.state.persistentDraw = true;
				FlxG.sound.list.forEach(s ->
				{
					musicObj?.pause();
					if (s.playing)
					{
						s.pause();
						pausedSounds.push(s);
					}
					FlxTween.globalManager.forEach(s -> s.active = false);
				});

				var bf = game.boyfriend.getScreenPosition();
				var pauseState = new PauseSubState(bf.x, bf.y,true, CUTSCENE);
				pauseState.cutscene_allowSkipping = true;
				game.openSubState(pauseState);

				game.subStateClosed.addOnce(s ->
				{ // TODO
					pauseJustClosed = true;
					FlxTimer.wait(0.1, () -> pauseJustClosed = false);
					switch (pauseState.specialAction)
					{
						case SKIP: {
								trace('skipped cutscene');
								skipCutscene();
							}
						case RESUME: {
								for (text in pausedSounds)
								{
									text.resume();
								}
								musicObj?.resume();
								pausedSounds = new Array<FlxSound>();
								FlxTween.globalManager.forEach(s -> s.active = true);
							}
						case NOTHING: {
							PlayState.seenCutscene = false;
						}
						case RESTART: {}
					}
				});

				#if DISCORD_ALLOWED
				@:privateAccess
				if (game.autoUpdateRPC)
					DiscordClient.changePresence("Cutscene paused", PlayState.SONG.song + " (" + game.storyDifficultyText + ")", game.iconP2.getCharacter());
				#end
			}
			// 	holdingTime = Math.max(0, Math.min(_timeToSkip, holdingTime + elapsed));
			// else if (holdingTime > 0)
			// 	holdingTime = Math.max(0, FlxMath.lerp(holdingTime, -0.1, FlxMath.bound(elapsed * 3, 0, 1)));

			// updateSkipAlpha();
		}
		if (endTime <= cutsceneTime) skipCutscene();

		while (timedEvents.length > 0 && timedEvents[0][0] <= cutsceneTime)
		{
			timedEvents[0][1]();
			timedEvents.splice(0, 1);
		}
	}
	function skipCutscene() {
		finishCallback();
			if (finishCallback2 != null)
				finishCallback2();

			for (spr in objects)
			{
				spr.kill();
				PlayState.instance.remove(spr);
				spr.destroy();
			}

			kill();
			destroy();
			PlayState.instance.remove(this);
	}
	public function push(spr:FlxSprite)
	{
		objects.push(spr);
	}

	public function timer(time:Float, func:Void->Void)
	{
		timedEvents.push([time, func]);
		timedEvents.sort(sortByTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}
}
