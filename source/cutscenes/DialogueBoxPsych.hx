package cutscenes;

import cutscenes.DialogueStyle.PixelDialogueStyle;
import cutscenes.DialogueStyle;
import substates.PauseSubState;
import haxe.Json;
import openfl.utils.Assets;

import objects.TypedAlphabet;
import cutscenes.DialogueCharacter;

typedef DialogueFile = {
	var dialogue:Array<DialogueLine>;
	var style:Null<String>;
}

typedef DialogueLine = {
	var portrait:Null<String>;
	var expression:Null<String>;
	var text:Null<String>;
	var boxState:Null<String>;
	var speed:Null<Float>;
	@:optional var sound:Null<String>;
}

// TO DO: Clean code? Maybe? idk
class DialogueBoxPsych extends FlxSpriteGroup
{
	// Some editors use those lol
	public static var DEFAULT_TEXT_X = 175;
	public static var DEFAULT_TEXT_Y = 460;
	public static var LONG_TEXT_ADD = 24;

	public static var LEFT_CHAR_X:Float = -60;
	public static var RIGHT_CHAR_X:Float = -100;
	public static var DEFAULT_CHAR_Y:Float = 60;

	public var style:DialogueStyle;
	var dialogueList:DialogueFile = null;

	public var finishThing:Void->Void;
	public var nextDialogueThing:Void->Void = null;
	public var skipDialogueThing:Void->Void = null;
	var bgFade:FlxSprite = null;
	var box:FlxSprite;
	var textToType:String = '';

	var arrayCharacters:Array<DialogueCharacter> = [];

	var currentText:Int = 0;
	var skipText:FlxText;

	var textBoxTypes:Array<String> = ['normal', 'angry'];
	
	var curCharacter:String = "";

	var pauseJustClosed:Bool = false;
	var staticDialList:Array<DialogueLine> = [];
	//var charPositionList:Array<String> = ['left', 'center', 'right'];

	public function new(dialogueList:DialogueFile, ?song:String = null)
	{
		super();
		switch(dialogueList.style){
			case "pixel":{
				this.style = new PixelDialogueStyle();
			}
			default:{
				this.style = new DialogueStyle();
			}
		}
		//precache sounds
		Paths.sound('dialogue');
		Paths.sound('dialogueClose');

		if(song != null && song != '') {
			FlxG.sound.playMusic(Paths.music(song), 0);
			FlxG.sound.music.fadeIn(2, 0, 1);
		}
		
		bgFade = new FlxSprite(-500, -500).makeGraphic(FlxG.width * 2, FlxG.height * 2, style.BG_COLOR);
		bgFade.scrollFactor.set();
		bgFade.visible = true;
		bgFade.alpha = 0;
		add(bgFade);

		this.dialogueList = dialogueList;
		this.staticDialList = dialogueList.dialogue.copy();
		spawnCharacters();

		box = style.makeDialogueBox();
		add(box);

		daText = style.initText();
		add(daText);

		skipText = new FlxText(FlxG.width - 320, FlxG.height - 30, 300, Language.getPhrase('dialogue_skip', 'Press BACK to Skip'), 16);
		skipText.setFormat(null, 16, FlxColor.WHITE, RIGHT, OUTLINE_FAST, FlxColor.BLACK);
		skipText.borderSize = 2;
		add(skipText);

		FlxTween.tween(bgFade,{alpha:0.5},style.FADE_DURATION,{
			ease: FlxEase.linear,
			onComplete: tween -> if(style.WAIT_FOR_FADE) startNextDialog()
		});
		if(!style.WAIT_FOR_FADE) startNextDialog();
	}

	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	function spawnCharacters() {
		var charsMap:Map<String, Bool> = new Map<String, Bool>();
		for (i in 0...dialogueList.dialogue.length) {
			if(dialogueList.dialogue[i] != null) {
				var charToAdd:String = dialogueList.dialogue[i].portrait;
				if(!charsMap.exists(charToAdd) || !charsMap.get(charToAdd)) {
					charsMap.set(charToAdd, true);
				}
			}
		}

		for (individualChar in charsMap.keys()) {
			var x:Float = style.LEFT_CHAR_X;
			var y:Float = style.DEFAULT_CHAR_Y;
			var char:DialogueCharacter = new DialogueCharacter(x + style.offsetXPos, y, individualChar);
			char.setGraphicSize(Std.int(char.width * DialogueCharacter.DEFAULT_SCALE * char.jsonFile.scale));
			char.updateHitbox();
			char.scrollFactor.set();
			char.alpha = 0.00001;
			add(char);

			var saveY:Bool = false;
			switch(char.jsonFile.dialogue_pos) {
				case 'center':
					char.x = FlxG.width / 2;
					char.x -= char.width / 2;
					y = char.y;
					char.y = style.offsetYPos + 50;
					saveY = true;
				case 'right':
					x = FlxG.width - char.width + style.RIGHT_CHAR_X;
					char.x = x - style.offsetXPos;
			}
			x += char.jsonFile.position[0];
			y += char.jsonFile.position[1];
			char.x += char.jsonFile.position[0];
			char.y += char.jsonFile.position[1];
			char.startingPos = (saveY ? y : x);
			arrayCharacters.push(char);
		}
	}

	var daText:FlxSprite = null;
	var ignoreThisFrame:Bool = true; //First frame is reserved for loading dialogue images

	public var closeSound:String = 'dialogueClose';
	public var closeVolume:Float = 1;
	override function update(elapsed:Float)
	{
		if(ignoreThisFrame) {
			ignoreThisFrame = false;
			super.update(elapsed);
			return;
		}

		if(!dialogueEnded) {

			var back:Bool = #if android FlxG.android.justReleased.BACK || #end Controls.instance.BACK;
			if((TouchUtil.justPressed || Controls.instance.ACCEPT || back) && box.visible) {
				if(!style.isLineFinished() && !back)
				{
					style.finishLine();
					if(skipDialogueThing != null) {
						skipDialogueThing();
					}
					FlxG.sound.play(Paths.sound(closeSound), closeVolume);
				}
				else if (back && !pauseJustClosed && !dialogueEnded)
					{
						var game = PlayState.instance;
						FlxG.camera.followLerp = 0;
						FlxG.state.persistentUpdate = false;
						FlxG.state.persistentDraw = true;
						FlxG.sound.music.pause();
			
						var pauseState = new PauseSubState(true,DIALOGUE);
						pauseState.cutscene_allowSkipping = true;
						pauseState.cutscene_hardReset = false;
						game.openSubState(pauseState);
			
						game.subStateClosed.addOnce(s ->
						{ // TODO
							pauseJustClosed = true;
							FlxTimer.wait(0.1, () -> pauseJustClosed = false);
							switch (pauseState.specialAction)
							{
								case SKIP: {
										trace('skipped cutscene');
										skipDialogue();
										FlxG.sound.play(Paths.sound(closeSound), closeVolume);
									}
								case RESUME: {
									FlxG.sound.music.resume();
								}
								case NOTHING: {}
								case RESTART: {
									dialogueList.dialogue = staticDialList.copy();
									currentText = 0;
									startNextDialog();
									FlxG.sound.play(Paths.sound(closeSound), closeVolume);
								}
							}
						});
					}
				else if(currentText >= dialogueList.dialogue.length)
				{
					FlxG.sound.play(Paths.sound(closeSound), closeVolume);
					skipDialogue();
				} else {
					FlxG.sound.play(Paths.sound(closeSound), closeVolume);
					startNextDialog();
				}
			} else if(style.isLineFinished()) {
				var char:DialogueCharacter = arrayCharacters[lastCharacter];
				if(char != null && char.animation.curAnim != null && char.animationIsLoop() && char.animation.finished) {
					char.playAnim(char.animation.curAnim.name, true);
				}
				//tryPlayingBoxAnim(checkArray[j] + textBoxTypes[i]);
			} else {
				var char:DialogueCharacter = arrayCharacters[lastCharacter];
				if(char != null && char.animation.curAnim != null && char.animation.finished) {
					char.animation.curAnim.restart();
				}
			}

			if(box.animation.curAnim.finished) {
				tryPlayingBoxAnim(last_pos,last_style,"");
				updateBoxOffsets(box);
			}

			if(lastCharacter != -1 && arrayCharacters.length > 0) {
				for (i in 0...arrayCharacters.length) {
					var char = arrayCharacters[i];
					if(char != null) {
						if(i != lastCharacter) {
							switch(char.jsonFile.dialogue_pos) {
								case 'left':
									char.x -= style.scrollSpeed * elapsed;
									if(char.x < char.startingPos + style.offsetXPos) char.x = char.startingPos + style.offsetXPos;
								case 'center':
									char.y += style.scrollSpeed * elapsed;
									if(char.y > char.startingPos + style.offsetYPos) char.y = char.startingPos + style.offsetYPos;
								case 'right':
									char.x += style.scrollSpeed * elapsed;
									if(char.x > char.startingPos - style.offsetXPos) char.x = char.startingPos - style.offsetXPos;
							}
							char.alpha -= style.alphaFadeinScale * 3 * elapsed;
							if(char.alpha < 0.00001) char.alpha = 0.00001;
						} else {
							switch(char.jsonFile.dialogue_pos) {
								case 'left':
									char.x += style.scrollSpeed * elapsed;
									if(char.x > char.startingPos) char.x = char.startingPos;
								case 'center':
									char.y -= style.scrollSpeed * elapsed;
									if(char.y < char.startingPos) char.y = char.startingPos;
								case 'right':
									char.x -= style.scrollSpeed * elapsed;
									if(char.x < char.startingPos) char.x = char.startingPos;
							}
							char.alpha += style.alphaFadeinScale * 3 * elapsed;
							if(char.alpha > 1) char.alpha = 1;
						}
					}
				}
			}
		} else { //Dialogue ending
			if(box != null && box.animation.curAnim.curFrame <= 0) {
				box.kill();
				remove(box);
				box.destroy();
				box = null;
			}

			if(bgFade != null) {
				bgFade.alpha -= 0.5 * elapsed;
				if(bgFade.alpha <= 0) {
					bgFade.kill();
					remove(bgFade);
					bgFade.destroy();
					bgFade = null;
				}
			}

			for (i in 0...arrayCharacters.length) {
				var leChar:DialogueCharacter = arrayCharacters[i];
				if(leChar != null) {
					switch(arrayCharacters[i].jsonFile.dialogue_pos) {
						case 'left':
							leChar.x -= style.scrollSpeed * elapsed;
						case 'center':
							leChar.y += style.scrollSpeed * elapsed;
						case 'right':
							leChar.x += style.scrollSpeed * elapsed;
					}
					leChar.alpha -= style.alphaFadeinScale * elapsed * 10;
				}
			}

			if(box == null && bgFade == null) {
				for (i in 0...arrayCharacters.length) {
					var leChar:DialogueCharacter = arrayCharacters[0];
					if(leChar != null) {
						arrayCharacters.remove(leChar);
						leChar.kill();
						remove(leChar);
						leChar.destroy();
					}
				}
				finishThing();
				kill();
			}
		}
		super.update(elapsed);
	}

	function skipDialogue(){
		dialogueEnded = true;

		tryPlayingBoxAnim(last_pos,last_style,'Open');

					box.animation.curAnim.curFrame = box.animation.curAnim.frames.length - 1;
					box.animation.curAnim.reverse();
					if(daText != null)
					{
						daText.kill();
						remove(daText);
						daText.destroy();
					}
					skipText.visible = false;
					updateBoxOffsets(box);
					FlxG.sound.music.fadeOut(1, 0, (_) -> FlxG.sound.music.stop());
	}
	var lastCharacter:Int = -1;
	var lastBoxType:String = '';
	function startNextDialog():Void
	{
		var curDialogue:DialogueLine = null;
		do {
			curDialogue = dialogueList.dialogue[currentText];
		} while(curDialogue == null);

		if(curDialogue.text == null || curDialogue.text.length < 1) curDialogue.text = ' ';
		if(curDialogue.boxState == null) curDialogue.boxState = 'normal';
		if(curDialogue.speed == null || Math.isNaN(curDialogue.speed)) curDialogue.speed = 0.05;

		var animName:String = curDialogue.boxState;
		var boxType:String = textBoxTypes[0];
		for (i in 0...textBoxTypes.length) {
			if(textBoxTypes[i] == animName) {
				boxType = animName;
			}
		}

		var character:Int = 0;
		box.visible = true;
		for (i in 0...arrayCharacters.length) {
			if(arrayCharacters[i].curCharacter == curDialogue.portrait) {
				character = i;
				break;
			}
		}
		var centerPrefix:String = '';
		var lePosition:String = arrayCharacters[character].jsonFile.dialogue_pos;
		if(lePosition == 'center') centerPrefix = 'center-';
		if(lePosition == 'left') centerPrefix = 'left-';

		if(character != lastCharacter) {
			tryPlayingBoxAnim(centerPrefix,boxType,'Open');
			updateBoxOffsets(box);
		} else if(boxType != lastBoxType) {
			tryPlayingBoxAnim(centerPrefix,boxType,"");
			updateBoxOffsets(box);
		}
		lastCharacter = character;
		lastBoxType = boxType;

		var dlg_sound = curDialogue.sound;
		if(dlg_sound == null || dlg_sound.trim() == '') dlg_sound = 'dialogue';
		style.prepareLine(curDialogue.text,curDialogue.speed,dlg_sound);

		daText.y = style.DEFAULT_TEXT_Y;
		if(style.rowCount() > 2) daText.y -= style.LONG_TEXT_ADD;

		var char:DialogueCharacter = arrayCharacters[character];
		if(char != null) {
			char.playAnim(curDialogue.expression, style.isLineFinished());
			if(char.animation.curAnim != null) {
				var rate:Float = 24 - (((curDialogue.speed - 0.05) / 5) * 480);
				if(rate < 12) rate = 12;
				else if(rate > 48) rate = 48;
				char.animation.curAnim.frameRate = rate;
			}
		}
		currentText++;

		if(nextDialogueThing != null) {
			nextDialogueThing();
		}
	}

	var last_pos = "";
	var last_style = "";
	var last_state = "";
	function tryPlayingBoxAnim(pos:String,style:String,state:String) {
		var anim = pos+style+state;
		if(!box.animation.getNameList().contains(anim)){
			#if debug
			trace('Animation ${anim} is missing from the box. Is that intentional?');
			#end
			return;
		}
		last_pos = pos;
		last_style = style;
		last_state = state;
		box.animation.play(anim, true);
	}

	inline public static function parseDialogue(path:String):DialogueFile {
		#if MODS_ALLOWED
		return cast (FileSystem.exists(path)) ? Json.parse(File.getContent(path)) : dummy();
		#else
		return cast (Assets.exists(path, TEXT)) ? Json.parse(Assets.getText(path)) : dummy();
		#end
	}

	inline public static function dummy():DialogueFile
	{
		return { dialogue: [
			{
				expression: "talk",
				text: "DIALOGUE NOT FOUND",
				boxState: "normal",
				speed: 0.05,
				portrait: "bf"
			}
		],
		style:""};
	}

	public static function updateBoxOffsets(box:FlxSprite) { //Had to make it static because of the editors
		box.centerOffsets();
		box.updateHitbox();
		if(box.animation.curAnim.name.startsWith('angry')) {
			box.offset.set(50, 65);
		} else if(box.animation.curAnim.name.startsWith('center-angry')) {
			box.offset.set(50, 30);
		} else {
			box.offset.set(10, 0);
		}
		
		if(!box.flipX) box.offset.y += 10;
	}
}
