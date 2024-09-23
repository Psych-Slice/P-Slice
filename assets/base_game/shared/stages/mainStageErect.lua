
--How makeLuaSprite works:
--makeLuaSprite(<SPRITE VARIABLE>, <SPRITE IMAGE FILE NAME>, <X>, <Y>);
--"Sprite Variable" is how you refer to the sprite you just spawned in other methods like "setScrollFactor" and "scaleObject" for example

--so for example, i made the sprites "stagelight_left" and "stagelight_right", i can use "scaleObject('stagelight_left', 1.1, 1.1)"
--to adjust the scale of specifically the one stage light on left instead of both of them

function onCreate()
	-- background shit
	makeLuaSprite('stageback', 'erect/backDark', 729, -170);

	makeAnimatedLuaSprite('stageCrowd', 'erect/crowd', 560, 290);
	addAnimationByPrefix("stageCrowd", "idle", "Symbol 2 instance 1",12);
	setScrollFactor('stageCrowd', 0.8, 0.8);

	
	makeLuaSprite('stagefront', 'erect/bg', -603, -187);

	makeLuaSprite('server', 'erect/server', -361, 205);
	
	makeLuaSprite('lights', 'erect/lights', -601, -147);
	setScrollFactor('lights', 1.2, 1.2);
	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
		makeLuaSprite('stagelight_small', 'erect/brightLightSmall', 967, -103);
		setScrollFactor('stagelight_small', 1.2, 1.2);
		
		makeLuaSprite('orangeLOL', 'erect/orangeLight', 189, -195);

		makeLuaSprite('greenLOL', 'erect/lightgreen', -171, 242);
		makeLuaSprite('redLOL', 'erect/lightred', -101, 560);
		makeLuaSprite('TheOneAbove', 'erect/lightAbove', 804, -117);
	end

	addLuaSprite('stageback', false);
	addLuaSprite('stageCrowd', false);
	addLuaSprite('stagelight_small', false);
	addLuaSprite('stagefront', false);
	addLuaSprite('server', false);
	addLuaSprite('greenLOL', false);
	addLuaSprite('redLOL', false);
	addLuaSprite('orangeLOL', false);

	addLuaSprite('lights', false);
	addLuaSprite('TheOneAbove', false);
end