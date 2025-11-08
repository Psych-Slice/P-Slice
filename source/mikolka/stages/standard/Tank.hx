package mikolka.stages.standard;


import mikolka.stages.cutscenes.TankStageScenes;
import mikolka.stages.objects.TankmenBG;
#if !LEGACY_PSYCH
import cutscenes.CutsceneHandler;
import substates.GameOverSubstate;
import objects.Character;
#end
import mikolka.compatibility.VsliceOptions;


class Tank extends BaseStage
{
	public var foregroundSprites:FlxTypedGroup<BGSprite>;
	var tankWatchtower:BGSprite;
	var tankGround:BackgroundTank;
	var tankmanRun:FlxTypedGroup<TankmenBG>;

	override function create()
	{
		var sky:BGSprite = new BGSprite('tankSky', -500, -400, 0, 0);
		sky.scale.x = 6000;
		add(sky);

		if(!VsliceOptions.LOW_QUALITY)
		{
			var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
			clouds.active = true;
			clouds.velocity.x = FlxG.random.float(5, 15);
			add(clouds);

			var mountains:BGSprite = new BGSprite('tankMountains', -500, -35, 0.2, 0.2);
			mountains.setGraphicSize(Std.int(1.2 * mountains.width));
			mountains.updateHitbox();
			add(mountains);

			var buildings:BGSprite = new BGSprite('tankBuildings', -260, -35, 0.3, 0.3);
			buildings.setGraphicSize(Std.int(1.1 * buildings.width));
			buildings.updateHitbox();
			add(buildings);
		}

		var ruins:BGSprite = new BGSprite('tankRuins',-200, 150,0.35,0.35);
		ruins.setGraphicSize(Std.int(1.1 * ruins.width));
		ruins.updateHitbox();
		add(ruins);

		if(!VsliceOptions.LOW_QUALITY)
		{
			var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
			add(smokeLeft);
			var smokeRight:BGSprite = new BGSprite('smokeRight', 1050, -35, 0.4, 0.4, ['SmokeRight'], true);
			add(smokeRight);

			tankWatchtower = new BGSprite('tankWatchtower', -35, 110, 0.5, 0.5, ['watchtower gradient color']);
			add(tankWatchtower);
		}

		tankGround = new BackgroundTank();
		add(tankGround);

		tankmanRun = new FlxTypedGroup<TankmenBG>();
		add(tankmanRun);

		var ground:BGSprite = new BGSprite('tankGround', -420, 534);
		ground.setGraphicSize(Std.int(1.15 * ground.width));
		ground.updateHitbox();
		add(ground);

		foregroundSprites = new FlxTypedGroup<BGSprite>();
		foregroundSprites.add(new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']));
		if(!VsliceOptions.LOW_QUALITY) foregroundSprites.add(new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']));
		foregroundSprites.add(new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']));
		if(!VsliceOptions.LOW_QUALITY) foregroundSprites.add(new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']));
		foregroundSprites.add(new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']));
		if(!VsliceOptions.LOW_QUALITY) foregroundSprites.add(new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']));

		// Default GFs
		if(songName == 'stress') setDefaultGF('pico-speaker');
		else setDefaultGF('gf-tankmen');
		
		if (isStoryMode && !seenCutscene)
		{
			var cutscene = new TankStageScenes(this);
			switch (songName.toLowerCase())
			{
				case 'ugh':
					setStartCallback(cutscene.ughIntro);
				case 'guns':
					setStartCallback(cutscene.gunsIntro);
				case 'stress':
					setStartCallback(cutscene.stressIntro);
			}
		}
		super.create();
	}
	override function createPost()
	{
		super.createPost();
		add(foregroundSprites);

		if(!VsliceOptions.LOW_QUALITY)
		{
			var bricks:BGSprite = new BGSprite('bricksGround', 438, 715, 1, 1);
			bricks.scale.set(1.15, 1.15);
			addBehindDad(bricks);
			for (daGf in gfGroup)
			{
				var gf:Character = cast daGf;
				if(gf.curCharacter == 'pico-speaker')
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 1500, true,true);
					firstTank.strumTime = 10;
					firstTank.visible = false;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length)
					{
						if(FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2,true);
							tankmanRun.add(tankBih);
						}
					}
					break;
				}
			}
		}
	}

	override function countdownTick(count:Countdown, num:Int) if(num % 2 == 0) everyoneDance();
	override function beatHit() {
		everyoneDance();
		super.beatHit();
	}
	function everyoneDance()
	{
		if(!VsliceOptions.LOW_QUALITY) tankWatchtower.dance();
		foregroundSprites.forEach(function(spr:BGSprite)
		{
			spr.dance();
		});
	}
}