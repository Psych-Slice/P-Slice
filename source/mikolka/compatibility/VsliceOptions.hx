package mikolka.compatibility;

class VsliceOptions {
    public static var ALLOW_COLORING(get,never):Bool;    
    public static function get_ALLOW_COLORING():Bool {
        return ClientPrefs.vsliceFreeplayColors;
    }

    public static var ANTIALIASING(get,never):Bool;    
    public static function get_ANTIALIASING():Bool {
        return ClientPrefs.globalAntialiasing;
    }
}