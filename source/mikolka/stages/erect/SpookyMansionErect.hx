package mikolka.stages.erect;

import mikolka.stages.objects.PicoCapableStage;
import mikolka.compatibility.VsliceOptions;
import shaders.RainShader;
#if !LEGACY_PSYCH
import objects.Note;
import objects.Character;
#else
using mikolka.compatibility.stages.misc.CharUtills;
#end
class SpookyMansionErect extends BaseStage
{
	var halloweenBG:BGSprite;
	var halloweenBGLight:BGSprite;

	var shader:RainShader;
	var halloweenWindow:BGSprite;

	var stairsDark:BGSprite;
	var stairsLight:BGSprite;

	var boyfriendGhost:Character;
	var gfGhost:Character;
	var dadGhost:Character;

	var nene:PicoCapableStage;
	public function new(nene:PicoCapableStage) {
		super();
		this.nene = nene;
	}
	override function create()
	{
		halloweenBG = new BGSprite('erect/bgDark', -360, -220);
		halloweenBGLight = new BGSprite('erect/bgLight', -360, -220);
		halloweenBGLight.alpha = 0;

		stairsDark = new BGSprite('erect/stairsDark', 966, -225);
		stairsLight = new BGSprite('erect/stairsLight', 966, -225);
		stairsLight.alpha = 0;

		halloweenWindow = new BGSprite('erect/bgtrees', 200, 50, 0.8, 0.8, ["bgtrees0"],true);
		halloweenWindow.animation.curAnim.frameRate = 5;

		add(halloweenWindow);
		add(halloweenBG);
		add(halloweenBGLight);

		// PRECACHE SOUNDS
		Paths.sound('thunder_1');
		Paths.sound('thunder_2');
	}

	override function createPost()
	{
		super.createPost();
		if(VsliceOptions.SHADERS){
			shader = new shaders.RainShader();
			shader.scale = FlxG.height / 200 * 2;
			shader.intensity = 0.4;
			shader.spriteMode = true;
			halloweenWindow.shader = shader;
		}


		halloweenWindow.animation.play("bgtrees0");
        if (!VsliceOptions.LOW_QUALITY) makeChars();
		add(stairsDark);
		add(stairsLight);
	}

	override function update(elapsed:Float) {
		if(VsliceOptions.SHADERS){
		shader?.updateFrameInfo(halloweenWindow.frame);
		shader?.update(elapsed);
		}
		super.update(elapsed);
	}
	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();
		if(VsliceOptions.LOW_QUALITY) return;
		if(curBeat == 4 && songName == "spookeez-erect") lightningStrikeShit(false); 
		if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit(); 
		}

        if (curBeat % game.boyfriend.danceEveryNumBeats == 0 && !StringTools.startsWith(boyfriend.getAnimationName(),'sing') && !game.boyfriend.stunned)
			boyfriendGhost.dance();
		if (curBeat % game.dad.danceEveryNumBeats == 0 && !StringTools.startsWith(dad.getAnimationName(),'sing') && !game.dad.stunned)
			dadGhost.dance();
		if (curBeat % game.gf.danceEveryNumBeats == 0 && !StringTools.startsWith(gf.getAnimationName(),'sing') && !game.gf.stunned)
			gfGhost.dance();
	}
    override function goodNoteHit(note:Note) {
        var anims = [ "singLEFT","singDOWN","singUP","singRIGHT"];
	    boyfriendGhost?.playAnim(anims[note.noteData],true);
		super.goodNoteHit(note);
    }
    override function noteMiss(note:Note) {
        var anims = [ "singLEFT","singDOWN","singUP","singRIGHT"];
	    boyfriendGhost?.playAnim(anims[note.noteData]+"miss",true);
		super.noteMiss(note);
    }
    override function opponentNoteHit(note:Note) {
        var anims = [ "singLEFT","singDOWN","singUP","singRIGHT"];
	    dadGhost?.playAnim(anims[note.noteData],true);
    }
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) {		
		switch (eventName){
			case "Play Animation":{
				var char:Character = dadGhost;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriendGhost;
					case 'gf' | 'girlfriend':
						char = gfGhost;
					default:
						if(flValue2 == null) flValue2 = 0;
						switch(Math.round(flValue2)) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}
			}
		}
	}
	function lightningStrikeShit(playSound:Bool = true):Void
	{
		if(playSound) FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
			FlxTimer.wait(0.06, () ->
			{
				halloweenBGLight.alpha = 0;
				stairsLight.alpha = 0;
				boyfriend.alpha = 1;
				dad.alpha = 1;
				gf.alpha = 1;

				gfGhost.alpha = 0;
				boyfriendGhost.alpha = 0;
				dadGhost.alpha = 0;
			});
			FlxTimer.wait(0.12, () ->
			{
				if (boyfriend.hasAnimation('scared'))
					boyfriend.playAnim('scared', true);

				if (dad.hasAnimation('scared'))
					dad.playAnim('scared', true);

				if (gf != null && gf.hasAnimation('scared'))
					gf.playAnim('scared', true);
				if (VsliceOptions.FLASHBANG)
				{
					nene.ABot_plink();
					boyfriend.alpha = 0;
					dad.alpha = 0;
					gf.alpha = 0;
					halloweenBGLight.alpha = 1;
					stairsLight.alpha = 1;

					gfGhost.alpha = 1;
					boyfriendGhost.alpha = 1;
					dadGhost.alpha = 1;
					FlxTween.tween(boyfriendGhost, {alpha: 0}, 1.5);
					FlxTween.tween(gfGhost, {alpha: 0}, 1.5);
					FlxTween.tween(dadGhost, {alpha: 0}, 1.5);

					FlxTween.tween(halloweenBGLight, {alpha: 0}, 1.5);
					FlxTween.tween(stairsLight, {alpha: 0}, 1.5);

					FlxTween.tween(boyfriend, {alpha: 1}, 1.5);
					FlxTween.tween(gf, {alpha: 1}, 1.5);
					FlxTween.tween(dad, {alpha: 1}, 1.5);
				}
			});

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if (VsliceOptions.CAM_ZOOMING)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if (!game.camZooming)
			{ // Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}
	}

	function makeChars()
	{
		
		var bfName = PlayState.instance.boyfriend.curCharacter.split("-")[0]; 
		if(bfName == "pico") bfName = "pico-playable";

		var gfMode = PlayState.instance.gf.curCharacter.split("-")[0];
		gfGhost = new Character(game.gf.x, game.gf.y, gfMode);
		//if (gfMode == 'nene')
			//gfGhost.y -= 190;
		game.add(gfGhost);
		gfGhost.dance();
		
		boyfriendGhost = new Character(game.boyfriend.x, game.boyfriend.y, bfName, true);
		game.add(boyfriendGhost);
		boyfriendGhost.dance();

		dadGhost = new Character(game.dad.x, game.dad.y, 'spooky', true);
		dadGhost.flipX = false;
		game.add(dadGhost);
		dadGhost.dance();

		boyfriendGhost.alpha = 0;
		gfGhost.alpha = 0;
		dadGhost.alpha = 0;
	}
}
