package mikolka.stages.objects;

import mikolka.compatibility.FunkinPath;
#if !LEGACY_PSYCH
import cutscenes.CutsceneHandler;
#end

class PicoDopplegangerSprite extends FlxAtlasSprite
{

  public var isPlayer:Bool = false;
  var suffix:String = '';

  public function new(x:Float, y:Float)
  {
    super(x, y, 'assets/week3/images/philly/erect/cutscenes/pico_doppleganger', {
      FrameRate: 24.0,
      Reversed: false,
      // ?OnComplete:Void -> Void,
      ShowPivot: false,
      Antialiasing: true,
      ScrollFactor: new FlxPoint(1, 1),
    });
  }

  var cutsceneSounds:FunkinSound = null;

  public function cancelSounds(){
    if(cutsceneSounds != null) cutsceneSounds.destroy();
  }

  public function doAnim(_suffix:String, shoot:Bool = false, explode:Bool = false, cutsceneHandler:CutsceneHandler){
    suffix = _suffix;

    trace('Doppelganger: doAnim(' + suffix + ', ' + shoot + ', ' + explode + ')');

    cutsceneHandler.timer(0.3, () -> {cutsceneSounds = FunkinSound.load(Paths.sound('cutscene/picoGasp'), 1.0, false, true, true);});

    if(shoot == true){
      playAnimation("shoot" + suffix, true, false, false);

      cutsceneHandler.timer(6.29, () -> {cutsceneSounds = FunkinSound.load(Paths.sound('cutscene/picoShoot'), 1.0, false, true, true);});
      cutsceneHandler.timer(10.33, () -> {cutsceneSounds = FunkinSound.load(Paths.sound('cutscene/picoSpin'), 1.0, false, true, true);});
    }else{
      if(explode == true){
        playAnimation("explode" + suffix, true, false, false);

        onAnimationComplete.add(startLoop);

        cutsceneHandler.timer(3.7, () -> {cutsceneSounds = FunkinSound.load(Paths.sound('cutscene/picoCigarette2'), 1.0, false, true, true);});
        cutsceneHandler.timer(8.75, () -> {cutsceneSounds = FunkinSound.load(Paths.sound('cutscene/picoExplode'), 1.0, false, true, true);});
        cutsceneHandler.objects.remove(this);
      }else{
        playAnimation("cigarette" + suffix, true, false, false);

        cutsceneHandler.timer(3.7, () -> {cutsceneSounds = FunkinSound.load(Paths.sound('cutscene/picoCigarette'), 1.0, false, true, true);});
      }
    }
  }

  function startLoop(x:String){
    playAnimation("loop" + suffix, true, false, true);
  }
}