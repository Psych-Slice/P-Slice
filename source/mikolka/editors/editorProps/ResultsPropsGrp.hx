package mikolka.editors.editorProps;

import mikolka.compatibility.funkin.FunkinPath;
import mikolka.editors.editorProps.sprites.IResultsSprite;
import mikolka.editors.editorProps.sprites.ResultsAtlasSprite;
import mikolka.editors.editorProps.sprites.ResultsStaticSprite;
import mikolka.editors.editorProps.sprites.ResultsSparrowSprite;
import haxe.Exception;
import flixel.util.FlxSort;
import mikolka.funkin.players.PlayerData.PlayerResultsAnimationData;
import mikolka.vslice.components.crash.UserErrorSubstate;

typedef ResultsProp = {
    var prop:IResultsSprite;
    var sprite:FlxSprite;
    var get_name:Void->String;
    var zIndex:Int;
    var data: PlayerResultsAnimationData;
}
class ResultsPropsGrp extends FlxTypedSpriteGroup<FlxSprite> {
    public var sprites:Array<ResultsProp> = new Array<ResultsProp>();

    public function addProp(data:PlayerResultsAnimationData,showErrors:Bool = false):Bool { // returns trye if succsessful
        var sprite = makeSprite(data,showErrors);
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
        if(sprite != null){
            prop_data.sprite.zIndex = data.zIndex;
            add(prop_data.sprite);
            prop_data.prop.resetAnimation("");
            return true;
        }
        return false;
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
        if (sprites.remove(data) && data.sprite != null)  remove(data.sprite);
    }
    public function reloadProp(data:ResultsProp) {
        if (!sprites.contains(data)) return;
        if(data.sprite != null) remove(data.sprite);
        var sprite = makeSprite(data.data,true);
        data.sprite = cast sprite;
        data.prop = sprite;
        refresh();
    }
    public function moveProp(data:ResultsProp,index:Int) {
        if (sprites.remove(data))  {
            if(data.sprite != null) remove(data.sprite);
            sprites.insert(index,data);
            if(data.sprite != null) insert(index,data.sprite);
            if(index == 0) data.zIndex = 0;
            else data.zIndex = sprites[index-1].zIndex+1;
        }
    }
    public function playAll(activeFilter:String) for (prop in sprites) prop.prop?.startAnimation(activeFilter);
    public function pauseAll() for (prop in sprites) prop.prop?.pauseAnimation();
    public function resumeAll() for (prop in sprites) prop.prop?.resumeAnimation();
    public function resetAll(activeFilter:String) for (prop in sprites) prop.prop?.resetAnimation(activeFilter);
    
    /**
        Internally removed props for the selected result 
    **/
    public function clearProps() {
        for( x in sprites.copy()){
            if(x.data != null) {
                sprites.remove(x);
                if(x.sprite != null) remove(x.sprite);
            }
        }
    }
    public function refresh() {
        clear();
        sprites.sort((a,b) -> FlxSort.byValues(FlxSort.ASCENDING,a.zIndex,b.zIndex));
        for (sprite in sprites){
            if(sprite.sprite != null) add(sprite.sprite);
        } 
    }
    private function makeSprite(data:PlayerResultsAnimationData,showErrors:Bool = false):IResultsSprite {
        switch (data.renderType){
            case "sparrow": {
                if(Paths.fileExists("images/"+FunkinPath.stripLibrary(data.assetPath)+".xml",TEXT)){
                    return new ResultsSparrowSprite(data);
                }
                else{
                    if(showErrors)
                        UserErrorSubstate.makeMessage("Failed to load Sparrow",'${FunkinPath.stripLibrary(data.assetPath)}/n/nIs not a valid Sparrow sprite');
                }
            }
            case "animateatlas": {
                if(Paths.fileExists("images/"+FunkinPath.stripLibrary(data.assetPath)+"/Animation.json",TEXT)){
                    return new ResultsAtlasSprite(data);
                }
                else{
                    if(showErrors)
                        UserErrorSubstate.makeMessage("Failed to load Atlas",'${FunkinPath.stripLibrary(data.assetPath)}/n/nIs not a valid Atlas');
                }
            }
            default: throw new Exception("Um.., the fuck were you trying to do?");
        }
        return null;
    }
}