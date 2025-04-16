package states.stages.objects;

#if funkin.vis
import funkin.vis.dsp.SpectralAnalyzer;
#end
import shaders.AdjustColorShader; //Golden Fungus
import mikolka.compatibility.VsliceOptions; //Golden Fungus

class ABotSpeaker extends FlxSpriteGroup
{
	final VIZ_MAX = 7; //ranges from viz1 to viz7
	final VIZ_POS_X:Array<Float> = [0, 59, 56, 66, 54, 52, 51];
	final VIZ_POS_Y:Array<Float> = [0, -8, -3.5, -0.4, 0.5, 4.7, 7];

	public var bg:FlxSprite;
	public var vizSprites:Array<FlxSprite> = [];
	public var eyeBg:FlxSprite;
	public var eyes:FlxAnimate;
	public var speaker:FlxAnimate;
	public var speakerAlt:FlxAnimate;
	var aboyShaders = new AdjustColorShader();
	var game = PlayState.instance;

	#if funkin.vis
	var analyzer:SpectralAnalyzer;
	#end
	var volumes:Array<Float> = [];

	public var snd(default, set):FlxSound;
	function set_snd(changed:FlxSound)
	{
		snd = changed;
		#if funkin.vis
		initAnalyzer();
		#end
		return snd;
	}

	public function new(x:Float = 0, y:Float = 0,useDark:Bool = false)
	{
		super(x, y);
		var songName = game.songName;

		//gives Abot shaders on levels that have them, this was a very noticible thing
		if(VsliceOptions.SHADERS){
			switch(songName){
				case 'bopeebo-(pico-mix)' | 'fresh-(pico-mix)' | 'dad-battle-(pico-mix)':
					shaders.hue = -9;
        				shaders.saturation = 0;
        				shaders.brightness = -30;
        				shaders.contrast = -4;
				case 'pico-(pico-mix)' | 'philly-nice-(pico-mix)' | 'blammed-(pico-mix)':
					shaders.hue = -26;
					shaders.saturation = -16;
					shaders.contrast = 0;
					shaders.brightness = -5;
				case 'satin-panties-(pico-mix)' | 'high-(pico-mix)' | 'milf-(pico-mix)': //GoldenFungus: futureproofing
					shaders.hue = -30;
					shaders.saturation = -20;
					shaders.contrast = 0;
					shaders.brightness = -30;
				case 'cocoa-(pico-mix)' | 'eggnog-(pico-mix)' | 'winter-horrorland-(pico-mix)': //GoldenFungus: This is assuming that winter horrorland wont have different shaders
					shaders.hue = 5;
					shaders.saturation = 20;
				/*case 'ugh-(pico-mix)' | 'guns-(pico-mix)' | 'stress-(pico-mix)': //GoldenFungus: this is just here for when this stage is added
					shaders.hue = -38;
					shaders.saturation = -20;
					shaders.contrast = -25;
					shaders.brightness = -46;*/
				case 'darnell-erect'| 'lit-up-erect' | '2hot-erect':
					shaders.hue = -5;
                			shaders.saturation = -40;
                			shaders.contrast = -25;
                			shaders.brightness = -20;
			}
		}

		var antialias = ClientPrefs.data.antialiasing;
		bg = new FlxSprite(90, 20).loadGraphic(Paths.image('abot/stereoBG'));
		bg.antialiasing = antialias;
		bg.shader = shaders;//GF
		add(bg);

		var vizX:Float = 0;
		var vizY:Float = 0;
		var vizFrames = Paths.getSparrowAtlas('abot/aBotViz');
		for (i in 1...VIZ_MAX+1)
		{
			volumes.push(0.0);
			vizX += VIZ_POS_X[i-1];
			vizY += VIZ_POS_Y[i-1];
			var viz:FlxSprite = new FlxSprite(vizX + 140, vizY + 74);
			viz.frames = vizFrames;
			viz.animation.addByPrefix('VIZ', 'viz$i', 0);
			viz.animation.play('VIZ', true);
			viz.animation.curAnim.finish(); //make it go to the lowest point
			viz.antialiasing = antialias;
			viz.shader = shaders;//GF
			vizSprites.push(viz);
			viz.updateHitbox();
			viz.centerOffsets();
			add(viz);
		}

		eyeBg = new FlxSprite(-30, 215).makeGraphic(1, 1, FlxColor.WHITE);
		eyeBg.scale.set(160, 60);
		eyeBg.updateHitbox();
		eyeBg.shader = shaders;//GF
		add(eyeBg);

		eyes = new FlxAnimate(-10, 230);
		Paths.loadAnimateAtlas(eyes, 'abot/systemEyes');
		eyes.anim.addBySymbolIndices('lookleft', 'a bot eyes lookin', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17], 24, false);
		eyes.anim.addBySymbolIndices('lookright', 'a bot eyes lookin', [18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35], 24, false);
		eyes.anim.play('lookright', true);
		eyes.anim.curFrame = eyes.anim.length - 1;
		eyes.shader = shaders;//GF
		add(eyes);

		speaker = abotLol(useDark);
		if(useDark) {
			speakerAlt = abotLol(false);
			speakerAlt.alpha = 0;
		}
	}
	function abotLol(useDark:Bool) {
		var temp = new FlxAnimate(-65, -10);
		Paths.loadAnimateAtlas(temp, '${useDark? "abot/dark" : "abot"}/abotSystem');
		temp.anim.addBySymbol('anim', 'Abot System', 24, false);
		temp.anim.play('anim', true);
		temp.anim.curFrame = temp.anim.length - 1;
		temp.antialiasing = ClientPrefs.data.antialiasing;
		temp.shader = shaders;//GF
		add(temp);
		return temp;
	}
	#if funkin.vis
	var levels:Array<Bar>;
	var levelMax:Int = 0;
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if(analyzer == null) return;

		levels = analyzer.getLevels(levels);
		var oldLevelMax = levelMax;
		levelMax = 0;
		for (i in 0...Std.int(Math.min(vizSprites.length, levels.length)))
		{
			var animFrame:Int = Math.round(levels[i].value * 5);
			animFrame = Std.int(Math.abs(FlxMath.bound(animFrame, 0, 5) - 5)); // shitty dumbass flip, cuz dave got da shit backwards lol!
		
			vizSprites[i].animation.curAnim.curFrame = animFrame;
			levelMax = Std.int(Math.max(levelMax, 5 - animFrame));
		}

		if(levelMax >= 4)
		{
			//trace(levelMax);
			if(oldLevelMax <= levelMax && (levelMax >= 5 || speaker.anim.curFrame >= 3))
				beatHit();
		}
	}
	#end

	public function beatHit()
	{
		speaker.anim.play('anim', true);
		speakerAlt?.anim.play('anim', true);
	}

	#if funkin.vis
	public function initAnalyzer()
	{
		@:privateAccess
		analyzer = new SpectralAnalyzer(snd._channel.__audioSource, 7, 0.1, 40);
	
		#if !web
		// On native it uses FFT stuff that isn't as optimized as the direct browser stuff we use on HTML5
		// So we want to manually change it!
		analyzer.fftN = 256;
		#end
	}
	#end

	var lookingAtRight:Bool = true;
	public function lookLeft()
	{
		if(lookingAtRight) eyes.anim.play('lookleft', true);
		lookingAtRight = false;
	}
	public function lookRight()
	{
		if(!lookingAtRight) eyes.anim.play('lookright', true);
		lookingAtRight = true;
	}
}
