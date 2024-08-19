package shaders;

import flixel.addons.display.FlxRuntimeShader;
import openfl.utils.Assets;

class Grayscale extends FlxRuntimeShader
{
  public var amount:Float = 1;

  public function new(amount:Float = 1)
  {
    super(Assets.getText(Paths.getPath('shaders/grayscale.frag', TEXT, null,false)));
    setAmount(amount);
  }

  public function setAmount(value:Float):Void
  {
    amount = value;
    this.setFloat("_amount", amount);
  }
}
