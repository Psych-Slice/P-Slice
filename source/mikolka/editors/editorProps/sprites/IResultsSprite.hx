package mikolka.editors.editorProps.sprites;

enum SpriteType {
    STATIC;
    SPARROW;
    ATLAS;
}

interface IResultsSprite  {
    function getSpriteType():SpriteType;
    function set_offset(x:Float,y:Float):Void;
    function startAnimation(activeFilter:String):Void;
    function pauseAnimation():Void;
    function resumeAnimation():Void;
    function resetAnimation(activeFilter:String):Void;
}