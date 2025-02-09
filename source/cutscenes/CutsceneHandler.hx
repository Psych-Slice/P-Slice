package cutscenes;

import substates.PauseSubState;
import flixel.FlxBasic;
import flixel.util.FlxSort;

typedef CutsceneEvent = {
	var time:Float;
	var func:Void->Void;
}

class CutsceneHandler extends FlxBasic
{
	public var timedEvents:Array<CutsceneEvent> = [];
	public var skipCallback:Void->Void = null;
	public var onStart:Void->Void = null;
	public var endTime:Float = 0;
	public var objects:Array<FlxSprite> = [];
	public var music:String = null;

	var musicObj:FlxSound = null;
	var pauseJustClosed:Bool = false;
	var pausedSounds:Array<FlxSound> = new Array<FlxSound>();

	final _timeToSkip:Float = 1;
	var _canSkip:Bool = false;
	public var holdingTime:Float = 0;
	public var finishCallback:Void->Void = null;

	public function new(canSkip:Bool = true)
	{
		super();

		timer(0, function()
		{
			if(music != null)
			{
				FlxG.sound.playMusic(Paths.music(music), 0, false);
				musicObj = FlxG.sound.music;
				FlxG.sound.music.fadeIn();
			}
			if(onStart != null) onStart();
		});
		FlxG.state.add(this);

		this._canSkip = canSkip;
	}

	private var cutsceneTime:Float = 0;
	private var firstFrame:Bool = false;
	override function update(elapsed)
	{
		super.update(elapsed);

		if(FlxG.state != PlayState.instance || !firstFrame)
		{
			firstFrame = true;
			return;
		}

		cutsceneTime += elapsed;
		while(timedEvents.length > 0 && timedEvents[0].time <= cutsceneTime)
		{
			timedEvents[0].func();
			timedEvents.shift();
		}
		
		if(_canSkip && cutsceneTime > 0.1)
		{
			if (Controls.instance.pressed('pause') #if android || FlxG.android.justReleased.BACK #end && !pauseJustClosed)
				{
					var game = PlayState.instance;
					FlxG.camera.followLerp = 0;
					FlxG.state.persistentUpdate = false;
					FlxG.state.persistentDraw = true;
					FlxG.sound.list.forEach( s -> {
						musicObj?.pause();
						if(s.playing){
							s.pause();
							pausedSounds.push(s);
						}
						FlxTween.globalManager.forEach(s -> s.active = false);
					});
					//game.paused = true;
					var pauseState = new PauseSubState(true,CUTSCENE);
					pauseState.cutscene_allowSkipping = _canSkip;
					game.openSubState(pauseState);

					game.subStateClosed.addOnce(s ->{ //TODO
						pauseJustClosed = true;
						FlxTimer.wait(0.1,() -> pauseJustClosed = false);
						switch (pauseState.specialAction){
							case SKIP:{
								trace('skipped cutscene');
								if(skipCallback != null)
									skipCallback();
								disposeCutscene();
							}
							case RESUME:{
								for (text in pausedSounds) {
									text.resume();
								}
								musicObj?.resume();
								pausedSounds = new Array<FlxSound>();
								FlxTween.globalManager.forEach(s -> s.active = true);
							}
							case NOTHING:{}
							case RESTART:{}
						}
						
					});

					#if DISCORD_ALLOWED
					@:privateAccess
					if(game.autoUpdateRPC) DiscordClient.changePresence("Cutscene paused", PlayState.SONG.song + " (" + game.storyDifficultyText + ")", game.iconP2.getCharacter());
					#end
				}
			// 	holdingTime = Math.max(0, Math.min(_timeToSkip, holdingTime + elapsed));
			// else if (holdingTime > 0)
			// 	holdingTime = Math.max(0, FlxMath.lerp(holdingTime, -0.1, FlxMath.bound(elapsed * 3, 0, 1)));

			// updateSkipAlpha();
		}

		if(endTime <= cutsceneTime)
		{
			finishCallback();
			disposeCutscene();
		}
	}

	function disposeCutscene() {
		for (spr in objects)
			{
				spr.kill();
				PlayState.instance.remove(spr);
				spr.destroy();
			}
			
			destroy();
			PlayState.instance.remove(this);
	}

	public function push(spr:FlxSprite)
	{
		objects.push(spr);
	}

	public function timer(time:Float, func:Void->Void)
	{
		timedEvents.push({time: time, func: func});
		timedEvents.sort(sortByTime);
	}

	function sortByTime(Obj1:CutsceneEvent, Obj2:CutsceneEvent):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.time, Obj2.time);
	}
}