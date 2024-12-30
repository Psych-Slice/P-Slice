package mikolka.editors.editorProps;

class HelpSubstate extends MusicBeatSubstate {
    public static var CHAR_EDIT_TEXT:Array<String> = [
        	"Animation preview controls:",
        	"Up/Down - Change active animation",
			"Left/Right - Change selected frame (will pause the animation)",
			"Space - Plays currently selected animation",
			"Hold Shift to Increase/Decrease scrolling of frames",
			"",
			"ESCAPE - Exit this editor",
    ];
    public static var CHAR_EDIT_TEXT_MOBILE:Array<String> = [
        	"Animation preview controls:",
        	"Up/Down - Change active animation",
			"Left/Right - Change selected frame (will pause the animation)",
			"X - Plays currently selected animation",
			"Hold C to Increase/Decrease scrolling of frames",
			"",
			"B - Exit this editor",
    ];
	public static var FREEPLAY_EDIT_TEXT:Array<String> = [
        "Animation preview controls:",
        	"Up/Down - Change active animation",
			"Left/Right - Change selected frame (will pause the animation)",
			"I/J/K/L - Changes offset for selected animation",
			"Space - Plays currently selected animation",
			"Hold Shift to Increase/Decrease scrolling of frames and offset",
			"",
			"ESCAPE - Exit this substate",
    ];
    public static var FREEPLAY_EDIT_TEXT_MOBILE:Array<String> = [
       		"Animation preview controls:",
        	"Up/Down - Change active animation",
			"Left/Right - Change selected frame (will pause the animation)",
			"Hold A and Touch Arrow Keys to Changes offset for selected animation",
			"X - Plays currently selected animation",
			"Hold Y to Increase/Decrease scrolling of frames and offset",
			"",
			"B - Exit this substate",
    ];
	private var text:Array<String>;
	public function new(text:Array<String>) {
		this.text = text;
		super();
	}
    override function create() {
        super.create();
        var tipBg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		tipBg.scale.set(FlxG.width, FlxG.height);
		tipBg.updateHitbox();
		tipBg.scrollFactor.set();
		tipBg.alpha = 0.6;
		add(tipBg);
		
		var fullTipText = new FlxText(0, 0, FlxG.width - 200);
		fullTipText.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER);
		//fullTipText.cameras = [camUI];
		fullTipText.scrollFactor.set();
		fullTipText.text = text.join('\n');
		fullTipText.screenCenter();
		add(fullTipText);
		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad("NONE", "F");
		touchPad.y -= 124;
		#end
    }
    override function update(elapsed:Float) {
        super.update(elapsed);
        if(#if TOUCH_CONTROLS_ALLOWED touchPad.buttonF.justPressed || #end FlxG.keys.justPressed.F1)
		{
			_parentState.persistentUpdate = true;
            close();
			#if TOUCH_CONTROLS_ALLOWED
			if (MusicBeatState?.getState() != null)
				MusicBeatState.getState().touchPad.visible = true;
			
			// had to add instance cuz this is also a substate :sob:
			if (FreeplayEditSubstate?.instance != null)
				Controls.instance.isInSubstate = true;

			removeTouchPad();
			#end
        }
    }
    public static function makeLabel():FlxText {
        var tipText:FlxText = new FlxText(0, FlxG.height - 30, FlxG.width, 'Press ${Controls.instance.mobileC ? 'F' : 'F1'} for Help', 20);
		tipText.setFormat(null, 16, FlxColor.WHITE, RIGHT);
		tipText.borderColor = FlxColor.BLACK;
		tipText.scrollFactor.set();
		tipText.borderSize = 1;
		tipText.active = false;
		return tipText;
    }
}