function onCreate()
	-- background shit
	if not lowQuality then
		makeLuaSprite('sky', 'philly/erect/sky', -100, 0);
		setScrollFactor('sky', 0.1, 0.1);

		makeLuaSprite('behindTrain', 'philly/erect/behindTrain', -40, 50);
	end
	
	makeLuaSprite('city', 'philly/erect/city', -10, 0);
	setScrollFactor('city', 0.3, 0.3);
	scaleObject('city', 0.85, 0.85);
	
	makeLuaSprite('train', 'philly/train', 2000, 360);
	makeLuaSprite('street', 'philly/erect/street', -40, 50);
	
	addLuaSprite('sky', false);
	addLuaSprite('city', false);

	makeLuaSprite('window', 'philly/window', -10, 0);
	setScrollFactor('window', 0.3, 0.3);
	scaleObject('window', 0.85, 0.85);
	setProperty('window.visible', false)
	addLuaSprite('window', false);

	addLuaSprite('behindTrain', false);
	addLuaSprite('train', false);
	addLuaSprite('street', false);

	-- PRECACHE SOUNDS TO PREVENT STUTTERS
	precacheSound('train_passes')
end

phillyLightsColors = {
	'502d64',
	'2663ac',
	'932c28',
	'329a6d',
	'b66f43'
};

trainMoving = false;
trainFrameTiming = 0;
startedMoving = false;

trainCars = 8;
trainFinishing = false;
trainCooldown = 0;

curLight = 0;
function onUpdate(elapsed)
	if trainMoving then
		trainFrameTiming = trainFrameTiming + elapsed;

		if trainFrameTiming >= 1 / 24 then
			updateTrainPos();
			trainFrameTiming = 0;
		end
	end
	setProperty('window.alpha', getProperty('window.alpha') - (crochet / 1000) * elapsed * 1.5);
end

function onBeatHit()
	if not trainMoving then
		trainCooldown = trainCooldown + 1;
	end

	if curBeat % 4 == 0 then
		for i = 0, 4 do
			setProperty('window.visible', false)
		end

		curLight = getRandomInt(0, 4);
		setProperty('window.visible', true)
		setProperty('window.alpha', 1)
		setProperty('window.color', getColorFromHex(phillyLightsColors[getRandomInt(0, #phillyLightsColors)]));
	end
	
	if curBeat % 8 == 4 and getRandomInt(0, 9) <= 3 and not trainMoving and trainCooldown > 8 then
		trainCooldown = getRandomInt(-4, 0);
		trainStart();
	end
end

function trainStart()
	trainMoving = true;
	playSound('train_passes', 1, 'trainSound');
end

function updateTrainPos()
	if getSoundTime('trainSound') >= 4700 then
		startedMoving = true;
		characterPlayAnim('gf', 'hairBlow');
		setProperty('gf.specialAnim', true);
	end

	if (startedMoving) then
		trainX = getProperty('train.x') - 400;
		setProperty('train.x', trainX);

		if trainX < -2000 and not trainFinishing then
			setProperty('train.x', -1150);
			trainX = -1150;
			trainCars = trainCars - 1;

			if trainCars <= 0 then
				trainFinishing = true;
			end
		end

		if trainX < -4000 and trainFinishing then
			trainReset();
		end
	end
end

function trainReset()
	setProperty('gf.danced', false); --Sets head to the correct position once the animation ends
	playAnim('gf', 'hairFall');
	setProperty('gf.specialAnim', true); --Prevents it from being reset by the idle animation
	setProperty('train.x', screenWidth + 200);
	trainMoving = false;
	trainCars = 8;
	trainFinishing = false;
	startedMoving = false;
end