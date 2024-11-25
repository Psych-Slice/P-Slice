package mikolka.editors.editorProps;

import mikolka.vslice.charSelect.Lock;
import mikolka.vslice.freeplay.obj.PixelatedIcon;

class CharIconGrid extends FlxTypedSpriteGroup<FlxSprite>{
	var charIcon:PixelatedIcon;

    var prevIndex:Int = 0;
    var grpXSpread:Float = 107;
	var grpYSpread:Float = 127;

    public function initLocks(index:Int,playerId:String):Void
        {
            clear();
    
            charIcon = new PixelatedIcon(0, 0);
            charIcon.setCharacter(playerId); //.56
            charIcon.setGraphicSize(128, 128);
            charIcon.updateHitbox();
            charIcon.ID = 0;
    
            for (i in 0...9)
            {
                var temp:Lock = new Lock(0, 0, i);
                temp.ID = 1;
                add(temp);
            }
            add(charIcon);
    
            x = 450;
            y = 120;
            for (index => member in members)
            {
                updateIconPosition(member, index);
            }
            updateCharHead(index);
            scrollFactor.set();
        }
    
        public function updateCharHead(index:Int) {
            group.members[prevIndex].visible = true;
            updateIconPosition(charIcon, index);
            group.members[index].visible = false;
            prevIndex = index;
    
        }
        public function updateCharId(playerId:String) {
            charIcon.setCharacter(playerId);
            charIcon.scale.add(0.5,0.5);
            charIcon.updateHitbox();
        }
        function updateIconPosition(member:FlxSprite, index:Int)
        {
            var posX:Float = (index % 3);
            var posY:Float = Math.floor(index / 3);
    
            member.x = posX * grpXSpread;
            member.y = posY * grpYSpread;
    
            member.x += x;
            member.y += y;
        }
    
}