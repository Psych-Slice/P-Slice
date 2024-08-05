function onCreate()
	makeLuaSprite('bg', 'christmas/evilBG', -400, -500);
	setScrollFactor('bg', 0.2, 0.2);
	scaleObject('bg', 0.8, 0.8);
	addLuaSprite('bg', false);

	makeLuaSprite('tree', 'christmas/evilTree', 300, -300);
	setScrollFactor('tree', 0.2, 0.2);
	addLuaSprite('tree', false);

	makeLuaSprite('snow', 'christmas/evilSnow', -200, 700);
	addLuaSprite('snow', false);
end