package mikolka.vslice.charSelect;

import flixel.util.FlxColor;
import mikolka.funkin.FunkinSprite;
import mikolka.compatibility.funkin.FunkinPath as Paths; 

@:nullSafety
class Lock extends FunkinSprite
{
  var colors:Array<FlxColor> = [
    0xFF31F2A5, 0xFF20ECCD, 0xFF24D9E8,
    0xFF20ECCD, 0xFF20C8D4, 0xFF209BDD,
    0xFF209BDD, 0xFF2362C9, 0xFF243FB9
  ];

  public function new(x:Float = 0, y:Float = 0, index:Int, settings:AtlasSpriteSettings)
  {
    var tint:FlxColor = colors[index];

    super(x, y);

    loadTextureAtlas("charSelect/lock",
      {
        swfMode: settings.swfMode,
        uniqueInCache: settings.uniqueInCache,
        onSymbolCreate: (symbol) -> {
          if (symbol.timeline.getLayer("color") != null)
          {
            var colorSymbol:Null<animate.internal.elements.SymbolInstance> = symbol.timeline.getLayer("color")?.getFrameAtIndex(0)?.convertToSymbol(0,
              1) ?? null;

            if (colorSymbol != null)
            {
              colorSymbol.setColorTransform(0, 0, 0, 1, tint.red, tint.green, tint.blue, 0);
            }
          }
        }
      });

    anim.play("idle");
    offset.set(330, 120);
  }
}

