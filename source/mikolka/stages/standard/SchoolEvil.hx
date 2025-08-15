package mikolka.stages.standard;

import shaders.WiggleEffectRuntime;
import mikolka.stages.cutscenes.SchoolDoof;
import flixel.addons.effects.FlxTrail;
import mikolka.compatibility.VsliceOptions;

#if !LEGACY_PSYCH
import substates.GameOverSubstate;
#end

import openfl.utils.Assets as OpenFlAssets;

class SchoolEvil extends BaseStage
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
		if(_song.gameOverSound == null || _song.gameOverSound.trim().length < 1) GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
		if(_song.gameOverLoop == null || _song.gameOverLoop.trim().length < 1) GameOverSubstate.loopSoundName = 'gameOver-pixel';
		if(_song.gameOverEnd == null || _song.gameOverEnd.trim().length < 1) GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
		if(_song.gameOverChar == null || _song.gameOverChar.trim().length < 1) GameOverSubstate.characterName = 'bf-pixel-dead';
		#end
		

		var trees = new BGSprite('weeb/evil/weebBackTrees', -842, -80, 0.5, 0.5);
		trees.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
		trees.updateHitbox();
		trees.antialiasing = false;
		add(trees);

		bg = new BGSprite('weeb/evil/weebSchool', -816, -38, 0.75, 0.75);
		bg.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
		bg.updateHitbox();
		bg.antialiasing = false;
		add(bg);

		var bgStreet:BGSprite = new BGSprite('weeb/evil/weebStreet', -662, 6, 1,1);
		bgStreet.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
		bgStreet.updateHitbox();
		bgStreet.antialiasing = false;
		add(bgStreet);

		var bgTrees:BGSprite = new BGSprite('weeb/evil/weebTrees', -662, 6, 1,1);
		bgTrees.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
		bgTrees.updateHitbox();
		bgTrees.antialiasing = false;
		add(bgTrees);

		setDefaultGF('gf-pixel');

		FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
		FlxG.sound.music.fadeIn(1, 0, 0.8);
		if(isStoryMode && !seenCutscene)
		{
			var cutscene = new SchoolDoof(songName);
			setStartCallback(cutscene.doSpiritIntro);
		}
	}
	override function createPost()
	{
		var trail:FlxTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
		if(VsliceOptions.SHADERS){
			wiggle = new WiggleEffectRuntime(2, 4, 0.017, WiggleEffectType.DREAMY);
			bg.shader = wiggle;
		}
		addBehindDad(trail);
	}
	override function update(elapsed:Float) {
		super.update(elapsed);
		wiggle?.update(elapsed);
	}
	// Ghouls event
	var bgGhouls:BGSprite;
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Trigger BG Ghouls":
				if(!VsliceOptions.LOW_QUALITY)
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
		switch(event.event)
		{
			case "Trigger BG Ghouls":
				if(!VsliceOptions.LOW_QUALITY)
				{
					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * PlayState.daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					bgGhouls.animation.finishCallback = function(name:String)
					{
						if(name == 'BG freaks glitch instance')
							bgGhouls.visible = false;
					}
					addBehindGF(bgGhouls);
				}
		}
	}
}