package mikolka.editors.editorProps;

import mikolka.funkin.players.PlayerData;
import haxe.Json;

class CharJson
{
	public static function saveCharacter(player:PlayableCharacter):String
	{   
		return Json.stringify(player._data, replace, "\t");
	}
    private static function replace(key:Dynamic,value:Dynamic):Dynamic {
        trace(value);
        if(key == "freeplayDJ"){
            var obj = cast (value,PlayerFreeplayDJData);
            return new JsonDJ(obj);
        }
        return value;
    }
}
class JsonDJ{
    public function new(val:PlayerFreeplayDJData) {
        @:privateAccess{
            assetPath = val.assetPath;
            text1 = val.text1;
            text2 = val.text2;
            text3 = val.text3;
            animations = val.animations;
            charSelect = val.charSelect;
            cartoon = val.cartoon;
            fistPump = val.fistPump;
        }
    }
    var assetPath:String;
    var text1:String = "BOYFRIEND";
    var text2:String = "HOT BLOODED IN MORE WAYS THAN ONE";
    var text3:String = "PROTECT YO NUTS";
    var animations:Array<AnimationData>;
    var charSelect:Null<PlayerFreeplayDJCharSelectData>;
    var cartoon:Null<PlayerFreeplayDJCartoonData>;
    var fistPump:Null<PlayerFreeplayDJFistPumpData>;
}
