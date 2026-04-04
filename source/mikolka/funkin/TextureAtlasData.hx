package mikolka.funkin;


typedef TextureAtlasData =
{
  /**
   * If true, the texture atlas will behave as if it was exported as an SWF file.
   * Notably, this allows MovieClip symbols to play.
   */
  @:optional
  var swfMode:Bool;

  /**
   * If true, filters and masks will be cached when the atlas is loaded, instead of during runtime.
   */
  @:optional
  var cacheOnLoad:Bool;

  /**
   * The filter quality.
   * Available values are: HIGH, MEDIUM, LOW, and RUDY.
   *
   * If you're making an atlas sprite in HScript, you pass an Int instead:
   *
   * HIGH - 0
   * MEDIUM - 1
   * LOW - 2
   * RUDY - 3
   */
  @:optional
  var filterQuality:Int;

  /**
   * Whether to apply the stage matrix, if it was exported from a symbol instance.
   * Also positions the Texture Atlas as it displays in Animate.
   * Turning this on is only recommended if you prepositioned the character in Animate.
   * For other cases, it should be turned off to act similarly to a normal FlxSprite.
   */
  @:optional
  var applyStageMatrix:Bool;

  /**
   * If enabled, the sprite will render as one texture instead of rendering multiple limbs.
   * This is useful for stuff like changing alpha, and shaders that require the whole sprite.
   *
   * Only enable this if your sprite either:
   * - Changes alpha to something other than 1.0
   * - Has a shader or blend mode
   */
  @:optional
  var useRenderTexture:Bool;
};
