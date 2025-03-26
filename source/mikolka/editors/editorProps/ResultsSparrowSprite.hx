package mikolka.editors.editorProps;

import mikolka.compatibility.funkin.FunkinPath;
import mikolka.compatibility.VsliceOptions;
import mikolka.funkin.players.PlayerData.PlayerResultsAnimationData;

class ResultsSparrowSprite extends FlxSprite {
    public function new(animData:PlayerResultsAnimationData) {
        var offsets = animData.offsets ?? [0, 0];
        super(offsets[0], offsets[1]);
        antialiasing = VsliceOptions.ANTIALIASING;
		frames = Paths.getSparrowAtlas(FunkinPath.stripLibrary(animData.assetPath));
          animation.addByPrefix('idle', '', 24, false, false, false);

          if (animData.loopFrame != null)
          {
            animation.finishCallback = (_name:String) -> {
              if (animation != null)
              {
                animation.play('idle', true, false, animData.loopFrame ?? 0);
              }
            }
          }

          // Hide until ready to play.
          visible = false;
    }
}