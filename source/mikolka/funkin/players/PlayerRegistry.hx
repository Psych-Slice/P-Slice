package mikolka.funkin.players;

import mikolka.compatibility.ModsHelper;
import haxe.Json;
import mikolka.funkin.players.PlayerData;
import mikolka.compatibility.funkin.FunkinPath;





//TODO softcode this soon
class PlayerRegistry extends PsliceRegistry{
    public static var instance:PlayerRegistry = new PlayerRegistry();
    public function new() {
        super('players');
    }

    public function isCharacterOwned(id:String):Bool {
        return true;
    }
    public function hasNewCharacter():Bool {
        return false;
    }
    public function fetchEntry(playableCharId:String):Null<PlayableCharacter> {
        try {
            var player_blob:Dynamic = readJson(playableCharId);// new PlayerData();
            if(player_blob == null) return null;
            var player_data = new PlayerData().mergeWithJson(player_blob,["freeplayDJ"]);
            var dj = new PlayerFreeplayDJData().mergeWithJson(player_blob.freeplayDJ);
            player_data.freeplayDJ = dj;
            return new PlayableCharacter(player_data);
        }
        catch(x){
            trace('Couldn\'t pull $playableCharId: ${x.message}');
            return null;
        }
        
    }
    
    // return ALL characters avaliable (from current mod)
    public function listEntryIds():Array<String> {
        if(ModsHelper.getActiveMod() == ""){
            var allJsons:Array<String> = [];
            var registry_mods = ModsHelper.getModsWithPlayersRegistry();
            var globalMods = ModsHelper.getGlobalMods().filter(s -> registry_mods.contains(s));
            for(mod in globalMods){
                ModsHelper.loadModDir(mod);
                allJsons.pushMany(listJsons());
            }
            ModsHelper.loadModDir("");
            #if LEGACY_PSYCH
            var basedCharFiles = NativeFileSystem.readDirectory("assets/registry/players");
            #else
            var basedCharFiles = NativeFileSystem.readDirectory("assets/shared/registry/players");
            #end
            allJsons.pushMany(basedCharFiles
                .filter(s -> s.endsWith(".json")).map(s -> s.substr(0,s.length-5)));
            return allJsons;
        }
        else return listJsons();
    }
    // This is only used to check if we should allow the player to open charSelect
    public function countUnlockedCharacters():Int {
        return 2;
    }
}