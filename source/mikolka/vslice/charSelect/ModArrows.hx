package mikolka.vslice.charSelect;

import mikolka.compatibility.funkin.FunkinControls;
import mikolka.vslice.ui.obj.ModSelector;

class ModArrows extends FlxSpriteGroup {
    var dipshitLeftArrow:Null<CharModArrow>;
	var dipshitRightArrow:Null<CharModArrow>;

	var modSelector:ModSelector;

    public function new(xOffset:Float,modBar:ModSelector) {
            super();
            modSelector = modBar;
        	dipshitLeftArrow = new CharModArrow(365 + xOffset, 215,false);
			add(dipshitLeftArrow);

			dipshitRightArrow = new CharModArrow(788 + xOffset, 215,true);
			add(dipshitRightArrow);
    }
    override function update(elapsed:Float) {
    
			var pressedUiLeft = FunkinControls.FREEPLAY_LEFT;
			var pressedUiRight = FunkinControls.FREEPLAY_RIGHT;
			#if TOUCH_CONTROLS_ALLOWED
			#if debug
			if(FlxG.mouse.overlaps(dipshitLeftArrow))
				pressedUiLeft = FlxG.mouse.justPressed;
			if(FlxG.mouse.overlaps(dipshitRightArrow))
				pressedUiRight = FlxG.mouse.justPressed;
			
			#end
			if(TouchUtil.overlaps(dipshitLeftArrow))
				pressedUiLeft = TouchUtil.justPressed;
			if(TouchUtil.overlaps(dipshitRightArrow))
				pressedUiRight = TouchUtil.justPressed;
			#end

            if(pressedUiLeft && modSelector.allowInput)
				previousModPress();
            else if(pressedUiRight && modSelector.allowInput)
				nextModPress();
            
        super.update(elapsed);
    }
    public function nextModPress() {
        dipshitRightArrow.pressButton();
        modSelector.changeDirectory(1);
    }
    public function previousModPress() {
        dipshitLeftArrow.pressButton();
        modSelector.changeDirectory(-1);
    }
}
class CharModArrow extends FlxSprite{

	private var allowIdle:Bool = true;
	private var waitTimer:Null<FlxTimer>;
	public function new(x:Float,y:Float,flip:Bool) {
		super(x,y);
		frames = Paths.getSparrowAtlas('charSelect/charSelectArrow');
		scale.set(0.4, 0.4);
		updateHitbox();
		animation.addByPrefix("idle","cs arrow left idle0",24,true,flip);
        animation.addByPrefix("press","cs arrow left select0",24,false,flip);
	}
	override function update(elapsed:Float) {
		if (allowIdle){
			animation.play('idle');
			centerOffsets();
		}
		super.update(elapsed);
	}
	public function pressButton() {
		animation.play('press');
		offset.y -= 15;
		allowIdle = false;
		waitTimer?.cancel();
		waitTimer = FlxTimer.wait(0.2,() ->{
			allowIdle = true;
		});
	}
}