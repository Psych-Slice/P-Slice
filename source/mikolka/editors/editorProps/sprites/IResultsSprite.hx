package mikolka.editors.editorProps.sprites;

enum SpriteType {
    STATIC;
    SPARROW;
    ATLAS;
}
interface IResultsSprite  {
    function getSpriteType():SpriteType;
    function startAnimation():Void;
    function pauseAnimation():Void;
    function resumeAnimation():Void;
    function resetAnimation():Void;
}