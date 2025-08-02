package mobile.objects;

import flixel.math.FlxRect;

class TouchZone extends #if debug flixel.FlxSprite #else flixel.FlxObject #end {
    public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0,color:FlxColor = FlxColor.GREEN){
        #if debug  
        super(x,y);
		FunkinTools.makeSolidColor(this,Std.int(width),Std.int(height),color);
		alpha = 0.2;
        #else
            super(x,y,width,height);
        #end
    }
}