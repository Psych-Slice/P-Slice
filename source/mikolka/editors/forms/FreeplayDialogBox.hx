package mikolka.editors.forms;

import haxe.Exception;
import mikolka.vslice.components.crash.UserErrorSubstate;
import mikolka.vslice.freeplay.BGScrollingText;
import mikolka.editors.substates.FreeplayEditSubstate;
using mikolka.editors.PsychUIUtills;

class FreeplayDialogBox extends PsychUIBox
{
    	// GENERAL
	public var input_assetPath:PsychUIInputText;
	public var btn_reload:PsychUIButton;
	public var steper_charSelectDelay:PsychUINumericStepper;
	public var input_text1:PsychUIInputText;
	public var input_text2:PsychUIInputText;
	public var input_text3:PsychUIInputText;
	// DJ EDITOR
	public var steper_introStartFrame:PsychUINumericStepper;
	public var steper_introEndFrame:PsychUINumericStepper;
	public var steper_loopStartFrame:PsychUINumericStepper;
	public var steper_loopEndFrame:PsychUINumericStepper;
	public var steper_introBadStartFrame:PsychUINumericStepper;
	public var steper_loopBadEndFrame:PsychUINumericStepper;
	public var steper_loopBadStartFrame:PsychUINumericStepper;
	public var steper_introBadEndFrame:PsychUINumericStepper;
	// ANIMATION
	public var list_animations:PsychUIDropDownMenu;
	public var input_animName:PsychUIInputText;
	public var input_animPrefix:PsychUIInputText;
	public var btn_newAnim:PsychUIButton;
	public var btn_trashAnim:PsychUIButton;
	public var stepper_offset_x:PsychUINumericStepper;
	public var stepper_offset_y:PsychUINumericStepper;

	public function new(host:FreeplayEditSubstate)
	{
		super(FlxG.width - 500, FlxG.height, 300, 250, ['General', "DJ Editor", "Animation"]);
		x -= width;
		y -= height;
		scrollFactor.set();
        var backingCard = host.backingCard;
        var data = host.data;
        var dj_anim = host.dj_anim;

		// GENERAL
		@:privateAccess {
			input_assetPath = new PsychUIInputText(10, 20, 150, data._data.freeplayDJ.assetPath);
			input_assetPath.onChange = (prev, cur) ->
			{
				data._data.freeplayDJ.assetPath = cur;
			};
		}

		btn_reload = new PsychUIButton(180, 20, "Reload", () ->
		{
			try{
				var sprite = new FlxAtlasSprite(640, 366, data.getFreeplayDJData().getAtlasPath());
				host.dj_anim.saveAnimations();
				host.remove(host.dj);
				host.dj.destroy();
				host.dj = sprite;
				host.dj_anim.attachSprite(host.dj);
				host.add(host.dj);
			}
			catch(x:Exception){
				UserErrorSubstate.makeMessage("Could not make the sprite",
				x.details()
				);
			}

		});

		@:privateAccess {
			steper_charSelectDelay = new PsychUINumericStepper(10, 130, 0.1, data._data.freeplayDJ.charSelect.transitionDelay, 0, 15, 1, 100);
			steper_charSelectDelay.onValueChange = () ->
			{
				data._data.freeplayDJ.charSelect.transitionDelay = steper_charSelectDelay.value;
			};

			input_text1 = new PsychUIInputText(10, 50, 150, data._data.freeplayDJ.text1);
			input_text2 = new PsychUIInputText(10, 70, 150, data._data.freeplayDJ.text2);
			input_text3 = new PsychUIInputText(10, 90, 150, data._data.freeplayDJ.text3);

			var currentCharacter = data.getFreeplayDJData();
			input_text1.onChange = (prev, current) ->
			{
				data.getFreeplayDJData().text1 = current;
				backingCard.remove(backingCard.funnyScroll);
				backingCard.remove(backingCard.funnyScroll2);
				backingCard.remove(backingCard.funnyScroll3);
				backingCard.funnyScroll.destroy();
				backingCard.funnyScroll2.destroy();
				backingCard.funnyScroll3.destroy();
				backingCard.funnyScroll = new BGScrollingText(0, 220, currentCharacter.getFreeplayDJText(1), FlxG.width / 2, false, 60);
				backingCard.funnyScroll2 = new BGScrollingText(0, 335, currentCharacter.getFreeplayDJText(1), FlxG.width / 2, false, 60);
				backingCard.funnyScroll3 = new BGScrollingText(0, backingCard.orangeBackShit.y + 10, currentCharacter.getFreeplayDJText(1), FlxG.width / 2, 60);
				backingCard.funnyScroll.funnyColor = 0xFFFF9963;
				backingCard.funnyScroll2.funnyColor = 0xFFFF9963;
				backingCard.funnyScroll3.funnyColor = 0xFFFEA400;
				backingCard.funnyScroll.speed = backingCard.funnyScroll2.speed = backingCard.funnyScroll3.speed = -3.8;
				backingCard.add(backingCard.funnyScroll);
				backingCard.add(backingCard.funnyScroll2);
				backingCard.add(backingCard.funnyScroll3);
			};
			input_text2.onChange = (prev, current) ->
			{
				data.getFreeplayDJData().text2 = current;
				backingCard.remove(backingCard.moreWays);
				backingCard.remove(backingCard.moreWays2);
				backingCard.moreWays.destroy();
				backingCard.moreWays2.destroy();
				backingCard.moreWays = new BGScrollingText(0, 160, currentCharacter.getFreeplayDJText(2), FlxG.width, true, 43);
				backingCard.moreWays2 = new BGScrollingText(0, 397, currentCharacter.getFreeplayDJText(2), FlxG.width, true, 43);
				backingCard.moreWays.speed = backingCard.moreWays2.speed = 6.8;
				backingCard.moreWays.funnyColor = backingCard.moreWays2.funnyColor = 0xFFFFF383;
				backingCard.add(backingCard.moreWays);
				backingCard.add(backingCard.moreWays2);
			}
			input_text3.onChange = (prev, current) ->
			{
				data.getFreeplayDJData().text3 = current;
				backingCard.remove(backingCard.txtNuts);
				backingCard.txtNuts.destroy();
				backingCard.txtNuts = new BGScrollingText(0, 285, currentCharacter.getFreeplayDJText(3), FlxG.width / 2, true, 43);
				backingCard.txtNuts.speed = 3.5;
				backingCard.add(backingCard.txtNuts);
			}
		}
		// DJ EDITOR
		var dj_editor_desc_txt = new FlxText(10, 10, 400, "Pick frames (start,end)");
		dj_editor_desc_txt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.BLACK);

		var txt_introStart = new FlxText(10, 50, 0, "Victory intro:", 10);
		steper_introStartFrame = new PsychUINumericStepper(100, 50, 1, data.getFreeplayDJData().getFistPumpIntroStartFrame(), 0, 100);
		steper_introEndFrame = new PsychUINumericStepper(170, 50, 1, data.getFreeplayDJData().getFistPumpIntroEndFrame(), -1, 100);

		var txt_introLoop = new FlxText(10, 90, 0, "Victory loop:", 10);
		steper_loopStartFrame = new PsychUINumericStepper(100, 90, 1, data.getFreeplayDJData().getFistPumpLoopStartFrame(), 0, 100);
		steper_loopEndFrame = new PsychUINumericStepper(170, 90, 1, data.getFreeplayDJData().getFistPumpLoopEndFrame(), -1, 100);

		var txt_introBadStart = new FlxText(10, 130, 0, "Loss intro:", 10);
		steper_introBadStartFrame = new PsychUINumericStepper(100, 130, 1, data.getFreeplayDJData().getFistPumpIntroBadStartFrame(), 0, 100);
		steper_introBadEndFrame = new PsychUINumericStepper(170, 130, 1, data.getFreeplayDJData().getFistPumpIntroBadEndFrame(), -1, 100);

		var txt_introBadLoop = new FlxText(10, 170, 0, "Loss loop:", 10);
		steper_loopBadStartFrame = new PsychUINumericStepper(100, 170, 1, data.getFreeplayDJData().getFistPumpLoopBadStartFrame(), 0, 100);
		steper_loopBadEndFrame = new PsychUINumericStepper(170, 170, 1, data.getFreeplayDJData().getFistPumpLoopBadEndFrame(), -1, 100);

		@:privateAccess {
			var fist = data.getFreeplayDJData().fistPump;
			steper_introStartFrame.onValueChange = () -> fist.introStartFrame = Math.floor(steper_introStartFrame.value);
			steper_introEndFrame.onValueChange = () -> fist.introEndFrame = Math.floor(steper_introEndFrame.value);
			steper_loopStartFrame.onValueChange = () -> fist.loopStartFrame = Math.floor(steper_loopStartFrame.value);
			steper_loopEndFrame.onValueChange = () -> fist.loopEndFrame = Math.floor(steper_loopEndFrame.value);

			steper_introBadStartFrame.onValueChange = () -> fist.introBadStartFrame = Math.floor(steper_introBadStartFrame.value);
			steper_introBadEndFrame.onValueChange = () -> fist.introBadEndFrame = Math.floor(steper_introBadEndFrame.value);
			steper_loopBadStartFrame.onValueChange = () -> fist.loopBadStartFrame = Math.floor(steper_loopBadStartFrame.value);
			steper_loopBadEndFrame.onValueChange = () -> fist.loopBadEndFrame = Math.floor(steper_loopBadEndFrame.value);
		}
		// Animation
		list_animations = new PsychUIDropDownMenu(10, 10, dj_anim.getAnimTitlesForSelector(), (index, name) ->
		{
			dj_anim.setAnimIndex(index);
			input_animName.text = dj_anim.curAnimName;
			input_animPrefix.text = dj_anim.curAnimPrefix;
			stepper_offset_x.value = dj_anim.curOffset[0];
			stepper_offset_y.value = dj_anim.curOffset[1];
		});
		btn_newAnim = new PsychUIButton(140, 10, "New", () ->
		{
			if (list_animations.list.length >= 20)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				return;
			}
			@:privateAccess {
				list_animations.addOption("newAnim");
				host.dj_anim.addAnim({
					readableName: "newAnim",
					anim: "prefix"
				});
			}
			dj_anim.offsets.push([0, 0]);
		}, 50);
		btn_trashAnim = new PsychUIButton(200, 10, "Delete", () ->
		{
			var index = list_animations.selectedIndex;
			if (list_animations.list.length == 1)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				return;
			}

			list_animations.removeIndex(index);
			dj_anim.anims.remove(dj_anim.anims[index]);
			var label = dj_anim.labels[index];
			dj_anim.remove(label);
			dj_anim.labels.remove(label);
			for (x in index...dj_anim.labels.length)
			{
				dj_anim.labels[x].y -= 20;
			}
			dj_anim.offsets.remove(dj_anim.offsets[index]);
			host.dj_selectAnim(index == 0 ? 0 : -1);
		}, 50);

		input_animName = new PsychUIInputText(10, 50, 150, dj_anim.curAnimName);
		input_animPrefix = new PsychUIInputText(10, 90, 150, dj_anim.curAnimPrefix);
		stepper_offset_x = new PsychUINumericStepper(20, 130, 1, dj_anim.curOffset[0], -9999, 9999); // dirty lol
		stepper_offset_y = new PsychUINumericStepper(85, 130, 1, dj_anim.curOffset[1], -9999, 9999);
		input_animName.onChange = (old, cur) ->
		{
			dj_anim.curAnimName = cur;
			list_animations.updateCurrentItem(cur);
		}
		input_animPrefix.onChange = (old, cur) ->
		{
			dj_anim.curAnimPrefix = cur;
		}
		stepper_offset_x.onValueChange = () ->
		{
			dj_anim.setOffset(stepper_offset_x.value, stepper_offset_y.value);
		};
		stepper_offset_y.onValueChange = () ->
		{
			dj_anim.setOffset(stepper_offset_x.value, stepper_offset_y.value);
		};

		// ?

		// GENERAL
		selectedName = 'General';
		var tab = getTab('General').menu;

		tab.add(input_assetPath.makeLabel('Asset path:'));
		tab.add(input_assetPath);
		tab.add(btn_reload);

		tab.add(input_text1.makeLabel("Scroll texts:"));
		tab.add(input_text1);
		tab.add(input_text2);
		tab.add(input_text3);

		tab.add(steper_charSelectDelay.makeLabel("Transition delay:"));
		tab.add(steper_charSelectDelay);

		// DJ EDITOR
		var tab = getTab("DJ Editor").menu;
		tab.add(dj_editor_desc_txt);
		tab.add(txt_introStart);
		tab.add(steper_introStartFrame);
		tab.add(steper_introStartFrame);
		tab.add(txt_introLoop);
		tab.add(steper_loopStartFrame);
		tab.add(steper_loopEndFrame);
		tab.add(txt_introBadStart);
		tab.add(steper_introBadStartFrame);
		tab.add(steper_introBadEndFrame);
		tab.add(txt_introBadLoop);
		tab.add(steper_loopBadStartFrame);
		tab.add(steper_loopBadEndFrame);
		tab.add(steper_introEndFrame);
		// tab.add(btn_player_prev);

		// Animation
		var tab = getTab("Animation").menu;
		tab.add(btn_newAnim);
		tab.add(btn_trashAnim);
		tab.add(input_animName.makeLabel("Name"));
		tab.add(input_animName);
		tab.add(input_animPrefix.makeLabel("Prefix"));
		tab.add(input_animPrefix);
		tab.add(new FlxText(10, 110, 100, "Offsets (x,y)"));
		tab.add(stepper_offset_x);
		tab.add(stepper_offset_y);
		tab.add(list_animations);
	}
    
}
