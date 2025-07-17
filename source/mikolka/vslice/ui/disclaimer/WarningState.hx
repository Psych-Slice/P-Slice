package mikolka.vslice.ui.disclaimer;

import flixel.FlxState;
import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import lime.app.Application;

class WarningState extends MusicBeatState
{
	public var leftState:Bool = false;

	var warnText:FlxText;
	var text:String;
	var onExit:() -> Void;
	var onAccept:() -> Void;
	var nextState:FlxState;
	public function new(text:String,onAccept:() -> Void,onExit:() -> Void,nextState:FlxState) {
		this.text = text;
		this.onExit = onExit;
		this.onAccept = onAccept;
		this.nextState = nextState;
		super();
	}
	override function create()
	{
		controls.isInSubstate = false; // qhar I hate it
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,text,32);
		warnText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('NONE', 'A_B');
		#end
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if(!back) {
					onAccept();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxTween.tween(warnText, {alpha: 0}, 0.5, {
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(nextState);
						}
					});

				} else {
					onExit();
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(warnText, {alpha: 0}, 0.5, {
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(nextState);
						}
					});
				}
			}
		}
		super.update(elapsed);
	}
}
