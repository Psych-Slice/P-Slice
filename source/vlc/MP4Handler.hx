package vlc;

import hxcodec.openfl.Video;
@:keep 
class MP4Handler extends Video {
    public function new() {
        super();
    }
    var finishCallback(never,set):Void->Void;
    function set_finishCallback(value:Void->Void) {
        onEndReached.add(value);
        return value;
    }
}