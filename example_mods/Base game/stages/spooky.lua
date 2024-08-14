--makeLuaSprite('thunderFlash', nil, -800, -400);
--"nil" means it loads no image sprites for optimization's sake, instead we create our own white square image with makeGraphic

animatedStage = false;
function onCreate()
	if not lowQuality then --If the player has Low Quality option turned off, it loads an animated version of the stage
		makeAnimatedLuaSprite('halloweenBG', 'halloween_bg', -200, -100);
		addAnimationByPrefix('halloweenBG', 'idle', 'halloweem bg0', 24, true);
		addAnimationByPrefix('halloweenBG', 'strike', 'halloweem bg lightning strike', 24, false);
		animatedStage = true;
	else --If the player has Low Quality option turned on, it loads a static version of the stage
		makeLuaSprite('halloweenBG', 'halloween_bg_low', -200, -100);
	end
	addLuaSprite('halloweenBG', false);

	makeLuaSprite('thunderFlash', nil, -200, -100);
	setScrollFactor('thunderFlash', 0, 0);
	makeGraphic('thunderFlash', screenWidth * 1.2, screenHeight * 1.2, 'FFFFFF');
	setBlendMode('thunderFlash', 'ADD'); --this works *kind of* like photoshop's blend modes
	addLuaSprite('thunderFlash', true);
	setProperty('thunderFlash.alpha', 0);

	-- PRECACHE SOUNDS TO PREVENT STUTTERS
	precacheSound('thunder_1');
	precacheSound('thunder_2');
end

lightningStrikeBeat = 0;
lightningOffset = 8;

function onBeatHit()
	--10% chance per beat hit
	if getRandomBool(10) and curBeat > lightningStrikeBeat + lightningOffset then
		lightningStrikeShit();
	end
end

function lightningStrikeShit()
	playSound('thunder_'..getRandomInt(1, 2));
	if animatedStage then
		playAnim('halloweenBG', 'strike');
	end

	lightningStrikeBeat = curBeat;
	lightningOffset = getRandomInt(8, 24);

	playAnim('boyfriend', 'scared', true);
	playAnim('gf', 'scared', true);

	if cameraZoomOnBeat then
		setProperty('camGame.zoom', getProperty('camGame.zoom') + 0.015);
		setProperty('camHUD.zoom', getProperty('camHUD.zoom') + 0.03);

		if not getProperty('camZooming') then
			--Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
			doTweenZoom('camGame thunder zoom', 'camGame', getProperty('defaultCamZoom'), 0.5, 'linear');
			doTweenZoom('camHUD thunder zoom', 'camHUD', 1, 0.5, 'linear');
		end
	end

	if flashingLights then
		setProperty('thunderFlash.alpha', 0.4);
		doTweenAlpha('thunderFlash alpha tween', 'thunderFlash', 0.5, 0.075, 'linear');
		runTimer('thunderFlash do end tween', 0.15);
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'thunderFlash do end tween' then
		doTweenAlpha('thunderFlash alpha tween', 'thunderFlash', 0, 0.25, 'linear');
	end
end