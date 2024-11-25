package mikolka;

import psychlua.LuaUtils;
import haxe.ds.StringMap;

class JoinedLuaVariables extends StringMap<Dynamic> {
    public function new() {
        super();
    }
    override function get(key:String):Null<Dynamic> {
        //! P-Slice patch
        var regex = ~/(.+)\[([0-9]+)\]/;
        if(regex.match(key)){
            var realKey = regex.matched(1);
            var index = Std.parseInt(regex.matched(2));
            var arrayValue = super.get(realKey);
            if(arrayValue == null) arrayValue = resolveUnknown(realKey);
            return arrayValue[index];
        }
        var arrayValue = super.get(key);
        if(arrayValue == null) arrayValue = resolveUnknown(key);
        return arrayValue;
    }
    private inline function resolveUnknown(key:String):Null<Dynamic> {
        return LuaUtils.getVarInArray(PlayState.instance, key, false);
    }
}