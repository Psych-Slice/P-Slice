hasCreeps = false;
function onCreate()
	makeLuaSprite('sky', 'weeb/weebSky', 0, 0);
	setScrollFactor('sky', 0.1, 0.1);
	setProperty('sky.antialiasing', false);
	widShit = math.floor(getProperty('sky.width') * 6);
	scaleObject('sky', 6, 6);
	addLuaSprite('sky', false);

	repositionShit = -200;
	makeLuaSprite('school', 'weeb/weebSchool', repositionShit, 0);
	setScrollFactor('school', 0.6, 0.9);
	setProperty('school.antialiasing', false);
	scaleObject('school', 6, 6);
	addLuaSprite('school', false);
	
	makeLuaSprite('street', 'weeb/weebStreet', repositionShit, 0);
	setScrollFactor('street', 0.95, 0.95);
	setProperty('street.antialiasing', false);
	scaleObject('street', 6, 6);
	addLuaSprite('street', false);

	if not lowQuality then
		makeLuaSprite('treesBack', 'weeb/weebTreesBack', repositionShit + 170, 130);
		setScrollFactor('treesBack', 0.9, 0.9);
		setProperty('treesBack.antialiasing', false);
		setGraphicSize('treesBack', math.floor(widShit * 0.8));
		addLuaSprite('treesBack', false);
	end
	
	makeAnimatedLuaSprite('trees', 'weeb/weebTrees', repositionShit - 380, -800, 'packer');
	addAnimation('trees', 'treeLoop', {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}, 12, true);
	setScrollFactor('trees', 0.85, 0.85);
	setProperty('trees.antialiasing', false);
	setGraphicSize('trees', math.floor(widShit * 1.4));
	addLuaSprite('trees', false);

	-- background things that only load if you have low quality option turned off
	if not lowQuality then
		makeAnimatedLuaSprite('petals', 'weeb/petals', repositionShit, -40);
		addAnimationByPrefix('petals', 'idle', 'PETALS ALL', 24, true);
		setScrollFactor('petals', 0.85, 0.85);
		setProperty('petals.antialiasing', false);
		setGraphicSize('petals', widShit);
		addLuaSprite('petals', false);

		makeAnimatedLuaSprite('bgGirls', 'weeb/bgFreaks', -100, 190);
		scaleObject('bgGirls', 6, 6);
		setScrollFactor('bgGirls', 0.9, 0.9);
		setProperty('bgGirls.antialiasing', false);
		addLuaSprite('bgGirls', false);
		swapDanceType();
		hasCreeps = true;
	end

	-- death screen properties
	setPropertyFromClass('substates.GameOverSubstate', 'characterName', 'bf-pixel-dead');
	setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx-pixel');
	setPropertyFromClass('substates.GameOverSubstate', 'loopSoundName', 'gameOver-pixel');
	setPropertyFromClass('substates.GameOverSubstate', 'endSoundName', 'gameOverEnd-pixel');
end

danceDir = false;
function onBeatHit()
	if hasCreeps then
		creepsDance();
	end
end

function onEvent(name, value1, value2)
	if name == 'BG Freaks Expression' then
		if hasCreeps then
			swapDanceType();
		end
	end
end

isPissed = true;
function swapDanceType()
	isPissed = not isPissed;
	if not isPissed then
		luaSpriteAddAnimationByIndices('bgGirls', 'danceRight', 'BG girls group', '15,16,17,18,19,20,21,22,23,24,25,26,27,28,29', 24);
		luaSpriteAddAnimationByIndices('bgGirls', 'danceLeft', 'BG girls group', '0,1,2,3,4,5,6,7,8,9,10,11,12,13', 24);
	else
		luaSpriteAddAnimationByIndices('bgGirls', 'danceRight', 'BG fangirls dissuaded', '15,16,17,18,19,20,21,22,23,24,25,26,27,28,29', 24);
		luaSpriteAddAnimationByIndices('bgGirls', 'danceLeft', 'BG fangirls dissuaded', '0,1,2,3,4,5,6,7,8,9,10,11,12,13', 24);
	end
	creepsDance();
end

function creepsDance()
	danceDir = not danceDir;
	if danceDir then
		playAnim('bgGirls', 'danceRight', true);
	else
		playAnim('bgGirls', 'danceLeft', true);
	end
end