package mikolka.stages.erect;

import shaders.AdjustColorShader;
import flxanimate.motion.AdjustColor;
import mikolka.compatibility.VsliceOptions;

class PhillyTrainErect extends PicoCapableStage
{
	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:PhillyTrain;
	var curLight:Int = -1;

	// For Philly Glow events
	var blammedLightsBlack:FlxSprite;
	var phillyGlowGradient:PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlowParticle>;
	var phillyWindowEvent:BGSprite;
	var curLightEvent:Int = -1;

	override function create()
	{
		if (!VsliceOptions.LOW_QUALITY)
		{
			var bg:BGSprite = new BGSprite('philly/erect/sky', -100, 0, 0.1, 0.1);
			add(bg);
		}

		var city:BGSprite = new BGSprite('philly/erect/city', -10, 0, 0.3, 0.3);
		city.setGraphicSize(Std.int(city.width * 0.85));
		city.updateHitbox();
		add(city);

		phillyLightsColors = [0x502d64, 0x2663ac, 0x932c28, 0x329a6d, 0xb66f43];
		phillyWindow = new BGSprite('philly/window', city.x, city.y, 0.3, 0.3);
		phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
		phillyWindow.updateHitbox();
		add(phillyWindow);
		phillyWindow.alpha = 0;

		if (!VsliceOptions.LOW_QUALITY)
		{
			var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
			add(streetBehind);
		}

		phillyTrain = new PhillyTrain(2000, 360);
		add(phillyTrain);

		phillyStreet = new BGSprite('philly/erect/street', -40, 50);
		add(phillyStreet);
	}

	override function createPost()
	{
		super.createPost();
		if (VsliceOptions.SHADERS)
		{
			var colorShader = new AdjustColorShader();
			colorShader.hue = -26;
			colorShader.saturation = -16;
			colorShader.contrast = 0;
			colorShader.brightness = -5;

			boyfriend.shader = colorShader;
			dad.shader = colorShader;
			gf.shader = colorShader;
			phillyTrain.shader = colorShader;
		}
	}

	override function update(elapsed:Float)
	{
		phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
		if (phillyGlowParticles != null)
		{
			phillyGlowParticles.forEachAlive(function(particle:PhillyGlowParticle)
			{
				if (particle.alpha <= 0)
					particle.kill();
			});
		}
		super.update(elapsed);
	}

	override function beatHit()
	{
		phillyTrain.beatHit(curBeat);
		if (curBeat % 4 == 0)
		{
			curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
			phillyWindow.color = phillyLightsColors[curLight];
			phillyWindow.alpha = 1;
		}
	}

	function doFlash()
	{
		var color:FlxColor = FlxColor.WHITE;
		if (!VsliceOptions.FLASHBANG)
			color.alphaFloat = 0.5;

		FlxG.camera.flash(color, 0.15, null, true);
	}

	// Cutscenes
	var cutsceneHandler:CutsceneHandler;
	var imposterPico:FlxAnimate;
	var pico:FlxAnimate;
	var bloodPool:FlxAtlasSprite;
	var cigarette:FlxSprite;
	var audioPlaying:FlxSound;

	var playerShoots:Bool;
	var explode:Bool;

	function prepareCutscene()
	{
		cutsceneHandler = new CutsceneHandler();

		dadGroup.alpha = 0.00001;
		boyfriendGroup.alpha = 0.00001;
		camHUD.visible = false;
		// inCutscene = true; //this would stop the camera movement, oops

		imposterPico = new FlxAnimate(dad.x + 419, dad.y + 225);
		imposterPico.showPivot = false;
		Paths.loadAnimateAtlas(imposterPico, 'cutscenes/pico_doppleganger');
		imposterPico.antialiasing = VsliceOptions.ANTIALIASING;
		addBehindDad(imposterPico);
		cutsceneHandler.push(imposterPico);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			startCountdown();

			dadGroup.alpha = 1;
			camHUD.visible = true;
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
		};
		#if LEGACY_PSYCH
		cutsceneHandler.finishCallback2 = function()
		#else
		cutsceneHandler.skipCallback = function()
		#end
		{
			dadGroup.alpha = 1;
			gfGroup.alpha = 1;
			boyfriendGroup.alpha = 1;
			camHUD.visible = true;

			if (audioPlaying != null)
				audioPlaying.stop();

			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
			dad.dance();
			boyfriend.dance();

			FlxTween.cancelTweensOf(FlxG.camera);
			FlxTween.cancelTweensOf(camFollow);
			@:privateAccess
			game.moveCameraSection();
			FlxG.camera.scroll.set(camFollow.x - FlxG.width / 2, camFollow.y - FlxG.height / 2);
			FlxG.camera.zoom = defaultCamZoom;
			startCountdown();
		};
		camFollow_set(dad.x + 280, dad.y + 170);
	}
	function ughIntro()
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
				camFollow.x += 750;
				camFollow.y += 100;
			});
	
			// Beep!
			cutsceneHandler.timer(4.5, function()
			{
				boyfriend.playAnim('singUP', true);
				boyfriend.specialAnim = true;
				FlxG.sound.play(Paths.sound('bfBeep'));
			});
	
			// Move camera to Tankman
			cutsceneHandler.timer(6, function()
			{
				camFollow.x -= 750;
				camFollow.y -= 100;
	
				// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
				tankman.anim.play('killYou', true);
				killYou.play(true);
				audioPlaying = killYou;
			});
		}
}
