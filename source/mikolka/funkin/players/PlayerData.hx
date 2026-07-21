package mikolka.funkin.players;

import mikolka.compatibility.funkin.FunkinPath as Paths;

@:nullSafety
class PlayerData
{
	public function new() {}
	/**
	 * The sematic version number of the player data JSON format.
	 * Supports fancy comparisons like NPM does it's neat.
	 */
	public var version:String = "1.0";

	/**
	 * A readable name for this playable character.
	 */
	public var name:String = 'Unknown';

	/**
	 * The character IDs this character is associated with.
	 * Only songs that use these characters will show up in Freeplay.
	 */
	public var ownedChars:Array<String> = ["bf"];

	/**
	 * Whether to show songs with character IDs that aren't associated with any specific character.
	 */
	public var showUnownedChars:Bool = false;

	/**
	 * Which freeplay style to use for this character.
	 */
	public var freeplayStyle:String = 'bf';

	/**
	 * Data for displaying this character in the Freeplay menu.
	 * If null, display no DJ.
	 */
	public var freeplayDJ:Null<PlayerFreeplayDJData> = null;

	/**
	 * Data for displaying this character in the Character Select menu.
	 * If null, exclude from Character Select.
	 */
	public var charSelect:Null<PlayerCharSelectData> = {
		"position": 5,
		"gf": {
			"assetPath": "charSelect/gfChill",
			"animInfoPath": "charSelect/gfAnimInfo",
			"visualizer": false
		  }
	};

	/**
	 * Data for displaying this character in the results screen.
	 */
	public var results:Null<PlayerResultsData> = {
		"music": {
			"PERFECT_GOLD": "resultsPERFECT",
			"PERFECT": "resultsPERFECT",
			"EXCELLENT": "resultsEXCELLENT",
			"GREAT": "resultsNORMAL",
			"GOOD": "resultsNORMAL",
			"SHIT": "resultsSHIT"
		  },
		  "perfect": [],
		  "excellent": [],
		  "great": [],
		  "good": [],
		  "loss": [],
	};

	/**
	 * Whether this character is unlocked by default.
	 * Use a ScriptedPlayableCharacter to add custom logic.
	 */
	public var unlocked:Bool = true;
}

class PlayerFreeplayDJData
{
  var assetPath:String;
  var animations:Array<AnimationData>;



  @:optional
  @:default("BOYFRIEND")
  var text1:String;

  @:optional
  @:default("HOT BLOODED IN MORE WAYS THAN ONE")
  var text2:String;

  @:optional
  @:default("PROTECT YO NUTS")
  var text3:String;

  @:jignored
  var animationMap:Map<String, AnimationData>;

  @:jignored
  var prefixToOffsetsMap:Map<String, Array<Float>>;

  @:optional
  var charSelect:Null<PlayerFreeplayDJCharSelectData>;

  @:optional
  var fistPump:Null<PlayerFreeplayDJFistPumpData>;

  @:optional
  public var atlasSettings:TextureAtlasData;

  @:optional
  @:default("animateatlas")
  public var renderType:Null<String>;

  @:optional
  @:default(false)
  public var useAnimatePosition:Bool;

  @:optional
  @:default([0, 0])
  var offsets:Array<Float>;

  public function new()
  {
    animationMap = new Map();
  }

  function mapAnimations():Void
  {
    if (animationMap == null) animationMap = new Map();
    if (prefixToOffsetsMap == null) prefixToOffsetsMap = new Map();

    animationMap.clear();
    prefixToOffsetsMap.clear();
    for (anim in animations)
    {
      animationMap.set(anim.name, anim);
      prefixToOffsetsMap.set(anim.prefix, anim.offsets);
    }
  }

  public inline function getAssetPath():String return assetPath; // return assetPath;

  public inline function getAnimationsList():Array<AnimationData> return animations;

  public function useApplyStageMatrix():Bool
  {
    return !useAnimatePosition;
  }

  public function getGlobalOffsets():Array<Float>
  {
    return offsets;
  }

  /**
   * Normally, we'd let `FunkinSprite` handle the settings validation, but
   * Freeplay DJs have a special case where the turntable lights use a movieclip
   * that remains static without SWF mode enabled!
   * So we have to manually validate the settings to have SWF mode enabled by default.
   *
   * @return The configuration for the texture atlas.
   */
  public function getAtlasSettings():FunkinSprite.AtlasSpriteSettings
  {
    return {
      swfMode: atlasSettings?.swfMode ?? true,
      cacheOnLoad: atlasSettings?.cacheOnLoad ?? false,
      filterQuality: cast atlasSettings?.filterQuality ?? animate.FlxAnimateFrames.FilterQuality.MEDIUM,
      applyStageMatrix: atlasSettings?.applyStageMatrix ?? false,
      useRenderTexture: atlasSettings?.useRenderTexture ?? false
    }
  }

  public function getFreeplayDJText(index:Int):String
  {
    switch (index)
    {
      case 1:
        return text1;
      case 2:
        return text2;
      case 3:
        return text3;
      default:
        return '';
    }
  }

  
  public function getAnimationPrefix(name:String):Null<String>
  {
    if (animationMap.size() == 0) mapAnimations();

    var anim = animationMap.get(name);
    if (anim == null) return null;
    return anim.prefix;
  }

  public function getAnimationOffsetsByPrefix(?prefix:String):Array<Float>
  {
    if (prefixToOffsetsMap.size() == 0) mapAnimations();
    if (prefix == null) return [0, 0];
    return prefixToOffsetsMap.get(prefix);
  }

  public function getAnimationOffsets(name:String):Array<Float>
  {
    return getAnimationOffsetsByPrefix(getAnimationPrefix(name));
  }

  public function getFistPumpIntroStartFrame():Int
  {
    return fistPump?.introStartFrame ?? 0;
  }

  public function getFistPumpIntroEndFrame():Int
  {
    return fistPump?.introEndFrame ?? 0;
  }

  public function getFistPumpLoopStartFrame():Int
  {
    return fistPump?.loopStartFrame ?? 0;
  }

  public function getFistPumpLoopEndFrame():Int
  {
    return fistPump?.loopEndFrame ?? 0;
  }

  public function getFistPumpIntroBadStartFrame():Int
  {
    return fistPump?.introBadStartFrame ?? 0;
  }

  public function getFistPumpIntroBadEndFrame():Int
  {
    return fistPump?.introBadEndFrame ?? 0;
  }

  public function getFistPumpLoopBadStartFrame():Int
  {
    return fistPump?.loopBadStartFrame ?? 0;
  }

  public function getFistPumpLoopBadEndFrame():Int
  {
    return fistPump?.loopBadEndFrame ?? 0;
  }

  public function getCharSelectTransitionDelay():Float
  {
    return charSelect?.transitionDelay ?? 0.25;
  }
}

typedef PlayerCharSelectData =
{
	/**
	 * A zero-indexed number for the character's preferred position in the grid.
	 * 0 = top left, 4 = center, 8 = bottom right
	 * In the event of a conflict, the first character alphabetically gets it,
	 * and others get shifted over.
	 */
	public var position:Null<Int>;
	public var gf:PlayerCharSelectGFData;
}

typedef PlayerResultsData =
{
	var music:PlayerResultsMusicData;

	var perfect:Array<PlayerResultsAnimationData>;
	var excellent:Array<PlayerResultsAnimationData>;
	var great:Array<PlayerResultsAnimationData>;
	var good:Array<PlayerResultsAnimationData>;
	var loss:Array<PlayerResultsAnimationData>;
};

typedef PlayerCharSelectGFData =
{
  public var assetPath:String;

  public var animInfoPath:String;

  public var visualizer:Bool;
}

typedef PlayerResultsMusicData =
{
	var PERFECT_GOLD:String;

	var PERFECT:String;

	var EXCELLENT:String;

	var GREAT:String;

	var GOOD:String;

	var SHIT:String;
}

typedef PlayerResultsAnimationData =
{
	/**
	 * `sparrow` or `animate` or whatever
	 */
	var renderType:String;

	var assetPath:String;

	var filter:String;

	// We can now play sounds apparently
	var sound:String;

	@:default([0, 0])
	var offsets:Array<Float>;

	@:default(500)
	var zIndex:Int;

	@:default(0.0)
	var delay:Float;

	@:default(1.0)
	var scale:Float;

	@:default('')
	var startFrameLabel:Null<String>;

	@:default(true)
	var looped:Bool;

	var loopFrame:Null<Int>;

	var loopFrameLabel:Null<String>;
};

typedef PlayerFreeplayDJCharSelectData =
{
	var transitionDelay:Float;
}

typedef PlayerFreeplayDJCartoonData =
{
	var soundClickFrame:Int;
	var soundCartoonFrame:Int;
	var loopBlinkFrame:Int;
	var loopFrame:Int;
	var channelChangeFrame:Int;
}

typedef PlayerFreeplayDJFistPumpData =
{
	@:default(0)
	var introStartFrame:Int;

	@:default(4)
	var introEndFrame:Int;

	@:default(4)
	var loopStartFrame:Int;

	@:default(-1)
	var loopEndFrame:Int;

	@:default(0)
	var introBadStartFrame:Int;

	@:default(4)
	var introBadEndFrame:Int;

	@:default(4)
	var loopBadStartFrame:Int;

	@:default(-1)
	var loopBadEndFrame:Int;
};
