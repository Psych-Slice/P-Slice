package mikolka.stages.standard;

import mikolka.stages.objects.PicoCapableStage;
import mikolka.compatibility.VsliceOptions;
import openfl.filters.ShaderFilter;
import shaders.RainShader;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxTiledSprite;

#if !LEGACY_PSYCH
import substates.GameOverSubstate;

import objects.Note;
#end

class PhillyBlazin extends BaseStage
{
	var rainShader:RainShader;
	var rainTimeScale:Float = 1;

	var scrollingSky:FlxTiledSprite;
	var skyAdditive:BGSprite;
	var lightning:BGSprite;
	var foregroundMultiply:BGSprite;
	var additionalLighten:FlxSprite;
	
	var lightningTimer:Float = 3.0;

	var nene:PicoCapableStage;
	public function new(nene:PicoCapableStage) {
		super();
		this.nene = nene;
	}
	
	override function create()
	{
		FlxTransitionableState.skipNextTransOut = true; //skip the original transition fade
		function setupScale(spr:BGSprite)
		{
			spr.scale.set(1.75, 1.75);
			spr.updateHitbox();
		}

		if(!VsliceOptions.LOW_QUALITY)
		{
			var skyImage = Paths.image('phillyBlazin/skyBlur');
			scrollingSky = new FlxTiledSprite(skyImage, Std.int(skyImage.width * 1.1) + 475, Std.int(skyImage.height / 1.1), true, false);
			scrollingSky.antialiasing = VsliceOptions.ANTIALIASING;
			scrollingSky.setPosition(-500, -120);
			scrollingSky.scrollFactor.set();
			add(scrollingSky);

			skyAdditive = new BGSprite('phillyBlazin/skyBlur', -600, -175, 0.0, 0.0);
			setupScale(skyAdditive);
			skyAdditive.visible = false;
			add(skyAdditive);
			
			lightning = new BGSprite('phillyBlazin/lightning', -50, -300, 0.0, 0.0, ['lightning0'], false);
			setupScale(lightning);
			lightning.visible = false;
			add(lightning);
		}
		
		var phillyForegroundCity:BGSprite = new BGSprite('phillyBlazin/streetBlur', -600, -175, 0.0, 0.0);
		setupScale(phillyForegroundCity);
		add(phillyForegroundCity);
		
		if(!VsliceOptions.LOW_QUALITY)
		{
			foregroundMultiply = new BGSprite('phillyBlazin/streetBlur', -600, -175, 0.0, 0.0);
			setupScale(foregroundMultiply);
			foregroundMultiply.blend = MULTIPLY;
			foregroundMultiply.visible = false;
			add(foregroundMultiply);
			
			additionalLighten = new FlxSprite(-600, -175).makeGraphic(1, 1, FlxColor.WHITE);
			additionalLighten.scrollFactor.set();
			additionalLighten.scale.set(2500, 2500);
			additionalLighten.updateHitbox();
			additionalLighten.blend = ADD;
			additionalLighten.visible = false;
			add(additionalLighten);
		}
		
		if(VsliceOptions.SHADERS)
			setupRainShader();

		var _song = PlayState.SONG;
		if(_song.gameOverSound == null || _song.gameOverSound.trim().length < 1) GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pico-gutpunch';
		if(_song.gameOverLoop == null || _song.gameOverLoop.trim().length < 1) GameOverSubstate.loopSoundName = 'gameOver-pico';
		if(_song.gameOverEnd == null || _song.gameOverEnd.trim().length < 1) GameOverSubstate.endSoundName = 'gameOverEnd-pico';
		if(_song.gameOverChar == null || _song.gameOverChar.trim().length < 1) GameOverSubstate.characterName = 'pico-blazin';
		GameOverSubstate.deathDelay = 0.15;

		setDefaultGF('nene');
		gfGroup.y += 200;
		gfGroup.x += 50;
		precache();
		
		if (isStoryMode)
		{
			switch (songName)
			{
				case 'blazin':
					setEndCallback(function()
					{
						game.endingSong = true;
						inCutscene = true;
						canPause = false;
						FlxTransitionableState.skipNextTransIn = true;
						FlxG.camera.visible = false;
						camHUD.visible = false;
						game.startVideo('blazinCutscene');
					});
			}
		}
	}
	
	override function createPost()
	{
		super.createPost();
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.camera.fade(FlxColor.BLACK, 1.5, true, null, true);

		for (character in boyfriendGroup.members)
		{
			if(character == null) continue;
			character.color = 0xFFDEDEDE;
		}
		for (character in dadGroup.members)
		{
			if(character == null) continue;
			character.color = 0xFFDEDEDE;
		}
		for (character in gfGroup.members)
		{
			if(character == null) continue;
			character.color = 0xFF888888;
		}
		nene.abot.color = 0xFF888888;

		var unspawnNotes:Array<Note> = cast game.unspawnNotes;
		for (note in unspawnNotes)
		{
			if(note == null) continue;

			//override animations for note types
			note.noAnimation = true;
			note.noMissAnimation = true;
		}
		remove(dadGroup, true);
		addBehindBF(dadGroup);
	}

	override function beatHit()
	{
		//if(curBeat % 2 == 0) abot.beatHit();
	}

	function setupRainShader()
	{
		rainShader = new RainShader();
		rainShader.scale = FlxG.height / 200;
		rainShader.intensity = 0.5;
		FlxG.camera.setFilters([new ShaderFilter(rainShader)]);
	}

	function precache()
	{
		for (i in 1...4)
		{
			Paths.sound('lightning/Lightning$i');
		}
	}

	override function update(elapsed:Float)
	{
		if(scrollingSky != null) scrollingSky.scrollX -= elapsed * 35;

		if(rainShader != null)
		{
			rainShader.updateViewInfo(FlxG.width, FlxG.height, FlxG.camera);
			rainShader.update(elapsed * rainTimeScale);
			rainTimeScale = FlxMath.lerp(0.02, Math.min(1, rainTimeScale), Math.exp(-elapsed / (1/3)));
		}
		
		lightningTimer -= elapsed;
		if (lightningTimer <= 0)
		{
			applyLightning();
			lightningTimer = FlxG.random.float(7, 15);
		}
	}
	
	function applyLightning():Void
	{
		if(VsliceOptions.LOW_QUALITY || game.endingSong) return;

		final LIGHTNING_FULL_DURATION = 1.5;
		final LIGHTNING_FADE_DURATION = 0.3;

		skyAdditive.visible = true;
		skyAdditive.alpha = 0.7;
		FlxTween.tween(skyAdditive, {alpha: 0.0}, LIGHTNING_FULL_DURATION, {onComplete: function(_)
		{
			skyAdditive.visible = false;
			lightning.visible = false;
			foregroundMultiply.visible = false;
			additionalLighten.visible = false;
		}});

		foregroundMultiply.visible = true;
		foregroundMultiply.alpha = 0.64;
		FlxTween.tween(foregroundMultiply, {alpha: 0.0}, LIGHTNING_FULL_DURATION);

		additionalLighten.visible = true;
		additionalLighten.alpha = 0.3;
		FlxTween.tween(additionalLighten, {alpha: 0.0}, LIGHTNING_FADE_DURATION);

		lightning.visible = true;
		lightning.animation.play('lightning0', true);

		if(FlxG.random.bool(65))
			lightning.x = FlxG.random.int(-250, 280);
		else
			lightning.x = FlxG.random.int(780, 900);

		// Darken characters
		FlxTween.color(boyfriend, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFFDEDEDE);
		FlxTween.color(dad, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFFDEDEDE);
		FlxTween.color(gf, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFF888888);
		FlxTween.color(nene.abot, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFF888888);

		// Sound
		FlxG.sound.play(Paths.soundRandom('lightning/Lightning', 1, 3));
	}

	// Note functions
	var picoFight:PicoBlazinHandler = new PicoBlazinHandler();
	var darnellFight:DarnellBlazinHandler = new DarnellBlazinHandler();
	override function goodNoteHit(note:Note)
	{
		//trace('hit note! ${note.noteType}');
		rainTimeScale += 0.7;
		picoFight.noteHit(note);
		darnellFight.noteHit(note);
	}
	override function noteMiss(note:Note)
	{
		//trace('missed note!');
		picoFight.noteMiss(note);
		darnellFight.noteMiss(note);
	}

	override function noteMissPress(direction:Int)
	{
		//trace('misinput!');
		picoFight.noteMissPress(direction);
		darnellFight.noteMissPress(direction);
	}

	// Darnell Note functions
	override function opponentNoteHit(note:Note)
	{
		//trace('opponent hit!');
		picoFight.noteMiss(note);
		darnellFight.noteMiss(note);
	}
}