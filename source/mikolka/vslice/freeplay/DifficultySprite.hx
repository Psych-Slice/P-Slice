package mikolka.vslice.freeplay;

import flixel.graphics.FlxGraphic;

/**
 * The sprite for the difficulty
 */
 class DifficultySprite extends FlxSprite
 {
     /**
      * The difficulty id which this sprite represents.
      */
     public var difficultyId:String;
     public var hasValidTexture = true;
     public var difficultyColor:FlxColor;
 
     public function new(diffId:String)
     {
         super();
 
         difficultyId = diffId;
         var tex:FlxGraphic = null;
         if(["easy", "normal", "hard", "erect", "nightmare"].contains(difficultyId)){
             tex = Paths.image('freeplay/freeplay' + diffId,null,false);
         }
         else{
             tex = Paths.image('menudifficulties/' + diffId,null,false);
         }
         hasValidTexture = (tex != null);
         if(hasValidTexture) this.loadGraphic(tex);
         try{
             difficultyColor = hasValidTexture ? CoolUtil.dominantColor(this) : FlxColor.GRAY;
         }
         catch(x){
             trace('Failed to get prime color for $diffId: ${x.message}');
             difficultyColor = FlxColor.GRAY;
         }
         x = -((width/2)-106);
     }
 }