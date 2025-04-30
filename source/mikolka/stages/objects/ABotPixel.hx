package mikolka.stages.objects;

import mikolka.compatibility.ModsHelper;
#if funkin.vis
import funkin.vis.dsp.SpectralAnalyzer;
#end

class ABotPixel extends FlxSpriteGroup
{
	final VIZ_MAX = 7; //ranges from viz1 to viz7
	final VIZ_POS_X:Array<Float> = [0, 7 * 6, 8 * 6, 9 * 6, 10 * 6, 6 * 6, 7 * 6];
	final VIZ_POS_Y:Array<Float> = [0, -2 * 6, -1 * 6, 0, 0, 1 * 6, 2 * 6];

	public var bg:FlxSprite;
	public var vizSprites:Array<FlxSprite> = [];
	public var eyeBg:FlxSprite;
	public var eyes:FlxSprite;
	public var speakerTop:FlxSprite;
	public var speaker:FlxSprite;

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

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		speakerTop = new FlxSprite(-65, -10);
		speakerTop.frames = Paths.getSparrowAtlas('abot/pixel/aBotPixelSpeaker');
		speakerTop.scale.set(6, 6);
		speakerTop.animation.addByPrefix("anim","bop",24,false);
		speakerTop.animation.play('anim', true);
		speakerTop.animation.frameIndex = speakerTop.animation.curAnim.numFrames - 1;
		speakerTop.antialiasing = false;
		speakerTop.updateHitbox();
		add(speakerTop);

		bg = new FlxSprite(90, 20).loadGraphic(Paths.image('abot/pixel/aBotPixelBack'));
        bg.scale.set(6, 6);
		bg.antialiasing = false;
		bg.updateHitbox();
		add(bg);

		var vizX:Float = 0;
		var vizY:Float = 0;
		var vizFrames = Paths.getSparrowAtlas('abot/pixel/aBotVizPixel');
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
			viz.antialiasing = false;
            viz.scale.set(6, 6);
			vizSprites.push(viz);
			viz.updateHitbox();
			viz.centerOffsets();
			add(viz);
		}

		eyes = new FlxSprite(-60, 80);
        eyes.frames = Paths.getSparrowAtlas('abot/pixel/abotHead');
        eyes.scale.set(6, 6);
		eyes.animation.addByPrefix('lookleft', 'toleft', 24, false);
		eyes.animation.addByPrefix('lookright', 'toright', 24, false);
		eyes.animation.play('lookright', true);
		eyes.animation.frameIndex = eyes.animation.curAnim.numFrames - 1;
		eyes.updateHitbox();
		add(eyes);

		speaker = abotLol();
	}
	function abotLol() {
		var temp = new FlxSprite(65, -10);
        temp.frames = Paths.getSparrowAtlas('abot/pixel/aBotPixelBody');
		temp.scale.set(6, 6);
		temp.animation.addByPrefix("anim","bop",24,false);
		temp.animation.play('anim', true);
		temp.animation.frameIndex = temp.animation.curAnim.numFrames - 1;
		temp.antialiasing = false;
		temp.updateHitbox();
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
			if(oldLevelMax <= levelMax && (levelMax >= 5 || speaker.animation.frameIndex >= 3))
				beatHit();
		}
	}
	#end

	public function beatHit()
	{
		speakerTop.animation.play('anim', true);
	}

	#if funkin.vis
	public function initAnalyzer()
	{
		@:privateAccess
		analyzer = new SpectralAnalyzer(ModsHelper.getSoundChannel(snd), 7, 0.1, 40);
	
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
		if(lookingAtRight) eyes.animation.play('lookleft', true);
		lookingAtRight = false;
	}
	public function lookRight()
	{
		if(!lookingAtRight) eyes.animation.play('lookright', true);
		lookingAtRight = true;
	}
}
