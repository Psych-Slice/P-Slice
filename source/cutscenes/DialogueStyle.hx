package cutscenes;

import flixel.addons.text.FlxTypeText;
import objects.TypedAlphabet;

class DialogueStyle {
	//? Text positions
	public var DEFAULT_TEXT_X = 175;
	public var DEFAULT_TEXT_Y = 460;
	public var LONG_TEXT_ADD = 24;
	
	//? Default positions for speakers
	public var LEFT_CHAR_X:Float = -60;
	public var RIGHT_CHAR_X:Float = -100;
	public var DEFAULT_CHAR_Y:Float = 60;

	public var scrollSpeed = 4000; // Used for scaling spped of speakers???
	public var alphaFadeinScale:Float = 1; // Scale for fading in characters
	public var offsetXPos:Float = -600; // Offset for initial X positions for swipeIn
	public var offsetYPos:Float = FlxG.height; // Offset for initial Y position for swipeIn

	//?Background fade in
	public var BG_COLOR:FlxColor = 0xFFFFFFFF;
	public var FADE_DURATION:Float = 1;
	public var WAIT_FOR_FADE:Bool = false;

	var alphabethText:TypedAlphabet;
	public function new() {}

	// {"","left-","center-"}+{"angry","normal"}+{"","Open","Wait"}
	public function makeDialogueBox():FlxSprite{
		var box = new FlxSprite(70, 370);
		box.antialiasing = ClientPrefs.data.antialiasing;
		box.frames = Paths.getSparrowAtlas('speech_bubble');
		box.scrollFactor.set();
		box.animation.addByPrefix('normal', 'speech bubble normal', 24);
		box.animation.addByPrefix('angry', 'AHH speech bubble', 24);		
		//box.animation.addByPrefix('normalWait', 'speech bubble normal', 24);
		//box.animation.addByPrefix('angryWait', 'AHH speech bubble', 24);
		box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		box.animation.addByPrefix('angryOpen', 'speech bubble loud open', 24, false);	

		box.animation.addByPrefix('left-normal', 'speech bubble normal', 24,true,true);
		box.animation.addByPrefix('left-normalOpen', 'Speech Bubble Normal Open', 24, false,true);
		box.animation.addByPrefix('left-angry', 'AHH speech bubble', 24,true,true);
		box.animation.addByPrefix('left-angryOpen', 'speech bubble loud open', 24, false,true);

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
	public function initText():FlxSprite {
		alphabethText = new TypedAlphabet(DEFAULT_TEXT_X, DEFAULT_TEXT_Y, '');
		alphabethText.setScale(0.7);
		return alphabethText;
	}
	//Dialogue BOX
	public function prepareLine(text:String,textSpeed:Float,sound:String) {
		set_text(text);
		set_delay(textSpeed);
		set_sound(sound);
		startLine();
	}
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
	public function new() {
		super();
		BG_COLOR = 0xFFB3DFd8;
		FADE_DURATION = 1;
		WAIT_FOR_FADE = true;

		offsetXPos = -50;
		offsetYPos = FlxG.height-700;
		scrollSpeed = 400;
		alphaFadeinScale = 3;

		DEFAULT_TEXT_X = 240;
		DEFAULT_TEXT_Y = 500;
	}
	public override function makeDialogueBox():FlxSprite{
		var box = new FlxSprite(500, 350);
		var staticBox = ["Text Box Speaking0001"];
		var senpaiBox = ['SENPAI ANGRY IMPACT SPEECH0007'];
		box.antialiasing = false;
		box.frames = Paths.getSparrowAtlas('pixelUI/dialogueBox-new');
		box.scrollFactor.set();
		box.animation.addByNames ('normal', staticBox, 24,false);
		box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
		box.animation.addByPrefix('normalWait', 'Text Box wait to click0', 24,true);

		box.animation.addByNames ('left-angry', senpaiBox, 24);
		box.animation.addByPrefix('left-angryOpen', 'SENPAI ANGRY IMPACT SPEECH0', 24, false);
		box.animation.addByPrefix('left-angryWait', 'Text Box wait to click0', 24, false);

		box.animation.addByNames ('left-normal', staticBox, 24,false);
		box.animation.addByPrefix('left-normalOpen', 'Text Box Appear', 24, false);
		box.animation.addByPrefix('left-normalWait', 'Text Box wait to click0', 24,true);
		box.animation.play('normalOpen', true);

		box.visible = false;
		box.setGraphicSize(Std.int(box.width * 6 * 0.9));
		box.updateHitbox();
		return box;
	}
	override function initText():FlxSprite {
		swagDialogue = new FlxTypeText(DEFAULT_TEXT_X, DEFAULT_TEXT_Y, Std.int(FlxG.width * 0.6), '', 32);
		swagDialogue.font = Paths.font('pixel-latin.ttf');
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.borderStyle = SHADOW;
		swagDialogue.borderColor = 0xFFD89494;
		swagDialogue.shadowOffset.set(2, 2);
		swagDialogue.completeCallback = () -> isDone = true;
		return swagDialogue;
	}

	override function set_text(value:String) swagDialogue.resetText(value);
	override function set_delay(value:Float) swagDialogue.delay = value;
	override function get_delay():Float return swagDialogue.delay;
	override function set_sound(value:String) [FlxG.sound.load(Paths.sound(value), 0.6)];
	override function startLine() {
		swagDialogue.start(null, true);
		isDone = false;
	}

	override function isLineFinished():Bool return isDone;
	override function finishLine() {
		swagDialogue.skip();
		isDone = true;
	}
	override function rowCount():Int return 1;
}