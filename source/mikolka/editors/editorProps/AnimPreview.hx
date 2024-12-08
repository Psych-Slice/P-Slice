package mikolka.editors.editorProps;

import flxanimate.animate.FlxSymbol;

class AnimPreview extends FlxTypedSpriteGroup<FlxSprite>
{
	public var activeSprite:FlxAtlasSprite;

	var selectedFrame:Int = 0;
	var selectedAnimIndices:Array<Int>;
	var selectedAnimLength:Int = 0;

	public var selectedIndex:Int = 0;
	var labels:Array<FlxText> = new Array();
	var anims:Array<CharAnim> = new Array();
	var frameTxt:FlxText;

	public function attachSprite(value:FlxAtlasSprite)
	{
		anims = new Array();
		labels = new Array();
		selectedIndex = 0;
		forEach((s) ->
		{
			remove(s);
		});
        if(value == null){
            activeSprite?.onAnimationFrame.remove(onFrameAdvance);
            activeSprite = null;
            return;
        }

		frameTxt = new FlxText(350, -50, 0, "Frames: 0");
		frameTxt.setFormat(Paths.font("vcr.ttf"), 40, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
		add(frameTxt);

		
		registerAnims(value);
		value.onAnimationFrame.add(onFrameAdvance);
		activeSprite?.onAnimationFrame.remove(onFrameAdvance);
		activeSprite = value;
		input_selectAnim(0);
	}

	private function registerAnims(value:FlxAtlasSprite) {
		for (x in value.listAnimations())
			{
				addAnim({
					anim: x,
					readableName: x
				});
			}
	}
	public function input_selectAnim(diff:Int = 0)
	{
		var newIndex = (selectedIndex + diff) % labels.length;
		setAnimIndex(newIndex);
	}
	public function setAnimIndex(index:Int = 0)
		{
			if (labels.length > selectedIndex) labels[selectedIndex].color = 0xFFFFFFFF;
			selectedIndex = index;
			if (selectedIndex == -1)
				selectedIndex = labels.length - 1;
			labels[selectedIndex].color = 0xFF09C729;
	
			input_playAnim();
		}

	public function input_selectFrame(diff:Int = 0)
	{
		activeSprite.pauseAnimation();
        var newFrame = Std.int(FlxMath.bound(selectedFrame+diff,1,selectedAnimLength));
		activeSprite.anim.curFrame = selectedAnimIndices[newFrame-1];
        selectedFrame = newFrame;
        frameTxt.text = 'Frame (${selectedFrame}/${selectedAnimLength})';
	}

	public function input_playAnim()
	{
		var newAnim = anims[selectedIndex];
        selectedFrame = 0;
        selectedAnimLength = 0;
		activeSprite.playAnimation(newAnim.anim, true);
	}

	private function addAnim(anim:CharAnim)
	{
		var curIndex = anims.length;
		anims.push(anim);
		addLabel();
		labels[curIndex].text = anim.readableName;
	}

	private function addLabel()
	{
		var curIndex = labels.length;
		var flxTxt = new FlxText(0, curIndex * 20);
		flxTxt.setFormat(Paths.font("vcr.ttf"), 25, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
		labels.push(flxTxt);
		add(flxTxt);
	}

	private function onFrameAdvance(anim:String, frame:Int)
	{
		var mainSymbol = activeSprite.anim.curSymbol;
		var symbol = mainSymbol.getFrameLabel(anim);
        if(selectedAnimLength == 0) {
            selectedAnimIndices = symbol.getFrameIndices();
            selectedAnimLength = symbol.getFrameIndices().length; // timeline.totalFrames;
        }
		// var labelFrame = indices.indexOf(frame);
		// if (labelFrame == -1)
		// 	labelFrame = indices.length;
        selectedFrame +=1;
		frameTxt.text = 'Frame (${selectedFrame}/${selectedAnimLength})';
	}
}

typedef CharAnim =
{
	anim:String,
	readableName:String
}
