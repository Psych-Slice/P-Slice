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

	//For Philly Glow events
	var blammedLightsBlack:FlxSprite;
	var phillyGlowGradient:PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlowParticle>;
	var phillyWindowEvent:BGSprite;
	var curLightEvent:Int = -1;

	override function create()
	{
		if(!VsliceOptions.LOW_QUALITY) {
			var bg:BGSprite = new BGSprite('philly/erect/sky', -100, 0, 0.1, 0.1);
			add(bg);
		}

		var city:BGSprite = new BGSprite('philly/erect/city', -10, 0, 0.3, 0.3);
		city.setGraphicSize(Std.int(city.width * 0.85));
		city.updateHitbox();
		add(city);

		phillyLightsColors = [0x502d64,0x2663ac,0x932c28,0x329a6d,0xb66f43];
		phillyWindow = new BGSprite('philly/window', city.x, city.y, 0.3, 0.3);
		phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
		phillyWindow.updateHitbox();
		add(phillyWindow);
		phillyWindow.alpha = 0;

		if(!VsliceOptions.LOW_QUALITY) {
			var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
			add(streetBehind);
		}

		phillyTrain = new PhillyTrain(2000, 360);
		add(phillyTrain);

		phillyStreet = new BGSprite('philly/erect/street', -40, 50);
		add(phillyStreet);
	}

	override function createPost() {
		super.createPost();
		if(VsliceOptions.SHADERS){
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
		if(phillyGlowParticles != null)
		{
			phillyGlowParticles.forEachAlive(function(particle:PhillyGlowParticle)
			{
				if(particle.alpha <= 0)
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
		if(!VsliceOptions.FLASHBANG) color.alphaFloat = 0.5;

		FlxG.camera.flash(color, 0.15, null, true);
	}
}
