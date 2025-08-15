package objects;

import mikolka.funkin.custom.mobile.MobileScaleMode;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.math.FlxRect;
import flixel.group.FlxGroup.FlxGroup;


class AlphabetMenu extends FlxGroup {
    public var onSelect(default,never):FlxTypedSignal<(option:String)->Void> = new FlxTypedSignal();
    public var grpTexts(default,never):FlxTypedGroup<Alphabet> = new FlxTypedGroup();

	public var curSelected:Int = 0;
	private var curSelectedPartial:Float = 0;
    private var options:Array<String>;

    public function new(options:Array<String>) {
        super();
        this.options = options;
        FlxG.watch.addQuick("curSelected", curSelected);
		FlxG.watch.addQuick("curSelectedPartial", curSelectedPartial);
		add(grpTexts);
		var cutoutSize = MobileScaleMode.gameCutoutSize.x / 2;

		for (i in 0...options.length)
		{
			var leText:Alphabet = new Alphabet(90+cutoutSize, 320, options[i], true);
			leText.isMenuItem = true;
			leText.targetY = i;
			grpTexts.add(leText);
			leText.snapToPosition();
			leText.screenCenter();
		}
        		
		#if TOUCH_CONTROLS_ALLOWED

		var button = new TouchZone(85,300,1000,100,FlxColor.PURPLE);
		
		var scroll = new ScrollableObject(-0.008,100,0,FlxG.width-200,FlxG.height,button);
		scroll.onPartialScroll.add(delta -> changeSelection(delta,false));
		// scroll.onFullScroll.add(delta -> {
		// 	FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		// });
        scroll.onFullScrollSnap.add(() ->changeSelection(0,true));
		scroll.onTap.add(() ->{
			onSelect.dispatch((options[curSelected]));
		});
		add(scroll);
		add(button);
		#end
        changeSelection(0,true);
		for (num => item in grpTexts.members) item.snapToPosition();
        
    }
    override function update(elapsed:Float)
        {
            if (Controls.instance.UI_UP_P)
            
                
                changeSelection(-1,true);
            
            if (Controls.instance.UI_DOWN_P)

                changeSelection(1,true);
            
            if (Controls.instance.ACCEPT) onSelect.dispatch((options[curSelected]));
            super.update(elapsed);
        }
    function changeSelection(delta:Float,usePrecision:Bool = false) {
		if(usePrecision) {
			if(delta != 0) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			curSelected =  FlxMath.wrap(curSelected + Std.int(delta), 0, options.length - 1);
			curSelectedPartial = curSelected;
		}
		else {
			curSelectedPartial = FlxMath.bound(curSelectedPartial + delta, 0, options.length - 1);
			if(curSelected != Math.round(curSelectedPartial)) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			curSelected = Math.round(curSelectedPartial);
		}
		for (num => item in grpTexts.members)
			{
				item.targetY = num - curSelectedPartial;
				item.alpha = 0.6;
				if (num == curSelected)
					item.alpha = 1;
			}
	}
}