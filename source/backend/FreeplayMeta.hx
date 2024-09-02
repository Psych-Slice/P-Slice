package backend;

typedef FreeplayMetaJSON = {
    songRating:Int,
    freeplayPrevStart:Float,
    freeplayPrevEnd:Float
}

class FreeplayMeta {
    public static function getMeta(songId:String):FreeplayMetaJSON {
        var meta_file = Paths.getTextFromFile('data/${Paths.formatToSongPath(songId)}/metadata.json');
        if(meta_file != null){
            var json_meta = getMetaFile(meta_file);
            json_meta.freeplayPrevStart = FlxMath.bound(json_meta.freeplayPrevStart,0,1);
            json_meta.freeplayPrevEnd = FlxMath.bound(json_meta.freeplayPrevEnd,0,1);
            return json_meta;
        }
        else {
            return {
                songRating: 0,
                freeplayPrevStart: 0.05,
                freeplayPrevEnd: 0.25
            };
        }
    }
    private static function getMetaFile(rawJson:String):FreeplayMetaJSON {

        try {
            if(rawJson != null && rawJson.length > 0) {
                return cast tjson.TJSON.parse(rawJson);
            }
        }
        catch(x){
            trace("Malfolded json? tf did you do to it?");
            trace(x.message);
        }
		
		return null;
	}
}