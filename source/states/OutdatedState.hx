package states;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		var guh:String;
		final bro:String = #if mobile 'kiddo' #else 'bro' #end;
		final escape:String = (controls.mobileC) ? 'B' : 'ESCAPE';

		guh = "Sup "+bro+", looks like you're running an   \n
		outdated version of P-Slice Engine (" + MainMenuState.pSliceVersion + "),\n
		please update to " + TitleState.updateVersion + "!\n
		Press "+escape+" to proceed anyway.\n
		\n
		Thank you for using the Engine!";

		warnText = new FlxText(0, 0, FlxG.width, guh, 32);
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
			if (controls.ACCEPT) {
				leftState = true;
				CoolUtil.browserLoad("https://github.com/Psych-Slice/P-Slice/releases");
			}
			else if(controls.BACK) {
				leftState = true;
			}

			if(leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new MainMenuState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}
