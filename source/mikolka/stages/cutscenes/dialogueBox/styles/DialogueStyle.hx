package mikolka.stages.cutscenes.dialogueBox.styles;

enum abstract DialogueBoxPosition(String) {
	var LEFT = "left";
	var RIGHT = "right";
	var CENTER = "center";
}
enum DialogueBoxState {
	OPEN_INIT; // Starting the encounter
	OPEN; // when changing characters
	IDLE; // We're typing things (or nothing is happening rn)
	WAIT; // "Click to contnue" 
	CLOSE_FINISH; // We done
}
abstract class DialogueStyle{
	//? Text positions
	public var DEFAULT_TEXT_X = 175;
	public var DEFAULT_TEXT_Y = 460;
	public var LONG_TEXT_ADD = 24;
	
	//? Default positions for speakers
	public var LEFT_CHAR_X:Float = -60;
	public var RIGHT_CHAR_X:Float = -100;
	public var DEFAULT_CHAR_Y:Float = 60;

	public var scrollSpeed = 4000; // Used for scaling spped of speakers???
	public var offsetXPos:Float = -600; // Offset for initial X positions for swipeIn
	public var offsetYPos:Float = FlxG.height; // Offset for initial Y position for swipeIn

	public var alphaFadeinScale:Float = 1; // Scale for fading in characters
	public var visualUpdateThreshold:Float = 0;

	//? Sounds
	public var closeSound:String = 'dialogueClose';
	public var closeVolume:Float = 1;

	//?Background fade in
	public var BG_COLOR:FlxColor = 0xFFFFFFFF;
	public var FADE_DURATION:Float = 1;

	var box:FlxSprite;

	private var _last_style:DialogueBoxState;
	public var last_style(get,null):DialogueBoxState;
	function get_last_style():DialogueBoxState return _last_style;

	private var _last_position:DialogueBoxPosition;
	public var last_position(get,null):DialogueBoxPosition;
	function get_last_position():DialogueBoxPosition return _last_position;

	function new() {
		var centerOffset = (FlxG.width-FlxG.initialWidth)/2;
		LEFT_CHAR_X += centerOffset;
		DEFAULT_TEXT_X += Std.int(centerOffset);
		RIGHT_CHAR_X -= centerOffset;
	}

	public function playBoxAnim(pos:DialogueBoxPosition,style:DialogueBoxState,boxType:String) {
		if(_last_style == style && _last_position == pos) return;
		_last_style = style;
		_last_position = pos;
		_playBoxAnim(pos,style,boxType);
	}
	private abstract function _playBoxAnim(pos:DialogueBoxPosition,style:DialogueBoxState,boxType:String):Void;

	public function advanceBoxLine(callback:Void -> Void) callback();
	public abstract function makeDialogueBox():FlxSprite;
	public function prepareLine(text:String,textSpeed:Float,sound:String) {
		set_text(text);
		set_delay(textSpeed);
		set_sound(sound);
		startLine();
	}
	public abstract function initText():FlxSprite;
		//TEXT 
	public abstract function set_text(value:String):Void;
	public abstract function set_delay(value:Float):Void;
	public abstract function get_delay():Float;
	public abstract function set_sound(value:String):Void;
	public abstract function startLine():Void;
	
	public abstract function isLineFinished():Bool;
	public abstract function finishLine():Void;
	public abstract function rowCount():Int;
	
}