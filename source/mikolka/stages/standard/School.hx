package mikolka.stages.standard;

import mikolka.stages.cutscenes.SchoolDoof;
import mikolka.stages.cutscenes.dialogueBox.DialogueBoxPsych.DialogueFile;
import mikolka.compatibility.VsliceOptions;

#if !LEGACY_PSYCH
import substates.GameOverSubstate;
#end

class School extends BaseStage
{
	var bgGirls:BackgroundGirls;
	var dialogue:DialogueFile;
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



		var bgSky:BGSprite = new BGSprite('weeb/weebSky', -626, -78, 0.2, 0.2);
		bgSky.makePixel();
		add(bgSky);
		
		var backTrees:BGSprite = new BGSprite('weeb/weebBackTrees', -842, -80, 0.5, 0.5);
		backTrees.makePixel();
		add(backTrees);
		
		var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', -816, -38, 0.75, 0.75);
		bgSchool.makePixel();
		add(bgSchool);

		var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', -662 , 6,1,1);
		bgStreet.makePixel();
		add(bgStreet);

		if(!VsliceOptions.LOW_QUALITY) {
			var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', -500, 6);
			fgTrees.makePixel();
			add(fgTrees);
		}

		var bgTrees:FlxSprite = new FlxSprite(-806, -1050);
		bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
		bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		bgTrees.animation.play('treeLoop');
		bgTrees.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
		bgTrees.updateHitbox();
		bgTrees.antialiasing = false;
		add(bgTrees);

		if(!VsliceOptions.LOW_QUALITY) {
			var treeLeaves:BGSprite = new BGSprite('weeb/petals', -20, -40, 0.85, 0.85, ['PETALS ALL'], true);
			treeLeaves.makePixel();
			add(treeLeaves);
		}

		if(!VsliceOptions.LOW_QUALITY) {
			bgGirls = new BackgroundGirls(-100, 190);
			bgGirls.scrollFactor.set(0.9, 0.9);
			add(bgGirls);
		}
		setDefaultGF('gf-pixel');

		switch (songName)
		{
			case 'senpai'|'senpai-erect':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'roses'|'roses-erect':
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
		}
		if(isStoryMode && !seenCutscene)
		{
			var cutscene = new SchoolDoof(songName);
			if(songName == 'roses' || songName == "roses-erect") setStartCallback(cutscene.doAngryIntro);
			setStartCallback(cutscene.doSchoolIntro);
		}
	}
	override function createPost() {
		super.createPost();
		camFollow_set(800, 500);
		camGame.snapToTarget();
	}

	override function beatHit()
	{
		if(bgGirls != null) bgGirls.dance();
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "BG Freaks Expression":
				if(bgGirls != null) bgGirls.swapDanceType();
		}
	}
}