package mikolka.editors.editorProps;

import haxe.Exception;
import flixel.util.FlxSort;
import mikolka.funkin.players.PlayerData.PlayerResultsAnimationData;

typedef ResultsProp = {
    var sprite:FlxSprite;
    var zIndex:Int;
    var data: PlayerResultsAnimationData;
}
class ResultsPropsGrp extends FlxTypedSpriteGroup<FlxSprite> {
    public var sprites:Array<ResultsProp> = new Array<ResultsProp>();

    public function addProp(data:PlayerResultsAnimationData) {
        var sprite:FlxSprite = null;
        switch (data.renderType){
            case "sparrow": sprite = new ResultsSparrowSprite(data);
            case "animateatlas": sprite = new ResultsAtlasSprite(data);
            default: throw new Exception("Um.., the fuck were you trying to do?");
        }
        sprites.push({
            sprite: sprite,
            zIndex: data.zIndex,
            data: data
        });
        sprite.zIndex = data.zIndex;
        add(sprite);
    }
    public function addStaticProp(sprite:FlxSprite,zIndex:Int) {
        sprites.push({
            sprite: sprite,
            zIndex: zIndex,
            data: null
        });
        sprite.zIndex = zIndex;
        add(sprite);
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
    /**
        Internally removed props for the selected result 
    **/
    public function clearProps() {
        for( x in sprites.copy()){
            if(x.data != null) {
                sprites.remove(x);
                remove(x.sprite);
            }
        }
    }
    public function refresh() {
        clear();
        sprites.sort((a,b) -> FlxSort.byValues(FlxSort.ASCENDING,a.zIndex,b.zIndex));
        for (sprite in sprites){
            add(sprite.sprite);
        } 
    }
}