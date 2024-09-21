--makeLuaSprite('thunderFlash', nil, -800, -400);
--"nil" means it loads no image sprites for optimization's sake, instead we create our own white square image with makeGraphic

animatedStage = false;
function onCreate()
	luaDebugMode = true;
	makeAnimatedLuaSprite('halloweenOutside', 'erect/bgtrees', 200, 50);
	addAnimationByPrefix('halloweenOutside', 'idle', 'bgtrees0', 24, true);
	setScrollFactor("halloweenOutside", 0.8, 0.8)
	addLuaSprite('halloweenOutside', false);
	
	addHaxeLibrary("RainShader","shaders")
	runHaxeCode([[
	var shader = new shaders.RainShader();
	shader.scale = FlxG.height / 200 * 2;
		shader.intensity = 0.4;
		shader.spriteMode = true;

	var target = game.variables.get("halloweenOutside");
	target.shader = shader;
	target.animation.callback = function(name,b,c) { shader.updateFrameInfo(target.frame); };
	]])
	
	animatedStage = true;
	 --If the player has Low Quality option turned on, it loads a static version of the stage
	makeLuaSprite('halloweenBG-dark', 'erect/bgDark', -360, -220);
	addLuaSprite('halloweenBG-dark', false);
	makeLuaSprite('stairs-dark', 'erect/stairsDark', 966, -225);
	addLuaSprite('halloweenBG-dark', false);

	makeLuaSprite('halloweenBG-light', 'erect/bgLight', -360, -220);
	setProperty('halloweenBG-light.alpha', 0);
	addLuaSprite("halloweenBG-light",false)

	playAnim("halloweenOutside", "idle")

	-- PRECACHE SOUNDS TO PREVENT STUTTERS
	precacheSound('thunder_1');
	precacheSound('thunder_2');
end

lightningStrikeBeat = 0;
lightningOffset = 8;

function onUpdate(elapsed)
	runHaxeCode('shader.update('+elapsed+');')
end
function onBeatHit()
	--10% chance per beat hit
	if getRandomBool(10) and curBeat > lightningStrikeBeat + lightningOffset then
		lightningStrikeShit();
	end
end

function lightningStrikeShit()
	playSound('thunder_'..getRandomInt(1, 2));

	lightningStrikeBeat = curBeat;
	lightningOffset = getRandomInt(8, 24);
	
	runTimer("reset pico",0.06);
	runTimer("scare pico",0.12);
	if cameraZoomOnBeat then
		setProperty('camGame.zoom', getProperty('camGame.zoom') + 0.015);
		setProperty('camHUD.zoom', getProperty('camHUD.zoom') + 0.03);

		if not getProperty('camZooming') then
			--Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
			doTweenZoom('camGame thunder zoom', 'camGame', getProperty('defaultCamZoom'), 0.5, 'linear');
			doTweenZoom('camHUD thunder zoom', 'camHUD', 1, 0.5, 'linear');
		end
	end

	
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'reset pico' then
		setProperty('halloweenBG-light.alpha', 0);
		--setProperty('boyfriend.alpha', 1);
		setProperty('dad.alpha', 1);
		setProperty('gf.alpha', 1);
	elseif tag == 'scare pico' then
		

		playAnim('boyfriend', 'scared', true);
		playAnim('gf', 'scared', true);
		if flashingLights then
			setProperty('boyfriend.alpha', 0);
			setProperty('dad.alpha', 0);
			setProperty('gf.alpha', 0);
			setProperty('halloweenBG-light.alpha', 1);

			doTweenAlpha('thunderFlash alpha tween', 'halloweenBG-light', 0, 1.5, 'linear');
			doTweenAlpha('Nene alpha tween', 'gf', 1, 1.5, 'linear');
			doTweenAlpha('Kid alpha tween', 'dad', 1, 1.5, 'linear');
			doTweenAlpha('Pico alpha tween', 'boyfriend', 1, 1.5, 'linear');
		end
	end
end
