package mikolka.stages.cutscenes;

import mikolka.compatibility.VsliceOptions;
import mikolka.stages.standard.Tank;
#if !LEGACY_PSYCH
import cutscenes.CutsceneHandler;
#end

class TankStageScenes {
    public function new(host:Tank) {
        stage = host;
        game =  PlayState.instance;
    }
    	// Cutscenes
	var stage:Tank;
    var game:PlayState;
	var cutsceneHandler:CutsceneHandler;
	var tankman:FlxAnimate;
	var pico:FlxAnimate;
	var boyfriendCutscene:FlxSprite;
	var audioPlaying:FlxSound;
	function prepareCutscene()
	{
		cutsceneHandler = new CutsceneHandler();

		game.dadGroup.alpha = 0.00001;
		game.camHUD.visible = false;
		//inCutscene = true; //this would stop the camera movement, oops

		tankman = new FlxAnimate(game.dad.x + 419, game.dad.y + 225);
		tankman.showPivot = false;
		Paths.loadAnimateAtlas(tankman, 'cutscenes/tankman');
		tankman.antialiasing = VsliceOptions.ANTIALIASING;
		stage.addBehindDad(tankman);
		cutsceneHandler.push(tankman);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: game.defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			game.startCountdown();

			game.dadGroup.alpha = 1;
			game.camHUD.visible = true;
			game.boyfriend.animation.finishCallback = null;
			game.gf.animation.finishCallback = null;
			game.gf.dance();
		};
		#if LEGACY_PSYCH
		cutsceneHandler.finishCallback2 = function()
		#else
		cutsceneHandler.skipCallback = function()
		#end
		{
			game.dadGroup.alpha = 1;
			game.gfGroup.alpha = 1;
			game.boyfriendGroup.alpha = 1;
			game.camHUD.visible = true;

			if(audioPlaying != null)
				audioPlaying.stop();

			game.boyfriend.animation.finishCallback = null;
			game.gf.animation.finishCallback = null;
			game.gf.dance();
			game.dad.dance();
			game.boyfriend.dance();

			FlxTween.cancelTweensOf(FlxG.camera);
			FlxTween.cancelTweensOf(game.camFollow);
			@:privateAccess
			game.moveCameraSection();
			FlxG.camera.scroll.set(game.camFollow.x - FlxG.width/2, game.camFollow.y - FlxG.height/2);
			FlxG.camera.zoom = game.defaultCamZoom;
			game.startCountdown();
		};
		stage.camFollow_set(game.dad.x + 280, game.dad.y + 170);
	}

	public function ughIntro()
	{
		prepareCutscene();
		cutsceneHandler.endTime = 12;
		cutsceneHandler.music = 'DISTORTO';
		Paths.sound('wellWellWell');
		Paths.sound('killYou');
		Paths.sound('bfBeep');

		var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
		FlxG.sound.list.add(wellWellWell);
		var killYou:FlxSound = new FlxSound().loadEmbedded(Paths.sound('killYou'));
		FlxG.sound.list.add(killYou);

		tankman.anim.addBySymbol('wellWell', 'TANK TALK 1 P1', 24, false);
		tankman.anim.addBySymbol('killYou', 'TANK TALK 1 P2', 24, false);
		tankman.anim.play('wellWell', true);
		FlxG.camera.zoom *= 1.2;

		// Well well well, what do we got here?
		cutsceneHandler.timer(0.1, function()
		{
			wellWellWell.play(true);
			audioPlaying = wellWellWell;
		});

		// Move camera to BF
		cutsceneHandler.timer(3, function()
		{
			game.camFollow.x += 750;
			game.camFollow.y += 100;
		});

		// Beep!
		cutsceneHandler.timer(4.5, function()
		{
			game.boyfriend.playAnim('singUP', true);
			game.boyfriend.specialAnim = true;
			FlxG.sound.play(Paths.sound('bfBeep'));
		});

		// Move camera to Tankman
		cutsceneHandler.timer(6, function()
		{
			game.camFollow.x -= 750;
			game.camFollow.y -= 100;

			// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
			tankman.anim.play('killYou', true);
			killYou.play(true);
			audioPlaying = killYou;
		});
	}
	public function gunsIntro()
	{
		prepareCutscene();
		cutsceneHandler.endTime = 11.5;
		cutsceneHandler.music = 'DISTORTO';
		Paths.sound('tankSong2');

		var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
		FlxG.sound.list.add(tightBars);

		tankman.anim.addBySymbol('tightBars', 'TANK TALK 2', 24, false);
		tankman.anim.play('tightBars', true);
		game.boyfriend.animation.curAnim.finish();

		cutsceneHandler.onStart = function()
		{
			tightBars.play(true);
			audioPlaying = tightBars;
			FlxTween.tween(FlxG.camera, {zoom: game.defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
			FlxTween.tween(FlxG.camera, {zoom: game.defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
			FlxTween.tween(FlxG.camera, {zoom: game.defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
		};

		cutsceneHandler.timer(4, function()
		{
			game.gf.playAnim('sad', true);
			game.gf.animation.finishCallback = function(name:String)
			{
				game.gf.playAnim('sad', true);
			};
		});
	}
	var dualWieldAnimPlayed = 0;
	public function stressIntro()
	{
		prepareCutscene();
		
		cutsceneHandler.endTime = 35.5;
		game.gfGroup.alpha = 0.00001;
		game.boyfriendGroup.alpha = 0.00001;
		stage.camFollow_set(game.dad.x + 400, game.dad.y + 170);
		FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
		stage.foregroundSprites.forEach(function(spr:BGSprite)
		{
			spr.y += 100;
		});
		Paths.sound('stressCutscene');

		pico = new FlxAnimate(game.gf.x + 150, game.gf.y + 450);
		pico.showPivot = false;
		Paths.loadAnimateAtlas(pico, 'cutscenes/picoAppears');
		pico.antialiasing = VsliceOptions.ANTIALIASING;
		pico.anim.addBySymbol('dance', 'GF Dancing at Gunpoint', 24, true);
		pico.anim.addBySymbol('dieBitch', 'GF Time to Die sequence', 24, false);
		pico.anim.addBySymbol('picoAppears', 'Pico Saves them sequence', 24, false);
		pico.anim.addBySymbol('picoEnd', 'Pico Dual Wield on Speaker idle', 24, false);
		pico.anim.play('dance', true);
		stage.addBehindGF(pico);
		cutsceneHandler.push(pico);

		// prepare pico animation cycle
		function picoStressCycle() {
			switch (pico.anim.curInstance.symbol.name) {
				case "dieBitch", "GF Time to Die sequence":
					pico.anim.play('picoAppears', true);
					game.boyfriendGroup.alpha = 1;
					boyfriendCutscene.visible = false;
					game.boyfriend.playAnim('bfCatch', true);
					game.boyfriend.animation.finishCallback = function(name:String)
					{
						if(name != 'idle')
						{
							game.boyfriend.playAnim('idle', true);
							game.boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
						}
					};
				case "picoAppears", "Pico Saves them sequence":
					pico.anim.play('picoEnd', true);
				case "picoEnd", "Pico Dual Wield on Speaker idle":
					game.gfGroup.alpha = 1;
					pico.visible = false;
					if (pico.anim.onComplete.has(picoStressCycle)) // for safety
						pico.anim.onComplete.remove(picoStressCycle);
			}
		}
		pico.anim.onComplete.add(picoStressCycle);

		boyfriendCutscene = new FlxSprite(game.boyfriend.x + 5, game.boyfriend.y + 20);
		boyfriendCutscene.antialiasing = VsliceOptions.ANTIALIASING;
		boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
		boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
		boyfriendCutscene.animation.play('idle', true);
		boyfriendCutscene.animation.curAnim.finish();
		stage.addBehindBF(boyfriendCutscene);
		cutsceneHandler.push(boyfriendCutscene);

		var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
		FlxG.sound.list.add(cutsceneSnd);

		tankman.anim.addBySymbol('godEffingDamnIt', 'TANK TALK 3 P1 UNCUT', 24, false);
		tankman.anim.addBySymbol('lookWhoItIs', 'TANK TALK 3 P2 UNCUT', 24, false);
		tankman.anim.play('godEffingDamnIt', true);

		cutsceneHandler.onStart = function()
		{
			cutsceneSnd.play(true);
			audioPlaying = cutsceneSnd;
		};

		cutsceneHandler.timer(15.2, function()
		{
			FlxTween.tween(game.camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
			FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});
			pico.anim.play('dieBitch', true);
		});

		cutsceneHandler.timer(17.5, function()
		{
			zoomBack();
		});

		cutsceneHandler.timer(19.5, function()
		{
			tankman.anim.play('lookWhoItIs', true);
		});

		cutsceneHandler.timer(20, function()
		{
			stage.camFollow_set(game.dad.x + 500, game.dad.y + 170);
		});

		cutsceneHandler.timer(31.2, function()
		{
			game.boyfriend.playAnim('singUPmiss', true);
			game.boyfriend.animation.finishCallback = function(name:String)
			{
				if (name == 'singUPmiss')
				{
					game.boyfriend.playAnim('idle', true);
					game.boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
				}
			};

			stage.camFollow_set(game.boyfriend.x + 280, game.boyfriend.y + 200);
			FlxG.camera.snapToTarget();
			game.cameraSpeed = 12;
			FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
		});

		cutsceneHandler.timer(32.2, function()
		{
			zoomBack();
		});
	}

	function zoomBack()
	{
		var calledTimes:Int = 0;
		stage.camFollow_set(630, 425);
		FlxG.camera.snapToTarget();
		FlxG.camera.zoom = 0.8;
		game.cameraSpeed = 1;

		calledTimes++;
		if (calledTimes > 1)
		{
			stage.foregroundSprites.forEach(function(spr:BGSprite)
			{
				spr.y -= 100;
			});
		}
	}
}