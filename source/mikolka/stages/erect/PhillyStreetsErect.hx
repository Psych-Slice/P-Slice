package mikolka.stages.erect;

import openfl.filters.BlurFilter;
import mikolka.compatibility.VsliceOptions;
import shaders.AdjustColorShader;
import flixel.addons.display.FlxBackdrop;
import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxTiledSprite;
import shaders.RainShader;
#if !LEGACY_PSYCH
import substates.PauseSubState;
import cutscenes.CutsceneHandler;
#end

import flixel.FlxSubState;

class PhillyStreetsErect extends BaseStage
    {
        var rainShader:RainShader;
        var rainShaderStartIntensity:Float = 0;
        var rainShaderEndIntensity:Float = 0.01;
    
        var rainSndAmbience:FlxSound;
        var carSndAmbience:FlxSound;
    
        var scrollingSky:FlxTiledSprite;
        var phillyTraffic:BGSprite;
    
        var phillyCars:BGSprite;
        var phillyCars2:BGSprite;
    
        var picoFade:FlxSprite;
        var spraycanPile:BGSprite;
    
        var darkenable:Array<FlxSprite> = [];
	    var colorShader:AdjustColorShader;
    
        override function create()
        {
            buildMist();
            if (!VsliceOptions.LOW_QUALITY)
            {
                var skyImage = Paths.image('phillyStreets/erect/phillySkybox');
                scrollingSky = new FlxTiledSprite(skyImage, skyImage.width + 400, skyImage.height, true, false);
                scrollingSky.antialiasing = VsliceOptions.ANTIALIASING;
                scrollingSky.setPosition(-650, -375);
                scrollingSky.scrollFactor.set(0.1, 0.1);
                scrollingSky.scale.set(0.65, 0.65);
                add(scrollingSky);
                darkenable.push(scrollingSky);
    
                var phillySkyline:BGSprite = new BGSprite('phillyStreets/erect/phillySkyline', -545, -273, 0.2, 0.2);
                add(phillySkyline);
                darkenable.push(phillySkyline);
    
                var phillyForegroundCity:BGSprite = new BGSprite('phillyStreets/erect/phillyForegroundCity', 625, 94, 0.3, 0.3);
                add(phillyForegroundCity);
                darkenable.push(phillyForegroundCity);
            }
    
            add(mist5);
            var phillyConstruction:BGSprite = new BGSprite('phillyStreets/erect/phillyConstruction', 1800, 364, 0.7, 1);
            add(phillyConstruction);
            darkenable.push(phillyConstruction);
    
            var phillyHighwayLights:BGSprite = new BGSprite('phillyStreets/erect/phillyHighwayLights', 284, 305, 1, 1);
            add(phillyHighwayLights);
            darkenable.push(phillyHighwayLights);
    
            if (!VsliceOptions.LOW_QUALITY)
            {
                var phillyHighwayLightsLightmap:BGSprite = new BGSprite('phillyStreets/phillyHighwayLights_lightmap', 284, 305, 1, 1);
                phillyHighwayLightsLightmap.blend = ADD;
                phillyHighwayLightsLightmap.alpha = 0.6;
                add(phillyHighwayLightsLightmap);
                darkenable.push(phillyHighwayLightsLightmap);
            }
    
            var phillyHighway:BGSprite = new BGSprite('phillyStreets/erect/phillyHighway', 139, 209, 1, 1);
            add(phillyHighway);
            darkenable.push(phillyHighway);
    
            if (!VsliceOptions.LOW_QUALITY)
            {
                var phillySmog:BGSprite = new BGSprite('phillyStreets/phillySmog', -6, 245, 0.8, 1);
                add(phillySmog);
                darkenable.push(phillySmog);
    
                for (i in 0...2)
                {
                    var car:BGSprite = new BGSprite('phillyStreets/erect/phillyCars', 1200, 818, 0.9, 1, ['car1', 'car2', 'car3', 'car4'], false);
                    add(car);
                    switch (i)
                    {
                        case 0:
                            phillyCars = car;
                        case 1:
                            phillyCars2 = car;
                    }
                    darkenable.push(car);
                }
                phillyCars2.flipX = true;
    
                phillyTraffic = new BGSprite('phillyStreets/erect/phillyTraffic', 1840, 608, 0.9, 1, ['redtogreen', 'greentored'], false);
                add(phillyTraffic);
                darkenable.push(phillyTraffic);
    
                var phillyTrafficLightmap:BGSprite = new BGSprite('phillyStreets/erect/phillyTraffic_lightmap', 1840, 608, 0.9, 1);
                phillyTrafficLightmap.blend = ADD;
                phillyTrafficLightmap.alpha = 0.6;
                add(phillyTrafficLightmap);
                darkenable.push(phillyTrafficLightmap);
            }
    
            add(mist4);
            //? gradient
            var gray1:BGSprite = new BGSprite('phillyStreets/erect/greyGradient', 88, 317, 1, 1);
            gray1.alpha = 0.3;
            gray1.blend = ADD;
            add(gray1);

            var gray2:BGSprite = new BGSprite('phillyStreets/erect/greyGradient', 88, 317, 1, 1);
            gray2.alpha = 0.8;
            gray2.blend = MULTIPLY;
            add(gray2);

            var phillyForeground:BGSprite = new BGSprite('phillyStreets/erect/phillyForeground', 88, 317, 1, 1);
            add(phillyForeground);
            darkenable.push(phillyForeground);
    
            if (!VsliceOptions.LOW_QUALITY)
            {
                picoFade = new FlxSprite();
                picoFade.antialiasing = VsliceOptions.ANTIALIASING;
                picoFade.alpha = 0;
                add(picoFade);
                darkenable.push(picoFade);
            }
    
            if (VsliceOptions.SHADERS)
                setupRainShader();
    
            
            var _song = PlayState.SONG;

            setDefaultGF('gf');
            gfGroup.y += 200;
            gfGroup.x += 50;
    
        }
    
        var mist0:FlxBackdrop;
	var mist1:FlxBackdrop;
	var mist2:FlxBackdrop;
	var mist3:FlxBackdrop;
	var mist4:FlxBackdrop;
	var mist5:FlxBackdrop;

    function makeMist(image:String,scrollFac:Float,alpha:Float,velX:Float) {
        var mist = new FlxBackdrop(Paths.image('phillyStreets/erect/$image'), X);
		mist.setPosition(-650, -100);
		mist.scrollFactor.set(scrollFac, scrollFac);
		//mist.zIndex = 1000;
        mist.blend = ADD;
		mist.color = 0xFF5c5c5c;
		mist.alpha = alpha;
		mist.velocity.x = velX;
        return mist;
    }
	function buildMist() // Probable will be really broken 😞
	{

		

		mist0 = makeMist('mistMid',1.2,0.6,172); //1000

		mist1 = makeMist('mistMid',1.1,0.6,150); //1000

		mist2 = makeMist('mistBack',1.2,0.8,-80); //1001

		mist3 = makeMist('mistMid',0.95,0.5,-50); //99
		mist3.scale.set(0.8, 0.8);

		mist4 = makeMist('mistBack',0.8,1,40); //88
		mist4.scale.set(0.7, 0.7);

		mist5 = makeMist('mistMid',0.5,1,20); //39
		mist5.scale.set(1.1, 1.1);

	}

    var _timer:Float = 0;
    function updateMist(elapsed:Float) {
        _timer += elapsed;
		mist0.y = 660 + (Math.sin(_timer*0.35)*70);
		mist1.y = 500 + (Math.sin(_timer*0.3)*80);
		mist2.y = 540 + (Math.sin(_timer*0.4)*60);
		mist3.y = 230 + (Math.sin(_timer*0.3)*70);
		mist4.y = 170 + (Math.sin(_timer*0.35)*50);
		mist5.y = -80 + (Math.sin(_timer*0.08)*100);
		// mist3.y = -20 + (Math.sin(_timer*0.5)*200);
		// mist4.y = -180 + (Math.sin(_timer*0.4)*300);
		// mist5.y = -450 + (Math.sin(_timer*0.2)*1xxx50);
		//trace(mist1.y);
    }
    
        override function createPost()
        {
            super.createPost();
            spraycanPile = new BGSprite('SpraycanPile', 920, 1045, 1, 1);

            add(spraycanPile);
            darkenable.push(spraycanPile);
            add(mist0);
            add(mist1);
            add(mist2);
    
            carSndAmbience = new FlxSound().loadEmbedded(Paths.sound("ambience/car"), true);
            carSndAmbience.volume = 0.01;
            carSndAmbience.play(false, FlxG.random.float(0, carSndAmbience.length));
    
            if (VsliceOptions.SHADERS)
            {
                // ? ambience
                rainSndAmbience = new FlxSound().loadEmbedded(Paths.sound("ambience/rain"), true);
                rainSndAmbience.volume = 0.01;
                rainSndAmbience.play(false, FlxG.random.float(0, rainSndAmbience.length));

                colorShader = new AdjustColorShader();
                colorShader.hue = -5;
                colorShader.saturation = -40;
                colorShader.contrast = -25;
                colorShader.brightness = -20;
                boyfriend.shader = colorShader;
                dad.shader = colorShader;
                gf.shader = colorShader;
            }
        }
    
    
        var videoEnded:Bool = false;
    
    
        override function startSong()
        {
            super.startSong();
            carSndAmbience.volume = 0.1;
        }
    
        override function openSubState(SubState:FlxSubState) {
            super.openSubState(SubState);
            if(!Std.isOfType(SubState,PauseSubState)) return;
            // Temporarily stop ambiance.
            if (rainSndAmbience != null) {
                rainSndAmbience.pause();
            }
            if (carSndAmbience != null) {
                carSndAmbience.pause();
            }
            PlayState.instance.subStateClosed.addOnce((sub) ->{
                carSndAmbience.volume = 0.1;
                if (carSndAmbience != null) carSndAmbience.resume();
                if (rainSndAmbience != null) rainSndAmbience.resume();
            });
        }

        var casingGroup:FlxSpriteGroup;
        var gunPrepSnd:FlxSound;
        var bonkSnd:FlxSound;
        var lightCanSnd:FlxSound;
        var kickCanSnd:FlxSound;
        var kneeCanSnd:FlxSound;
    
        function setupRainShader()
        {
            rainShader = new RainShader();
            rainShader.scale = FlxG.height / 200;
            switch (songName)
            {
                case 'darnell':
                    rainShaderStartIntensity = 0;
                    rainShaderEndIntensity = 0.1;
                case 'lit-up':
                    rainShaderStartIntensity = 0.1;
                    rainShaderEndIntensity = 0.2;
                case '2hot':
                    rainShaderStartIntensity = 0.2;
                    rainShaderEndIntensity = 0.4;
            }
            rainShader.intensity = rainShaderStartIntensity;
            FlxG.camera.setFilters([new ShaderFilter(rainShader)]);
        }
    
        override function update(elapsed:Float)
        {
            if (scrollingSky != null)
                scrollingSky.scrollX -= elapsed * 22;
    
            if (rainShader != null)
            {
                var remappedIntensityValue:Float = FlxMath.remapToRange(Conductor.songPosition, 0, (FlxG.sound.music != null ? FlxG.sound.music.length : 0),
                    rainShaderStartIntensity, rainShaderEndIntensity);
                rainShader.intensity = remappedIntensityValue;
                rainShader.updateViewInfo(FlxG.width, FlxG.height, FlxG.camera);
                rainShader.update(elapsed);
    
                if (rainSndAmbience != null)
                {
                    rainSndAmbience.volume = Math.min(0.3, remappedIntensityValue * 2);
                }
            }
            updateMist(elapsed);
            super.update(elapsed);
        }
    
        var lightsStop:Bool = false;
        var lastChange:Int = 0;
        var changeInterval:Int = 8;
    
        var carWaiting:Bool = false;
        var carInterruptable:Bool = true;
        var car2Interruptable:Bool = true;
    
        override function beatHit()
        {
            // if(curBeat % 2 == 0) abot.beatHit();
            super.beatHit();
    
            if (VsliceOptions.LOW_QUALITY)
                return;
    
            if (FlxG.random.bool(10) && curBeat != (lastChange + changeInterval) && carInterruptable == true)
            {
                if (lightsStop == false)
                    driveCar(phillyCars);
                else
                    driveCarLights(phillyCars);
            }
    
            if (FlxG.random.bool(10) && curBeat != (lastChange + changeInterval) && car2Interruptable == true && lightsStop == false)
                driveCarBack(phillyCars2);
    
            if (curBeat == (lastChange + changeInterval))
                changeLights(curBeat);
        }
    
        function changeLights(beat:Int):Void
        {
            lastChange = beat;
            lightsStop = !lightsStop;
    
            if (lightsStop)
            {
                phillyTraffic.animation.play('greentored');
                changeInterval = 20;
            }
            else
            {
                phillyTraffic.animation.play('redtogreen');
                changeInterval = 30;
    
                if (carWaiting == true)
                    finishCarLights(phillyCars);
            }
        }
    
        function finishCarLights(sprite:BGSprite):Void
        {
            carWaiting = false;
            var duration:Float = FlxG.random.float(1.8, 3);
            var rotations:Array<Int> = [-5, 18];
            var offset:Array<Float> = [306.6, 168.3];
            var startdelay:Float = FlxG.random.float(0.2, 1.2);
    
            var path:Array<FlxPoint> = [
                FlxPoint.get(1950 - offset[0] - 80, 980 - offset[1] + 15),
                FlxPoint.get(2400 - offset[0], 980 - offset[1] - 50),
                FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 40)
            ];
    
            FlxTween.angle(sprite, rotations[0], rotations[1], duration, {ease: FlxEase.sineIn, startDelay: startdelay});
            FlxTween.quadPath(sprite, path, duration, true, {ease: FlxEase.sineIn, startDelay: startdelay, onComplete: function(_) carInterruptable = true});
        }
    
        function driveCarLights(sprite:BGSprite):Void
        {
            carInterruptable = false;
            FlxTween.cancelTweensOf(sprite);
            var variant:Int = FlxG.random.int(1, 4);
            sprite.animation.play('car' + variant);
            var extraOffset = [0, 0];
            var duration:Float = 2;
    
            switch (variant)
            {
                case 1:
                    duration = FlxG.random.float(1, 1.7);
                case 2:
                    extraOffset = [20, -15];
                    duration = FlxG.random.float(0.9, 1.5);
                case 3:
                    extraOffset = [30, 50];
                    duration = FlxG.random.float(1.5, 2.5);
                case 4:
                    extraOffset = [10, 60];
                    duration = FlxG.random.float(1.5, 2.5);
            }
            var rotations:Array<Int> = [-7, -5];
            var offset:Array<Float> = [306.6, 168.3];
            sprite.offset.set(extraOffset[0], extraOffset[1]);
    
            var path:Array<FlxPoint> = [
                FlxPoint.get(1500 - offset[0] - 20, 1049 - offset[1] - 20),
                FlxPoint.get(1770 - offset[0] - 80, 994 - offset[1] + 10),
                FlxPoint.get(1950 - offset[0] - 80, 980 - offset[1] + 15)
            ];
    
            FlxTween.angle(sprite, rotations[0], rotations[1], duration, {ease: FlxEase.cubeOut});
            FlxTween.quadPath(sprite, path, duration, true, {
                ease: FlxEase.cubeOut,
                onComplete: function(_)
                {
                    carWaiting = true;
                    if (lightsStop == false)
                        finishCarLights(phillyCars);
                }
            });
        }
    
        function driveCar(sprite:BGSprite):Void
        {
            carInterruptable = false;
            FlxTween.cancelTweensOf(sprite);
            var variant:Int = FlxG.random.int(1, 4);
            sprite.animation.play('car' + variant);
    
            var extraOffset = [0, 0];
            var duration:Float = 2;
            switch (variant)
            {
                case 1:
                    duration = FlxG.random.float(1, 1.7);
                case 2:
                    extraOffset = [20, -15];
                    duration = FlxG.random.float(0.6, 1.2);
                case 3:
                    extraOffset = [30, 50];
                    duration = FlxG.random.float(1.5, 2.5);
                case 4:
                    extraOffset = [10, 60];
                    duration = FlxG.random.float(1.5, 2.5);
            }
    
            var offset:Array<Float> = [306.6, 168.3];
            sprite.offset.set(extraOffset[0], extraOffset[1]);
    
            var rotations:Array<Int> = [-8, 18];
            var path:Array<FlxPoint> = [
                FlxPoint.get(1570 - offset[0], 1049 - offset[1] - 30),
                FlxPoint.get(2400 - offset[0], 980 - offset[1] - 50),
                FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 40)
            ];
    
            FlxTween.angle(sprite, rotations[0], rotations[1], duration);
            FlxTween.quadPath(sprite, path, duration, true, {onComplete: function(_) carInterruptable = true});
        }
    
        function driveCarBack(sprite:FlxSprite):Void
        {
            car2Interruptable = false;
            FlxTween.cancelTweensOf(sprite);
            var variant:Int = FlxG.random.int(1, 4);
            sprite.animation.play('car' + variant);
    
            var extraOffset = [0, 0];
            var duration:Float = 2;
            switch (variant)
            {
                case 1:
                    duration = FlxG.random.float(1, 1.7);
                case 2:
                    extraOffset = [20, -15];
                    duration = FlxG.random.float(0.6, 1.2);
                case 3:
                    extraOffset = [30, 50];
                    duration = FlxG.random.float(1.5, 2.5);
                case 4:
                    extraOffset = [10, 60];
                    duration = FlxG.random.float(1.5, 2.5);
            }
    
            var offset:Array<Float> = [306.6, 168.3];
            sprite.offset.set(extraOffset[0], extraOffset[1]);
    
            var rotations:Array<Int> = [18, -8];
            var path:Array<FlxPoint> = [
                FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 60),
                FlxPoint.get(2400 - offset[0], 980 - offset[1] - 30),
                FlxPoint.get(1570 - offset[0], 1049 - offset[1] - 10)
            ];
    
            FlxTween.angle(sprite, rotations[0], rotations[1], duration);
            FlxTween.quadPath(sprite, path, duration, true, {onComplete: function(_) car2Interruptable = true});
        }


        function showPicoFade()
        {
            if (VsliceOptions.LOW_QUALITY)
                return;
    
            picoFade.setPosition(boyfriend.x, boyfriend.y);
            picoFade.frames = boyfriend.frames;
            picoFade.frame = boyfriend.frame;
            picoFade.alpha = 0.3;
            picoFade.scale.set(1, 1);
            picoFade.updateHitbox();
            picoFade.visible = true;
    
            FlxTween.cancelTweensOf(picoFade.scale);
            FlxTween.cancelTweensOf(picoFade);
            FlxTween.tween(picoFade.scale, {x: 1.3, y: 1.3}, 0.4);
            FlxTween.tween(picoFade, {alpha: 0}, 0.4, {onComplete: (_) -> (picoFade.visible = false)});
        }
    
        function darkenStageProps()
        {
            // Darken the background, then fade it back.
            for (sprite in darkenable)
            {
                // If not excluded, darken.
                sprite.color = 0xFF111111;
                new FlxTimer().start(1 / 24, (tmr) ->
                {
                    sprite.color = 0xFF222222;
                    FlxTween.color(sprite, 1.4, 0xFF222222, 0xFFFFFFFF);
                });
            }
        }
    
        override function destroy()
        {
            super.destroy();
            // Fully stop ambiance.
            if (rainSndAmbience != null)
                rainSndAmbience.stop();
            if (carSndAmbience != null)
                carSndAmbience.stop();
        }
    }
    