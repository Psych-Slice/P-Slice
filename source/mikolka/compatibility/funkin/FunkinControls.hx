package mikolka.compatibility.funkin;

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
    public static function FREEPLAY_CHAR_name():String {
        return InputFormatter.getKeyName(ClientPrefs.keyBinds.get("char_select")[0]);
    }
    public static function enableVolume(){
		FlxG.sound.muteKeys = InitState.muteKeys;
		FlxG.sound.volumeDownKeys = InitState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = InitState.volumeUpKeys;
    }
    public static function disableVolume(){
        FlxG.sound.muteKeys = [];
		FlxG.sound.volumeDownKeys = [];
		FlxG.sound.volumeUpKeys = [];
    }
}