package mikolka.vslice.freeplay.dj;

import openfl.utils.Assets;
import flixel.FlxG;
import funkin.audio.FunkinSound;
import funkin.ui.freeplay.dj.AnimateAtlasFreeplayDJ;
import funkin.ui.freeplay.dj.FreeplayDJState;
import funkin.data.freeplay.player.PlayerRegistry;
import funkin.util.Constants;
import funkin.Paths;

using StringTools;

class BoyfriendFreeplayDJ extends AnimateAtlasFreeplayDJ
{
  public var cartoonSnd:FunkinSound = null;
  public var playingCartoon:Bool = false;

  final CARTOON_CHANNEL_FRAME:Int = 60;
  final CARTOON_LIST:Array<String> = Assets.list().filter((path) -> return path.startsWith("assets/sounds/cartoons/"));

  public function new(x:Float, y:Float, characterId:String)
  {
    super(x, y, characterId);
    this.cartoonSnd?.destroy();

    animation.onFrameChange.add((name, number) -> {
      if (name == playableCharData.getAnimationPrefix('cartoon'))
      {
        if (number == playableCharData.getCartoonSoundClickFrame()) FunkinSound.playOnce(Paths.sound('remote_click'));
        if (number == playableCharData.getCartoonSoundCartoonFrame()) runTvLogic();
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

      this.CARTOON_CHANNEL_FRAME = FlxG.random.bool(33) ? (playableCharData.getCartoonLoopBlinkFrame()) : (playableCharData.getCartoonLoopFrame());

      // Character switches channels when the video ends, or at a 10% chance each time his idle loops.
      if (FlxG.random.bool(10))
      {
        this.CARTOON_CHANNEL_FRAME = playableCharData.getCartoonChannelChangeFrame();
      }
      var animPrefix = playableCharData.getAnimationPrefix('cartoon');
      playFlashAnimation(animPrefix, true, false, false, this.CARTOON_CHANNEL_FRAME);
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

  public function runTvLogic():Void
  {
    if (this.cartoonSnd == null)
    {
      // tv is OFF, but getting turned on
      FunkinSound.playOnce(Paths.sound('tv_on'), 1.0, () -> {
        loadCartoon();
      });
    }
    else
    {
      // plays it smidge after the click
      FunkinSound.playOnce(Paths.sound('channel_switch'), 1.0, () -> {
        loadCartoon();
      });
    }
  }

  public function loadCartoon():Void
  {
    var cartoonSndPersist:FunkinSound = cartoonSnd;
    playingCartoon = true;

    // Krue... or Kralse...?
    if (cartoonSndPersist != null)
    {
      cartoonSndPersist.stop();
      cartoonSndPersist = null;
    }

    this.cartoonSnd = FunkinSound.load(Paths.sound(getRandomFlashToon()), 1.0, false, true, true, () -> {
      var animPrefix = playableCharData.getAnimationPrefix('cartoon');
      if (animPrefix != null) playFlashAnimation(animPrefix, true, false, false, 60);
    });

    // Fade out music to 40% volume over 1 second.
    // This helps make the TV a bit more audible.
    FlxG.sound.music.fadeOut(1.0, 0.1);

    // Play the cartoon at a random time between the start and 5 seconds from the end.
    if (this.cartoonSnd != null) this.cartoonSnd.time = FlxG.random.float(0, Math.max(this.cartoonSnd.length - (5 * Constants.MS_PER_SEC), 0.0));
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
