package mikolka.stages.cutscenes;

import openfl.filters.ShaderFilter;
import shaders.DropShadowScreenspace;
import mikolka.stages.erect.TankErect;
#if !LEGACY_PSYCH
import cutscenes.CutsceneHandler;
#end

class PicoTankman {
    public function new(stage:TankErect) {
        this.stage = stage;
    }
    public function preloadCutscene() {
		var shader = new DropShadowScreenspace();
		shader.baseBrightness = -46;
		shader.baseHue = -38;
		shader.baseContrast = -25;
		shader.baseSaturation = -20;
    	shader.angle = 45;
		shader.threshold = 0.3;
		shaderCamera = new ShaderFilter(shader);
		tankmanEnding = new FlxAtlasSprite(520,350,"assets/week7/images/erect/cutscene/tankmanEnding");
		cutsceneSounds = new FlxSound().loadEmbedded(Paths.sound('erect/endCutscene'));
		bgSprite = new FunkinSprite(0, 0);
		bgSprite.makeSolidColor(2000, 2500, 0xFF000000);
		bgSprite.cameras = [stage.camOther]; // Show over the HUD but below the video.
		bgSprite.alpha = 0;
		PlayState.instance.add(bgSprite);
	}
	var cutscene:CutsceneHandler;
	var stage:TankErect;
	var shaderCamera:ShaderFilter;
	var tankmanEnding:FlxAtlasSprite;
	var cutsceneSounds:FlxSound;
	var bgSprite:FunkinSprite;

	public function playCutscene() {
		var game = PlayState.instance;
		cutscene = new CutsceneHandler();
		FlxG.sound.list.add(cutsceneSounds);
		cutsceneSounds.play();
		var tankmanPos:Array<Float> = [500,500];
		cutscene.endTime = 320/24;
		cutscene.onStart = () -> {
			FlxTween.tween(game.camHUD,{alpha:0},1);
			FlxTween.tween(game.camFollow,{ x:tankmanPos[0] + 320, y:tankmanPos[1] - 70}, 2.8, { ease:FlxEase.expoOut});
			game.defaultCamZoom = 0.65;
			game.dad.visible = false;
			tankmanEnding.playAnimation("tankman stress ending", true, false, false);
    		cutsceneSounds.play();
		};
		cutscene.finishCallback = () ->{
			game.endSong();
		};
		#if LEGACY_PSYCH
		cutscene.finishCallback2 = function()
		#else
		cutscene.skipCallback = function()
		#end
		{
			game.endSong();
		};
		cutscene.timer(176/24,() ->{
			stage.boyfriend.playAnim("laughEnd",true);
		});
		cutscene.timer(270/24,() ->{
			FlxTween.tween(game.camFollow,{ x:tankmanPos[0] + 320, y:tankmanPos[1] - 370}, 2, { ease:FlxEase.quadInOut});
      		FlxTween.tween(bgSprite, {alpha: 1}, 2, null);
		});
		var rimlightCamera = new FlxCamera();
    	rimlightCamera.bgColor = 0x00FFFFFF; // Show the game scene behind the camera.
		
		#if LEGACY_PSYCH
		rimlightCamera.setFilters([shaderCamera]);
    	FlxG.cameras.list.insert(FlxG.cameras.list.indexOf(game.camHUD),rimlightCamera);
		#else
		rimlightCamera.filters = [shaderCamera];
    	FlxG.cameras.insert(rimlightCamera, FlxG.cameras.list.indexOf(game.camHUD), false);
		#end
		@:privateAccess{
			stage.applyAbotShader(tankmanEnding);
			game.canPause = false;
		}
		game.add(tankmanEnding);
		cutscene.objects.push(tankmanEnding);
		game.inCutscene = true;
	}
}