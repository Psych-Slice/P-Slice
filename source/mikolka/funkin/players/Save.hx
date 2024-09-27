package mikolka.funkin.players;

class Save {
    public static var instance:Save = new Save();
	public var oldChar:Bool;
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