package mikolka.vslice.freeplay;

import flixel.graphics.FlxGraphic;
import mikolka.compatibility.funkin.FunkinPath as Paths;

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
     public var widthOffset:Float = 0;
 
     public function new(diffId:String)
     {
         super();
 
         difficultyId = diffId;
         var tex:FlxGraphic = null;
         tex = Paths.noGpuImage('freeplay/freeplayDifficulties/freeplay' + diffId);

         if(tex == null){
             tex = Paths.noGpuImage('menudifficulties/' + diffId);
             if(tex != null) widthOffset = (tex.width/2) - 80; // story texture offset
         }
         else widthOffset = (tex.width/2) - 20; // standard offset

         if(tex == null){
            var grpFallbackDifficulty = new FlxText(70, 90, 250, difficultyId);
            grpFallbackDifficulty.setFormat("VCR OSD Mono", 60, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
            grpFallbackDifficulty.borderSize = 2;
            @:privateAccess
            grpFallbackDifficulty.regenGraphic();
            @:privateAccess
            tex = grpFallbackDifficulty.graphic;
            widthOffset = (tex.width/2) - 55; //text offset
         }
         
         this.loadGraphic(tex);
             
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