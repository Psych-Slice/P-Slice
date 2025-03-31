package mikolka.editors.editorProps;

import mikolka.editors.editorProps.sprites.IResultsSprite;
import mikolka.editors.editorProps.sprites.ResultsAtlasSprite;
import mikolka.editors.editorProps.sprites.ResultsStaticSprite;
import mikolka.editors.editorProps.sprites.ResultsSparrowSprite;
import haxe.Exception;
import flixel.util.FlxSort;
import mikolka.funkin.players.PlayerData.PlayerResultsAnimationData;

typedef ResultsProp = {
    var prop:IResultsSprite;
    var sprite:FlxSprite;
    var get_name:Void->String;
    var zIndex:Int;
    var data: PlayerResultsAnimationData;
}
class ResultsPropsGrp extends FlxTypedSpriteGroup<FlxSprite> {
    public var sprites:Array<ResultsProp> = new Array<ResultsProp>();

    public function addProp(data:PlayerResultsAnimationData) {
        var sprite:IResultsSprite = null;
        switch (data.renderType){
            case "sparrow": sprite = new ResultsSparrowSprite(data);
            case "animateatlas": sprite = new ResultsAtlasSprite(data);
            default: throw new Exception("Um.., the fuck were you trying to do?");
        }
        var prop_data = {
            sprite: cast sprite,
            prop: sprite,
            zIndex: data.zIndex,
            get_name: () ->{
                var parts = data.assetPath.split("/");
                return parts[parts.length - 1].split(".")[0];
            },
            data: data
        };
        sprites.push(prop_data);
        prop_data.sprite.zIndex = data.zIndex;
        add(prop_data.sprite);
        prop_data.prop.resetAnimation();
    }
    public function addStaticProp(sprite:FlxSprite,name:String,zIndex:Int) {
        sprites.push({
            sprite: sprite,
            prop: new ResultsStaticSprite(),
            get_name: () -> name,
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
    public function playAll() for (prop in sprites) prop.prop.startAnimation();
    public function pauseAll() for (prop in sprites) prop.prop.pauseAnimation();
    public function resumeAll() for (prop in sprites) prop.prop.resumeAnimation();
    public function resetAll() for (prop in sprites) prop.prop.resetAnimation();
    
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