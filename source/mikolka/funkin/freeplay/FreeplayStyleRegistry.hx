package mikolka.funkin.freeplay;

class FreeplayStyleRegistry extends PsliceRegistry {
    public static var instance:FreeplayStyleRegistry = new FreeplayStyleRegistry();
    public function new() {
        super('ui/freeplay/styles');
    }

    public function fetchEntry(characterId:String):Null<FreeplayStyle> {
        var data = readJson(characterId);
        var freeplay_data:FreeplayStyleData = data;
        if(data == null) return null;
        return new FreeplayStyle(characterId,freeplay_data);
    }
}