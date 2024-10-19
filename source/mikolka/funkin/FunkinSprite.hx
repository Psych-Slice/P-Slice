package mikolka.funkin;

import mikolka.compatibility.VsliceOptions;

class FunkinSprite extends FlxSprite
{
	public static function create(x:Float = 0.0, y:Float = 0.0, key:String)
	{
		return new FunkinSprite(x, y, Paths.image(key));
	}

	public function makeSolidColor(width:Int, height:Int, color:FlxColor = FlxColor.WHITE):FunkinSprite
	{
		// Create a tiny solid color graphic and scale it up to the desired size.
		FunkinTools.makeSolidColor(this, width, height, FlxColor.WHITE);
		this.color = color;
		return this;
	}

	public static function createSparrow(x:Float = 0.0, y:Float = 0.0, key:String):FunkinSprite
	{
		var sprite:FunkinSprite = new FunkinSprite(x, y);
		sprite.antialiasing = VsliceOptions.ANTIALIASING;
		sprite.frames = Paths.getSparrowAtlas(key);
		return sprite;
	}
}
