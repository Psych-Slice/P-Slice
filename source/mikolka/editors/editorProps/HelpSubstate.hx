package mikolka.editors.editorProps;

class HelpSubstate extends MusicBeatSubstate {
    public static var CHAR_EDIT_TEXT:Array<String> = [
        	"Animation preview controls:",
        	"Up/Down - Change active animation",
			"Left/Right - Change selected frame (will pause the animation)",
			"Space - Plays currently selected animation",
			"Hold Shift to Increase/Decrease scrolling of frames",
			"",
			"BACK key - Exit this editor",
    ];
    public static var CHAR_EDIT_TEXT_MOBILE:Array<String> = [
        "Up/Down - Move Conductor's Time",
			"Left/Right - Change Sections",
			"Up/Down (On The Right) - Decrease/Increase Note Sustain Length",
			"Hold Y to Increase/Decrease move by 4x",
			"",
			"C - Preview Chart",
			"A - Playtest Chart",
			"X - Stop/Resume Song",
			"",
			"Hold H and touch to Select Note(s)",
			"Z - Hide Action TouchPad Buttons",
			"V/D - Zoom in/out",
			""
			#if FLX_PITCH
			,"G - Reset Song Playback Rate"
			#end
    ];
	public static var FREEPLAY_EDIT_TEXT:Array<String> = [
        "Animation preview controls:",
        	"Up/Down - Change active animation",
			"Left/Right - Change selected frame (will pause the animation)",
			"I/J/K/L - Changes offset for selected animation",
			"Space - Plays currently selected animation",
			"Hold Shift to Increase/Decrease scrolling of frames and offset",
			"",
			"BACK key - Exit this substate",
    ];
    public static var FREEPLAY_EDIT_TEXT_MOBILE:Array<String> = [
        "Up/Down - Move Conductor's Time",
			"Left/Right - Change Sections",
			"Up/Down (On The Right) - Decrease/Increase Note Sustain Length",
			"Hold Y to Increase/Decrease move by 4x",
			"",
			"C - Preview Chart",
			"A - Playtest Chart",
			"X - Stop/Resume Song",
			"",
			"Hold H and touch to Select Note(s)",
			"Z - Hide Action TouchPad Buttons",
			"V/D - Zoom in/out",
			""
			#if FLX_PITCH
			,"G - Reset Song Playback Rate"
			#end
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
    }
    override function update(elapsed:Float) {
        super.update(elapsed);
        if(controls.BACK){
			_parentState.persistentUpdate = true;
            close();
        }
    }
    public static function makeLabel(isMobile:Bool):FlxText {
        var tipText:FlxText = new FlxText(FlxG.width - 210, FlxG.height - 30, 200, 'Press ${isMobile ? 'F' : 'F1'} for Help', 20);
		tipText.setFormat(null, 16, FlxColor.WHITE, RIGHT);
		tipText.borderColor = FlxColor.BLACK;
		tipText.scrollFactor.set();
		tipText.borderSize = 1;
		tipText.active = false;
		return tipText;
    }
}