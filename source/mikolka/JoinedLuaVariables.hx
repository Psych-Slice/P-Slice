package mikolka;

import psychlua.LuaUtils;
import haxe.ds.StringMap;

class JoinedLuaVariables extends StringMap<Dynamic> {
    public function new() {
        super();
    }
    //? JS does some inlining shit with this function
    #if !js
    override function get(key:String):Null<Dynamic> {
        //! P-Slice patch
        var arrayValue = super.get(key);
        if(arrayValue == null) arrayValue = LuaUtils.getVarInArray(PlayState.instance, key, false);
        return arrayValue;
    }
    #end
}
