package vlc;

import hxcodec.flixel.FlxVideoSprite;
import hxcodec.vlc.LibVLC;

class MP4Handler extends FlxVideoSprite {
    public function new() {
        super();
        bitmap.onTextureSetup.add(function()
        {
            setGraphicSize(FlxG.width);
            updateHitbox();
            screenCenter();
        });
    }
    var finishCallback(never,set):Void->Void;
    function set_finishCallback(value:Void->Void) {
        
        return value;
    }
}