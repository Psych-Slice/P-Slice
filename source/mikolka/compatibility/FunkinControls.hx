package mikolka.compatibility;

class FunkinControls {
    public static var FREEPLAY_LEFT(get,never):Bool;    
    public static function get_FREEPLAY_LEFT():Bool {
        return Controls.instance.BAR_LEFT;
    }
    public static var FREEPLAY_RIGHT(get,never):Bool;    
    public static function get_FREEPLAY_RIGHT():Bool {
        return Controls.instance.BAR_RIGHT;
    }
    public static var SCREENSHOT(get,never):Bool;    
    public static function get_SCREENSHOT():Bool {
        return Controls.instance.SCREENSHOT;
    }
    public static var FREEPLAY_CHAR(get,never):Bool;    
    public static function get_FREEPLAY_CHAR():Bool {
        return Controls.instance.CHAR_SELECT;
    }
    public static function enableVolume() {
        ClientPrefs.toggleVolumeKeys(true);
    }
    public static function disableVolume() {
        ClientPrefs.toggleVolumeKeys(false);
    }
}