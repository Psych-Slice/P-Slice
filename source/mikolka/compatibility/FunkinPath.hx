package mikolka.compatibility;

class FunkinPath {
    public static function animateAtlas(path:String,lib:String = "preload") {
        return Paths.getSharedPath("images/"+path);
    }

    public static function sound(key:String):String {
        return Paths.getPath("sounds/"+Language.getFileTranslation(key) + '.ogg', SOUND, null, true);
    }

    public static function image(s:String) {
        return Paths.image(s);
    }
}