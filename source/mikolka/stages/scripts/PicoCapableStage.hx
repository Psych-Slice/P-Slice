package mikolka.stages.scripts;

import flixel.util.FlxSignal;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.util.typeLimit.OneOfTwo;
import mikolka.vslice.StickerSubState;
import mikolka.compatibility.VsliceOptions;
import mikolka.stages.objects.ABotPixel;
#if !LEGACY_PSYCH
import objects.Note;
import substates.GameOverSubstate;
#else
using mikolka.compatibility.stages.misc.CharUtills;
#end

enum NeneState
{
	STATE_DEFAULT;
	STATE_PRE_RAISE;
	STATE_RAISE;
	STATE_READY;
	STATE_LOWER;
}

class PicoCapableStage extends BaseStage
{
	final MIN_BLINK_DELAY:Int = 3;
	final MAX_BLINK_DELAY:Int = 7;
	final VULTURE_THRESHOLD:Float = 0.5;
	public final onABotInit:FlxTypedSignal<PicoCapableStage->Void> = new FlxTypedSignal();

	public static var instance:PicoCapableStage = null;
	public static var NENE_LIST = ['nene','nene-pixel', 'nene-christmas', 'nene-dark'];
	public static var PIXEL_LIST = ['nene-pixel'];

	public var abot:ABotSpeaker;
	public var abotPixel:ABotPixel;
	public var forceABot:Bool = false;
	var blinkCountdown:Int = 3;
	public function new(forceABot:Bool = false) {
		instance?.destroy();
		instance = this;
		super();
		this.forceABot = forceABot;
	}
	public function applyABotShader(shader:FlxGraphicsShader) {
		if(abotPixel != null){
			abotPixel.bg.shader = shader;
			abotPixel.eyes.shader = shader;
			abotPixel.speaker.shader = shader;
			for (viz in abotPixel.vizSprites) viz.shader = shader;
		}
		else if(abot != null){
			abot.bg.shader = shader;
			abot.eyes.shader = shader;
			abot.speaker.shader = shader;
			for (viz in abot.vizSprites) viz.shader = shader;
		}
	}

	override function destroy() {
		instance = null;
		onABotInit.removeAll();
		super.destroy();
	}
	override function create() {
		
		if (!(NENE_LIST.contains(PlayState.SONG.gfVersion) || forceABot))
			return;	
		var _song = PlayState.SONG;
		#if !LEGACY_PSYCH if (_song.gameOverSound == null || _song.gameOverSound.trim().length < 1) #end
		GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pico';
		#if !LEGACY_PSYCH if (_song.gameOverLoop == null || _song.gameOverLoop.trim().length < 1) #end
		GameOverSubstate.loopSoundName = 'gameOver-pico';
		#if !LEGACY_PSYCH if (_song.gameOverEnd == null || _song.gameOverEnd.trim().length < 1) #end
		GameOverSubstate.endSoundName = 'gameOverEnd-pico';
		#if !LEGACY_PSYCH if (_song.gameOverChar == null || _song.gameOverChar.trim().length < 1) #end
		GameOverSubstate.characterName = 'pico-dead';
	}
	override function createPost()
	{
		super.createPost();
		abot = null;
		var game = PlayState.instance;
		if (!(NENE_LIST.contains(PlayState.SONG.gfVersion) || forceABot))
			return;
		if (!forceABot) StickerSubState.STICKER_SET = "stickers-set-2"; //? yep, it's pico time!

		game.gfGroup.y -= 200;
		if(PIXEL_LIST.contains(PlayState.SONG.gfVersion) || PlayState.isPixelStage) {
			abotPixel = new ABotPixel(game.gfGroup.x - 165, game.gfGroup.y + 340 - 30);
			updateABotEye(true);
			game.addBehindGF(abotPixel);
		}
		else {
			abot = new ABotSpeaker(game.gfGroup.x - 50, game.gfGroup.y + 550 - 30, PlayState.SONG.gfVersion == "nene-dark");
			updateABotEye(true);
			game.addBehindGF(abot);
		}

		if (gf != null)
		{
			var oldCallback = gf.animation.callback;
			gf.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
			{
				if(oldCallback != null) oldCallback(name,frameNumber,frameIndex);
				switch (currentNeneState)
				{
					case STATE_PRE_RAISE:
						if (name == 'danceLeft' && frameNumber >= 14)
						{
							animationFinished = true;
							transitionState();
						}
					default:
						// Ignore.
				}
			}
		}
		onABotInit.dispatch(this);
	}

	override function startSong()
	{
		super.startSong();
		if(gf != null) gf.animation.finishCallback = onNeneAnimationFinished;
		if (abot != null) abot.snd = FlxG.sound.music;
		if (abotPixel != null) abotPixel.snd = FlxG.sound.music;
	}

	override function sectionHit()
	{
		if (abot == null && abotPixel == null)
			return;
		updateABotEye(); // If this fails we probably need to dispose our ABot
	}

	function onNeneAnimationFinished(name:String)
	{
		@:privateAccess
		if (!game.startedCountdown)
			return;

		switch (currentNeneState)
		{
			case STATE_RAISE, STATE_LOWER:
				if (name == 'raiseKnife' || name == 'lowerKnife')
				{
					animationFinished = true;
					transitionState();
				}

			default:
				// Ignore.
		}
	}

	override function beatHit()
	{
		super.beatHit();
		if (!NENE_LIST.contains(PlayState.SONG.gfVersion))
			return;
		if(abotPixel != null) abotPixel.speaker.animation.play('anim', true);
		switch (currentNeneState)
		{
			case STATE_READY:
				if (blinkCountdown == 0)
				{
					gf.playAnim('idleKnife', false);
					blinkCountdown = FlxG.random.int(MIN_BLINK_DELAY, MAX_BLINK_DELAY);
				}
				else
					blinkCountdown--;

			default:
				// In other states, don't interrupt the existing animation.
		}
	}

	var currentNeneState:NeneState = STATE_DEFAULT;
	var animationFinished:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!NENE_LIST.contains(PlayState.SONG.gfVersion))
			return;
		@:privateAccess
		if (gf == null || !game.startedCountdown)
			return;

		animationFinished = gf.isAnimationFinished();
		transitionState();
	}

	override function goodNoteHit(note:Note)
	{
		super.goodNoteHit(note);
		if (!NENE_LIST.contains(PlayState.SONG.gfVersion))
			return;
		// 10% chance of playing combo50/combo100 animations for Nene
		switch (game.combo)
		{
			case 50, 100:
				var animToPlay:String = 'combo${game.combo}';
				if (gf.animation.exists(animToPlay))
				{
					gf.playAnim(animToPlay);
					gf.specialAnim = true;
				}
		}
	}

	function transitionState()
	{
		switch (currentNeneState)
		{
			case STATE_DEFAULT:
				if (game.health <= VULTURE_THRESHOLD)
				{
					currentNeneState = STATE_PRE_RAISE;
					gf.skipDance = true;
				}

			case STATE_PRE_RAISE:
				if (game.health > VULTURE_THRESHOLD)
				{
					currentNeneState = STATE_DEFAULT;
					gf.skipDance = false;
				}
				else if (animationFinished)
				{
					currentNeneState = STATE_RAISE;
					gf.playAnim('raiseKnife');
					gf.skipDance = true;
					gf.danced = true;
					animationFinished = false;
				}

			case STATE_RAISE:
				if (animationFinished)
				{
					currentNeneState = STATE_READY;
					animationFinished = false;
				}

			case STATE_READY:
				if (game.health > VULTURE_THRESHOLD)
				{
					currentNeneState = STATE_LOWER;
					gf.playAnim('lowerKnife');
				}

			case STATE_LOWER:
				if (animationFinished)
				{
					currentNeneState = STATE_DEFAULT;
					animationFinished = false;
					gf.skipDance = false;
				}
		}
	}

	public function ABot_plink()
	{ // silly daniel
		if (abot == null || abot.speakerAlt == null)
			return;
		abot.speakerAlt.alpha = 1;
		abot.speaker.alpha = 0;
		FlxTween.tween(abot.speakerAlt, {alpha: 0}, 1.5, {
			ease: FlxEase.linear
		});
		FlxTween.tween(abot.speaker, {alpha: 1}, 1.5, {
			ease: FlxEase.linear
		});
	}

	function updateABotEye(finishInstantly:Bool = false)
	{
		@:privateAccess // lol
		if (PlayState.SONG.notes[
			Std.int(FlxMath.bound(PlayState.instance.curSection, 0, PlayState.SONG.notes.length - 1))
		].mustHitSection == true){
			abot?.lookRight();
			abotPixel?.lookRight();
		}
		else{
			abot?.lookLeft();
			abotPixel?.lookLeft();
		}

		if (finishInstantly){
			if(abot != null) abot.eyes.anim.curFrame = abot.eyes.anim.length - 1;
			if(abotPixel != null) abotPixel.eyes.animation.frameIndex= abotPixel.eyes.animation.curAnim.numFrames - 1;
		}
	}

	override function gameOverStart(state:GameOverSubstate)
	{
		if (['pico-dead', 'pico-christmas-dead'].contains(GameOverSubstate.characterName))
		{
			var overlay = new FlxSprite(state.boyfriend.x + 205, state.boyfriend.y - 80);
			overlay.frames = Paths.getSparrowAtlas('Pico_Death_Retry');
			overlay.animation.addByPrefix('deathLoop', 'Retry Text Loop', 24, true);
			overlay.animation.addByPrefix('deathConfirm', 'Retry Text Confirm', 24, false);
			overlay.antialiasing = VsliceOptions.ANTIALIASING;
			@:privateAccess {
				state.overlay = overlay;
				state.overlayConfirmOffsets.set(250, 200);
			}
			overlay.visible = false;
			state.add(overlay);

			state.boyfriend.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
			{
				switch (name)
				{
					case 'firstDeath':
						if (frameNumber >= 36 - 1)
						{
							overlay.visible = true;
							overlay.animation.play('deathLoop');
							state.boyfriend.animation.callback = null;
						}
					default:
						state.boyfriend.animation.callback = null;
				}
			}

			if (PlayState.instance.gf != null && NENE_LIST.contains(PlayState.SONG.gfVersion))
			{
				var neneKnife:FlxSprite = new FlxSprite(state.boyfriend.x - 450, state.boyfriend.y - 250);
				if(PlayState.isPixelStage){
					neneKnife.frames = Paths.getSparrowAtlas('NenePixelKnifeToss');
					neneKnife.antialiasing = false;
					neneKnife.animation.addByPrefix('anim', 'knifetosscolor', 24, false);
				}
				else{
					neneKnife.frames = Paths.getSparrowAtlas('NeneKnifeToss');
					neneKnife.antialiasing = VsliceOptions.ANTIALIASING;
					neneKnife.animation.addByPrefix('anim', 'knife toss', 24, false);
				}
				neneKnife.animation.finishCallback = function(_)
				{
					state.remove(neneKnife);
					//neneKnife.destroy();
				}
				state.insert(0, neneKnife);
				neneKnife.animation.play('anim', true);
			}
		}
	}
}
