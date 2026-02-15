package mikolka.stages.objects;

import mikolka.compatibility.funkin.FunkinPath;
#if !LEGACY_PSYCH
import cutscenes.CutsceneHandler;
#end

class PicoDopplegangerSprite extends FunkinSprite
{

  public var isPlayer:Bool = false;
  var suffix:String = '';

  public function new(x:Float, y:Float)
  {
    super(x, y, 'philly/erect/cutscenes/pico_doppleganger');
  }

  var cutsceneSounds:FunkinSound = null;

  public function cancelSounds(){
    if(cutsceneSounds != null) cutsceneSounds.destroy();
  }

  public function doAnim(_suffix:String, shoot:Bool = false, explode:Bool = false, cutsceneHandler:CutsceneHandler){
    suffix = _suffix;

    trace('Doppelganger: doAnim(' + suffix + ', ' + shoot + ', ' + explode + ')');

    if(shoot == true){
      anim.play("shoot" + suffix, true, false);
      anim.curAnim.looped = false;
      cutsceneHandler.timer(6.29, () -> {cutsceneSounds = FunkinSound.load(Paths.sound('cutscene/picoShoot'), 1.0, false, true, true);});
      cutsceneHandler.timer(10.33, () -> {cutsceneSounds = FunkinSound.load(Paths.sound('cutscene/picoSpin'), 1.0, false, true, true);});
    }else{
      if(explode == true){
        anim.play("explode" + suffix, true, false);
        anim.curAnim.looped = false;
        anim.onFinish.add(startLoop);

        cutsceneHandler.timer(3.7, () -> {cutsceneSounds = FunkinSound.load(Paths.sound('cutscene/picoCigarette2'), 1.0, false, true, true);});
        cutsceneHandler.timer(8.75, () -> {cutsceneSounds = FunkinSound.load(Paths.sound('cutscene/picoExplode'), 1.0, false, true, true);});
        cutsceneHandler.objects.remove(this);
      }else{
        anim.play("cigarette" + suffix, true, false);
        anim.curAnim.looped = false;
        cutsceneHandler.timer(3.7, () -> {cutsceneSounds = FunkinSound.load(Paths.sound('cutscene/picoCigarette'), 1.0, false, true, true);});
      }
    }
  }

  function startLoop(x:String){
    anim.play("loop" + suffix, true, false);
    anim.curAnim.looped = true;
  }
}