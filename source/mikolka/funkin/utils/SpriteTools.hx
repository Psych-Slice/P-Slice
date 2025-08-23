package mikolka.funkin.utils;

class SpriteTools {
    /**
     * Sets whethever or not this sprite is visible (and pauses animations)
     */
    public static function setVisibility(spr:FlxSprite,state:Bool) {
        spr.visible = state;
        spr.animation.paused = state;
    }
}