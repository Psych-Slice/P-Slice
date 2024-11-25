package mikolka.vslice.freeplay.obj;

import mikolka.compatibility.FunkinPath;
import mikolka.compatibility.ModsHelper;
import mikolka.compatibility.FreeplayHelpers;
import flixel.FlxSprite;
import mikolka.funkin.FlxFilteredSprite;

/**
 * The icon that gets used for Freeplay capsules and char select
 * NOT to be confused with the CharIcon class, which is for the in-game icons
 */
class PixelatedIcon extends FlxFilteredSprite
{
	public var type:IconType;
  public function new(x:Float, y:Float)
  {
    super(x, y);
    this.makeGraphic(32, 32, 0x00000000);
    this.antialiasing = false;
    this.active = false;
  }

  public function setCharacter(char:String):Void
  {
    //? rewrote this to allow for cuistom character icons
    //60, 10
    //trace(char);
    if(char.startsWith("icon-")) char = char.replace("icon-","");
    type = IconType.LEGACY;
    if(FunkinPath.exists('images/freeplay/icons/${char}pixel.png')){
      if(FunkinPath.exists('images/freeplay/icons/${char}pixel.xml')) type = ANIMATED;
      else type = PIXEL;
    }
    switch (type){
      case LEGACY:
        // Legacy FNF icon (no freeplay one)
        var charPath:String = "icons/";
        charPath += "icon-";
        charPath += '${char}';
        
        
        var image = Paths.image(charPath);

        if (image == null) //TODO
        {
          trace('[WARN] Character ${char} has no freeplay icon.');
          image = Paths.image("icons/icon-face");
        }
        this.loadGraphic(image,true,Math.floor(image.width / 2), Math.floor(image.height));
        animation.add("idle",[0]);
        animation.add("confirm",[1]);
        this.scale.x = this.scale.y = 0.58;
        this.updateHitbox();
        this.origin.x = 100;
        //animation.play("idle");
      case PIXEL:
        // legacy P-Slice freeplay icons
        var image = Paths.image('freeplay/icons/${char}pixel');
        this.loadGraphic(image);
        this.scale.x = this.scale.y = 2;
        this.updateHitbox();
        animation.add("idle",[0]);
        animation.add("confirm",[0]);
        this.origin.x = 25;
        if(char == "parents") this.origin.x = 55;
      case ANIMATED:
        // NEW freeplay animated icon
        frames = FunkinPath.getSparrowAtlas('freeplay/icons/${char}pixel');
        this.active = true;
        this.scale.x = this.scale.y = 2;
        this.updateHitbox();
        this.animation.addByPrefix('idle', 'idle0', 10, true);
        this.animation.addByPrefix('confirm', 'confirm0', 10, false);
        this.animation.addByPrefix('confirm-hold', 'confirm-hold0', 10, true);

        this.animation.finishCallback = function(name:String):Void {
          trace('Finish pixel animation: ${name}');
          if (name == 'confirm') this.animation.play('confirm-hold');
        };
        this.origin.x = 25;
        if(char == "parents") this.origin.x = 55;
    }
      animation.play("idle");
    
  }
}
enum IconType {
  LEGACY;
  PIXEL;
  ANIMATED;
}
