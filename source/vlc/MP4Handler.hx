package vlc;

import hxcodec.flixel.FlxVideoSprite;

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
        bitmap.onEndReached.add(value);
        return value;
    }
}