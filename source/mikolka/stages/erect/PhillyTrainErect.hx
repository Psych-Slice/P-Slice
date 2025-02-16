package mikolka.stages.erect;

import flixel.FlxSubState;
import mikolka.stages.objects.PhillyLights;
import mikolka.stages.objects.PicoDopplegangerSprite;
import shaders.AdjustColorShader;
import flxanimate.motion.AdjustColor;
import mikolka.compatibility.VsliceOptions;
#if !LEGACY_PSYCH
import cutscenes.CutsceneHandler;
import objects.Character;
#end

class PhillyTrainErect extends BaseStage
{
	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:PhillyTrain;
	var curLight:Int = -1;

	var curLightEvent:Int = -1;
	var colorShader:AdjustColorShader;

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
			var streetBehind:BGSprite = new BGSprite('philly/erect/behindTrain', -40, 50);
			add(streetBehind);
		}

		phillyTrain = new PhillyTrain(2000, 360);
		add(phillyTrain);

		phillyStreet = new BGSprite('philly/erect/street', -40, 50);
		add(phillyStreet);
		

		if(!seenCutscene 
			&& PlayState.SONG.player1 == "pico-playable" 
			&& PlayState.SONG.player2 == "pico") setStartCallback(ughIntro);
		
		new PhillyLights(phillyStreet,phillyWindow.x,phillyWindow.y,phillyLightsColors);
	}

	override function createPost()
	{
		super.createPost();

		if (VsliceOptions.SHADERS)
		{
			colorShader = new AdjustColorShader();
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
		phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.9;
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

	override function openSubState(SubState:FlxSubState) {
		if(phillyTrain.sound?.playing){
			phillyTrain.sound.pause();
			PlayState.instance.subStateClosed.addOnce((sub) ->{
				if (phillyTrain.sound != null) phillyTrain.sound.resume();
			});
		}
		super.openSubState(SubState);
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
	var imposterPico:PicoDopplegangerSprite;
	var pico:PicoDopplegangerSprite;
	var bloodPool:FlxAnimate;
	var cigarette:FlxSprite;
	var audioPlaying:FlxSound;

	var playerShoots:Bool;
	var explode:Bool;
	var seenOutcome:Bool;

	function prepareCutscene()
	{
		cutsceneHandler = new CutsceneHandler();

		boyfriend.visible = dad.visible = false;
		camHUD.visible = false;
		// inCutscene = true; //this would stop the camera movement, oops

		imposterPico = new PicoDopplegangerSprite(dad.x + 82, dad.y + 400);
		imposterPico.showPivot = false;
		imposterPico.antialiasing = VsliceOptions.ANTIALIASING;
		cutsceneHandler.push(imposterPico);

		pico = new PicoDopplegangerSprite(boyfriend.x + 48.5, boyfriend.y + 400);
		pico.showPivot = false;
		pico.antialiasing = VsliceOptions.ANTIALIASING;
		cutsceneHandler.push(pico);

		bloodPool = new FlxAnimate(0, 0);
		bloodPool.visible = false;
		Paths.loadAnimateAtlas(bloodPool, "philly/erect/cutscenes/bloodPool");

		cigarette = new FlxSprite();
		cigarette.frames = Paths.getSparrowAtlas('philly/erect/cutscenes/cigarette');
		cigarette.animation.addByPrefix('cigarette spit', 'cigarette spit', 24, false);
		cigarette.visible = false;

		cutsceneHandler.finishCallback = function()
		{
			seenCutscene = true;
			//Restore camera
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});

			//Show still alive chars
			if (explode)
				{
					if (playerShoots) boyfriend.visible = true;
					else dad.visible = true;
				}
			else boyfriend.visible = dad.visible = true;
			
			camHUD.visible = true;

			//Crear callbacks
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
	
			if (audioPlaying != null) audioPlaying.stop();
			pico.cancelSounds();
			imposterPico.cancelSounds();
			
			if (explode)
			{
				if(playerShoots){
					if (seenOutcome)
						imposterPico.playAnimation("loopOpponent", true, true, true);
					else
					{
						imposterPico.kill();
						game.remove(imposterPico);
						imposterPico.destroy();
						dad.visible = true;
					}
				}
				else{

					if(seenOutcome){
						pico.playAnimation("loopPlayer", true, true, true);
						endSong();
					}
					else{
						pico.kill();
						game.remove(pico);
						pico.destroy();
						boyfriend.visible = true;
					}
				}
				if(seenOutcome && playerShoots){
					game.camZooming = true;
					#if LEGACY_PSYCH
					game.vocals = new FlxSound();
					switch(songName.toLowerCase()){
						case "blammed-(pico-mix)":
							game.vocals.loadEmbedded(Paths.sound("blammed_solo"));
						case "pico-(pico-mix)":
							game.vocals.loadEmbedded(Paths.sound("pico_solo"));
						case "philly-nice-(pico-mix)":
							game.vocals.loadEmbedded(Paths.sound("philly_solo"));
					}
					#else
					game.opponentVocals = new FlxSound();
					#end
					for (note in game.unspawnNotes){
						if (!note.mustPress && note.eventName == "")
							{
								note.ignoreNote = true;
							}
					} 
				}
			}
			//Dance!
			dad.dance();
			boyfriend.dance();
			gf.dance();

			FlxTween.cancelTweensOf(FlxG.camera);
			FlxTween.cancelTweensOf(camFollow);
			@:privateAccess
			game.moveCameraSection();
			FlxG.camera.scroll.set(camFollow.x - FlxG.width / 2, camFollow.y - FlxG.height / 2);
			FlxG.camera.zoom = defaultCamZoom;
			if(!explode || playerShoots) startCountdown();
		};
		#if LEGACY_PSYCH
		cutsceneHandler.finishCallback2 = function()
		#else
		cutsceneHandler.skipCallback = function()
		#end
		{
			#if !LEGACY_PSYCH cutsceneHandler.finishCallback(); #end
		};
		camFollow_set(dad.x + 280, dad.y + 170);
	}

	function ughIntro()
	{
		prepareCutscene();
		seenOutcome = false;
		// 50/50 chance for who shoots
		if (FlxG.random.bool(50))
		{
			playerShoots = true;
		}
		else
		{
			playerShoots = false;
		}
		if (FlxG.random.bool(8))
		{
			explode = true;
		}
		else
		{
			explode = false;
		}
		cutsceneHandler.endTime = 13;
		cutsceneHandler.music = playerShoots ? 'cutscene/cutscene2' : 'cutscene/cutscene';
		Paths.sound('cutscene/picoCigarette');
		Paths.sound('cutscene/picoExplode');
		Paths.sound('cutscene/picoShoot');
		Paths.sound('cutscene/picoSpin');
		Paths.sound('cutscene/picoCigarette2');
		Paths.sound('cutscene/picoGasp');

		var cigarettePos:Array<Float> = [];
		var shooterPos:Array<Float> = [];
		if (playerShoots == true)
		{
			cigarette.flipX = true;

			addBehindBF(cigarette);
			addBehindBF(bloodPool);
			addBehindBF(imposterPico);
			addBehindBF(pico);

			cigarette.setPosition(boyfriend.x - 143.5, boyfriend.y + 210);
			bloodPool.setPosition(dad.x - 1487, dad.y - 173);

			shooterPos = cameraPos(boyfriend, game.boyfriendCameraOffset);
			cigarettePos = cameraPos(dad, [250, 0]);
		}
		else
		{
			addBehindDad(cigarette);
			addBehindDad(bloodPool);
			addBehindDad(pico);
			addBehindDad(imposterPico);
			bloodPool.setPosition(boyfriend.x - 788.5, boyfriend.y - 173);
			cigarette.setPosition(boyfriend.x - 478.5, boyfriend.y + 205);

			cigarettePos = cameraPos(boyfriend, game.boyfriendCameraOffset);
			shooterPos = cameraPos(dad, [250, 0]);
		}
		var midPoint:Array<Float> = [(shooterPos[0] + cigarettePos[0]) / 2, (shooterPos[1] + cigarettePos[1]) / 2];

		// Allw picos to set their cutscene timers
		imposterPico.doAnim("Opponent", !playerShoots, explode, cutsceneHandler);
		pico.doAnim("Player", playerShoots, explode, cutsceneHandler);

		camFollow_set(midPoint[0], midPoint[1]);

		if (VsliceOptions.SHADERS)
		{
			cutsceneHandler.timer(0.01, () ->
			{
				pico.shader = colorShader;
				imposterPico.shader = colorShader;
				bloodPool.shader = colorShader;
			});
		}

		cutsceneHandler.timer(4, () ->
		{
			camFollow_set(cigarettePos[0], cigarettePos[1]);
		});

		cutsceneHandler.timer(6.3, () ->
		{
			camFollow_set(shooterPos[0], shooterPos[1]);
		});

		cutsceneHandler.timer(8.75, () ->
		{
			seenOutcome = true;
			// cutting off skipping here. really dont think its needed after this point and it saves problems from happening
			camFollow_set(cigarettePos[0], cigarettePos[1]);
		});

		cutsceneHandler.timer(11.2, () ->
		{
			if (explode == true)
			{
				bloodPool.visible = true;
				bloodPool.anim.play("bloodPool", true);
			}
		});

		cutsceneHandler.timer(11.5, () ->
		{
			if (explode == false)
			{
				cigarette.visible = true;
				cigarette.animation.play('cigarette spit');
			}
		});
	}

	function cameraPos(char:Character, camOffset:Array<Float>)
	{
		var point = new FlxPoint(char.getMidpoint().x - 100, char.getMidpoint().y - 100);
		point.x -= char.cameraPosition[0] - camOffset[0];
		point.y += char.cameraPosition[1] + camOffset[1];
		return [point.x, point.y];
	}
}
