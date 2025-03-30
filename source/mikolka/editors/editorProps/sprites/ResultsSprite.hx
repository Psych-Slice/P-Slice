package mikolka.editors.editorProps.sprites;

enum SpriteType {
    STATIC;
    SPARROW;
    ATLAS;
}
interface ResultsSprite  {
    public function getSpriteType():SpriteType;
    public function startAnimation():Void;
    public function pauseAnimation():Void;
    public function resumeAnimation():Void;
    public function resetAnimation():Void;
}