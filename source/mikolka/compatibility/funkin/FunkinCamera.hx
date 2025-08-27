package mikolka.compatibility.funkin;
import backend.PsychCamera;

class FunkinCamera extends PsychCamera {
    //removed name as its super now has this, just kinda made more sense, sorry
    public function new(name:String, X:Int = 0, Y:Int = 0, Width:Int = 0, Height:Int = 0, Zoom:Float = 1) {
        super(name, X, Y, Width, Height, Zoom);
    }
}
