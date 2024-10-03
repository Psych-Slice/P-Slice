package mikolka.funkin.freeplay;

import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;

/**
 * A class representing the data for a style of the Freeplay menu.
 */
class FreeplayStyle
{
  /**
   * The internal ID for this freeplay style.
   */
  public final id:String;

  /**
   * The full data for a freeplay style.
   */
  public final _data:FreeplayStyleData;

  public function new(id:String,data:FreeplayStyleData)
  {
    this.id = id;
    this._data = data;

    if (_data == null)
    {
      throw 'Could not parse freeplay data for id: $id';
    }
  }

  /**
   * Get the background art as a graphic, ready to apply to a sprite.
   * @return The built graphic
   */
  public function getBgAssetGraphic():FlxGraphic
  {
    return FlxG.bitmap.add(Paths.image(getBgAssetKey()));
  }

  /**
   * Get the asset key for the background.
   * @return The asset key
   */
  public function getBgAssetKey():String
  {
    return _data.bgAsset;
  }

  /**
   * Get the asset key for the background.
   * @return The asset key
   */
  public function getSelectorAssetKey():String
  {
    return _data.selectorAsset;
  }

  /**
   * Get the asset key for the number assets.
   * @return The asset key
   */
  public function getCapsuleAssetKey():String
  {
    return _data.capsuleAsset;
  }

  /**
   * Get the asset key for the capsule art.
   * @return The asset key
   */
  public function getNumbersAssetKey():String
  {
    return _data.numbersAsset;
  }

  /**
   * Return the deselected color of the text outline
   * for freeplay capsules.
   * @return The deselected color
   */
  public function getCapsuleDeselCol():FlxColor
  {
    return FlxColor.fromString(_data.capsuleTextColors[0]);
  }

  /**
   * Return the song selection transition delay.
   * @return The start delay
   */
  public function getStartDelay():Float
  {
    return _data.startDelay;
  }

  public function toString():String
  {
    return 'Style($id)';
  }

  /**
   * Return the selected color of the text outline
   * for freeplay capsules.
   * @return The selected color
   */
  public function getCapsuleSelCol():FlxColor
  {
    return FlxColor.fromString(_data.capsuleTextColors[1]);
  }

  public function destroy():Void {}
}
