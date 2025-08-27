package mikolka.vslice.charSelect;

import mikolka.compatibility.funkin.FunkinControls;
import mikolka.vslice.ui.obj.ModSelector;

class ModArrows extends FlxSpriteGroup {
    var dipshitLeftArrow:Null<FlxSprite>;
	var dipshitRightArrow:Null<FlxSprite>;
	var modSelector:ModSelector;

    public function new(xOffset:Float,modBar:ModSelector) {
            super();
            modSelector = modBar;
        	dipshitLeftArrow = new FlxSprite(240 + xOffset, 135);
			dipshitLeftArrow.frames = Paths.getSparrowAtlas('charSelect/charSelectArrow');
            dipshitLeftArrow.animation.addByPrefix("idle","cs arrow left idle0",24,true);
            dipshitLeftArrow.animation.addByPrefix("press","cs arrow left select0",24);
			dipshitLeftArrow.scale.set(0.4, 0.4);
			add(dipshitLeftArrow);

			dipshitRightArrow = new FlxSprite(663 + xOffset, 135);
			dipshitRightArrow.frames = Paths.getSparrowAtlas('charSelect/charSelectArrow');
			dipshitRightArrow.scale.set(0.4, 0.4);
			dipshitRightArrow.animation.addByPrefix("idle","cs arrow left idle0",24,true,true);
            dipshitRightArrow.animation.addByPrefix("press","cs arrow left select0",24,false,true);
			add(dipshitRightArrow);
    }
    override function update(elapsed:Float) {
    
        	var holdingUiRight = FunkinControls.FREEPLAY_RIGHT;
			var holdingUiLeft = FunkinControls.FREEPLAY_LEFT;
			var pressedUiLeft = FunkinControls.FREEPLAY_LEFT;
			var pressedUiRight = FunkinControls.FREEPLAY_RIGHT;
			#if TOUCH_CONTROLS_ALLOWED
			#if debug
			if(FlxG.mouse.overlaps(dipshitLeftArrow)){
				holdingUiLeft = true;
				pressedUiLeft = FlxG.mouse.justPressed;
			}			
			if(FlxG.mouse.overlaps(dipshitRightArrow)){
				holdingUiRight = true;
				pressedUiRight = FlxG.mouse.justPressed;
			}
			#end
			if(TouchUtil.overlaps(dipshitLeftArrow)){
				holdingUiLeft = true;
				pressedUiLeft = TouchUtil.justPressed;
			}			
			if(TouchUtil.overlaps(dipshitRightArrow)){
				holdingUiRight = true;
				pressedUiRight = TouchUtil.justPressed;
			}

			#end

			if (holdingUiRight)
				dipshitRightArrow.animation.play('press')
			else
				dipshitRightArrow.animation.play('idle');

			if (holdingUiLeft)
				dipshitLeftArrow.animation.play('press');
			else
				dipshitLeftArrow.animation.play('idle');

            if(pressedUiLeft)
			    modSelector.changeDirectory(-1);
            else if(pressedUiRight)
			    modSelector.changeDirectory(1);
            
        super.update(elapsed);
    }
    public function nextModPress() {
        dipshitRightArrow.animation.play('press');
        modSelector.changeDirectory(1);
    }
    public function previousModPress() {
        dipshitLeftArrow.animation.play('press');
        modSelector.changeDirectory(-11);
    }
}