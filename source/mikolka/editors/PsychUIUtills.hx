package mikolka.editors;

class PsychUIUtills {
    public static function makeLabel(ref:FlxSprite, text:String){
        return new FlxText(ref.x, ref.y - 13, 100, text);
    }
    
    public static inline function removeIndex(box:PsychUIDropDownMenu,index:Int) {
        @:privateAccess
        box._items.remove(box._items[index]);
        box.list.remove(box.list[index]);
        
    }
    @:privateAccess
    public static inline function updateCurrentItem(box:PsychUIDropDownMenu,text:String) {
        box.list[box.selectedIndex] = text;
		@:privateAccess
		box._items[box.selectedIndex].label = text;
		box.text = text;
        
    }
    public static function moveCurrentItem(box:PsychUIDropDownMenu,diff:Int) {
        
        var curIndex = box.selectedIndex;
        
		swap(box.list,curIndex,curIndex+diff);
        @:privateAccess{
            swap(box._items,curIndex,curIndex+diff);
            box._items[curIndex].onClick = function() box.clickedOn(curIndex,box._items[curIndex].label);
            box._items[curIndex+diff].onClick = function() box.clickedOn(curIndex+diff,box._items[curIndex+diff].label);
        }
    }
    private static function swap<T>(list:Array<T>,oldIndex:Int,newIndex:Int) {
        var carry = list[newIndex];
        list[newIndex] = list[oldIndex];
        list[oldIndex] = carry;
    }
    
}