package mikolka.stages.cutscenes;

import openfl.filters.ShaderFilter;
import cutscenes.CutsceneHandler;
import shaders.DropShadowScreenspace;
import mikolka.stages.erect.TankErect;

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
		tankmanEnding = new FlxAtlasSprite(0,0,"assets/week7/images/philly/erect/cutscenes/pico_doppleganger");
		cutsceneSounds = new FlxSound().loadEmbedded(Paths.sound('erect/endCutscene'));
		bgSprite = new FunkinSprite(0, 0);
		bgSprite.makeSolidColor(2000, 2500, 0xFF000000);
		bgSprite.cameras = [stage.camOther]; // Show over the HUD but below the video.
		bgSprite.alpha = 0;
		stage.add(bgSprite);
	}
	var cutscene:CutsceneHandler;
	var stage:TankErect;
	var shaderCamera:ShaderFilter;
	var tankmanEnding:FlxAtlasSprite;
	var cutsceneSounds:FlxSound;
	var bgSprite:FunkinSprite;

	public function playCutscene() {
		cutscene = new CutsceneHandler();
		var tankmanPos:Array<Float> = [500,500];
		cutscene.endTime = 320/24;
		cutscene.onStart = () -> {
			var rimlightCamera = new FlxCamera();
    		FlxG.cameras.insert(rimlightCamera, -1, false);
    		rimlightCamera.bgColor = 0x00FFFFFF; // Show the game scene behind the camera.

			rimlightCamera.filters = [shaderCamera];
			FlxTween.tween(camHUD,{alpha:0},1);
			FlxTween.tween(game.camFollow,{ x:tankmanPos[0] + 320, y:tankmanPos[1] - 70}, 2.8, { ease:FlxEase.expoOut});
			defaultCamZoom = 0.65;
			tankmanEnding.playAnimation("tankman stress ending", true, false, false);
    		cutsceneSounds.play();
		};
		cutscene.timer(176/24,() ->{
			boyfriend.playAnim("laughEnd",true);
		});
		cutscene.timer(270/24,() ->{
			FlxTween.tween(game.camFollow,{ x:tankmanPos[0] + 320, y:tankmanPos[1] - 370}, 2, { ease:FlxEase.quadInOut});
      		FlxTween.tween(bgSprite, {alpha: 1}, 2, null);
		});
		return false;
	}
}