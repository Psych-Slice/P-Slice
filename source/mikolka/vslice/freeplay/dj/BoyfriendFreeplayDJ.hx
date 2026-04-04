package mikolka.vslice.freeplay.dj;

import animate.internal.SymbolItem;
import animate.internal.Frame;
import openfl.utils.Assets;
import flixel.FlxG;
import mikolka.vslice.freeplay.dj.AnimateAtlasFreeplayDJ;
import mikolka.vslice.freeplay.dj.BaseFreeplayDJ.FreeplayDJState;
import mikolka.funkin.players.PlayerRegistry;
import mikolka.compatibility.funkin.FunkinPath as Paths;

using StringTools;

class BoyfriendFreeplayDJ extends AnimateAtlasFreeplayDJ
{
  final CARTOON_LIST:Array<String> = Assets.list().filter((path) -> return path.startsWith("assets/sounds/cartoons/"));
  final CARTOON_SYMBOL:String = 'Boyfriend DJ watchin tv OG';

  var currentCartoonFrame:Int = 60;
  var cartoonSnd:Null<FunkinSound> = null;
  var playingCartoon:Bool = false;

  public function new(x:Float, y:Float, characterId:String)
  {
    super(x, y, characterId);
    this.cartoonSnd?.destroy();

    animation.onFrameChange.add((name, number,_) ->
    {
      if (name == playableCharData.getAnimationPrefix('cartoon'))
      {
        if (number == getCartoonFrame('REMOTE_CLICK')) FunkinSound.playOnce(Paths.sound('remote_click'));
        if (number == getCartoonFrame('TV_SOUND')) _runTVLogic();
      }
    });
  }

  override function onFinishAnim(name:String):Void
  {
    if (name == playableCharData?.getAnimationPrefix('intro'))
    {
      currentState = (PlayerRegistry.instance.hasNewCharacter()) ? FreeplayDJState.NewUnlock : FreeplayDJState.Idle;
      onIntroDone.dispatch();
    }
    else if (name == playableCharData?.getAnimationPrefix('idle'))
    {
      if (timeIdling >= IDLE_EGG_PERIOD && !seenIdleEasterEgg) currentState = FreeplayDJState.IdleEasterEgg;
      else if (timeIdling >= IDLE_CARTOON_PERIOD) currentState = FreeplayDJState.Cartoon;
    }
    else if (name == playableCharData?.getAnimationPrefix('confirm'))
    {
      // trace('Finished confirm');
    }
    else if (name == playableCharData?.getAnimationPrefix('fistPump'))
    {
      // trace('Finished fist pump');
      currentState = FreeplayDJState.Idle;
    }
    else if (name == playableCharData?.getAnimationPrefix('idleEasterEgg'))
    {
      // trace('Finished spook');
      currentState = FreeplayDJState.Idle;
    }
    else if (name == playableCharData?.getAnimationPrefix('loss'))
    {
      // trace('Finished loss reaction');
      currentState = FreeplayDJState.Idle;
    }
    else if (name == playableCharData?.getAnimationPrefix('cartoon'))
    {
      // trace('Finished cartoon');

      this.currentCartoonFrame = FlxG.random.bool(33) ? getCartoonFrame('BLINK') : getCartoonFrame('LOOP');

      // Character switches channels when the video ends, or at a 10% chance each time his idle loops.
      if (FlxG.random.bool(10))
      {
        this.currentCartoonFrame = getCartoonFrame('CHANGE_CHANNEL');
      }

      var animationPrefix:String = playableCharData.getAnimationPrefix('cartoon');
      playFlashAnimation(animationPrefix, true, false, false, this.currentCartoonFrame);
    }
    else if (name == playableCharData?.getAnimationPrefix('newUnlock'))
    {
      // Animation should loop.
    }
    else if (name == playableCharData?.getAnimationPrefix('charSelect'))
    {
      onCharSelectComplete();
    }
    else
    {
      trace('Finished ${name}');
    }
  }

  function _runTVLogic():Void
  {
    if (cartoonSnd == null)
    {
      // tv is OFF, but getting turned on
      FunkinSound.playOnce(Paths.sound('tv_on'), 1.0, () ->
      {
        loadCartoon();
      });
    }
    else
    {
      // plays it smidge after the click
      FunkinSound.playOnce(Paths.sound('channel_switch'), 1.0, () ->
      {
        loadCartoon();
      });
    }
  }

  public function getCartoonFrame(frameLabel:String):Int
  {
    var cartoonSymbol:SymbolItem = this.library.getSymbol(CARTOON_SYMBOL);
    var cartoonFrame:Frame = this.getFrameLabel(frameLabel, cartoonSymbol.timeline);

    return cartoonFrame.index;
  }

  public function loadCartoon():Void
  {
    playingCartoon = true;

    if (cartoonSnd != null)
    {
      cartoonSnd.stop();
      cartoonSnd = null;
    }

    cartoonSnd = FunkinSound.load(Paths.sound(getRandomFlashToon()), 1.0, false, true, true, () ->
    {
      var animationPrefix:String = playableCharData.getAnimationPrefix('cartoon');
      if (animationPrefix != null) playFlashAnimation(animationPrefix, true, false, false, getCartoonFrame('CHANGE_CHANNEL'));
    });

    // Fade out music to 40% volume over 1 second.
    // This helps make the TV a bit more audible.
    FlxG.sound.music.fadeOut(1.0, 0.1);

    // Play the cartoon at a random time between the start and 5 seconds from the end.
    if (cartoonSnd != null) cartoonSnd.time = FlxG.random.float(0, Math.max(cartoonSnd.length - (5 * Constants.MS_PER_SEC), 0.0));
  }

  function getRandomFlashToon():String
  {
    var randomFile:String = CARTOON_LIST[FlxG.random.int(0, CARTOON_LIST.length - 1)];

    // Strip folder prefix
    randomFile = randomFile.replace("assets/sounds/", "");
    // Strip file extension
    randomFile = randomFile.substring(0, randomFile.length - 4);

    return randomFile;
  }

  public override function getMusicPreviewMult():Float
  {
    return playingCartoon ? 0.15 : 1;
  }

  public override function onConfirm():Void
  {
    super.onConfirm();
    if (this.cartoonSnd != null) this.cartoonSnd.fadeOut(.25, 0);
  }

  public override function toCharSelect():Void
  {
    super.toCharSelect();
    if (this.cartoonSnd != null) this.cartoonSnd.fadeOut(.25, 0);
  }

  public override function destroy():Void
  {
    super.destroy();

    if (this.cartoonSnd != null)
    {
      this.cartoonSnd.stop();
      this.cartoonSnd.destroy();
      this.cartoonSnd = null;
    }
  }
}
