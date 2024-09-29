package mikolka.vslice.charSelect;

import flixel.FlxSprite;
import mikolka.funkin.FlxAtlasSprite;
import flxanimate.animate.FlxKeyFrame;
import mikolka.compatibility.FunkinPath as Paths;
class CharSelectPlayer extends FlxAtlasSprite 
{
  public function new(x:Float, y:Float)
  {
    super(x, y, Paths.animateAtlas("charSelect/bfChill"));

    onAnimationComplete.add(function(animLabel:String) { //? changed the hook here
      switch (animLabel)
      {
        case "slidein":
          if (hasAnimation("slidein idle point"))
          {
            playAnimation("slidein idle point", true, false, false);
          }
          else
          {
            playAnimation("idle", true, false, false);
          }
        case "deselect":
          playAnimation("deselect loop start", true, false, true);

        case "slidein idle point", "cannot select Label", "unlock":
          playAnimation("idle", true, false, false);
        case "idle":
          trace('Waiting for onBeatHit');
      }
    });
  }

  public function onBeatHit():Void
  {
    // TODO: There's a minor visual bug where there's a little stutter.
    // This happens because the animation is getting restarted while it's already playing.
    // I tried make this not interrupt an existing idle,
    // but isAnimationFinished() and isLoopComplete() both don't work! What the hell?
    // danceEvery isn't necessary if that gets fixed.
    //
    if (getCurrentAnimation() == "idle")
    {
      //trace('Player beat hit');
      playAnimation("idle", true, false, false);
    }
  };

  public function updatePosition(str:String)
  {
    switch (str)
    {
      case "bf":
        x = 0;
        y = 0;
      case "pico":
        x = 0;
        y = 0;
      case "random":
    }
  }

  public function switchChar(str:String)
  {
    switch str
    {
      default:
        loadAtlas(Paths.animateAtlas("charSelect/" + str + "Chill"));
    }

    playAnimation("slidein", true, false, false);

    updateHitbox();

    updatePosition(str);
  }

}
