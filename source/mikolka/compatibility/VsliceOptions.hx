package mikolka.compatibility;

class VsliceOptions {
    public static var ALLOW_COLORING(get,never):Bool;    
    public static function get_ALLOW_COLORING():Bool {
        return ClientPrefs.data.vsliceFreeplayColors;
    }
    public static var FLASHBANG(get,never):Bool;    
    public static function get_FLASHBANG():Bool {
        return ClientPrefs.data.flashing;
    }
}