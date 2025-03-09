package mikolka.editors.editorProps;

import mikolka.funkin.players.PlayerData.PlayerResultsAnimationData;

typedef ResultsProp = {
    var sprite:FlxSprite;
    var zIndex:Int;
    var data: PlayerResultsAnimationData;
}
class ResultsPropsGrp extends FlxTypedSpriteGroup<FlxSprite> {
    public var sprites:Array<ResultsProp> = new Array<ResultsProp>();

    public function addProp(data:ResultsProp) {
        sprites.push(data);
        add(data.sprite);
    }
    public function removeProp(data:ResultsProp) {
        if (sprites.remove(data))  remove(data.sprite);
    }
    public function moveProp(data:ResultsProp,index:Int) {
        if (sprites.remove(data))  {
            remove(data.sprite);
            sprites.insert(index,data);
            insert(index,data.sprite);
        }
    }
}