package mikolka.vslice.charSelect;

import flixel.group.FlxGroup;
import mikolka.funkin.custom.mobile.MobileScaleMode;
import mikolka.compatibility.ModsHelper;
import mikolka.vslice.ui.obj.ModSelector;
import mikolka.compatibility.VsliceOptions;
import mikolka.compatibility.freeplay.FreeplayHelpers;
import mikolka.vslice.freeplay.FreeplayState;
import openfl.filters.BitmapFilter;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.system.debug.watch.Tracker.TrackerProfile;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import mikolka.funkin.FunkinSound;
import mikolka.funkin.players.PlayerRegistry;
import mikolka.funkin.FlxAtlasSprite;
import openfl.filters.DropShadowFilter;
import mikolka.compatibility.funkin.FunkinCamera;
import shaders.BlueFade;
import mikolka.funkin.players.PlayableCharacter;
import mikolka.vslice.freeplay.obj.PixelatedIcon;
import mikolka.funkin.utils.MathUtil;
import funkin.vis.dsp.SpectralAnalyzer;
import openfl.display.BlendMode;
import openfl.filters.ShaderFilter;
import mikolka.funkin.FramesJSFLParser;
import mikolka.funkin.FramesJSFLParser.FramesJSFLInfo;
import mikolka.funkin.custom.VsliceSubState as MusicBeatSubState;
import mikolka.compatibility.funkin.FunkinPath as Paths;

class CharSelectSubState extends MusicBeatSubState
{
	var chrSelectCursor:FlxSprite;
	var modSelector:ModSelector;

	var cursorBlue:FlxSprite;
	var cursorDarkBlue:FlxSprite;
	var grpCursors:FlxTypedGroup<FlxSprite>;
	var cursorConfirmed:FlxSprite;
	var cursorDenied:FlxSprite;
	var cursorX:Int = 0;
	var cursorY:Int = 0;
	var cursorFactor:Float = 110;
	var cursorOffsetX:Float = -16;
	var cursorOffsetY:Float = -48;
	var cursorLocIntended:FlxPoint = new FlxPoint(0, 0);
	var lerpAmnt:Float = 0.95;
	var tmrFrames:Int = 60;
	var playerChill:CharSelectPlayer;
	var playerChillOut:CharSelectPlayer;
	var gfChill:CharSelectGF;
	var gfChillOut:CharSelectGF;
	var barthing:FlxAtlasSprite;
	var dipshitBacking:FlxSprite;
	var modArrows:Null<ModArrows>;
	var chooseDipshit:FlxSprite;
	var dipshitBlur:FlxSprite;
	var transitionGradient:FlxSprite;
	var curChar(default, set):String = "bf";
	var nametag:Nametag;
	var camFollow:FlxObject;
	var autoFollow:Bool = false;
	var availableChars:Map<Int, String> = new Map<Int, String>();
	var pressedSelect:Bool = false;
	var selectTimer:FlxTimer = new FlxTimer();
	var allowInput:Bool = false;

	var selectSound:FunkinSound;
	var unlockSound:FunkinSound;
	var lockedSound:FunkinSound;
	var introSound:FunkinSound;
	var staticSound:FunkinSound;

	#if TOUCH_CONTROLS_ALLOWED
	var touchKeys:Array<TouchZone>;
	#end

	var selectedBizz:Array<BitmapFilter> = [
		new DropShadowFilter(0, 0, 0xFFFFFF, 1, 2, 2, 19, 1, false, false, false),
		new DropShadowFilter(5, 45, 0x000000, 1, 2, 2, 1, 1, false, false, false)
	];

	var bopInfo:FramesJSFLInfo;
	var blackScreen:FunkinSprite;
	var cutoutSize:Float = 0;

	public function new()
	{
		super();
		var charData = VsliceOptions.LAST_MOD; // ? Added character save store
		if (ModsHelper.isModDirEnabled(charData.mod_dir) || charData.mod_dir == '')
		{
			ModsHelper.loadModDir(charData.mod_dir);
			@:bypassAccessor
			curChar = charData.char_name;
		}
		loadAvailableCharacters();
	}

	function loadAvailableCharacters():Void
	{
		var playerIds:Array<String> = PlayerRegistry.instance.listEntryIds();

		for (playerId in playerIds)
		{
			var player:Null<PlayableCharacter> = PlayerRegistry.instance.fetchEntry(playerId);
			if (player == null)
				continue;
			var playerData = player.getCharSelectData();
			if (playerData == null)
				continue;

			var targetPosition:Int = playerData.position ?? 0;
			while (availableChars.exists(targetPosition))
			{
				targetPosition += 1;
			}

			trace('Placing player ${playerId} at position ${targetPosition}');
			availableChars.set(targetPosition, playerId);
		}
	}

	var fadeShader:BlueFade = new BlueFade();

	override public function create():Void
	{
		super.create();

		cutoutSize = MobileScaleMode.gameCutoutSize.x / 2;

		bopInfo = FramesJSFLParser.parse("images/charSelect/iconBopInfo/iconBopInfo.txt");

		var bg:FlxSprite = new FlxSprite(cutoutSize + -153, -140);
		bg.loadGraphic(Paths.image('charSelect/charSelectBG'));
		bg.scrollFactor.set(0.1, 0.1);

		add(bg);

		var crowd:FlxAtlasSprite = new FlxAtlasSprite(cutoutSize, 0, "charSelect/crowd");

		crowd.anim.play();
		crowd.anim.onComplete.add(function()
		{
			crowd.anim.play();
		});
		crowd.scrollFactor.set(0.3, 0.3);
		add(crowd);

		var stageSpr:FlxAtlasSprite = new FlxAtlasSprite(cutoutSize + -2, 1, "charSelect/charSelectStage");
		stageSpr.anim.play("");
		stageSpr.anim.onComplete.add(function()
		{
			stageSpr.anim.play("");
		});
		add(stageSpr);

		var curtains:FlxSprite = new FlxSprite(cutoutSize + (-47 - 165), -49 - 50);
		curtains.loadGraphic(Paths.image('charSelect/curtains'));
		curtains.scrollFactor.set(1.4, 1.4);
		add(curtains);

		barthing = new FlxAtlasSprite(0, 0, "charSelect/barThing");

		barthing.anim.play("");
		barthing.anim.onComplete.add(function()
		{
			barthing.anim.play("");
		});
		barthing.blend = BlendMode.MULTIPLY;
		barthing.scale.x = 2.5;
		barthing.scrollFactor.set(0, 0);
		add(barthing);

		barthing.y += 80;
		FlxTween.tween(barthing, {y: barthing.y - 80}, 1.3, {ease: FlxEase.expoOut});

		var charLight:FlxSprite = new FlxSprite(cutoutSize + 800, 250);
		charLight.loadGraphic(Paths.image('charSelect/charLight'));
		add(charLight);

		var charLightGF:FlxSprite = new FlxSprite(cutoutSize + 180, 240);
		charLightGF.loadGraphic(Paths.image('charSelect/charLight'));
		add(charLightGF);

		function setupPlayerChill(character:String)
		{
			gfChill = new CharSelectGF();
			gfChill.switchGF(character);
			gfChill.x += cutoutSize;
			add(gfChill);

			playerChillOut = new CharSelectPlayer(cutoutSize*2, 0);
			playerChillOut.switchChar(character);
			playerChillOut.visible = false;
			add(playerChillOut);

			playerChill = new CharSelectPlayer(cutoutSize*2.5, 0);
			playerChill.switchChar(character);
			add(playerChill);
		}

		// I think I can do the character preselect thing here? This better work
		// Edit: [UH-OH!] yes! It does!
		if (curChar != null && curChar != Constants.DEFAULT_CHARACTER)
		{
			setupPlayerChill(curChar);
			for (pos => charId in availableChars)
			{
				if (charId == curChar)
				{
					setCursorPosition(pos);
					break;
				}
			}
			// @:bypassAccessor curChar = rememberedChar;
		}
		else
			setupPlayerChill(Constants.DEFAULT_CHARACTER);

		var speakers:FlxAtlasSprite = new FlxAtlasSprite(cutoutSize - 10, 0, "charSelect/charSelectSpeakers");
		speakers.anim.play("");
		speakers.anim.onComplete.add(function()
		{
			speakers.anim.play("");
		});
		speakers.scrollFactor.set(1.8, 1.8);
		speakers.scale.set(1.05, 1.05);
		add(speakers);

		var fgBlur:FlxSprite = new FlxSprite(cutoutSize + -125, 170);
		fgBlur.loadGraphic(Paths.image('charSelect/foregroundBlur'));
		fgBlur.blend = openfl.display.BlendMode.MULTIPLY;

		add(fgBlur);

		dipshitBlur = new FlxSprite(cutoutSize + 419, -65);
		dipshitBlur.frames = Paths.getSparrowAtlas("charSelect/dipshitBlur");
		dipshitBlur.animation.addByPrefix('idle', "CHOOSE vertical offset instance 1", 24, true);
		dipshitBlur.blend = BlendMode.ADD;
		dipshitBlur.animation.play("idle");

		add(dipshitBlur);

		dipshitBacking = new FlxSprite(cutoutSize + 423, -17);
		dipshitBacking.frames = Paths.getSparrowAtlas("charSelect/dipshitBacking");
		dipshitBacking.animation.addByPrefix('idle', "CHOOSE horizontal offset instance 1", 24, true);
		dipshitBacking.blend = BlendMode.ADD;
		dipshitBacking.animation.play("idle");

		add(dipshitBacking);

		dipshitBacking.y += 210;
		FlxTween.tween(dipshitBacking, {y: dipshitBacking.y - 210}, 1.1, {ease: FlxEase.expoOut});

		chooseDipshit = new FlxSprite(cutoutSize + 426, -13);
		chooseDipshit.loadGraphic(Paths.image('charSelect/chooseDipshit'));
		add(chooseDipshit);

		// ? P-SLice code
		#if MODS_ALLOWED
		var UICam = new FunkinCamera("special", 0, 0, FlxG.width, FlxG.height);
		UICam.bgColor = 0x00FFFFFF;
		FlxG.cameras.add(UICam, false);
		modSelector = new ModSelector(this);
		modSelector.camera = UICam;
		add(modSelector);

		if (modSelector.hasModsAvailable)
		{
			modArrows = new ModArrows(cutoutSize,modSelector);
			add(modArrows);
		}

		modSelector.y += 80;
		FlxTween.tween(modSelector, {y: modSelector.y - 80}, 1.3, {ease: FlxEase.expoOut});
		#end
		// ?

		chooseDipshit.y += 200;
		FlxTween.tween(chooseDipshit, {y: chooseDipshit.y - 200}, 1, {ease: FlxEase.expoOut});

		dipshitBlur.y += 220;
		FlxTween.tween(dipshitBlur, {y: dipshitBlur.y - 220}, 1.2, {ease: FlxEase.expoOut});

		if (modArrows != null)
		{
			modArrows.y += 200;
			FlxTween.tween(modArrows, {y: modArrows.y - 200}, 1.2, {ease: FlxEase.expoOut});
		}

		chooseDipshit.scrollFactor.set();
		dipshitBacking.scrollFactor.set();
		dipshitBlur.scrollFactor.set();
		modArrows?.scrollFactor.set();

		nametag = new Nametag(curChar);
		nametag.midpointX += cutoutSize;
		add(nametag);
		@:privateAccess
		{
			nametag.midpointY += 200;
			FlxTween.tween(nametag, {midpointY: nametag.midpointY - 200}, 1, {ease: FlxEase.expoOut});
		}

		nametag.scrollFactor.set();

		FlxG.debugger.addTrackerProfile(new TrackerProfile(FlxSprite, ["x", "y", "alpha", "scale", "blend"]));
		FlxG.debugger.addTrackerProfile(new TrackerProfile(FlxAtlasSprite, ["x", "y"]));
		FlxG.debugger.addTrackerProfile(new TrackerProfile(FlxSound, ["pitch", "volume"]));

		grpCursors = new FlxTypedGroup<FlxSprite>();
		add(grpCursors);

		chrSelectCursor = new FlxSprite(0, 0);
		chrSelectCursor.loadGraphic(Paths.image('charSelect/charSelector'));
		chrSelectCursor.color = 0xFFFFFF00;

		// FFCC00

		cursorBlue = new FlxSprite(0, 0);
		cursorBlue.loadGraphic(Paths.image('charSelect/charSelector'));
		cursorBlue.color = 0xFF3EBBFF;

		cursorDarkBlue = new FlxSprite(0, 0);
		cursorDarkBlue.loadGraphic(Paths.image('charSelect/charSelector'));
		cursorDarkBlue.color = 0xFF3C74F7;

		cursorBlue.blend = BlendMode.SCREEN;
		cursorDarkBlue.blend = BlendMode.SCREEN;

		cursorConfirmed = new FlxSprite(0, 0);
		cursorConfirmed.scrollFactor.set();
		cursorConfirmed.frames = Paths.getSparrowAtlas("charSelect/charSelectorConfirm");
		cursorConfirmed.animation.addByPrefix("idle", "cursor ACCEPTED instance 1", 24, true);
		cursorConfirmed.visible = false;
		add(cursorConfirmed);

		cursorDenied = new FlxSprite(0, 0);
		cursorDenied.scrollFactor.set();
		cursorDenied.frames = Paths.getSparrowAtlas("charSelect/charSelectorDenied");
		cursorDenied.animation.addByPrefix("idle", "cursor DENIED instance 1", 24, false);
		cursorDenied.visible = false;
		add(cursorDenied);

		grpCursors.add(cursorDarkBlue);
		grpCursors.add(cursorBlue);
		grpCursors.add(chrSelectCursor);

		selectSound = FunkinSound.load(Paths.sound('CS_select'), 0.7); // ? fix loaders
		selectSound.pitch = 1;

		FlxG.sound.defaultSoundGroup.add(selectSound);
		FlxG.sound.list.add(selectSound);

		unlockSound = FunkinSound.load(Paths.sound('CS_unlock'), 0); // ? fix loaders
		unlockSound.pitch = 1;

		unlockSound.play(true);

		FlxG.sound.defaultSoundGroup.add(unlockSound);
		FlxG.sound.list.add(unlockSound);

		lockedSound = FunkinSound.load(Paths.sound('CS_locked'), 1); // ? fix loaders
		lockedSound.pitch = 1;

		FlxG.sound.defaultSoundGroup.add(lockedSound);
		FlxG.sound.list.add(lockedSound);

		staticSound = FunkinSound.load(Paths.sound('static loop'), 0.6, true); // ? fix loaders
		staticSound.pitch = 1;

		FlxG.sound.defaultSoundGroup.add(staticSound);
		FlxG.sound.list.add(staticSound);

		// playing it here to preload it. not doing this makes a super awkward pause at the end of the intro
		// TODO: probably make an intro thing for funkinSound itself that preloads the next audio?
		FunkinSound.playMusic('stayFunky', {
			startingVolume: 0,
			overrideExisting: true,
			restartTrack: true,
		});
		// ? I did some tweaks here
		FreeplayHelpers.BPM = 90;
		initLocks();
		// ?

		for (index => member in grpIcons.members)
		{
			member.y += 300;
			FlxTween.tween(member, {y: member.y - 300}, 1, {ease: FlxEase.expoOut});
		}

		chrSelectCursor.scrollFactor.set();
		cursorBlue.scrollFactor.set();
		cursorDarkBlue.scrollFactor.set();

		FlxTween.color(chrSelectCursor, 0.2, 0xFFFFFF00, 0xFFFFCC00, {type: PINGPONG});

		// FlxG.debugger.track(chrSelectCursor);

		FlxG.debugger.addTrackerProfile(new TrackerProfile(CharSelectSubState, ["curChar", "grpXSpread", "grpYSpread"]));
		FlxG.debugger.track(this);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		camFollow.screenCenter();

		// FlxG.camera.follow(camFollow, LOCKON, 0.01);
		FlxG.camera.follow(camFollow, LOCKON);

		var fadeShaderFilter:ShaderFilter = new ShaderFilter(fadeShader);
		ModsHelper.setFiltersOnCam(FlxG.camera, [fadeShaderFilter]);

		// var temp:FlxSprite = new FlxSprite(); //? why was this a thing?
		// temp.loadGraphic(Paths.image('charSelect/placement'));
		// add(temp);
		// temp.alpha = 0.0;

		// FlxG.debugger.track(temp, "tempBG");

		transitionGradient = new FlxSprite(0, 0).loadGraphic(Paths.image('freeplay/transitionGradient'));
		transitionGradient.scale.set(1280, 1);
		transitionGradient.flipY = true;
		transitionGradient.updateHitbox();
		FlxTween.tween(transitionGradient, {y: -720}, 1, {ease: FlxEase.expoOut});
		add(transitionGradient);

		camFollow.screenCenter();
		camFollow.y -= 150;
		FlxG.camera.snapToTarget();
		fadeShader.fade(0.0, 1.0, 0.8, {ease: FlxEase.quadOut});
		FlxTween.tween(camFollow, {y: camFollow.y + 150}, 1.5, {
			ease: FlxEase.expoOut,
			onComplete: function(_)
			{
				autoFollow = true;
				FlxG.camera.follow(camFollow, LOCKON, 0.01);
			}
		});

		var blackScreen = new FunkinSprite().makeSolidColor(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		blackScreen.x = -(FlxG.width * 0.5);
		blackScreen.y = -(FlxG.height * 0.5);
		add(blackScreen);

		introSound = FunkinSound.load(Paths.sound('CS_Lights'), 0); // ? fix call
		introSound.pitch = 1;

		FlxG.sound.defaultSoundGroup.add(introSound);
		FlxG.sound.list.add(introSound);

		#if TOUCH_CONTROLS_ALLOWED
		touchKeys = new Array();
		for (index in 0...9)
		{
			var posX:Float = (index % 3);
			var posY:Float = Math.floor(index / 3);

			var finalX = (posX * grpXSpread) + cutoutSize + 450 + 16;
			var finalY = (posY * grpYSpread) + 120 + 20;

			var touch = new TouchZone(finalX, finalY, 100, 100, FlxColor.PURPLE);
			touch.camera = UICam;
			touchKeys.push(touch);
			add(touch);
		}
		#end

		remove(blackScreen); // ? There was supposed to be a video, but we don't lock characters
		checkNewChar(); // ? so no reason for unlock video lol

		subStateClosed.addOnce((_) ->
		{
			remove(blackScreen);
			if (!Save.instance.oldChar)
			{
				camera.flash();

				introSound.volume = 1;
				introSound.play(true);
			}
			checkNewChar();

			Save.instance.oldChar = true;
		});

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('NONE', 'NONE');
		addTouchPadCamera();
		// if (allowInput && pressedSelect && controls.BACK) onAcceptPress();
		#end
	}

	function checkNewChar():Void
	{
		if (nonLocks.length > 0)
			selectTimer.start(2, (_) ->
			{
				unLock();
			});
		else
		{
			FunkinSound.playMusic('stayFunky', {
				startingVolume: 1,
				overrideExisting: true,
				restartTrack: true,
				onLoad: function()
				{
					allowInput = true;
					if (modSelector != null)
						modSelector.allowInput = true;

					@:privateAccess
					gfChill.analyzer = new SpectralAnalyzer(ModsHelper.getSoundChannel(FlxG.sound.music), 7, 0.1);
					#if (desktop || mobile)
					// On native it uses FFT stuff that isn't as optimized as the direct browser stuff we use on HTML5
					// So we want to manually change it!
					@:privateAccess
					gfChill.analyzer.fftN = 512;
					#end
				}
			});
		}
	}

	var grpIcons:FlxSpriteGroup;
	var grpXSpread(default, set):Float = 107;
	var grpYSpread(default, set):Float = 127;
	var nonLocks = [];

	function initLocks():Void
	{
		grpIcons = new FlxSpriteGroup();
		add(grpIcons);

		FlxG.debugger.addTrackerProfile(new TrackerProfile(FlxSpriteGroup, ["x", "y"]));
		// FlxG.debugger.track(grpIcons, "iconGrp");

		for (i in 0...9)
		{
			if (availableChars.exists(i) && Save.instance.charactersSeen.contains(availableChars[i]))
			{
				var path:String = availableChars.get(i);
				var temp:PixelatedIcon = new PixelatedIcon(0, 0);
				temp.setCharacter(path);
				temp.setGraphicSize(128, 128);
				temp.updateHitbox();
				temp.ID = 0;
				grpIcons.add(temp);
			}
			else
			{
				if (availableChars.exists(i))
					nonLocks.push(i);

				var temp:Lock = new Lock(0, 0, i);
				temp.ID = 1;

				// temp.onAnimationComplete.add(function(anim) {
				//   if (anim == "unlock") playerChill.playAnimation("unlock", true);
				// });

				grpIcons.add(temp);
			}
		}

		updateIconPositions();

		grpIcons.scrollFactor.set();
	}

	function unLock()
	{
		var index = nonLocks[0];

		pressedSelect = true;

		var copy = 3;

		var yThing = -1;

		while ((index + 1) > copy)
		{
			yThing++;
			copy += 3;
		}

		var xThing = (copy - index - 2) * -1;
		// Look, I'd write better code but I had better aneurysms, my bad - Cheems
		cursorY = yThing;
		cursorX = xThing;

		selectSound.play(true);

		nonLocks.shift();

		selectTimer.start(0.5, function(_)
		{
			var lock:Lock = cast grpIcons.group.members[index];

			lock.anim.getFrameLabel("unlockAnim").add(function()
			{
				playerChillOut.playAnimation("death");
			});

			lock.playAnimation("unlock");

			unlockSound.volume = 0.7;
			unlockSound.play(true);

			syncLock = lock;

			sync = true;

			lock.onAnimationComplete.addOnce(function(_)
			{
				syncLock = null;
				var char = availableChars.get(index);
				camera.flash(0xFFFFFFFF, 0.1);
				playerChill.playAnimation("unlock");
				playerChill.visible = true;

				var id = grpIcons.members.indexOf(lock);

				nametag.switchChar(char);
				gfChill.switchGF(char);

				var icon = new PixelatedIcon(0, 0);
				icon.setCharacter(char);
				icon.setGraphicSize(128, 128);
				icon.updateHitbox();
				grpIcons.insert(id, icon);
				grpIcons.remove(lock, true);
				icon.ID = 0;

				bopPlay = true;

				updateIconPositions();
				playerChillOut.onAnimationComplete.addOnce((_) -> if (_ == "death")
				{
					// sync = false;
					playerChillOut.visible = false;
					playerChillOut.switchChar(char);
				});

				Save.instance.addCharacterSeen(char);
				if (nonLocks.length == 0)
				{
					pressedSelect = false;
					@:bypassAccessor curChar = char;

					staticSound.stop();

					FunkinSound.playMusic('stayFunky', {
						startingVolume: 1,
						overrideExisting: true,
						restartTrack: true,
						onLoad: function()
						{
							allowInput = true;
							if (modSelector != null)
								modSelector.allowInput = true;

							@:privateAccess
							gfChill.analyzer = new SpectralAnalyzer(ModsHelper.getSoundChannel(FlxG.sound.music), 7, 0.1);
							#if (desktop || mobile)
							// On native it uses FFT stuff that isn't as optimized as the direct browser stuff we use on HTML5
							// So we want to manually change it!
							@:privateAccess
							gfChill.analyzer.fftN = 512;
							#end
						}
					});
				}
				else
					playerChill.onAnimationComplete.addOnce((_) -> unLock());
			});

			playerChill.visible = false;
			playerChill.switchChar(availableChars[index]);

			playerChillOut.visible = true;
		});
	}

	function updateIconPositions()
	{
		grpIcons.x = cutoutSize + 450;
		grpIcons.y = 120;
		for (index => member in grpIcons.members)
		{
			var posX:Float = (index % 3);
			var posY:Float = Math.floor(index / 3);

			member.x = posX * grpXSpread;
			member.y = posY * grpYSpread;

			member.x += grpIcons.x;
			member.y += grpIcons.y;
		}
	}

	var sync:Bool = false;
	var syncLock:Lock = null;
	var audioBizz:Float = 0;

	function syncAudio(elapsed:Float):Void
	{
		@:privateAccess
		if (sync && unlockSound.time > 0)
		{
			// if (playerChillOut.anim.framerate > 0)
			// {
			//   if (syncLock != null) syncLock.anim.framerate = 0;
			//   playerChillOut.anim.framerate = 0;
			// }

			playerChillOut.anim._tick = 0;
			if (syncLock != null)
				syncLock.anim._tick = 0;

			if ((unlockSound.time - audioBizz) >= ((delay) * 100))
			{
				if (syncLock != null)
					syncLock.anim._tick = delay;

				playerChillOut.anim._tick = delay;
				audioBizz += delay * 100;
			}
		}
	}

	function goToFreeplay():Void
	{
		allowInput = false;
		autoFollow = false; // ! Add mod support
		// ? P-Slice mods
		VsliceOptions.LAST_MOD = {mod_dir: modSelector?.curMod ?? "", char_name: curChar}; // ? save selected character
		#if MODS_ALLOWED
		modSelector.allowInput = false;
		FlxTween.tween(modSelector, {y: modSelector.y + 80}, 0.8, {ease: FlxEase.backIn});
		#end
		// ?
		FlxTween.tween(chrSelectCursor, {alpha: 0}, 0.8, {ease: FlxEase.expoOut});
		FlxTween.tween(cursorBlue, {alpha: 0}, 0.8, {ease: FlxEase.expoOut});
		FlxTween.tween(cursorDarkBlue, {alpha: 0}, 0.8, {ease: FlxEase.expoOut});
		FlxTween.tween(cursorConfirmed, {alpha: 0}, 0.8, {ease: FlxEase.expoOut});

		FlxTween.tween(barthing, {y: barthing.y + 80}, 0.8, {ease: FlxEase.backIn});
		FlxTween.tween(nametag, {y: nametag.y + 80}, 0.8, {ease: FlxEase.backIn});
		FlxTween.tween(dipshitBacking, {y: dipshitBacking.y + 210}, 0.8, {ease: FlxEase.backIn});
		FlxTween.tween(chooseDipshit, {y: chooseDipshit.y + 200}, 0.8, {ease: FlxEase.backIn});
		FlxTween.tween(dipshitBlur, {y: dipshitBlur.y + 220}, 0.8, {ease: FlxEase.backIn});

		if (modArrows != null)
			FlxTween.tween(modArrows, {y: modArrows.y + 200}, 0.8, {ease: FlxEase.backIn});

		for (index => member in grpIcons.members)
		{
			// member.y += 300;
			FlxTween.tween(member, {y: member.y + 300}, 0.8, {ease: FlxEase.backIn});
		}
		FlxG.camera.follow(camFollow, LOCKON);
		FlxTween.tween(transitionGradient, {y: -150}, 0.8, {ease: FlxEase.backIn});
		fadeShader.fade(1.0, 0, 0.8, {ease: FlxEase.quadIn});
		FlxTween.tween(camFollow, {y: camFollow.y - 150}, 0.8, {
			ease: FlxEase.backIn,
			onComplete: function(_)
			{
				if (!FlxG.random.bool(0.01))
					FlxTransitionableState.skipNextTransOut = true; // ? a fix
				FlxG.switchState(FreeplayState.build(null));
				FlxG.switchState(FreeplayState.build({
					{
						fromCharSelect: true
					}
				}));
			}
		});
		#if TOUCH_CONTROLS_ALLOWED
		FlxTween.tween(touchPad, {alpha: 0}, 0.8, {ease: FlxEase.expoOut});
		#end
	}

	var holdTmrUp:Float = 0;
	var holdTmrDown:Float = 0;
	var holdTmrLeft:Float = 0;
	var holdTmrRight:Float = 0;
	var spamUp:Bool = false;
	var spamDown:Bool = false;
	var spamLeft:Bool = false;
	var spamRight:Bool = false;

	override public function update(elapsed:Float):Void
	{
		controls.isInSubstate = true;

		super.update(elapsed);

		if (controls.UI_UP_R || controls.UI_DOWN_R || controls.UI_LEFT_R || controls.UI_RIGHT_R)
			selectSound.pitch = 1;

		syncAudio(elapsed);

		if (!pressedSelect && allowInput)
		{

			if (controls.UI_UP)
				holdTmrUp += elapsed;
			if (controls.UI_UP_R)
			{
				holdTmrUp = 0;
				spamUp = false;
			}

			if (controls.UI_DOWN)
				holdTmrDown += elapsed;
			if (controls.UI_DOWN_R)
			{
				holdTmrDown = 0;
				spamDown = false;
			}

			if (controls.UI_LEFT)
				holdTmrLeft += elapsed;
			if (controls.UI_LEFT_R)
			{
				holdTmrLeft = 0;
				spamLeft = false;
			}

			if (controls.UI_RIGHT)
				holdTmrRight += elapsed;
			if (controls.UI_RIGHT_R)
			{
				holdTmrRight = 0;
				spamRight = false;
			}

			var initSpam = 0.5;

			if (holdTmrUp >= initSpam)
				spamUp = true;
			if (holdTmrDown >= initSpam)
				spamDown = true;
			if (holdTmrLeft >= initSpam)
				spamLeft = true;
			if (holdTmrRight >= initSpam)
				spamRight = true;

			if (controls.UI_UP_P)
			{
				cursorY -= 1;
				cursorDenied.visible = false;

				holdTmrUp = 0;

				selectSound.play(true);
			}
			if (controls.UI_DOWN_P)
			{
				cursorY += 1;
				cursorDenied.visible = false;
				holdTmrDown = 0;
				selectSound.play(true);
			}
			if (controls.UI_LEFT_P)
			{
				cursorX -= 1;
				cursorDenied.visible = false;

				holdTmrLeft = 0;
				selectSound.play(true);
			}
			if (controls.UI_RIGHT_P)
			{
				cursorX += 1;
				cursorDenied.visible = false;
				holdTmrRight = 0;
				selectSound.play(true);
			}
		}
		// Overflow handlers
		if (cursorX < -1)
		{
			cursorX = 1;
			#if MODS_ALLOWED
			modArrows?.previousModPress();
			#end
		}
		if (cursorX > 1)
		{
			cursorX = -1;
			#if MODS_ALLOWED
			modArrows?.nextModPress();
			#end
		}
		if (cursorY < -1)
		{
			cursorY = 1;
		}
		if (cursorY > 1)
		{
			cursorY = -1;
		}

		#if TOUCH_CONTROLS_ALLOWED
		if (TouchUtil.pressed #if debug || FlxG.mouse.pressed #end)
		{
			for (index => member in touchKeys)
			{
				if (member.pressed)
				{
					var newCursorY = (Math.floor(index / 3));
					var newCursorX = (index % 3);
					if (cursorX == newCursorX - 1 && cursorY == newCursorY - 1 && member.justPressed)
					{
						if (!pressedSelect)
							onAcceptPress();
						else
							onBackPress();
					}
					else if (!pressedSelect)
					{
						if (cursorX != newCursorX - 1 || cursorY != newCursorY - 1)
							selectSound.play(true);
						cursorY = newCursorY - 1;
						cursorX = newCursorX - 1;
						cursorDenied.visible = false;
						holdTmrDown = 0;
					}
				}
			}
		}
		#end
		if (controls.ACCEPT)
			onAcceptPress();
		if (controls.BACK)
			onBackPress();

		updateLockAnims();

		if (autoFollow
			&& availableChars.exists(getCurrentSelected())
			&& Save.instance.charactersSeen.contains(availableChars[getCurrentSelected()]))
		{
			curChar = availableChars.get(getCurrentSelected());
			playerChillOut.onAnimationFrame.addOnce((s, i) ->
			{
				gfChill.visible = true;
			});
		}
		else if (autoFollow)
		{
			curChar = "locked";

			gfChill.visible = false;
		}

		if (autoFollow == true)
		{
			camFollow.screenCenter();
			camFollow.x += cursorX * 10;
			camFollow.y += cursorY * 10;
		}

		cursorLocIntended.x = (cursorFactor * cursorX) + (FlxG.width / 2) - chrSelectCursor.width / 2;
		cursorLocIntended.y = (cursorFactor * cursorY) + (FlxG.height / 2) - chrSelectCursor.height / 2;

		cursorLocIntended.x += cursorOffsetX;
		cursorLocIntended.y += cursorOffsetY;

		chrSelectCursor.x = MathUtil.coolLerp(chrSelectCursor.x, cursorLocIntended.x, lerpAmnt, false); // ? disable wobbling here
		chrSelectCursor.y = MathUtil.coolLerp(chrSelectCursor.y, cursorLocIntended.y, lerpAmnt, false);

		cursorBlue.x = MathUtil.coolLerp(cursorBlue.x, chrSelectCursor.x, lerpAmnt * 0.4, false);
		cursorBlue.y = MathUtil.coolLerp(cursorBlue.y, chrSelectCursor.y, lerpAmnt * 0.4, false);
		// ! buggy code
		cursorDarkBlue.x = MathUtil.coolLerp(cursorDarkBlue.x, cursorLocIntended.x, lerpAmnt * 0.2, false);
		cursorDarkBlue.y = MathUtil.coolLerp(cursorDarkBlue.y, cursorLocIntended.y, lerpAmnt * 0.2, false);
	}

	var bopTimer:Float = 0;
	var delay = 1 / 24;
	var bopFr = 0;
	var bopPlay:Bool = false;
	var bopRefX:Float = 0;
	var bopRefY:Float = 0;

	private function onAcceptPress()
	{
		if (!allowInput || pressedSelect)
			return;
		if (autoFollow
			&& availableChars.exists(getCurrentSelected())
			&& Save.instance.charactersSeen.contains(availableChars[getCurrentSelected()]))
		{
			cursorConfirmed.visible = true;
			cursorConfirmed.x = chrSelectCursor.x - 2;
			cursorConfirmed.y = chrSelectCursor.y - 4;
			cursorConfirmed.animation.play("idle", true);

			grpCursors.visible = false;

			FunkinSound.playOnce(Paths.sound('CS_confirm')); // ? replace with FunkinSound call

			FlxTween.tween(FlxG.sound.music, {pitch: 0.1}, 1, {ease: FlxEase.quadInOut});
			FlxTween.tween(FlxG.sound.music, {volume: 0.0}, 1.5, {ease: FlxEase.quadInOut});
			playerChill.playAnimation("select");
			gfChill.playAnimation("confirm", true, false, true);
			pressedSelect = true;
			selectTimer.start(1.5, (_) ->
			{
				pressedSelect = false;
				// FlxG.switchState(FreeplayState.build(
				//   {
				//     {
				//       character: curChar
				//     }
				//   }));
				goToFreeplay();
			});
		}
		else
		{
			cursorDenied.visible = true;
			cursorDenied.x = chrSelectCursor.x - 2;
			cursorDenied.y = chrSelectCursor.y - 4;

			playerChill.playAnimation("cannot select Label", true);

			lockedSound.play(true);

			cursorDenied.animation.play("idle", true);
			cursorDenied.animation.finishCallback = (_) ->
			{
				cursorDenied.visible = false;
			};
		}
	}

	private function onBackPress()
	{
		if (!allowInput || !pressedSelect)
			return;
		cursorConfirmed.visible = false;
		grpCursors.visible = true;

		FlxTween.globalManager.cancelTweensOf(FlxG.sound.music);
		FlxTween.tween(FlxG.sound.music, {pitch: 1.0, volume: 1.0}, 1, {ease: FlxEase.quartInOut});
		playerChill.playAnimation("deselect");
		gfChill.playAnimation("deselect");
		pressedSelect = false;
		FlxTween.tween(FlxG.sound.music, {pitch: 1.0}, 1, {
			ease: FlxEase.quartInOut,
			onComplete: (_) ->
			{
				if (playerChill.getCurrentAnimation() == "deselect loop start" || playerChill.getCurrentAnimation() == "deselect")
				{
					playerChill.playAnimation("idle", true, false, true);
					gfChill.playAnimation("idle", true, false, true);
				}
			}
		});
		selectTimer.cancel();
	}

	function doBop(icon:PixelatedIcon, elapsed:Float):Void
	{
		if (bopFr >= bopInfo.frames.length)
		{
			bopRefX = 0;
			bopRefY = 0;
			bopPlay = false;
			bopFr = 0;
			return;
		}
		bopTimer += elapsed;

		if (bopTimer >= delay)
		{
			bopTimer -= bopTimer;

			var refFrame = bopInfo.frames[bopInfo.frames.length - 1];
			var curFrame = bopInfo.frames[bopFr];
			if (bopFr >= 13)
				icon.filters = selectedBizz;

			var scaleXDiff:Float = curFrame.scaleX - refFrame.scaleX;
			var scaleYDiff:Float = curFrame.scaleY - refFrame.scaleY;

			icon.scale.set(2.6, 2.6);
			icon.scale.add(scaleXDiff, scaleYDiff);

			bopFr++;
		}
	}

	override function beatHit()
	{
		super.beatHit(); // ? We have no enevt system here.
		playerChill.onBeatHit(); // ? emulate beats here
		gfChill.onBeatHit(this.curBeat);
	}

	override function stepHit()
	{ // ? emulate Conductor, which would call this every step
		spamOnStep();
		super.stepHit();
	}

	function spamOnStep():Void
	{
		if (spamUp || spamDown || spamLeft || spamRight)
		{
			// selectSound.changePitchBySemitone(1);
			if (selectSound.pitch > 5)
				selectSound.pitch = 5;
			selectSound.play(true);

			cursorDenied.visible = false;

			if (spamUp)
			{
				cursorY -= 1;
				holdTmrUp = 0;
			}
			if (spamDown)
			{
				cursorY += 1;
				holdTmrDown = 0;
			}
			if (spamLeft)
			{
				cursorX -= 1;
				holdTmrLeft = 0;
			}
			if (spamRight)
			{
				cursorX += 1;
				holdTmrRight = 0;
			}
		}
	}

	private function updateLockAnims():Void
	{
		for (index => member in grpIcons.group.members)
		{
			switch (member.ID)
			{
				case 1:
					var lock:Lock = cast member;
					if (index == getCurrentSelected())
					{
						switch (lock.getCurrentAnimation())
						{
							case "idle":
								lock.playAnimation("selected");
							case "selected" | "clicked":
								if (controls.ACCEPT || TouchUtil.justPressed #if debug || FlxG.mouse.justPressed #end) lock.playAnimation("clicked", true);
						}
					}
					else
					{
						lock.playAnimation("idle");
					}
				case 0:
					var memb:PixelatedIcon = cast member;

					if (index == getCurrentSelected())
					{
						// memb.pixels = memb.withDropShadow.clone();

						if (bopPlay)
						{
							if (bopRefX == 0)
							{
								bopRefX = memb.x;
								bopRefY = memb.y;
							}
							doBop(memb, FlxG.elapsed);
						}
						else
						{
							memb.filters = selectedBizz;
							memb.scale.set(2.6, 2.6);
						}
						if (pressedSelect && memb.animation.curAnim.name == "idle")
							memb.animation.play("confirm");
						if (autoFollow && !pressedSelect && memb.animation.curAnim.name != "idle")
						{
							memb.animation.play("confirm", false, true);
							member.animation.finishCallback = (_) ->
							{
								member.animation.play("idle");
								member.animation.finishCallback = null;
							};
						}
					}
					else
					{
						// memb.pixels = memb.noDropShadow.clone();
						memb.filters = null;
						memb.scale.set(2, 2);
					}
			}
		}
	}

	function getCurrentSelected():Int
	{
		var tempX:Int = cursorX + 1;
		var tempY:Int = cursorY + 1;
		var gridPosition:Int = tempX + tempY * 3;
		return gridPosition;
	}

	// Moved this code into a function because is now used twice
	function setCursorPosition(index:Int)
	{
		var copy = 3;
		var yThing = -1;

		while ((index + 1) > copy)
		{
			yThing++;
			copy += 3;
		}

		var xThing = (copy - index - 2) * -1;

		// Look, I'd write better code but I had better aneurysms, my bad - Cheems
		cursorY = yThing;
		cursorX = xThing;
	}

	function set_curChar(value:String):String
	{
		if (curChar == value)
			return value;

		curChar = value;

		if (value == "locked")
			staticSound.play();
		else
			staticSound.stop();

		nametag.switchChar(value);
		playerChill.visible = false;
		playerChillOut.visible = true;
		playerChillOut.playAnimation("slideout");
		var index = playerChillOut.anim.getFrameLabel("slideout").index;
		playerChillOut.onAnimationFrame.add((_, frame:Int) ->
		{
			if (frame == index + 1)
			{
				playerChill.visible = true;
				playerChill.switchChar(value);
				gfChill.switchGF(value);
			}
			if (frame == index + 2)
			{
				playerChillOut.switchChar(value);
				playerChillOut.visible = false;
				playerChillOut.onAnimationFrame.removeAll();
			}
		});

		return value;
	}

	function set_grpXSpread(value:Float):Float
	{
		grpXSpread = value;
		updateIconPositions();
		return value;
	}

	function set_grpYSpread(value:Float):Float
	{
		grpYSpread = value;
		updateIconPositions();
		return value;
	}
}