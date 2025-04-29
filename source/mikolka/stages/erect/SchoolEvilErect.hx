package mikolka.stages.erect;

import shaders.DropShadowShader;
import shaders.WiggleEffectRuntime;
import mikolka.stages.cutscenes.SchoolDoof;
import flixel.addons.effects.FlxTrail;
import mikolka.compatibility.VsliceOptions;
#if !LEGACY_PSYCH
import substates.GameOverSubstate;
#end
import openfl.utils.Assets as OpenFlAssets;

class SchoolEvilErect extends BaseStage
{
	var bg:BGSprite;
	var wiggle:WiggleEffectRuntime;

	override function create()
	{
		var _song = PlayState.SONG;
		#if LEGACY_PSYCH
		PlayState.SONG.splashSkin = "pixelNoteSplash";
		GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
		GameOverSubstate.loopSoundName = 'gameOver-pixel';
		GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
		GameOverSubstate.characterName = 'bf-pixel-dead';
		#else
		if (_song.gameOverSound == null || _song.gameOverSound.trim().length < 1)
			GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
		if (_song.gameOverLoop == null || _song.gameOverLoop.trim().length < 1)
			GameOverSubstate.loopSoundName = 'gameOver-pixel';
		if (_song.gameOverEnd == null || _song.gameOverEnd.trim().length < 1)
			GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
		if (_song.gameOverChar == null || _song.gameOverChar.trim().length < 1)
			GameOverSubstate.characterName = 'bf-pixel-dead';
		#end

		var posX = 410;
		var posY = 390;

		bg = new BGSprite('weeb/erect/evilSchoolBG', posX, posY, 0.8, 0.9);
		bg.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
		bg.antialiasing = false;
		add(bg);

		setDefaultGF('gf-pixel');

		FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
		FlxG.sound.music.fadeIn(1, 0, 0.8);
		if (isStoryMode && !seenCutscene)
		{
			var cutscene = new SchoolDoof(songName);
			setStartCallback(cutscene.doSpiritIntro);
		}
	}

	override function createPost()
	{
		var trail:FlxTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
		if (VsliceOptions.SHADERS)
		{
			wiggle = new WiggleEffectRuntime(2, 4, 0.017, WiggleEffectType.DREAMY);
			bg.shader = wiggle;
		}
		addBehindDad(trail);
		if (VsliceOptions.SHADERS)
			{
				applyShader(boyfriend, boyfriend.curCharacter);
				applyShader(gf, gf.curCharacter);
				applyShader(dad, dad.curCharacter);
				
			}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		wiggle?.update(elapsed);
	}

	// Ghouls event
	var bgGhouls:BGSprite;

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch (eventName)
		{
			case "Trigger BG Ghouls":
				if (!VsliceOptions.LOW_QUALITY)
				{
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}
		}
	}

	#if LEGACY_PSYCH
	override function eventPushed(event:Note.EventNote)
	#else
	override function eventPushed(event:objects.Note.EventNote)
	#end
	{
		// used for preloading assets used on events
		switch (event.event)
		{
			case "Trigger BG Ghouls":
				if (!VsliceOptions.LOW_QUALITY)
				{
					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * PlayState.daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					bgGhouls.animation.finishCallback = function(name:String)
					{
						if (name == 'BG freaks glitch instance')
							bgGhouls.visible = false;
					}
					addBehindGF(bgGhouls);
				}
		}
	}
	function applyShader(sprite:FlxSprite, char_name:String)
		{
			var rim = new DropShadowShader();
			rim.setAdjustColor(-66, -10, 24, -23);
			rim.color = 0xFF641B1B;
			rim.antialiasAmt = 0;
			rim.attachedSprite = sprite;
			rim.distance = 5;
			switch (char_name)
			{
				case "bf-pixel":
					{
						rim.angle = 90;
						sprite.shader = rim;
	
						// rim.loadAltMask('assets/week6/images/weeb/erect/masks/bfPixel_mask.png');
						rim.altMaskImage = Paths.image("weeb/erect/masks/bfPixel_mask").bitmap;
						rim.maskThreshold = 1;
						rim.useAltMask = true;
	
						sprite.animation.callback = function(anim, frame, index)
						{
							rim.updateFrameInfo(sprite.frame);
						};
					}
				case "pico-pixel":
					{
						rim.angle = 90;
						sprite.shader = rim;
	
						// rim.loadAltMask('assets/week6/images/weeb/erect/masks/bfPixel_mask.png');
						rim.altMaskImage = Paths.image("weeb/erect/masks/picoPixel_mask").bitmap;
						rim.maskThreshold = 1;
						rim.useAltMask = true;
	
						sprite.animation.callback = function(anim, frame, index)
						{
							rim.updateFrameInfo(sprite.frame);
						};
					}
				case "gf-pixel":
					{
						rim.setAdjustColor(-42, -10, 5, -25);
						rim.angle = 90;
						sprite.shader = rim;
						rim.distance = 3;
						rim.threshold = 0.3;
						rim.altMaskImage = Paths.image("weeb/erect/masks/gfPixel_mask").bitmap;
						rim.maskThreshold = 1;
						rim.useAltMask = true;
	
						sprite.animation.callback = function(anim, frame, index)
						{
							rim.updateFrameInfo(sprite.frame);
						};
					}
				case "nene-pixel":
					{
						rim.setAdjustColor(-42, -10, 5, -25);
						rim.angle = 90;
						sprite.shader = rim;
						rim.distance = 3;
						rim.threshold = 0.3;
						rim.altMaskImage = Paths.image("weeb/erect/masks/nenePixel_mask").bitmap;
						rim.maskThreshold = 1;
						rim.useAltMask = true;
						sprite.animation.callback = function(anim, frame, index)
						{
							rim.updateFrameInfo(sprite.frame);
						};
					}
	
				case "spirit":
					{
						rim.angle = 90;
						sprite.shader = rim;
						rim.setAdjustColor(0, -10, 44, -13);
						rim.useAltMask = false;
	
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
