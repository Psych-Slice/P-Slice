-- Lua stuff
tankX = 400;
tankSpeed = 0;
tankAngle = 0;
finishedGameover = false;
startedPlaying = false;

function onCreate()
	-- background shit
	tankSpeed = getRandomInt(5, 7);
	tankAngle = getRandomInt(-90, 45);
	makeLuaSprite('tankSky', 'tankSky', -400, -400);
	setScrollFactor('tankSky', 0, 0);

	makeLuaSprite('tankBuildings', 'tankBuildings', -200, 0);
	setScrollFactor('tankBuildings', 0.3, 0.3);
	scaleObject('tankBuildings', 1.1, 1.1);

	makeLuaSprite('tankRuins', 'tankRuins', -200, 0);
	setScrollFactor('tankRuins', 0.35, 0.35);
	scaleObject('tankRuins', 1.1, 1.1);

	makeAnimatedLuaSprite('tankWatchtower', 'tankWatchtower', 100, 50);
	addAnimationByPrefix('tankWatchtower', 'idle', 'watchtower', 24, false);
	setScrollFactor('tankWatchtower', 0.5, 0.5);

	makeAnimatedLuaSprite('tankRolling', 'tankRolling', 300, 300);
	addAnimationByPrefix('tankRolling', 'idle', 'BG tank w lighting', 24, true);
	setScrollFactor('tankRolling', 0.5, 0.5);

	makeLuaSprite('tankGround', 'tankGround', -420, -150);
	scaleObject('tankGround', 1.15, 1.15);
	
	-- those are only loaded if you have Low quality turned off, to decrease loading times and memory
	if not lowQuality then
		makeLuaSprite('tankClouds', 'tankClouds', getRandomInt(-700, -100), getRandomInt(-20, 20));
		setScrollFactor('tankClouds', 0.1, 0.1);
		setProperty('tankClouds.velocity.x', getRandomInt(5, 15));

		makeLuaSprite('tankMountains', 'tankMountains', -300, -20);
		setScrollFactor('tankMountains', 0.2, 0.2);
		scaleObject('tankMountains', 1.2, 1.2);

		makeAnimatedLuaSprite('smokeLeft', 'smokeLeft', -200, -100);
		addAnimationByPrefix('smokeLeft', 'idle', 'SmokeBlurLeft');
		setScrollFactor('smokeLeft', 0.4, 0.4);

		makeAnimatedLuaSprite('smokeRight', 'smokeRight', 1100, -100);
		addAnimationByPrefix('smokeRight', 'idle', 'SmokeRight');
		setScrollFactor('smokeRight', 0.4, 0.4);
	end

	addLuaSprite('tankSky', false);
	addLuaSprite('tankClouds', false);
	addLuaSprite('tankMountains', false);
	addLuaSprite('tankBuildings', false);
	addLuaSprite('tankRuins', false);
	addLuaSprite('smokeLeft', false);
	addLuaSprite('smokeRight', false);
	addLuaSprite('tankWatchtower', false);
	addLuaSprite('tankRolling', false);
	addLuaSprite('tankGround', false);


	-- foreground shit
	makeAnimatedLuaSprite('tank0', 'tank0', -500, 650);
	addAnimationByPrefix('tank0', 'idle', 'fg', 24, false);
	setScrollFactor('tank0', 1.7, 1.5);
	
	makeAnimatedLuaSprite('tank2', 'tank2', 450, 940);
	addAnimationByPrefix('tank2', 'idle', 'foreground', 24, false);
	setScrollFactor('tank2', 1.5, 1.5);
	
	makeAnimatedLuaSprite('tank5', 'tank5', 1620, 700);
	addAnimationByPrefix('tank5', 'idle', 'fg', 24, false);
	setScrollFactor('tank5', 1.5, 1.5);
	
	if not lowQuality then
		makeAnimatedLuaSprite('tank1', 'tank1', -300, 750);
		addAnimationByPrefix('tank1', 'idle', 'fg', 24, false);
		setScrollFactor('tank1', 2.0, 0.2);
		
		makeAnimatedLuaSprite('tank4', 'tank4', 1300, 900);
		addAnimationByPrefix('tank4', 'idle', 'fg', 24, false);
		setScrollFactor('tank4', 1.5, 1.5);
		
		makeAnimatedLuaSprite('tank3', 'tank3', 1300, 1200);
		addAnimationByPrefix('tank3', 'idle', 'fg', 24, false);
		setScrollFactor('tank3', 3.5, 2.5);
	end

	addLuaSprite('tank0', true);
	if not lowQuality then
		addLuaSprite('tank1', true);
	end
	addLuaSprite('tank2', true);
	if not lowQuality then
		addLuaSprite('tank4', true);
	end
	addLuaSprite('tank5', true);
	if not lowQuality then
		addLuaSprite('tank3', true);
	end

	moveTank(0);
end

function onUpdate(elapsed)
	moveTank(elapsed);
	
	if inGameOver and not startedPlaying and not finishedGameover then
		setPropertyFromClass('flixel.FlxG', 'sound.music.volume', 0.2);
	end
end

function moveTank(elapsed)
	if not inCutscene then
		tankAngle = tankAngle + (elapsed * tankSpeed);
		setProperty('tankRolling.angle', tankAngle - 90 + 15);
		setProperty('tankRolling.x', tankX + (1500 * math.cos(math.pi / 180 * (1 * tankAngle + 180))));
		setProperty('tankRolling.y', 1300 + (1100 * math.sin(math.pi / 180 * (1 * tankAngle + 180))));
	end
end

-- Gameplay/Song interactions
function onBeatHit()
	-- triggered 2 times per section
	if curBeat % 2 == 0 then
		playAnim('tankWatchtower', 'idle', true);
		
		playAnim('tank0', 'idle', true);
		playAnim('tank2', 'idle', true);
		playAnim('tank5', 'idle', true);
		if not lowQuality then
			playAnim('tank1', 'idle', true);
			playAnim('tank3', 'idle', true);
			playAnim('tank4', 'idle', true);
		end
	end
end

-- Game over voiceline
function onGameOverStart()
	runTimer('playJeffVoiceline', 2.7);
end

function onGameOverConfirm(reset)
	finishedGameover = true;
end

function onTimerCompleted(tag, loops, loopsLeft)
	-- A tween you called has been completed, value "tag" is it's tag
	if not finishedGameover and tag == 'playJeffVoiceline' then
		soundName = 'jeffGameover/jeffGameover-23';
		playSound(soundName, 1, 'voiceJeff');
		startedPlaying = true;
	end
end

function onSoundFinished(tag)
	if tag == 'voiceJeff' and not finishedGameover then
		soundFadeIn(nil, 4, 0.2, 1);
	end
end