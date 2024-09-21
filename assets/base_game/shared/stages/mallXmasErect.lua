hasUpperBoppers = false;
function onCreate()
	makeLuaSprite('walls', 'christmas/bgWalls', -1000, -500);
	scaleObject('walls', 0.8, 0.8);
	setScrollFactor('walls', 0.2, 0.2);
	addLuaSprite('walls', false);

	--only loads if low quality option is turned off
	if not lowQuality then
		makeAnimatedLuaSprite('upperBoppers', 'christmas/erect/upperBop', -240, -90);
		addAnimationByPrefix('upperBoppers', 'idle', 'upperBop', 24, false);
		scaleObject('upperBoppers', 0.85, 0.85);
		setScrollFactor('upperBoppers', 0.33, 0.33);
		addLuaSprite('upperBoppers', false);
		
		makeLuaSprite('escalator', 'christmas/erect/bgEscalator', -1100, -600);
		scaleObject('escalator', 0.9, 0.9);
		setScrollFactor('escalator', 0.3, 0.3);
		addLuaSprite('escalator', false);
		hasUpperBoppers = true;
	end
	
	makeLuaSprite('tree', 'christmas/erect/christmasTree', 370, -250);
	setScrollFactor('tree', 0.4, 0.4);
	addLuaSprite('tree', false);
	
	makeAnimatedLuaSprite('bottomBoppers', 'christmas/erect/bottomBop', -300, 140);
	addAnimationByPrefix('bottomBoppers', 'idle', 'bottomBop', 24, false);
	setScrollFactor('bottomBoppers', 0.9, 0.9);
	addLuaSprite('bottomBoppers', false);
	
	makeLuaSprite('snow', 'christmas/fgSnow', -600, 700);
	addLuaSprite('snow', false);

	makeAnimatedLuaSprite('santa', 'christmas/santa', -840, 150);
	addAnimationByPrefix('santa', 'idle', 'santa idle in fear', 24, true);
	addLuaSprite('santa', false);
end

heyTimer = 0;
function onUpdate(elapsed)
	if heyTimer > 0 then
		heyTimer = heyTimer - elapsed;
		if heyTimer <= 0 then
			playAnim('bottomBoppers', 'idle', true);
			heyTimer = 0;
		end
	end
end

function onEvent(name, value1, value2)
	if name == 'Hey!' then
		value1 = tonumber(value1);
		if value1 == nil then
			value1 = 0;
		end

		value2 = tonumber(value2);
		if value2 == nil then
			value2 = 0.6;
		end

		if value1 ~= 0 then
			playAnim('bottomBoppers', 'hey', true);
			heyTimer = value2;
		end
	end
end

function onCountdownTick(counter)
	makeBoppersDance();
end

function onBeatHit()
	makeBoppersDance();
end

function makeBoppersDance()
	if hasUpperBoppers then
		playAnim('upperBoppers', 'idle', true);
	end

	if heyTimer <= 0 then
		playAnim('bottomBoppers', 'idle', true);
	end
end