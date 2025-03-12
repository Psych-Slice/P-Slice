package mikolka.editors;

class PsychUIUtills {
    public static function makeLabel(ref:FlxSprite, text:String){
        return new FlxText(ref.x, ref.y - 13, 100, text);
    }
    
    public static inline function removeIndex(box:PsychUIDropDownMenu,index:Int) {
        @:privateAccess
        box._items.remove(box._items[index]);
        
    }
    @:privateAccess
    public static inline function updateCurrentItem(box:PsychUIDropDownMenu,text:String) {
        box.list[box.selectedIndex] = text;
		@:privateAccess
		box._items[box.selectedIndex].label = text;
		box.text = text;
        
    }
    
}