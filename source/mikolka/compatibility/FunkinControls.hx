package mikolka.compatibility;

class FunkinControls {
    public static var FREEPLAY_LEFT(get,never):Bool;    
    public static function get_FREEPLAY_LEFT():Bool {
        return PlayerSettings.player1.controls.BAR_LEFT;
    }
    public static var FREEPLAY_RIGHT(get,never):Bool;    
    public static function get_FREEPLAY_RIGHT():Bool {
        return PlayerSettings.player1.controls.BAR_RIGHT;
    }
    public static var SCREENSHOT(get,never):Bool;    
    public static function get_SCREENSHOT():Bool {
        return PlayerSettings.player1.controls.SCREENSHOT;
    }
    public static var FREEPLAY_CHAR(get,never):Bool;    
    public static function get_FREEPLAY_CHAR():Bool {
        return PlayerSettings.player1.controls.CHAR_SELECT;
    }
}