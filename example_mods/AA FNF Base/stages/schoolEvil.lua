hasGhouls = false;

function onCreate()
	posX = 400;
	posY = 200;

	-- animated sprites that load only if low quality option is turned off
	if not lowQuality then
		makeAnimatedLuaSprite('bg', 'weeb/animatedEvilSchool', posX, posY);
		addAnimationByPrefix('bg', 'idle', 'background 2', 24, true);
		setScrollFactor('bg', 0.8, 0.9);
		scaleObject('bg', 6, 6, false);
		setProperty('bg.antialiasing', false);
		addLuaSprite('bg', false);

		makeAnimatedLuaSprite('bgGhouls', 'weeb/bgGhouls', -100, 190);
		addAnimationByPrefix('bgGhouls', 'idle', 'BG freaks glitch instance', 24, false);
		setScrollFactor('bgGhouls', 0.9, 0.9);
		scaleObject('bgGhouls', 6, 6);
		setProperty('bgGhouls.antialiasing', false);
		setProperty('bgGhouls.visible', false);
		addLuaSprite('bgGhouls', false);
		hasGhouls = true;
	else
		makeLuaSprite('bg', 'weeb/animatedEvilSchool_low', posX, posY);
		setScrollFactor('bg', 0.8, 0.9);
		scaleObject('bg', 6, 6, false);
		setProperty('bg.antialiasing', false);
		addLuaSprite('bg', false);
	end

	-- death screen properties
	setPropertyFromClass('substates.GameOverSubstate', 'characterName', 'bf-pixel-dead');
	setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx-pixel');
	setPropertyFromClass('substates.GameOverSubstate', 'loopSoundName', 'gameOver-pixel');
	setPropertyFromClass('substates.GameOverSubstate', 'endSoundName', 'gameOverEnd-pixel');
end

function onCreatePost()
	-- dad trail, due to being too case-specific, there's no native implementation for the trails, so we just use runHaxeCode for it.
	addHaxeLibrary('FlxTrail', 'flixel.addons.effects');
	runHaxeCode("game.insert(game.members.indexOf(game.dadGroup) - 1, new FlxTrail(game.dad, null, 4, 24, 0.3, 0.069));");
end

function onEvent(name, value1, value2)
	if name == 'Trigger BG Ghouls' then
		playAnim('bgGhouls', 'idle', true);
		setProperty('bgGhouls.visible', true);
	end
end

function onUpdate(elapsed)
	if hasGhouls and getProperty('bgGhouls.animation.curAnim.finished') then
		setProperty('bgGhouls.visible', false);
	end
end