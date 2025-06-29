package mikolka.stages.cutscenes;

#if !LEGACY_PSYCH
import cutscenes.CutsceneHandler;
#end
import mikolka.stages.standard.PhillyStreets;

class DarnellStart {
    
	public inline static function darnellCutscene(stage:PhillyStreets)
	{
		var game = PlayState.instance;
		@:privateAccess
		stage.moveCamera(false);
		stage.camFollow.x += 250;
		FlxG.camera.snapToTarget();
		FlxG.camera.zoom = 1.3;
		stage.spraycan.cutscene = true;

		var cutsceneHandler = new CutsceneHandler();
		cutsceneHandler.endTime = 10;

		var cutsceneMusic:FlxSound = new FlxSound().loadEmbedded(Paths.music('darnellCanCutscene'));
		cutsceneMusic.looped = true;
		FlxG.sound.list.add(cutsceneMusic);

		var darnellLaugh:FlxSound = new FlxSound().loadEmbedded(Paths.sound('cutscene/darnell_laugh'));
		darnellLaugh.volume = 0.6;
		FlxG.sound.list.add(darnellLaugh);

		var neneLaugh:FlxSound = new FlxSound().loadEmbedded(Paths.sound('cutscene/nene_laugh'));
		neneLaugh.volume = 0.6;
		FlxG.sound.list.add(neneLaugh);

		game.camHUD.alpha = 0;
		stage.gf.animation.finishCallback = function(name:String)
		{
			switch (name)
			{
				case 'danceLeft', 'danceRight':
					stage.gf.dance();
			}
		}
		stage.gf.dance();

		stage.dad.animation.finishCallback = function(name:String)
		{
			switch (name)
			{
				case 'idle':
					stage.dad.dance();
			}
		}
		stage.dad.dance();

		final cutsceneDelay = 2.0;
		stage.boyfriend.playAnim('intro1', true);
		cutsceneHandler.timer(0.7, function() // play music
		{
			cutsceneMusic.play();
		});
		cutsceneHandler.timer(cutsceneDelay, function() // zoom out to show off everything
		{
			game.moveCamera(true);
			stage.camFollow.x += 100;
			FlxTween.tween(FlxG.camera.scroll, {x: stage.camFollow.x + 100 - FlxG.width / 2, y: stage.camFollow.y - FlxG.height / 2}, 2.5, {ease: FlxEase.quadInOut});
			FlxTween.tween(FlxG.camera, {zoom: 0.66}, 2.5, {ease: FlxEase.quadInOut});
		});
		cutsceneHandler.timer(cutsceneDelay + 3, function() // darnell lights can
		{
			stage.dad.playAnim('lightCan', true);
			stage.lightCanSnd.play(true);
		});
		cutsceneHandler.timer(cutsceneDelay + 4, function() // pico reloads
		{
			stage.boyfriend.playAnim('cock', true);
			FlxTween.tween(FlxG.camera.scroll, {x: stage.camFollow.x + 180 - FlxG.width / 2}, 0.4, {ease: FlxEase.backOut});
			stage.gunPrepSnd.play(true);
		});
		cutsceneHandler.timer(cutsceneDelay + 4.166, function() stage.createCasing());
		cutsceneHandler.timer(cutsceneDelay + 4.4, function() // darnell kicks can
		{
			stage.dad.playAnim('kickCan', true);
			stage.spraycan.playCanStart();
			stage.kickCanSnd.play(true);
		});
		cutsceneHandler.timer(cutsceneDelay + 4.8, function() // darnell knees can
		{
			stage.dad.playAnim('kneeCan', true);
			stage.kneeCanSnd.play(true);
		});
		cutsceneHandler.timer(cutsceneDelay + 5.1, function() // pico fires at can
		{
			stage.boyfriend.playAnim('intro2', true);

			FlxG.sound.play(Paths.soundRandom('shots/shot', 1, 4));

			FlxTween.tween(FlxG.camera.scroll, {x: stage.camFollow.x + 100 - FlxG.width / 2}, 2.5, {ease: FlxEase.quadInOut});

			stage.spraycan.playCanShot();
			new FlxTimer().start(1 / 24, function(_)
			{
				stage.darkenStageProps();
			});
		});
		// darnell laughs
		cutsceneHandler.timer(cutsceneDelay + 5.9, function()
		{
			stage.dad.animation.finishCallback = null;
			stage.dad.playAnim('laughCutscene', true);
			darnellLaugh.play(true);
		});

		// nene spits and laughs
		cutsceneHandler.timer(cutsceneDelay + 6.2, function()
		{
			stage.gf.animation.finishCallback = null;
			stage.gf.playAnim('laughCutscene', true);
			neneLaugh.play(true);
		});

		// cutscene ended, camera returns to normal, cutscene flags set and countdown starts.
		cutsceneHandler.finishCallback = function()
		{
			cutsceneMusic.stop(); // stop the music!!!!!!

			game.cameraSpeed = 0;
			FlxTween.tween(FlxG.camera, {zoom: 0.77}, 2, {ease: FlxEase.sineInOut});
			FlxTween.tween(FlxG.camera.scroll, {x: stage.camFollow.x + 180 - FlxG.width / 2}, 2,
				{ease: FlxEase.sineInOut, onComplete: function(_) game.cameraSpeed = 1});
			game.inCutscene = false;

			stage.spraycan.visible = stage.spraycan.active = stage.spraycan.cutscene = false;
			game.camHUD.alpha = 1;
			game.startCountdown();
		};
		#if LEGACY_PSYCH
		cutsceneHandler.finishCallback2 = function()
		#else
		cutsceneHandler.skipCallback = function()
		#end
		{
			cutsceneHandler.finishCallback();

			stage.dad.dance();
			stage.gf.dance();
			stage.boyfriend.dance();
			stage.dad.animation.finishCallback = null;
			stage.gf.animation.finishCallback = null;
			@:privateAccess
			game.moveCameraSection();
			game.cameraSpeed = 1;
			FlxTween.cancelTweensOf(FlxG.camera);
			FlxTween.cancelTweensOf(FlxG.camera.scroll);
			FlxG.camera.scroll.set(stage.camFollow.x - FlxG.width / 2, stage.camFollow.y - FlxG.height / 2);
			FlxG.camera.zoom = stage.defaultCamZoom;
		};
		FlxG.camera.fade(FlxColor.BLACK, 2, true, null, true);
	}

}