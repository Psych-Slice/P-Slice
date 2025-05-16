package mikolka.editors.editorProps.sprites;

enum SpriteType {
    STATIC;
    SPARROW;
    ATLAS;
}
enum abstract FilterType(String) {
    var NONE = "both";
    var NAUGHTY = "naughty";
    var SAFE = "safe";
}
interface IResultsSprite  {
    function getSpriteType():SpriteType;
    function set_offset(x:Float,y:Float):Void;
    function startAnimation(activeFilter:FilterType):Void;
    function pauseAnimation():Void;
    function resumeAnimation():Void;
    function resetAnimation():Void;
}