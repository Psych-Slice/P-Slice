package mikolka.funkin.players;
/**
 * I figured that since the way player select screen works might not be obvious at first I will explain it here
 * 
 * **charactersSeen** is supposed to be a list of characters that player ALREADY SAW
 * **PlayerRegistry.listEntryIds()** returns a list of all characters *available* to select by the player
 * 
 * Now, the game will try to play an unlock animation for every chararter **available**, bot **NOT seen** by the player yet.
 * Once thqt's done, the game will call "addCharacterSeen" to not repeat this anim in the future.
 */
class Save {
    public static var instance:Save = new Save();
	public var oldChar:Bool = true; //! Should we SKIP playing an intro cutscene (lights video)?
	public var charactersSeen(get, null):FakeCharArray;
    function get_charactersSeen() {
        return new FakeCharArray();
    }
    public function new() {
        
    }

    public function addCharacterSeen(char:Null<String>) {
        // Do nothing. We have no unlocking system yet
    }
}
class FakeCharArray{
    public function new() {
        
    }
    public function contains(value:String) {
        return true;
    }
}