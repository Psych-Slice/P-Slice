--makeLuaSprite('thunderFlash', nil, -800, -400);
--"nil" means it loads no image sprites for optimization's sake, instead we create our own white square image with makeGraphic

animatedStage = false;
function onCreate()
	--luaDebugMode = true;
	makeAnimatedLuaSprite('halloweenOutside', 'erect/bgtrees', 200, 50);
	addAnimationByPrefix('halloweenOutside', 'idle', 'bgtrees0', 24, true);
	setScrollFactor("halloweenOutside", 0.8, 0.8)
	addLuaSprite('halloweenOutside', false);

	addHaxeLibrary("RainShader","shaders")
	addHaxeLibrary("StringTools")
	runHaxeCode([[
	var shader = new shaders.RainShader();
	shader.scale = FlxG.height / 200 * 2;
		shader.intensity = 0.4;
		shader.spriteMode = true;

	var target = game.variables.get("halloweenOutside");
	target.shader = shader;
	target.animation.callback = function(name,b,c) { 
		shader.updateFrameInfo(target.frame); 
		shader.update(FlxG.elapsed);
	};
	]])

	animatedStage = true;
	 --If the player has Low Quality option turned on, it loads a static version of the stage
	
	makeLuaSprite('halloweenBG-dark', 'erect/bgDark', -360, -220);
	addLuaSprite('halloweenBG-dark', false);

	makeLuaSprite('halloweenBG-light', 'erect/bgLight', -360, -220);
	setProperty('halloweenBG-light.alpha', 0);
	addLuaSprite("halloweenBG-light",false)
	
	addHaxeLibrary("Character","objects")
	addHaxeLibrary("ABotManager","mikolka")
	bfName = boyfriendName == 'pico-dark' and "pico-playable" or "boyfriend"
	runHaxeCode([[
		var bico = new Character(game.boyfriend.x,game.boyfriend.y,']]..bfName..[[',true);
		game.variables.set('boyfriend-ghost',bico);
		game.add(bico);
		bico.dance();
	]])
	runHaxeCode([[
		var bico = new Character(game.dad.x,game.dad.y,'spooky',true);
		bico.flipX = false;
		game.variables.set('dad-ghost',bico);
		game.add(bico);
		bico.dance();
	]])
	xx = gfName == 'nene-dark' and "nene" or "gf"
	runHaxeCode([[
		var gfMode = ']]..xx..[[';
		var bico = new Character(game.gf.x,game.gf.y,gfMode);
		if(gfMode == 'nene') bico.y -=190;
		game.variables.set('gf-ghost',bico);
		game.add(bico);
		bico.dance();
	]])

	
	makeLuaSprite('stairs-dark', 'erect/stairsDark', 966, -225);
	addLuaSprite('stairs-dark', true);

	makeLuaSprite('stairs-light', 'erect/stairsLight', 966, -225);
	setProperty('stairs-light.alpha', 0);
	addLuaSprite('stairs-light', true);

	playAnim("halloweenOutside", "idle")

	if not luaDebugMode then
		setProperty("gf-ghost.alpha", 0)
		setProperty("boyfriend-ghost.alpha", 0)
		setProperty("dad-ghost.alpha", 0)
	end
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
	addHaxeLibrary("StringTools")
	runHaxeCode([[
		var bico = game.variables.get('boyfriend-ghost');
		var daddy = game.variables.get('dad-ghost');
		var bestie = game.variables.get('gf-ghost');
		if (]]..curBeat..[[ % game.boyfriend.danceEveryNumBeats == 0 && !StringTools.startsWith(game.boyfriend.getAnimationName(),'sing') && !game.boyfriend.stunned)
			bico.dance();
		if (]]..curBeat..[[ % game.dad.danceEveryNumBeats == 0 && !StringTools.startsWith(game.dad.getAnimationName(),'sing') && !game.dad.stunned)
			daddy.dance();
		if (]]..curBeat..[[ % game.gf.danceEveryNumBeats == 0 && !StringTools.startsWith(game.gf.getAnimationName(),'sing') && !game.gf.stunned)
			bestie.dance();
		]])
end
---
-- Code stolen from DDTO HUD V2.5


function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
	anims = { "singLEFT","singDOWN","singUP","singRIGHT"}
	runHaxeCode("game.variables.get('boyfriend-ghost').playAnim('"..anims[noteData+1].."',true);")
end



function noteMiss(membersIndex, noteData, noteType, isSustainNote)
	anims = { "singLEFT","singDOWN","singUP","singRIGHT"}
	runHaxeCode("game.variables.get('boyfriend-ghost').playAnim('"..anims[noteData+1].."miss',true);")
end


function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
	anims = { "singLEFT","singDOWN","singUP","singRIGHT"}
	runHaxeCode("game.variables.get('dad-ghost').playAnim('"..anims[noteData+1].."',true);")
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
		setProperty('stairs-light.alpha', 0);
		setProperty('boyfriend.alpha', 1);
		setProperty('dad.alpha', 1);
		setProperty('gf.alpha', 1);
		if not luaDebugMode then
			setProperty("gf-ghost.alpha", 0)
			setProperty("boyfriend-ghost.alpha", 0)
			setProperty("dad-ghost.alpha", 0)
		end
	elseif tag == 'scare pico' then
		

		playAnim('boyfriend', 'scared', true);
		playAnim('gf', 'scared', true);
		if flashingLights then
			runHaxeCode("ABotManager.ABot_plink();")
			setProperty('boyfriend.alpha', 0);
			setProperty('dad.alpha', 0);
			setProperty('gf.alpha', 0);
			setProperty('halloweenBG-light.alpha', 1);
			setProperty('stairs-light.alpha', 1);
			if not luaDebugMode then
				setProperty("gf-ghost.alpha", 1)
				setProperty("boyfriend-ghost.alpha", 1)
				setProperty("dad-ghost.alpha", 1)
				doTweenAlpha('qw', 'boyfriend-ghost', 0, 1.5, 'linear');
				doTweenAlpha('az', 'dad-ghost', 0, 1.5, 'linear');
				doTweenAlpha('xc', 'gf-ghost', 0, 1.5, 'linear');
			end

			doTweenAlpha('thunderFlash alpha tween', 'halloweenBG-light', 0, 1.5, 'linear');
			doTweenAlpha('thunderFlash alpha stairs', 'stairs-light', 0, 1.5, 'linear');
			doTweenAlpha('Nene alpha tween', 'gf', 1, 1.5, 'linear');
			doTweenAlpha('Kid alpha tween', 'dad', 1, 1.5, 'linear');
			doTweenAlpha('Pico alpha tween', 'boyfriend', 1, 1.5, 'linear');
		end
	end
end
