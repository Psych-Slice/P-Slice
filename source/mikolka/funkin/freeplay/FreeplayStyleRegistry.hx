package mikolka.funkin.freeplay;

class FreeplayStyleRegistry extends PsliceRegistry {
    public static var instance:FreeplayStyleRegistry = new FreeplayStyleRegistry();
    public function new() {
        super('freeplayStyles');
    }
}