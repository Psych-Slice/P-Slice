package mikolka.stages.cutscenes.dialogueBox.styles;

import mikolka.stages.cutscenes.dialogueBox.styles.DialogueStyle.DialogueBoxState;
import mikolka.stages.cutscenes.dialogueBox.styles.DialogueStyle.DialogueBoxPosition;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.text.FlxTypeText;
#if !LEGACY_PSYCH
import backend.Paths;
#end

class DecayDialogueStyle extends DialogueStyle {
	var swagDialogue:FlxTypeText;
	var isDone:Bool = false;
	var lastSnd:String = "";
	public function new() {
		super();
		BG_COLOR = 0xBF0A3D35;
		FADE_DURATION = 1;

		offsetXPos = -100;
		offsetYPos = FlxG.height-700;
		scrollSpeed = 400;
		alphaFadeinScale = 3;
		visualUpdateThreshold = 0.05;

		DEFAULT_TEXT_Y = 470;
		DEFAULT_TEXT_X = 206;
		DEFAULT_TEXT_X += Std.int((FlxG.width-FlxG.initialWidth)/2);
		closeSound = "clickText";
	}
	public function makeDialogueBox():FlxSprite{
		box = new FlxSprite(537+((FlxG.width-FlxG.initialWidth)/2), 335);
		var staticBox = ["Spirit Textbox0000"];
		box.antialiasing = false;
		box.frames = Paths.getSparrowAtlas('pixelUI/dialogueBox-evilNew');
		box.scrollFactor.set();
		box.animation.addByNames ('normal', staticBox, 24,false);
		box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
		box.animation.addByPrefix('normalWait', 'Spirit Text Box Sentence Complete0', 24,true);
		box.animation.addByPrefix('normalClick', 'Spirit Text Box Click', 24, false);
		//box.animation.addByPrefix('normalClick', 'SENPAI ANGRY IMPACT SPEECH0', 24, false);
		box.animation.play('normalOpen', true);

		box.visible = false;
		box.setGraphicSize(Std.int(box.width * 6 * 0.9));
		box.updateHitbox();
		return box;
	}
	override function advanceBoxLine(callback:() -> Void) {
		box.animation.play("normalClick");
		#if LEGACY_PSYCH
		box.animation.finishCallback = (anim) ->{
			callback();
			box.animation.finishCallback = null;
		}
		#else
		box.animation.onFinish.addOnce(anim ->{
			callback();
		});
		#end
	}
	public function _playBoxAnim(pos:DialogueBoxPosition,style:DialogueBoxState,boxType:String) {
		super.playBoxAnim(pos,style,boxType);
		switch(style){
			case OPEN_INIT:
				box.centerOffsets();
				box.updateHitbox();
				box.offset.set(10, 0);
				box.animation.play("normalOpen",true);
				
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
		swagDialogue.color = 0xFFFFFFFF;
		swagDialogue.borderStyle = NONE;
		swagDialogue.borderColor = 0xFF3D3D3D;
		//swagDialogue.shadowOffset.set(2, 2);
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
		 isDone = false;
		swagDialogue.start(null, true);
	}

	 function isLineFinished():Bool return isDone;
	 function finishLine() {
		swagDialogue.skip();
		isDone = true;
	}
	 function rowCount():Int return 1;

}