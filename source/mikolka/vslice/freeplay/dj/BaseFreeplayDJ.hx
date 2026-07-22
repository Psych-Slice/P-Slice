package mikolka.vslice.freeplay.dj;

import flixel.util.FlxSignal;
import mikolka.funkin.players.PlayerData.PlayerFreeplayDJData;

enum FreeplayDJState
{
  /**
   * Character enters the frame and transitions to Idle.
   */
  Intro;

  /**
   * Character loops in idle.
   */
  Idle;

  /**
   * Plays an easter egg animation after a period in Idle, then reverts to Idle.
   */
  IdleEasterEgg;

  /**
   * Plays an elaborate easter egg animation. Does not revert until another animation is triggered.
   */
  Cartoon;

  /**
   * Player has selected a song.
   */
  Confirm;

  /**
   * Character preps to play the fist pump animation; plays after the Results screen.
   * The actual frame label that gets played may vary based on the player's success.
   */
  FistPumpIntro;

  /**
   * Character plays the fist pump animation.
   * The actual frame label that gets played may vary based on the player's success.
   */
  FistPump;

  /**
   * Plays an animation to indicate that the player has a new unlock in Character Select.
   * Overrides all idle animations as well as the fist pump. Only Confirm and CharSelect will override this.
   */
  NewUnlock;

  /**
   * Plays an animation to transition to the Character Select screen.
   */
  CharSelect;
}

@:nullSafety
class BaseFreeplayDJ extends FunkinSprite
{
  public var IDLE_EGG_PERIOD:Float = 60.0;
  public var IDLE_CARTOON_PERIOD:Float = 120.0;

  // Represents the sprite's current status.
  // Without state machines I would have driven myself crazy years ago.
  // Made this PRIVATE so we can keep track of everything that can alter the state!
  //   Add a function to this class if you want to edit this value from outside.
  private var currentState:FreeplayDJState = Intro;

  // A callback activated when the intro animation finishes.
  public var onIntroDone:FlxSignal = new FlxSignal();

  // A callback activated when the idle easter egg plays.
  public var onIdleEasterEgg:FlxSignal = new FlxSignal();

  var seenIdleEasterEgg:Bool = false;

  final characterId:String = Constants.DEFAULT_CHARACTER;
  final playableCharData:Null<PlayerFreeplayDJData>;

  var timeIdling:Float = 0;
  var lowPumpLoopPoint:Int = 4;

  public function new(x:Float, y:Float, characterId:String)
  {
    this.characterId = characterId;

    final playableChar = PlayerRegistry.instance.fetchEntry(characterId);
    playableCharData = playableChar?.getFreeplayDJData();

    super(x, y);
  }

  function onFinishAnim(name:String):Void {}

  public function onCharSelectComplete():Void
  {
    trace('onCharSelectComplete()');
  }

  public function playFlashAnimation(id:String, Force:Bool = false, Reverse:Bool = false, Loop:Bool = false, Frame:Int = 0):Void
  {
    // playAnimationSimple(id, Force, Reverse, Loop, Frame);
    applyAnimationOffset();
  }

  public function onPlayerAction():Void
  {
    resetAFKTimer();
  }

  public function resetAFKTimer():Void
  {
    timeIdling = 0;
    seenIdleEasterEgg = false;
  }

  public function getMusicPreviewMult():Float
  {
    return 1;
  }

  public function onConfirm():Void
  {
    // We really don't want to play anything but the new character animation here.
    if (PlayerRegistry.instance.hasNewCharacter())
    {
      currentState = NewUnlock;
      return;
    }

    currentState = Confirm;
  }

  public function toCharSelect():Void
  {
    var animPrefix = playableCharData?.getAnimationPrefix('charSelect');
    if (animPrefix != null && hasAnimation(animPrefix))
    {
      currentState = CharSelect;
      playFlashAnimation(animPrefix, true, false, false, 0);
    }
    else
    {
      FlxG.log.warn("Freeplay character does not have 'charSelect' animation!");
      currentState = Confirm;
      // Call this immediately; otherwise, we get locked out of Character Select.
      onCharSelectComplete();
    }
  }

  public function fistPumpIntro():Void
  {
    // We really don't want to play anything but the new character animation here.
    if (PlayerRegistry.instance.hasNewCharacter())
    {
      currentState = NewUnlock;
      return;
    }

    currentState = FistPumpIntro;
    var animPrefix = playableCharData?.getAnimationPrefix('fistPump');
    if (animPrefix != null) playFlashAnimation(animPrefix, true, false, false, playableCharData?.getFistPumpIntroStartFrame());
  }

  public function fistPump():Void
  {
    // We really don't want to play anything but the new character animation here.
    if (PlayerRegistry.instance.hasNewCharacter())
    {
      currentState = NewUnlock;
      return;
    }

    currentState = FistPump;
    var animPrefix = playableCharData?.getAnimationPrefix('fistPump');
    if (animPrefix != null) playFlashAnimation(animPrefix, true, false, false, playableCharData?.getFistPumpLoopStartFrame());
  }

  public function fistPumpLossIntro():Void
  {
    // We really don't want to play anything but the new character animation here.
    if (PlayerRegistry.instance.hasNewCharacter())
    {
      currentState = NewUnlock;
      return;
    }

    currentState = FistPumpIntro;
    var animPrefix = playableCharData?.getAnimationPrefix('loss');
    if (animPrefix != null) playFlashAnimation(animPrefix, true, false, false, playableCharData?.getFistPumpIntroBadStartFrame());
  }

  public function fistPumpLoss():Void
  {
    // We really don't want to play anything but the new character animation here.
    if (PlayerRegistry.instance.hasNewCharacter())
    {
      currentState = NewUnlock;
      return;
    }

    currentState = FistPump;
    var animPrefix = playableCharData?.getAnimationPrefix('loss');
    if (animPrefix != null) playFlashAnimation(animPrefix, true, false, false, playableCharData?.getFistPumpLoopBadStartFrame());
  }

  function applyAnimationOffset():Void
  {
    var animationName:String = getCurrentAnimation();
    var animationOffsets:Null<Array<Float>> = playableCharData?.getAnimationOffsetsByPrefix(animationName);
    var globalOffsets:Array<Float> = [this.x, this.y];

    if (animationOffsets != null)
    {
      var finalOffsetX:Float = 0;
      var finalOffsetY:Float = 0;

      if (this.applyStageMatrix)
      {
        finalOffsetX = animationOffsets[0];
        finalOffsetY = animationOffsets[1];
      }
      else
      {
        finalOffsetX = globalOffsets[0] + animationOffsets[0] - (FreeplayState.CUTOUT_WIDTH * FreeplayState.DJ_POS_MULTI);
        finalOffsetY = globalOffsets[1] + animationOffsets[1];
      }

      offset.set(finalOffsetX, finalOffsetY);
    }
    else
    {
      offset.set(0, 0);
    }
  }
}
