package cutscenes;

import flixel.addons.text.FlxTypeText;
import objects.TypedAlphabet;

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

	//?Background fade in
	public var BG_COLOR:FlxColor = 0xFFFFFFFF;
	public var FADE_DURATION:Float = 1;

	var alphabethText:TypedAlphabet;
	var box:FlxSprite;

	private var _last_style:DialogueBoxState;
	public var last_style(get,null):DialogueBoxState;
	function get_last_style():DialogueBoxState return _last_style;
	private var _last_position:DialogueBoxPosition;
	public var last_position(get,null):DialogueBoxPosition;
	function get_last_position():DialogueBoxPosition return _last_position;
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
class PsychDialogueStyle extends DialogueStyle {
	
	public function new() {}

	// {"","left-","center-"}+{"angry","normal"}+{"","Open","Wait"}
	public function makeDialogueBox():FlxSprite{
		box = new FlxSprite(70, 370);
		box.antialiasing = ClientPrefs.data.antialiasing;
		box.frames = Paths.getSparrowAtlas('speech_bubble');
		box.scrollFactor.set();
		box.animation.addByPrefix('normal', 'speech bubble normal', 24);
		box.animation.addByPrefix('angry', 'AHH speech bubble', 24);		
		box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		box.animation.addByPrefix('angryOpen', 'speech bubble loud open', 24, false);	

		box.animation.addByPrefix('center-normal', 'speech bubble middle', 24);
		box.animation.addByPrefix('center-normalOpen', 'Speech Bubble Middle Open', 24, false);
		box.animation.addByPrefix('center-angry', 'AHH Speech Bubble middle', 24);
		box.animation.addByPrefix('center-angryOpen', 'speech bubble Middle loud open', 24, false);
		box.animation.play('normal', true);
		box.visible = false;
		box.setGraphicSize(Std.int(box.width * 0.9));
		box.updateHitbox();
		return box;
	}
	public function _playBoxAnim(pos:DialogueBoxPosition,style:DialogueBoxState,boxType:String) {
		switch(style){
			case OPEN | OPEN_INIT:
				box.centerOffsets();
				box.updateHitbox();
				if(boxType == "angry"){
					if(pos == CENTER) {
						box.offset.set(50, 30); //center-angry
						box.animation.play("center-angryOpen");
						box.animation.onFinish.addOnce(anim -> playBoxAnim(pos,IDLE,boxType));
					}
					else {
						box.offset.set(50, 65); //angry
						box.animation.play("angryOpen");
						box.animation.onFinish.addOnce(anim -> playBoxAnim(pos,IDLE,boxType));
					}
				}
				else{
					box.offset.set(10, 0);
					if(pos == CENTER) box.animation.play("center-normalOpen");
					else box.animation.play("normalOpen");
					box.animation.onFinish.addOnce(anim -> playBoxAnim(pos,IDLE,boxType));
				}
				box.flipX = pos == LEFT;
				if(!box.flipX) box.offset.y += 10;
			case CLOSE_FINISH:
				var centerPrefix = pos == CENTER ? "center-" : "";
				if(boxType != "angry")box.animation.play(centerPrefix+"normalOpen",true,true);
				else box.animation.play(centerPrefix+"angryOpen",true,true);
			case IDLE:
				box.centerOffsets();
				box.updateHitbox();
				if(boxType == "angry"){
					if(pos == CENTER) {
						box.offset.set(50, 30); //center-angry
						box.animation.play("center-angry");
					}
					else {
						box.offset.set(50, 65); //angry
						box.animation.play("angry");
					}
				}
				else{
					box.offset.set(10, 0);
					if(pos == CENTER) box.animation.play("center-normal");
					else box.animation.play("normal");
				}
				box.flipX = pos == LEFT;
				if(!box.flipX) box.offset.y += 10;
			case WAIT:{}

		}
	}

	public function initText():FlxSprite {
		alphabethText = new TypedAlphabet(DEFAULT_TEXT_X, DEFAULT_TEXT_Y, '');
		alphabethText.setScale(0.7);
		return alphabethText;
	}
	
	//Dialogue BOX
	public function set_text(value:String) alphabethText.text = value;
	public function set_delay(value:Float) alphabethText.delay = value;
	public function get_delay():Float return alphabethText.delay;
	public function set_sound(value:String) alphabethText.sound = value;
	public function startLine() {}
	//

	public function isLineFinished():Bool return alphabethText.finishedText;
	public function finishLine() alphabethText.finishText();
	public function rowCount():Int return alphabethText.rows;
}

class PixelDialogueStyle extends DialogueStyle {
	var swagDialogue:FlxTypeText;
	var isDone:Bool = false;
	var lastSnd:String = "";
	public function new() {
		BG_COLOR = 0xBFB3DFD8;
		FADE_DURATION = 1;

		offsetXPos = -100;
		offsetYPos = FlxG.height-700;
		scrollSpeed = 400;
		alphaFadeinScale = 3;
		visualUpdateThreshold = 0.05;

		DEFAULT_TEXT_Y = 470;
		DEFAULT_TEXT_X = 206;
	}
	public function makeDialogueBox():FlxSprite{
		box = new FlxSprite(537, 347);
		var staticBox = ["Text Box Speaking0001"];
		var senpaiBox = ['SENPAI ANGRY IMPACT SPEECH0007'];
		box.antialiasing = false;
		box.frames = Paths.getSparrowAtlas('pixelUI/dialogueBox-new');
		box.scrollFactor.set();
		box.animation.addByNames ('normal', staticBox, 24,false);
		box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
		box.animation.addByPrefix('normalWait', 'Text Box wait to click0', 24,true);
		box.animation.addByPrefix('angryOpen', 'SENPAI ANGRY IMPACT SPEECH0', 24, false);
		box.animation.addByPrefix('normalClick', 'Text Box CLICK', 24, false);
		//box.animation.addByPrefix('normalClick', 'SENPAI ANGRY IMPACT SPEECH0', 24, false);
		box.animation.play('normalOpen', true);

		box.visible = false;
		box.setGraphicSize(Std.int(box.width * 6 * 0.9));
		box.updateHitbox();
		return box;
	}
	override function advanceBoxLine(callback:() -> Void) {
		box.animation.play("normalClick");
		box.animation.onFinish.addOnce(anim ->{
			callback();
		});
	}
	public function _playBoxAnim(pos:DialogueBoxPosition,style:DialogueBoxState,boxType:String) {
		super.playBoxAnim(pos,style,boxType);
		switch(style){
			case OPEN_INIT:
				box.centerOffsets();
				box.updateHitbox();
				if(boxType == "angry"){
					box.offset.set(50, 65); //angry
					box.animation.play("angryOpen",true);
					
				}
				else{
					box.offset.set(10, 0);
					box.animation.play("normalOpen",true);
				}
			case CLOSE_FINISH:
				box.animation.play("normalOpen",true,true);
			case IDLE:
				box.centerOffsets();
				box.updateHitbox();
				box.offset.set(10, 0);
				box.animation.play("normal",true);
			case WAIT:{
				box.centerOffsets();
				box.updateHitbox();
				box.offset.set(10, 0);
				box.animation.play("normalWait",true);
			}
			case OPEN:{}
		}
	}
	 function initText():FlxSprite {
		swagDialogue = new FlxTypeText(DEFAULT_TEXT_X, DEFAULT_TEXT_Y, Std.int(FlxG.width * 0.6), '', 32);
		swagDialogue.font = Paths.font('pixel-latin.ttf');
		set_sound("pixelText");
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.borderStyle = SHADOW;
		swagDialogue.borderColor = 0xFFD89494;
		swagDialogue.shadowOffset.set(2, 2);
		swagDialogue.completeCallback = () -> isDone = true;
		return swagDialogue;
	}

	//TEXT 
	 function set_text(value:String) swagDialogue.resetText(value);
	 function set_delay(value:Float) swagDialogue.delay = value;
	 function get_delay():Float return swagDialogue.delay;
	 function set_sound(value:String) {
		if(lastSnd == value) return;
		lastSnd = value;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound(value), 0.6)];
	}
	 function startLine() {
		swagDialogue.start(null, true);
		isDone = false;
	}

	 function isLineFinished():Bool return isDone;
	 function finishLine() {
		swagDialogue.skip();
		isDone = true;
	}
	 function rowCount():Int return 1;

}