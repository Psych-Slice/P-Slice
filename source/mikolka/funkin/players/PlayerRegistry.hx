package mikolka.funkin.players;

import haxe.Json;
import mikolka.funkin.players.PlayerData;
import mikolka.compatibility.FunkinPath;

using mikolka.funkin.custom.FunkinTools;
using StringTools;
//TODO softcode this soon
class PlayerRegistry extends PsliceRegistry{
    public static var instance:PlayerRegistry = new PlayerRegistry();
    public function new() {
        super('playableChars');
    }
    // Based on a character ID from a stage obtain it's playable character ID
    public function getCharacterOwnerId(charId:String) {
        var binds = new Map<String,String>();
        binds.set("pico-playable","pico");
        return binds.get(charId) ?? "bf";
    }
    public function isCharacterOwned(id:String):Bool {
        return true;
    }

    public function fetchEntry(playableCharId:String):PlayableCharacter {

        var player_blob:Dynamic = readJson(playableCharId);// new PlayerData();
        var player_data = new PlayerData().mergeWithJson(player_blob,["freeplayDJ"]);
        var dj = new PlayerFreeplayDJData().mergeWithJson(player_blob.freeplayDJ);
        player_data.freeplayDJ = dj;
        return new PlayableCharacter(player_data);
    }

    
    // return ALL characters avaliable (from current mod)
    public function listEntryIds():Array<String> {
        return listJsons();
    }
}