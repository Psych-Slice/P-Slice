package mikolka.stages.objects;

#if !LEGACY_PSYCH
import objects.Character;
#end

class StageSpotlight extends BaseStage{
    var dadbattleBlack:BGSprite;
	var dadbattleLight:BGSprite;
	var dadbattleFog:DadBattleFog;
    var X:Int;
    var Y:Int;
    public function new(X:Int,Y:Int) {
        super();
        this.X = X;
        this.Y = Y;
    }
    
    #if LEGACY_PSYCH
	override function eventPushed(event:Note.EventNote)
	#else
	override function eventPushed(event:objects.Note.EventNote)
	#end
	{
		switch(event.event)
		{
			case "Dadbattle Spotlight":
				dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.25;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BGSprite('spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;
				add(dadbattleLight);

				dadbattleFog = new DadBattleFog(X,Y);
				dadbattleFog.visible = false;
				add(dadbattleFog);
		}
	}

    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
        {
            switch(eventName)
            {
                case "Dadbattle Spotlight":
                    if(flValue1 == null) flValue1 = 0;
                    var val:Int = Math.round(flValue1);
    
                    switch(val)
                    {
                        case 1, 2, 3: //enable and target dad
                            if(val == 1) //enable
                            {
                                dadbattleBlack.visible = true;
                                dadbattleLight.visible = true;
                                dadbattleFog.visible = true;
                                defaultCamZoom += 0.12;
                            }
    
                            var who:Character = dad;
                            if(val > 2) who = boyfriend;
                            //2 only targets dad
                            dadbattleLight.alpha = 0;
                            new FlxTimer().start(0.12, function(tmr:FlxTimer) {
                                dadbattleLight.alpha = 0.375;
                            });
                            dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);
                            FlxTween.tween(dadbattleFog, {alpha: 0.7}, 1.5, {ease: FlxEase.quadInOut});
    
                        default:
                            dadbattleBlack.visible = false;
                            dadbattleLight.visible = false;
                            defaultCamZoom -= 0.12;
                            FlxTween.tween(dadbattleFog, {alpha: 0}, 0.7, {onComplete: function(twn:FlxTween) dadbattleFog.visible = false});
                    }
            }
        }
}