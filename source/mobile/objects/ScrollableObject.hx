package mobile.objects;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxRect;
#if TOUCH_CONTROLS_ALLOWED
import flixel.util.FlxSignal;
import flixel.FlxObject;

class ScrollableObject extends FlxObject {
    public var onFullScroll(default,never):FlxTypedSignal<(delta:Int)->Void> = new FlxTypedSignal();
    public var onPartialScroll(default,never):FlxTypedSignal<(delta:Float) ->Void> = new FlxTypedSignal();
    public var onTap(default,never):FlxTypedSignal<(point:FlxTouch) ->Void> = new FlxTypedSignal();

    private var isDragging:Bool = false;
    private var isTapping:Bool = false;
    private var lastYPos:Float = 0;
    private var partialScrollTracker:Float = 0;
    private var scrollScale:Float = 0;

    public function new(scrollScale:Float,scrollZone:FlxRect) {
        this.scrollScale = scrollScale;
        super(scrollZone.x,scrollZone.y,scrollZone.width,scrollZone.height);
    }
    override function update(elapsed:Float) {
        super.update(elapsed);
        var curDelta = getDeltaY();
        
        if
            #if mobile
            (TouchUtil.justPressed && TouchUtil.overlapsComplex(this))
            #else 
            (FlxG.mouse.justPressed && FlxG.mouse.overlaps(this)) 
            #end
        {
            isDragging = false;
            isTapping = true;
        }
        else if( #if mobile TouchUtil.justReleased #else FlxG.mouse.justReleased #end) {
            if(isTapping){
                onTap.dispatch(getjustPressed());
                isTapping = false;
            }
            else if(isDragging) {
                onPartialScroll.dispatch(-partialScrollTracker);
                isDragging = false;
            }
            else return;
            
            partialScrollTracker = 0;
        }
        else if(( #if mobile TouchUtil.pressed || #end FlxG.mouse.pressed) && (Math.abs(curDelta)) > 3)
            {
                if(isTapping){
                    isDragging = true;
                    isTapping = false;
                }
                else if(!isDragging) return;
                // What we moved now
                var dragMove = curDelta*scrollScale;

                partialScrollTracker += dragMove;
                onPartialScroll.dispatch(dragMove);

                if((Math.abs(Math.round(partialScrollTracker))) >= 1){
                    // We have a full scroll
                    var fullScroll = Math.round(partialScrollTracker);
                    partialScrollTracker -= fullScroll;
                    onFullScroll.dispatch(fullScroll);
                }
            }
    }
    private function getjustPressed():FlxTouch
        {
            for (touch in FlxG.touches.list)
                if (touch.justPressed)
                    return touch;
    
            return null;
        }
    private function getDeltaY():Float {
        #if mobile
        if(FlxG.touches.getFirst() == null) return 0;
        var delta = FlxG.touches.getFirst().viewY - lastYPos;
        lastYPos = FlxG.touches.getFirst().viewY;
        return delta;
        #else
        return FlxG.mouse.deltaViewY;
        #end
    }
    
}
#end