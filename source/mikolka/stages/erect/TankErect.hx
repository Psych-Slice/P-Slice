package mikolka.stages.erect;

import mikolka.stages.objects.PicoCapableStage;
import objects.Character;
import mikolka.compatibility.VsliceOptions;
import shaders.DropShadowShader;

// tankmanBattlefieldErect
class TankErect extends BaseStage
{
	var sniper:FlxSprite;
	var guy:FlxSprite;
	var tankmanRim:DropShadowShader;
	var tankmanRun:FlxTypedGroup<TankmenBG>;

	override function create()
	{
		super.create();

		var bg:BGSprite = new BGSprite('erect/bg', -985, -805, 1, 1);
		bg.scale.set(1.15, 1.15);
		add(bg);

		sniper = new FlxSprite(-346, 245);
		sniper.frames = Paths.getSparrowAtlas('erect/sniper');
		sniper.animation.addByPrefix("idle", "Tankmanidlebaked instance 1", 24);
		sniper.animation.addByPrefix("sip", "tanksippingBaked instance 1", 24);
		sniper.scale.set(1.15, 1.15);
		add(sniper);

		guy = new FlxSprite(1175, 270);
		guy.frames = Paths.getSparrowAtlas('erect/guy');
		guy.animation.addByPrefix("idle", "BLTank2 instance 1", 24);
		guy.scale.set(1.15, 1.15);
		add(guy);

		tankmanRun = new FlxTypedGroup<TankmenBG>();
		add(tankmanRun);
		if (songName == "stress-(pico-mix)" && !seenCutscene)
		{
			setStartCallback(videoCutscene.bind('stressPicoCutscene'));

			// setEndCallback(function()
			// {
			// 	game.endingSong = true;
			// 	inCutscene = true;
			// 	canPause = false;
			// 	FlxTransitionableState.skipNextTransIn = true;
			// 	FlxG.camera.visible = false;
			// 	camHUD.visible = false;
			// 	game.startVideo('2hotCutscene');
			// });
		}
	}

	override function beatHit()
	{
		super.beatHit();
		if (curBeat % 2 == 0)
		{
			sniper.animation.play('idle', true);
			guy.animation.play('idle', true);
		}
		if (FlxG.random.bool(2))
			sniper.animation.play('sip', true);
		if (songName.toLowerCase() == "stress (pico mix)")
		{
			// We gonna have some events here
		}
	}

	override function createPost()
	{
		if (VsliceOptions.SHADERS)
		{
			applyShader(boyfriend, boyfriend.curCharacter);
			applyShader(gf, gf.curCharacter);
			applyShader(dad, dad.curCharacter);
			if (PicoCapableStage.instance?.abot != null)
				applyShader(PicoCapableStage.instance.abot, "abot");
		}
		if (!VsliceOptions.LOW_QUALITY)
		{
			for (daGf in gfGroup)
			{
				var gf:Character = cast daGf;
				if (gf.curCharacter == 'otis-speaker')
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					applyShader(firstTank, "");
					firstTank.resetShit(20, 1500, true);
					firstTank.strumTime = 10;
					firstTank.visible = false;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length)
					{
						if (FlxG.random.bool(16))
						{
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
					break;
				}
			}
		}
	}

	var videoEnded:Bool = false;

	function videoCutscene(?videoName:String = null)
	{
		game.inCutscene = true;
		if (!videoEnded && videoName != null)
		{
			#if VIDEOS_ALLOWED
			game.startVideo(videoName);
			game.videoCutscene.finishCallback = game.videoCutscene.onSkip = function()
			{
				videoEnded = true;
				game.videoCutscene = null;
				videoCutscene();
			};
			#else // Make a timer to prevent it from crashing due to sprites not being ready yet.
			new FlxTimer().start(0.0, function(tmr:FlxTimer)
			{
				videoEnded = true;
				videoCutscene(videoName);
			});
			#end
			return;
		}
		startCountdown();
	}
	function applyShader(sprite:FlxSprite, char_name:String)
	{
		var rim = new DropShadowShader();
		rim.setAdjustColor(-46, -38, -25, -20);
		rim.color = 0xFFDFEF3C;
		rim.antialiasAmt = 0;
		rim.attachedSprite = sprite;
		rim.distance = 5;
		switch (char_name)
		{
			case "bf":
				{
					rim.angle = 90;
					sprite.shader = rim;

					sprite.animation.callback = function(anim, frame, index)
					{
						rim.updateFrameInfo(sprite.frame);
					};
				}
			case "gf-tankmen":
				{
					rim.setAdjustColor(-42, -10, 5, -25);
					rim.angle = 90;
					sprite.shader = rim;
					rim.distance = 3;
					rim.threshold = 0.3;
					rim.altMaskImage = Paths.image("erect/masks/gfTankmen_mask").bitmap;
					rim.maskThreshold = 1;
					rim.useAltMask = true;

					sprite.animation.callback = function(anim, frame, index)
					{
						rim.updateFrameInfo(sprite.frame);
					};
				}

			case "tankman-bloody":
				{
					rim.angle = 135;
					sprite.shader = rim;
					rim.altMaskImage = Paths.image("erect/masks/tankmanCaptainBloody_mask").bitmap;
					rim.threshold = 0.3;
					rim.maskThreshold = 1;
					rim.useAltMask = false;

					sprite.animation.callback = function(anim, frame, index)
					{
						rim.updateFrameInfo(sprite.frame);
					};
				}
			case "nene":
				{
					rim.threshold = 0.1;
					rim.angle = 90;
					sprite.shader = rim;
					sprite.animation.callback = function(anim, frame, index)
					{
						rim.updateFrameInfo(sprite.frame);
					};
				}
			default:
				{
					rim.angle = 90;
					sprite.shader = rim;
					sprite.animation.callback = function(anim, frame, index)
					{
						rim.updateFrameInfo(sprite.frame);
					};
				}
		}
	}
}
