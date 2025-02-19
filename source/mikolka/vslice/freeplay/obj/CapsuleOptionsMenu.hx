package mikolka.vslice.freeplay.obj;

import shaders.PureColor;
using mikolka.funkin.utils.StringTools;

class CapsuleOptionsMenu extends FlxSpriteGroup
{
  var capsuleMenuBG:FunkinSprite;
  var parent:FreeplayState;

  var queueDestroy:Bool = false;
  var busy:Bool = false;

  var instrumentalIds:Array<String> = [''];
  var currentInstrumentalIndex:Int = 0;

  var currentInstrumental:FlxText;

  var leftArrow:InstrumentalSelector;
  var rightArrow:InstrumentalSelector;

  public function new(parent:FreeplayState, x:Float = 0, y:Float = 0, instIds:Array<String>):Void
  {
    super(x, y);

    this.parent = parent;
    this.instrumentalIds = instIds;

    capsuleMenuBG = FunkinSprite.createSparrow(0, 0, 'freeplay/instBox/instBox');

    capsuleMenuBG.animation.addByPrefix('open', 'open0', 24, false);
    capsuleMenuBG.animation.addByPrefix('idle', 'idle0', 24, true);
    capsuleMenuBG.animation.addByPrefix('open', 'open0', 24, false);

    currentInstrumental = new FlxText(0, 36, capsuleMenuBG.width, '');
    currentInstrumental.setFormat(Paths.font("vcr.ttf"), 40, FlxTextAlign.CENTER, true);

    final PAD = 4;
    leftArrow = new InstrumentalSelector(parent, PAD, 30, false, parent.getControls());
    rightArrow = new InstrumentalSelector(parent, capsuleMenuBG.width - leftArrow.width - PAD, 30, true, parent.getControls());

    var label:FlxText = new FlxText(0, 5, capsuleMenuBG.width, 'INSTRUMENTAL');
    label.setFormat(Paths.font("vcr.ttf"), 24, FlxTextAlign.CENTER, true);

    add(capsuleMenuBG);
    add(leftArrow);
    add(rightArrow);
    add(label);
    add(currentInstrumental);

    capsuleMenuBG.animation.finishCallback = function(_) {
      capsuleMenuBG.animation.play('idle', true);
    };
    capsuleMenuBG.animation.play('open', true);
  }

  public override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (queueDestroy)
    {
      destroy();
      return;
    }
    @:privateAccess
    if (parent.controls.BACK && !busy)
    {
      busy = true;
      close();
      return;
    }

    var changedInst = false;
    if (parent.getControls().UI_LEFT_P || (TouchUtil.overlapsComplex(leftArrow) && TouchUtil.justPressed))
    {
      currentInstrumentalIndex = (currentInstrumentalIndex + 1) % instrumentalIds.length;
      changedInst = true;
      if (leftArrow != null) leftArrow.setPress(true);
    }
    if (parent.getControls().UI_RIGHT_P || (TouchUtil.overlapsComplex(rightArrow) && TouchUtil.justPressed))
    {
      currentInstrumentalIndex = (currentInstrumentalIndex - 1 + instrumentalIds.length) % instrumentalIds.length;
      changedInst = true;
      if (rightArrow != null) rightArrow.setPress(true);
    }
    if (leftArrow != null && rightArrow != null && TouchUtil.justReleased)
		{
			rightArrow.setPress(false);
			leftArrow.setPress(false);
		}
    if (!changedInst && currentInstrumental.text == '') changedInst = true;

    if (changedInst)
    {
        var newText = instrumentalIds[currentInstrumentalIndex] ?? '';
        var coolTemplate = ~/\((.*)\)/g;
        if(coolTemplate.match(newText)){
            newText = coolTemplate.matched(1);
        }
        currentInstrumental.text = newText.toTitleCase();
        if (currentInstrumental.text == '') currentInstrumental.text = 'Default';
    }

    if (parent.getControls().ACCEPT && !busy)
    {
      busy = true;
      onConfirm(instrumentalIds[currentInstrumentalIndex] ?? '');
    }
  }

  public function close():Void
  {
    // Play in reverse.
    capsuleMenuBG.animation.play('open', true, true);
    capsuleMenuBG.animation.finishCallback = function(_) {
      parent.cleanupCapsuleOptionsMenu();
      queueDestroy = true;
    };
  }

  /**
   * Override this with `capsuleOptionsMenu.onConfirm = myFunction;`
   */
  public dynamic function onConfirm(targetInstId:String):Void
  {
    throw 'onConfirm not implemented!';
  }
}

/**
 * The difficulty selector arrows to the left and right of the difficulty.
 */
class InstrumentalSelector extends FunkinSprite
{
  var controls:Controls;
  var whiteShader:PureColor;

  var parent:FreeplayState;

  var baseScale:Float = 0.6;

  public function new(parent:FreeplayState, x:Float, y:Float, flipped:Bool, controls:Controls)
  {
    super(x, y);

    this.parent = parent;

    this.controls = controls;

    frames = Paths.getSparrowAtlas('freeplay/freeplaySelector');
    animation.addByPrefix('shine', 'arrow pointer loop', 24);
    animation.play('shine');

    whiteShader = new PureColor(FlxColor.WHITE);

    shader = whiteShader;

    flipX = flipped;

    scale.x = scale.y = 1 * baseScale;
    updateHitbox();
  }

  override function update(elapsed:Float):Void
  {
    if (flipX && controls.UI_RIGHT_P) moveShitDown();
    if (!flipX && controls.UI_LEFT_P) moveShitDown();

    super.update(elapsed);
  }

  public function setPress(press:Bool):Void
	{
		if (!press)
		{
			scale.x = scale.y = 1 * baseScale;
			whiteShader.colorSet = false;
			updateHitbox();
		}
		else
		{
			offset.y -= 5;
			whiteShader.colorSet = true;
			scale.x = scale.y = 0.5 * baseScale;
		}
	}

  function moveShitDown():Void
  {
    offset.y -= 5;

    whiteShader.colorSet = true;

    scale.x = scale.y = 0.5 * baseScale;

    new FlxTimer().start(2 / 24, function(tmr) {
      scale.x = scale.y = 1 * baseScale;
      whiteShader.colorSet = false;
      updateHitbox();
    });
  }
}
