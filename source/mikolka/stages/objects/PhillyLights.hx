package mikolka.stages.objects;

import mikolka.compatibility.VsliceOptions;

#if !LEGACY_PSYCH
import objects.Character;
#end

class PhillyLights extends BaseStage {

    //For Philly Glow events
	var blammedLightsBlack:FlxSprite;
	var phillyGlowGradient:PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlowParticle>;
	var phillyWindowEvent:BGSprite;
	var curLightEvent:Int = -1;

	var phillyStreet:FlxSprite;
	var X:Float;
	var Y:Float;
    var phillyLightsColors:Array<FlxColor>;
    /**
     * Creates a new stage for handling philly lights.
     * @param index members.indexOf(phillyStreet)
     * @param windowX 
     * @param windowY 
     */
    public function new(phillyStreet:FlxSprite,windowX:Float,windowY:Float,colors:Array<FlxColor>) {
        super();
        this.phillyStreet = phillyStreet;
        phillyLightsColors = colors;
        X = windowX;
        Y = windowY;
    }
    #if LEGACY_PSYCH
	override function eventPushed(event:Note.EventNote)
	#else
	override function eventPushed(event:objects.Note.EventNote)
	#end
	{
		switch(event.event)
		{
			case "Philly Glow":
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				insert(members.indexOf(phillyStreet), blammedLightsBlack);

				phillyWindowEvent = new BGSprite('philly/window', X, Y, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);

				phillyGlowGradient = new PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);
				if(!VsliceOptions.FLASHBANG) phillyGlowGradient.intendedAlpha = 0.7;

				Paths.image('philly/particle'); //precache philly glow particle image
				phillyGlowParticles = new FlxTypedGroup<PhillyGlowParticle>();
				phillyGlowParticles.visible = false;
				insert(members.indexOf(phillyGlowGradient) + 1, phillyGlowParticles);
		}
	}
    override function update(elapsed:Float) {
        if(phillyGlowParticles != null)
            {
                phillyGlowParticles.forEachAlive(function(particle:PhillyGlowParticle)
                {
                    if(particle.alpha <= 0)
                        particle.kill();
                });
            }
    }
    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
        {
            switch(eventName)
            {
                case "Philly Glow":
                    if(flValue1 == null || flValue1 <= 0) flValue1 = 0;
                    var lightId:Int = Math.round(flValue1);
    
                    var chars:Array<Character> = [boyfriend, gf, dad];
                    switch(lightId)
                    {
                        case 0:
                            if(phillyGlowGradient.visible)
                            {
                                doFlash();
                                if(VsliceOptions.CAM_ZOOMING)
                                {
                                    FlxG.camera.zoom += 0.5;
                                    camHUD.zoom += 0.1;
                                }
    
                                blammedLightsBlack.visible = false;
                                phillyWindowEvent.visible = false;
                                phillyGlowGradient.visible = false;
                                phillyGlowParticles.visible = false;
                                curLightEvent = -1;
    
                                for (who in chars)
                                {
                                    who.color = FlxColor.WHITE;
                                }
                                phillyStreet.color = FlxColor.WHITE;
                            }
    
                        case 1: //turn on
                            curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);
                            var color:FlxColor = phillyLightsColors[curLightEvent];
    
                            if(!phillyGlowGradient.visible)
                            {
                                doFlash();
                                if(VsliceOptions.CAM_ZOOMING)
                                {
                                    FlxG.camera.zoom += 0.5;
                                    camHUD.zoom += 0.1;
                                }
    
                                blammedLightsBlack.visible = true;
                                blammedLightsBlack.alpha = 1;
                                phillyWindowEvent.visible = true;
                                phillyGlowGradient.visible = true;
                                phillyGlowParticles.visible = true;
                            }
                            else if(VsliceOptions.FLASHBANG)
                            {
                                var colorButLower:FlxColor = color;
                                colorButLower.alphaFloat = 0.25;
                                FlxG.camera.flash(colorButLower, 0.5, null, true);
                            }
    
                            var charColor:FlxColor = color;
                            if(!VsliceOptions.FLASHBANG) charColor.saturation *= 0.5;
                            else charColor.saturation *= 0.75;
    
                            for (who in chars)
                            {
                                who.color = charColor;
                            }
                            phillyGlowParticles.forEachAlive(function(particle:PhillyGlowParticle)
                            {
                                particle.color = color;
                            });
                            phillyGlowGradient.color = color;
                            phillyWindowEvent.color = color;
    
                            color.brightness *= 0.5;
                            phillyStreet.color = color;
    
                        case 2: // spawn particles
                            if(!VsliceOptions.LOW_QUALITY)
                            {
                                var particlesNum:Int = FlxG.random.int(8, 12);
                                var width:Float = (2000 / particlesNum);
                                var color:FlxColor = phillyLightsColors[curLightEvent];
                                for (j in 0...3)
                                {
                                    for (i in 0...particlesNum)
                                    {
                                        var particle:PhillyGlowParticle = phillyGlowParticles.recycle(PhillyGlowParticle);
                                        particle.x = -400 + width * i + FlxG.random.float(-width / 5, width / 5);
                                        particle.y = phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40);
                                        particle.color = color;
                                        phillyGlowParticles.add(particle);
                                    }
                                }
                            }
                            phillyGlowGradient.bop();
                    }
            }
        }
    
        function doFlash()
        {
            var color:FlxColor = FlxColor.WHITE;
            if(!VsliceOptions.FLASHBANG) color.alphaFloat = 0.5;
    
            FlxG.camera.flash(color, 0.15, null, true);
        }
}