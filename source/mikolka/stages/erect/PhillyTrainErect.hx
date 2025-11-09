package mikolka.stages.erect;

import mikolka.stages.cutscenes.TwoPicos;
import mikolka.stages.scripts.PicoCapableStage;
import flixel.FlxSubState;
import mikolka.stages.objects.PhillyLights;
import shaders.AdjustColorShader;
import mikolka.compatibility.VsliceOptions;

class PhillyTrainErect extends BaseStage
{
	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:PhillyTrain;
	var curLight:Int = -1;

	var cutsceneObj:TwoPicos;

	var curLightEvent:Int = -1;
	var colorShader:AdjustColorShader;

	override function create()
	{
		if (!VsliceOptions.LOW_QUALITY)
		{
			var bg:BGSprite = new BGSprite('philly/erect/sky', -50, 0, 0.1, 0.1);
			add(bg);
		}

		var city:BGSprite = new BGSprite('philly/erect/city', -255, 45, 0.3, 0.3);
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
			var streetBehind:BGSprite = new BGSprite('philly/erect/behindTrain', 178, 148);
			add(streetBehind);
		}

		phillyTrain = new PhillyTrain(2000, 360);
		add(phillyTrain);

		phillyStreet = new BGSprite('philly/erect/street', -299, 144);
		add(phillyStreet);

		if (VsliceOptions.SHADERS)
		{
			colorShader = new AdjustColorShader();
			colorShader.hue = -26;
			colorShader.saturation = -16;
			colorShader.contrast = 0;
			colorShader.brightness = -5;
		}

		if (!seenCutscene && PlayState.SONG.player1 == "pico-playable" && PlayState.SONG.player2 == "pico"){
			cutsceneObj = new TwoPicos(this, colorShader);
			setStartCallback(cutsceneObj.startCutscene);
		}

		new PhillyLights(phillyStreet, phillyWindow.x, phillyWindow.y, phillyLightsColors);
	}

	override function createPost()
	{
		super.createPost();

		if (VsliceOptions.SHADERS)
		{
			boyfriend.shader = colorShader;
			dad.shader = colorShader;
			gf.shader = colorShader;
			phillyTrain.shader = colorShader;
			PicoCapableStage.instance?.applyABotShader(colorShader);
		}
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		if (eventName == "Change Character" && VsliceOptions.SHADERS)
		{
			switch (value1.toLowerCase().trim())
			{
				case 'gf' | 'girlfriend' | '2':
					gf.shader = colorShader;
				case 'dad' | 'opponent' | '1':
					dad.shader = colorShader;
				default:
					boyfriend.shader = colorShader;
			}
		}
		else if (eventName == "Philly Glow" && cutsceneObj != null)
		{
        	if(flValue1 == null || flValue1 <= 0) flValue1 = 0;
            var lightId:Int = Math.round(flValue1);
            switch(lightId){
				case 0: //off
					cutsceneObj.imposterPico.color = 0xFFFFFFFF;
				case 1: //on
					cutsceneObj.imposterPico.color = dad.color;
			}
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

	override function openSubState(SubState:FlxSubState)
	{
		if (phillyTrain.sound?.playing)
		{
			phillyTrain.sound.pause();
			PlayState.instance.subStateClosed.addOnce((sub) ->
			{
				if (phillyTrain.sound != null)
					phillyTrain.sound.resume();
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
}
