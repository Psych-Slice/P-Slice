danced = false
function onCreate()
	-- background shit
	makeLuaSprite('skyBG', 'limo/limoSunset', -120, -50);
	setScrollFactor('skyBG', 0.1, 0.1);
	addLuaSprite('skyBG', false);

	if not lowQuality then
		bgLimoY = 480;
		makeAnimatedLuaSprite('bgLimo', 'limo/bgLimo', -150, bgLimoY);
		addAnimationByPrefix('bgLimo', 'background limo pink', 'background limo pink', 24, true);
		setScrollFactor('bgLimo', 0.4, 0.4);
		addLuaSprite('bgLimo', false);

		for i = 0, 4 do
			tag = 'limoDancer'..i;
			makeAnimatedLuaSprite(tag, 'limo/limoDancer', (370 * i) + 170, bgLimoY - 400)
			addAnimationByIndices(tag, 'danceLeft', 'bg dancer sketch PINK', '0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14', 24);
			addAnimationByIndices(tag, 'danceRight', 'bg dancer sketch PINK', '15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29', 24);
			setScrollFactor(tag, 0.4, 0.4);
			addLuaSprite(tag, false);
		end
	end

	makeLuaSprite('fastCar', 'limo/fastCarLol', -300, -160);
	addLuaSprite('fastCar', false);
	resetFastCar();
	
	makeAnimatedLuaSprite('stageLimo', 'limo/limoDrive', -120, 550);
	addAnimationByPrefix('stageLimo', 'Limo stage', 'Limo stage', 24, true);
	setObjectOrder('stageLimo', getObjectOrder('gfGroup') + 1);
end

function onBeatHit()
	animToPlay = 'danceRight';
	if danced then
		animToPlay = 'danceLeft';
	end

	for i = 0, 4 do
		playAnim('limoDancer'..i, animToPlay, true);
	end
	
	if getRandomBool(10) and fastCarCanDrive then
		fastCarDrive();
	end
	danced = not danced;
end

fastCarCanDrive = true;
function resetFastCar()
	setProperty('fastCar.x', -12600);
	setProperty('fastCar.y', getRandomInt(140, 250));
	setProperty('fastCar.velocity.x', 0);
	fastCarCanDrive = true;
end

function fastCarDrive()
	playSound('carPass'..getRandomInt(0, 1), 0.7);
	setProperty('fastCar.velocity.x', (getRandomInt(170, 220) / (1 / framerate)) * 3);
	runTimer('reset car timer', 2);
	fastCarCanDrive = false;
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'reset car timer' then
		resetFastCar();
	end
end