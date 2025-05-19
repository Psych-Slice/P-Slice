package mikolka.stages.scripts;

class VSliceEvents extends BaseStage {
    private var zoomTween:FlxTween;
    private var camTween:FlxTween;

    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) {
        switch (eventName){
            case 'Vslice Scroll Speed':
				if (game.songSpeedType != "constant")
				{
					if(flValue1 == null) flValue1 = 1;
					if(flValue2 == null) flValue2 = 0;

					var newValue:Float = ClientPrefs.getGameplaySetting('scrollspeed',1.0) * flValue1;
					if(flValue2 <= 0)
						game.songSpeed = newValue;
					else
						game.songSpeedTween = FlxTween.tween(game, {songSpeed: newValue}, flValue2 / game.playbackRate, {ease: FlxEase.quadInOut, onComplete:
							function (twn:FlxTween)
							{
								game.songSpeedTween = null;
							}
						});
				}
            case 'Set Camera Bopping': //P-slice event notes
				var val1 = Std.parseFloat(value1);
				var val2 = Std.parseFloat(value2);
				game.camZoomingMult = !Math.isNaN(val2) ? val2 : 1;
				game.camZoomingFrequency = !Math.isNaN(val1) ? val1 : 4;
            case 'Target Camera': //P-slice event notes val1: char val2: x,y,dur,ease
                var keyValues = value2.split(",");
                if(keyValues.length != 4) {
                    trace("INVALID EVENT VALUE");
                    return;
                }
                var ease = keyValues.pop().toLowerCase();
                var floaties = keyValues.map(s -> Std.parseFloat(s));
                if(mikolka.funkin.utils.ArrayTools.findIndex(floaties,s -> Math.isNaN(s)) != -1) {
                    trace("INVALID FLOATIES");
                    return;
                }
                @:privateAccess
                game.isCameraOnForcedPos = true;

                var targetx = floaties[0];
                var targety = floaties[1];
                var dur = floaties[2]*(Conductor.stepCrochet/1000);
                switch (value1){
                    case "bf"|"0":{
                        targetx += game.boyfriend.getMidpoint().x -100 - boyfriend.cameraPosition[0] + game.boyfriendCameraOffset[0];
                        targety += game.boyfriend.getMidpoint().y -100 + boyfriend.cameraPosition[1] + game.boyfriendCameraOffset[1];
                    }
                    case "dad"|"1":{
                        targetx += game.dad.getMidpoint().x +150 + dad.cameraPosition[0] + game.opponentCameraOffset[0];
                        targety += game.dad.getMidpoint().y -100 + dad.cameraPosition[1] + game.opponentCameraOffset[1];
                    }
                    case "gf"|"2":{
                        targetx += game.gf.getMidpoint().x + gf.cameraPosition[0] - game.girlfriendCameraOffset[0];
                        targety += game.gf.getMidpoint().y + gf.cameraPosition[1] - game.girlfriendCameraOffset[1];
                    }
                }

                if(ease == "classic" || ease == "instant"){
                    game.camFollow.x = targetx;
                    game.camFollow.y = targety;
                    if(ease == "instant") FlxG.camera.snapToTarget();
                }
                else{
                    #if LEGACY_PSYCH
                    var easeFunc = FunkinLua.getFlxEaseByString(ease);
                    #else
                    var easeFunc = psychlua.LuaUtils.getTweenEaseByString(ease);
                    #end
                    camTween?.cancel();
                    camTween = FlxTween.tween(game.camFollow,{x:targetx,y:targety},dur,{
                        ease: easeFunc,
                        onComplete: s -> {
                            camTween = null;
                        }
                    });
                }
			case 'Zoom Camera': //defaultCamZoom
				var keyValues = value1.split(",");
				if(keyValues.length != 2) {
					trace("INVALID EVENT VALUE");
					return;
				}
				var floaties = keyValues.map(s -> Std.parseFloat(s));
				if(mikolka.funkin.utils.ArrayTools.findIndex(floaties,s -> Math.isNaN(s)) != -1) {
					trace("INVALID FLOATIES");
					return;
				}
				#if LEGACY_PSYCH
                var easeFunc = FunkinLua.getFlxEaseByString(value2);
                #else
                var easeFunc = psychlua.LuaUtils.getTweenEaseByString(value2);
                #end
				if(zoomTween != null) zoomTween.cancel();
				var targetZoom = floaties[1]*game.defaultStageZoom;
				zoomTween = FlxTween.tween(this,{ defaultCamZoom:targetZoom},(Conductor.stepCrochet/1000)*floaties[0],{
					onStart: (x) ->{
						//camZooming = false;
						game.camZoomingDecay = 7;
					},
					ease: easeFunc,
					onComplete: (x) ->{
						defaultCamZoom = targetZoom;
						game.camZoomingDecay = 1;
						//camZooming = true;
						zoomTween = null;
					}
				});
        }
    }
}