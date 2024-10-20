package mikolka.compatibility;
import backend.PsychCamera;

class FunkinCamera extends PsychCamera {
    var camName:String;
    public function new(name:String,X:Float = 0, Y:Float = 0, Width:Int = 0, Height:Int = 0, Zoom:Float = 0) {
        camName = name;
        super(X,Y,Width,Height,Zoom);
    }
}