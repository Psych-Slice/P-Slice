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
    public static var FLASHBANG(get,never):Bool;    
    public static function get_FLASHBANG():Bool {
        return ClientPrefs.flashing;
    }
    public static var LOW_QUALITY(get,never):Bool;    
    public static function get_LOW_QUALITY():Bool {
        return ClientPrefs.lowQuality;
    }
    public static var CAM_ZOOMING(get,never):Bool;    
    public static function get_CAM_ZOOMING():Bool {
        return ClientPrefs.camZooms;
    }
    public static var FP_CARDS(get,never):Bool;    
    public static function get_FP_CARDS():Bool {
        return ClientPrefs.vsliceSpecialCards;
    }
    public static var SHADERS(get,never):Bool;    
    public static function get_SHADERS():Bool {
        return ClientPrefs.shaders;
    }
    public static var LAST_MOD(get,set):CharSave; //format: "mod_dir||char_name"
    public static function get_LAST_MOD():CharSave {
        var shards = ClientPrefs.lastFreeplayMod.split('||');
        if(shards.length != 2) return {mod_dir: "", char_name: "bf"};
        else return {mod_dir: shards[0],char_name: shards[1]};
    }
    public static function set_LAST_MOD(value:CharSave) {
        ClientPrefs.lastFreeplayMod = '${value.mod_dir}||${value.char_name}';
        ClientPrefs.saveSettings();
        return value;
    }
}