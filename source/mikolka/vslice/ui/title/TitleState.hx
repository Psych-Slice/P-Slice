package mikolka.vslice.ui.title;

import mikolka.funkin.custom.mobile.MobileScaleMode;
import mikolka.compatibility.VsliceOptions;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.util.FlxDirectionFlags;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import haxe.Json;
import openfl.Assets;
import mikolka.vslice.components.crash.Logger;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import shaders.ColorSwap;
import mikolka.vslice.components.ScreenshotPlugin;
#if VIDEOS_ALLOWED
import mikolka.vslice.ui.title.AttractState;
#end

using StringTools;

typedef TitleData =
{
	var titlex:Float;
	var titley:Float;
	var startx:Float;
	var starty:Float;
	var gfx:Float;
	var gfy:Float;
	var backgroundSprite:String;
	var bpm:Float;

	@:optional var animation:String;
	@:optional var dance_left:Array<Int>;
	@:optional var dance_right:Array<Int>;
	@:optional var idle:Bool;
}

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	var enterTimer:FlxTimer;

	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	#if TITLE_SCREEN_EASTER_EGG
	final easterEggKeys:Array<String> = ['SHADOW', 'RIVEREN', 'BBPANZU', 'PESSY'];
	final allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var easterEggKeysBuffer:String = '';
	#end

	override public function create():Void
	{
		Paths.clearStoredMemory();
		super.create();
		Paths.clearUnusedMemory();
		startIntro();
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		trace("Enforcing log settings!");
		Logger.enforceLogSettings = true;

		persistentUpdate = true;
		if (!initialized && FlxG.sound.music == null)
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

		var cutout_size = MobileScaleMode.gameCutoutSize.x / 2.5;
		loadJsonData();
		#if TITLE_SCREEN_EASTER_EGG easterEggData(); #end
		Conductor.bpm = musicBPM;

		logoBl = new FlxSprite(logoPosition.x+cutout_size, logoPosition.y);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = VsliceOptions.ANTIALIASING;

		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();

		gfDance = new FlxSprite(gfPosition.x+cutout_size, gfPosition.y);
		gfDance.antialiasing = VsliceOptions.ANTIALIASING;

		if (VsliceOptions.SHADERS)
		{
			swagShader = new ColorSwap();
			gfDance.shader = swagShader.shader;
			logoBl.shader = swagShader.shader;
		}

		gfDance.frames = Paths.getSparrowAtlas(characterImage);
		if (!useIdle)
		{
			gfDance.animation.addByIndices('danceLeft', animationName, danceLeftFrames, "", 24, false);
			gfDance.animation.addByIndices('danceRight', animationName, danceRightFrames, "", 24, false);
			gfDance.animation.play('danceRight');
		}
		else
		{
			gfDance.animation.addByPrefix('idle', animationName, 24, false);
			gfDance.animation.play('idle');
		}

		var animFrames:Array<FlxFrame> = [];
		titleText = new FlxSprite(enterPosition.x+cutout_size, enterPosition.y);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		@:privateAccess
		{
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}

		if (newTitle = animFrames.length > 0)
		{
			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', VsliceOptions.FLASHBANG ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else
		{
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		titleText.animation.play('idle');
		titleText.updateHitbox();

		if (swagShader != null)
		{
			gfDance.shader = swagShader.shader;
			logoBl.shader = swagShader.shader;
			titleText.shader = swagShader.shader;
		}

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.antialiasing = VsliceOptions.ANTIALIASING;
		logo.screenCenter();

		add(gfDance);
		add(logoBl); // FNF Logo
		add(titleText); // "Press Enter to Begin" text

		if (initialized)
			skipIntro();
		else
		{
			openSubState(new IntroSubstate());
			initialized = true;
		}

		// credGroup.add(credTextShit);
	}

	// JSON data
	var characterImage:String = 'gfDanceTitle';
	var animationName:String = 'gfDance';

	var gfPosition:FlxPoint = FlxPoint.get(512, 40);
	var logoPosition:FlxPoint = FlxPoint.get(-150, -100);
	var enterPosition:FlxPoint = FlxPoint.get(100, 576);

	var useIdle:Bool = false;
	var musicBPM:Float = 102;
	var danceLeftFrames:Array<Int> = [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29];
	var danceRightFrames:Array<Int> = [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];

	function loadJsonData()
	{
		if (Paths.fileExists('images/gfDanceTitle.json', TEXT))
		{
			var titleRaw:String = Paths.getTextFromFile('images/gfDanceTitle.json');
			if (titleRaw != null && titleRaw.length > 0)
			{
				try
				{
					#if LEGACY_PSYCH
					var titleJSON:TitleData = Json.parse(titleRaw);
					#else
					var titleJSON:TitleData = tjson.TJSON.parse(titleRaw);
					#end
					gfPosition.set(titleJSON.gfx, titleJSON.gfy);
					logoPosition.set(titleJSON.titlex, titleJSON.titley);
					enterPosition.set(titleJSON.startx, titleJSON.starty);
					musicBPM = titleJSON.bpm;

					if (titleJSON.animation != null && titleJSON.animation.length > 0)
						animationName = titleJSON.animation;
					if (titleJSON.dance_left != null && titleJSON.dance_left.length > 0)
						danceLeftFrames = titleJSON.dance_left;
					if (titleJSON.dance_right != null && titleJSON.dance_right.length > 0)
						danceRightFrames = titleJSON.dance_right;
					useIdle = (titleJSON.idle == true);

					if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.trim().length > 0)
					{
						var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image(titleJSON.backgroundSprite));
						bg.antialiasing = VsliceOptions.ANTIALIASING;
						add(bg);
					}
				}
				catch (e:haxe.Exception)
				{
					trace('[WARN] Title JSON might broken, ignoring issue...\n${e.details()}');
				}
			}
			else
				trace('[WARN] No Title JSON detected, using default values.');
		}
		// else trace('[WARN] No Title JSON detected, using default values.');
	}

	function easterEggData()
	{
		if (FlxG.save.data.psychDevsEasterEgg == null)
			FlxG.save.data.psychDevsEasterEgg = ''; // Crash prevention
		var easterEgg:String = FlxG.save.data.psychDevsEasterEgg;
		switch (easterEgg.toUpperCase())
		{
			case 'SHADOW':
				characterImage = 'ShadowBump';
				animationName = 'Shadow Title Bump';
				gfPosition.x += 210;
				gfPosition.y += 40;
				useIdle = true;
			case 'RIVEREN':
				characterImage = 'ZRiverBump';
				animationName = 'River Title Bump';
				gfPosition.x += 180;
				gfPosition.y += 40;
				useIdle = true;
			case 'BBPANZU':
				characterImage = 'BBBump';
				animationName = 'BB Title Bump';
				danceLeftFrames = [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27];
				danceRightFrames = [27, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
				gfPosition.x += 45;
				gfPosition.y += 100;
			case 'PESSY':
				characterImage = 'PessyBump';
				animationName = 'Pessy Title Bump';
				gfPosition.x += 165;
				gfPosition.y += 60;
				danceLeftFrames = [29, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
				danceRightFrames = [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28];
		}
	}

	var transitioning:Bool = false;

	private static var playJingle:Bool = false;

	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		#if debug
		if (controls.FAVORITE)
			moveToAttract();
		#end
		if (!cheatActive && skippedIntro)
			cheatCodeShit();

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT || (TouchUtil.justReleased && !SwipeUtil.swipeAny);

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (enterTimer != null && pressedEnter)
		{
			enterTimer.cancel();
			enterTimer.onComplete(enterTimer);
			enterTimer = null;
		}

		if (newTitle)
		{
			titleTimer += FlxMath.bound(elapsed, 0, 1);
			if (titleTimer > 2)
				titleTimer -= 2;
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;

				timer = FlxEase.quadInOut(timer);

				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}

			if (pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;

				if (titleText != null)
					titleText.animation.play('press');

				FlxG.camera.flash(VsliceOptions.FLASHBANG ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				enterTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (cheatActive)
					{
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
					}
					FlxTransitionableState.skipNextTransIn = true;
					MusicBeatState.switchState(new MainMenuState());

					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
			#if TITLE_SCREEN_EASTER_EGG
			else if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
			{
				var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
				var keyName:String = Std.string(keyPressed);
				if (allowedKeys.contains(keyName))
				{
					easterEggKeysBuffer += keyName;
					if (easterEggKeysBuffer.length >= 32)
						easterEggKeysBuffer = easterEggKeysBuffer.substring(1);
					// trace('Test! Allowed Key pressed!!! Buffer: ' + easterEggKeysBuffer);

					for (wordRaw in easterEggKeys)
					{
						var word:String = wordRaw.toUpperCase(); // just for being sure you're doing it right
						if (easterEggKeysBuffer.contains(word))
						{
							// trace('YOOO! ' + word);
							if (FlxG.save.data.psychDevsEasterEgg == word)
								FlxG.save.data.psychDevsEasterEgg = '';
							else
								FlxG.save.data.psychDevsEasterEgg = word;
							FlxG.save.flush();

							FlxG.sound.play(Paths.sound('secret'));

							var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
							black.scale.set(FlxG.width, FlxG.height);
							black.updateHitbox();
							black.alpha = 0;
							add(black);

							FlxTween.tween(black, {alpha: 1}, 1, {
								onComplete: function(twn:FlxTween)
								{
									FlxTransitionableState.skipNextTransIn = true;
									FlxTransitionableState.skipNextTransOut = true;
									MusicBeatState.switchState(new TitleState());
								}
							});
							FlxG.sound.music.fadeOut();
							closedState = true;
							transitioning = true;
							playJingle = true;
							easterEggKeysBuffer = '';
							break;
						}
					}
				}
			}
			#end
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if (swagShader != null)
		{
			if (cheatActive && TouchUtil.pressed || controls.UI_LEFT)
				swagShader.hue -= elapsed * 0.1;
			if (controls.UI_RIGHT)
				swagShader.hue += elapsed * 0.1;
		}
		#if FLX_PITCH
		if (controls.UI_UP)
			FlxG.sound.music.pitch += 0.5 * elapsed;
		if (controls.UI_DOWN)
			FlxG.sound.music.pitch -= 0.5 * elapsed;
		#end
		#if desktop
		if (controls.BACK)
			openfl.Lib.application.window.close();
		#end

		super.update(elapsed);
	}

	private var sickBeats:Int = 0; // Basically curBeat but won't be skipped if you hold the tab or resize the screen

	// Did we close this already???
	public static var closedState:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		if (logoBl != null)
			logoBl.animation.play('bump', true);

		if (gfDance != null)
		{
			danceLeft = !danceLeft;
			if (!useIdle)
			{
				if (danceLeft)
					gfDance.animation.play('danceRight');
				else
					gfDance.animation.play('danceLeft');
			}
			else if (curBeat % 2 == 0)
				gfDance.animation.play('idle', true);
		}

		if (cheatActive && this.curBeat % 2 == 0 && swagShader != null)
			swagShader.hue += 0.125;

		if (!closedState)
		{
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					// FlxG.sound.music.stop();
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					#if VIDEOS_ALLOWED
					FlxG.sound.music.onComplete = moveToAttract;
					#end
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 17:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			#if VIDEOS_ALLOWED
			FlxG.sound.music.onComplete = moveToAttract;
			#end
			#if TITLE_SCREEN_EASTER_EGG
			if (playJingle) // Ignore deez
			{
				playJingle = false;
				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null)
					easteregg = '';
				easteregg = easteregg.toUpperCase();

				var sound:FlxSound = null;
				switch (easteregg)
				{
					case 'RIVEREN':
						sound = FlxG.sound.play(Paths.sound('JingleRiver'));
					case 'SHADOW':
						FlxG.sound.play(Paths.sound('JingleShadow'));
					case 'BBPANZU':
						sound = FlxG.sound.play(Paths.sound('JingleBB'));
					case 'PESSY':
						sound = FlxG.sound.play(Paths.sound('JinglePessy'));

					default: // Go back to normal ugly ass boring GF
						closeSubState();
						FlxG.camera.flash(FlxColor.WHITE, 2);
						skippedIntro = true;

						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						return;
				}

				transitioning = true;
				if (easteregg == 'SHADOW')
				{
					new FlxTimer().start(3.2, function(tmr:FlxTimer)
					{
						closeSubState();
						FlxG.camera.flash(FlxColor.WHITE, 0.6);
						transitioning = false;
					});
				}
				else
				{
					closeSubState();
					FlxG.camera.flash(FlxColor.WHITE, 3);
					sound.onComplete = function()
					{
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						transitioning = false;
						if (easteregg == 'PESSY')
							Achievements.unlock('pessy_easter_egg');
					};
				}
			}
			else
			#end // Default! Edit this one!!
			{
				closeSubState();
				FlxG.camera.flash(FlxColor.WHITE, 4);

				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null)
					easteregg = '';
				easteregg = easteregg.toUpperCase();
				#if TITLE_SCREEN_EASTER_EGG
				if (easteregg == 'SHADOW')
				{
					FlxG.sound.music.fadeOut();
				}
				#end
			}
			skippedIntro = true;
		}
	}

	// Cheat code shit
	var cheatArray:Array<Int> = [0x0001, 0x0010, 0x0001, 0x0010, 0x0100, 0x1000, 0x0100, 0x1000];
	var curCheatPos:Int = 0;
	var cheatActive:Bool = false;

	function cheatCodeShit():Void
	{
		if (SwipeUtil.swipeAny || FlxG.keys.justPressed.ANY)
		{
			if (controls.NOTE_DOWN_P || controls.UI_DOWN_P || SwipeUtil.swipeUp)
				codePress(FlxDirectionFlags.DOWN);
			if (controls.NOTE_UP_P || controls.UI_UP_P || SwipeUtil.swipeDown)
				codePress(FlxDirectionFlags.UP);
			if (controls.NOTE_LEFT_P || controls.UI_LEFT_P || SwipeUtil.swipeRight)
				codePress(FlxDirectionFlags.LEFT);
			if (controls.NOTE_RIGHT_P || controls.UI_RIGHT_P || SwipeUtil.swipeLeft)
				codePress(FlxDirectionFlags.RIGHT);
		}
	}

	function codePress(input:Int)
	{
		if (input == cheatArray[curCheatPos])
		{
			curCheatPos += 1;
			if (curCheatPos >= cheatArray.length)
				startCheat();
		}
		else
			curCheatPos = 0;

		trace(input);
	}

	function startCheat():Void
	{
		cheatActive = true;

		// var spec:SpectogramSprite = new SpectogramSprite(FlxG.sound.music);

		FlxG.sound.playMusic(Paths.music('girlfriendsRingtone'), 0);
		Conductor.bpm = 160; // GF's ringnote has different BPM

		FlxG.sound.music.fadeIn(4.0, 0.0, 1.0);

		FlxG.camera.flash(FlxColor.WHITE, 1);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	}

	/**
	 * After sitting on the title screen for a while, transition to the attract screen.
	 */
	function moveToAttract():Void
	{
		#if VIDEOS_ALLOWED 
		if (!Std.isOfType(FlxG.state, TitleState))
			return;
		#if LEGACY_PSYCH
		FlxG.switchState(new AttractState()); 
		#else
		FlxG.switchState(() -> new AttractState()); 
		#end
		#end
	}
}
