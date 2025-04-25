package mikolka.stages.cutscenes.dialogueBox.styles;

import mikolka.compatibility.VsliceOptions;
import mikolka.stages.cutscenes.dialogueBox.styles.DialogueStyle.DialogueBoxState;
import mikolka.stages.cutscenes.dialogueBox.styles.DialogueStyle.DialogueBoxPosition;
#if !LEGACY_PSYCH
import objects.TypedAlphabet;
#end

class PsychDialogueStyle extends DialogueStyle
{
	var alphabethText:TypedAlphabet;

	public function new()
	{
	}

	// {"","left-","center-"}+{"angry","normal"}+{"","Open","Wait"}
	public function makeDialogueBox():FlxSprite
	{
		box = new FlxSprite(70, 370);
		box.antialiasing = VsliceOptions.ANTIALIASING;
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

	public function _playBoxAnim(pos:DialogueBoxPosition, style:DialogueBoxState, boxType:String)
	{
		switch (style)
		{
			case OPEN | OPEN_INIT:
				box.centerOffsets();
				box.updateHitbox();
				if (boxType == "angry")
				{
					if (pos == CENTER)
					{
						box.offset.set(50, 30); // center-angry
						box.animation.play("center-angryOpen");
						#if LEGACY_PSYCH
						box.animation.finishCallback = (anim) ->
						{
							playBoxAnim(pos, IDLE, boxType);
							box.animation.finishCallback = null;
						}
						#else
						box.animation.onFinish.addOnce(anim -> playBoxAnim(pos, IDLE, boxType));
						#end
					}
					else
					{
						box.offset.set(50, 65); // angry
						box.animation.play("angryOpen");
						#if LEGACY_PSYCH
						box.animation.finishCallback = (anim) ->
						{
							playBoxAnim(pos, IDLE, boxType);
							box.animation.finishCallback = null;
						}
						#else
						box.animation.onFinish.addOnce(anim -> playBoxAnim(pos, IDLE, boxType));
						#end
					}
				}
				else
				{
					box.offset.set(10, 0);
					if (pos == CENTER)
						box.animation.play("center-normalOpen");
					else
						box.animation.play("normalOpen");
					#if LEGACY_PSYCH
					box.animation.finishCallback = (anim) ->
					{
						playBoxAnim(pos, IDLE, boxType);
						box.animation.finishCallback = null;
					}
					#else
					box.animation.onFinish.addOnce(anim -> playBoxAnim(pos, IDLE, boxType));
					#end
				}
				box.flipX = pos == LEFT;
				if (!box.flipX)
					box.offset.y += 10;
			case CLOSE_FINISH:
				var centerPrefix = pos == CENTER ? "center-" : "";
				if (boxType != "angry")
					box.animation.play(centerPrefix + "normalOpen", true, true);
				else
					box.animation.play(centerPrefix + "angryOpen", true, true);
			case IDLE:
				box.centerOffsets();
				box.updateHitbox();
				if (boxType == "angry")
				{
					if (pos == CENTER)
					{
						box.offset.set(50, 30); // center-angry
						box.animation.play("center-angry");
					}
					else
					{
						box.offset.set(50, 65); // angry
						box.animation.play("angry");
					}
				}
				else
				{
					box.offset.set(10, 0);
					if (pos == CENTER)
						box.animation.play("center-normal");
					else
						box.animation.play("normal");
				}
				box.flipX = pos == LEFT;
				if (!box.flipX)
					box.offset.y += 10;
			case WAIT:
				{}
		}
	}

	public function initText():FlxSprite
	{
		alphabethText = new TypedAlphabet(DEFAULT_TEXT_X, DEFAULT_TEXT_Y, '');
		alphabethText.setScale(0.7);
		return alphabethText;
	}

	// Dialogue BOX
	public function set_text(value:String)
		alphabethText.text = value;

	public function set_delay(value:Float)
		alphabethText.delay = value;

	public function get_delay():Float
		return alphabethText.delay;

	public function set_sound(value:String)
		alphabethText.sound = value;

	public function startLine()
	{
	}

	//

	public function isLineFinished():Bool
		return alphabethText.finishedText;

	public function finishLine()
		alphabethText.finishText();

	public function rowCount():Int
		return alphabethText.rows;
}
