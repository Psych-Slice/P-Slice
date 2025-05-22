package mikolka.stages.cutscenes;

#if !LEGACY_PSYCH
import objects.Character;
import cutscenes.CutsceneHandler;
#end
import mikolka.compatibility.VsliceOptions;
import mikolka.stages.objects.PicoDopplegangerSprite;
import mikolka.stages.erect.PhillyTrainErect;

class TwoPicos {
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
	var host:BaseStage;
	var shader:FlxShader;

	public function new(host:BaseStage,shader:FlxShader) {
		this.host = host;
		this.shader = shader;
	}

	function prepareCutscene()
	{
		cutsceneHandler = new CutsceneHandler();
		var game = PlayState.instance;

		host.boyfriend.visible = host.dad.visible = false;
		host.camHUD.visible = false;
		// inCutscene = true; //this would stop the camera movement, oops

		imposterPico = new PicoDopplegangerSprite(host.dad.x + 82, host.dad.y + 400);
		imposterPico.showPivot = false;
		imposterPico.antialiasing = VsliceOptions.ANTIALIASING;
		cutsceneHandler.push(imposterPico);

		pico = new PicoDopplegangerSprite(host.boyfriend.x + 48.5, host.boyfriend.y + 400);
		pico.showPivot = false;
		pico.antialiasing = VsliceOptions.ANTIALIASING;
		cutsceneHandler.push(pico);

		if(VsliceOptions.NAUGHTYNESS){

			bloodPool = new FlxAnimate(0, 0);
			bloodPool.visible = false;
			Paths.loadAnimateAtlas(bloodPool, "philly/erect/cutscenes/bloodPool");
		}

		cigarette = new FlxSprite();
		cigarette.frames = Paths.getSparrowAtlas('philly/erect/cutscenes/cigarette');
		cigarette.animation.addByPrefix('cigarette spit', 'cigarette spit', 24, false);
		cigarette.visible = false;

		cutsceneHandler.finishCallback = function()
		{
			host.seenCutscene = true;
			//Restore camera
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: host.defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});

			//Show still alive chars
			if (explode)
				{
					if (playerShoots) host.boyfriend.visible = true;
					else host.dad.visible = true;
				}
			else host.boyfriend.visible = host.dad.visible = true;
			
			host.camHUD.visible = true;

			//Crear callbacks
			host.boyfriend.animation.finishCallback = null;
			host.gf.animation.finishCallback = null;
	
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
						host.dad.visible = true;
					}
				}
				else{

					if(seenOutcome){
						pico.playAnimation("loopPlayer", true, true, true);
						game.endSong();
					}
					else{
						pico.kill();
						game.remove(pico);
						pico.destroy();
						host.boyfriend.visible = true;
					}
				}
				if(seenOutcome && playerShoots){
					game.camZooming = true;
					#if LEGACY_PSYCH
					game.vocals = new FlxSound();
					switch(host.songName.toLowerCase()){
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
			host.dad.dance();
			host.boyfriend.dance();
			host.gf.dance();

			FlxTween.cancelTweensOf(FlxG.camera);
			FlxTween.cancelTweensOf(host.camFollow);
			@:privateAccess
			game.moveCameraSection();
			FlxG.camera.scroll.set(host.camFollow.x - FlxG.width / 2, host.camFollow.y - FlxG.height / 2);
			FlxG.camera.zoom = host.defaultCamZoom;
			if(!explode || playerShoots) game.startCountdown();
		};
		#if LEGACY_PSYCH
		cutsceneHandler.finishCallback2 = function()
		#else
		cutsceneHandler.skipCallback = function()
		#end
		{
			#if !LEGACY_PSYCH cutsceneHandler.finishCallback(); #end
		};
		host.camFollow_set(host.dad.x + 280, host.dad.y + 170);
	}

	public function startCutscene()
	{
		prepareCutscene();
		var game = PlayState.instance;

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
		if (#if pico_always_kill true #else FlxG.random.bool(8) #end)
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

			host.addBehindBF(cigarette);
			if(VsliceOptions.NAUGHTYNESS) host.addBehindBF(bloodPool);
			host.addBehindBF(imposterPico);
			host.addBehindBF(pico);

			cigarette.setPosition(host.boyfriend.x - 143.5, host.boyfriend.y + 210);
			if(VsliceOptions.NAUGHTYNESS) bloodPool.setPosition(host.dad.x - 1487, host.dad.y - 173);

			shooterPos = cameraPos(host.boyfriend, game.boyfriendCameraOffset);
			cigarettePos = cameraPos(host.dad, [250, 0]);
		}
		else
		{
			host.addBehindDad(cigarette);
			if(VsliceOptions.NAUGHTYNESS) host.addBehindDad(bloodPool);
			host.addBehindDad(pico);
			host.addBehindDad(imposterPico);
			if(VsliceOptions.NAUGHTYNESS) bloodPool.setPosition(host.boyfriend.x - 788.5, host.boyfriend.y - 173);
			cigarette.setPosition(host.boyfriend.x - 478.5, host.boyfriend.y + 205);

			cigarettePos = cameraPos(host.boyfriend, game.boyfriendCameraOffset);
			shooterPos = cameraPos(host.dad, [250, 0]);
		}
		var midPoint:Array<Float> = [(shooterPos[0] + cigarettePos[0]) / 2, (shooterPos[1] + cigarettePos[1]) / 2];

		// Allw picos to set their cutscene timers
		imposterPico.doAnim("Opponent", !playerShoots, explode, cutsceneHandler);
		pico.doAnim("Player", playerShoots, explode, cutsceneHandler);

		host.camFollow_set(midPoint[0], midPoint[1]);

		if (VsliceOptions.SHADERS)
		{
			cutsceneHandler.timer(0.01, () ->
			{
				pico.shader = shader;
				imposterPico.shader = shader;
				if(VsliceOptions.NAUGHTYNESS) bloodPool.shader = shader;
			});
		}

		cutsceneHandler.timer(4, () ->
		{
			host.camFollow_set(cigarettePos[0], cigarettePos[1]);
		});

		cutsceneHandler.timer(6.3, () ->
		{
			host.camFollow_set(shooterPos[0], shooterPos[1]);
		});

		cutsceneHandler.timer(8.75, () ->
		{
			seenOutcome = true;
			// cutting off skipping here. really dont think its needed after this point and it saves problems from happening
			host.camFollow_set(cigarettePos[0], cigarettePos[1]);
		});

		cutsceneHandler.timer(11.2, () ->
		{
			if (explode == true && VsliceOptions.NAUGHTYNESS)
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