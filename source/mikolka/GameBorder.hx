package mikolka;

import openfl.display.Sprite;
import openfl.Lib;

class GameBorder extends Sprite {
    var fillScreen:Bool;

	/**
	 * @param fillScreen Whether to cut the excess side to fill the
	 * screen or always display everything.
	 */
	public function new(fillScreen:Bool = false)
	{
		super();
		this.fillScreen = fillScreen;
	}
	public function updateGameSize(Width:Int, Height:Int):Void
	{
		var ratio:Float = FlxG.width / FlxG.height;
		var realRatio:Float = Width / Height;
		//trace("REDRAWING!!!");
		var scaleY:Bool = realRatio < ratio;
		if (fillScreen)
		{
			scaleY = !scaleY;
		}

		if (scaleY)
		{
			var scale = Width/FlxG.width;
            if(!fillScreen){
				var fillHeight = (Height-(FlxG.height*scale))/2;
				graphics.clear();
				//graphics.beginFill(0xFF1158A0,0.5);
				graphics.beginFill(0xFF000000,1);
                graphics.drawRect(0,0,Width,fillHeight);
                graphics.drawRect(0,Height-fillHeight,Width,fillHeight);
				graphics.endFill();
            }
		}
		else
		{
			//gameSize.y = Height;
			//gameSize.x = Math.floor(gameSize.y * ratio);
			var scale = Height/FlxG.height;
			if(!fillScreen){
				var fillWight = (Width-(FlxG.width*scale))/2;
				graphics.clear();
				//graphics.beginFill(0xFF0EC00E,0.5);
				graphics.beginFill(0xFF000000,1);
                graphics.drawRect(0,0,fillWight,Height);
                graphics.drawRect(Width-fillWight,0,fillWight,Height);
				graphics.endFill();
            }
		}
	}
}