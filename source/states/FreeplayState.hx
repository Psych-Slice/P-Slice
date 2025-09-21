package states;

import flixel.FlxState;

// https://gamebanana.com/posts/12920491
class FreeplayState extends FlxState {
    override function create() {
        FlxG.switchState(mikolka.vslice.freeplay.FreeplayState.build());
        super.create();
    }
}