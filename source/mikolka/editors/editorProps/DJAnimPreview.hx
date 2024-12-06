package mikolka.editors.editorProps;

class DJAnimPreview extends AnimPreview {
    public var dj:PlayableCharacter;
    public var offsets:Array<Array<Float>>;
    public var curAnimName(get,set):String;
    public var curOffset(get,null):Array<Float>;
    public var curAnimPrefix(get,set):String;

    override function attachSprite(value:FlxAtlasSprite) {
        super.attachSprite(value);
        frameTxt.x = 0;
        frameTxt.y = 8;
        frameTxt.alignment = LEFT;
        frameTxt.font = 'VCR OSD Mono';
        frameTxt.size = 48;
    }
    // Adds anims + offsets
    override function registerAnims(value:FlxAtlasSprite) {
        offsets = new Array<Array<Float>>();
        value.offset.set(0,0);
        @:privateAccess
        for (x in dj.getFreeplayDJData().animations)
			{
                // I prefer my numbers clean -Mikolka
                x.offsets[0] = Math.round(x.offsets[0]); 
                x.offsets[1] = Math.round(x.offsets[1]);
                offsets.push(x.offsets);
				addAnim({
					anim: x.prefix,
					readableName: x.name
				});
			}
    }


    override function onFrameAdvance(anim:String, frame:Int)
        {
            if(selectedAnimLength == 0) {
                selectedAnimLength = activeSprite.anim.length; // timeline.totalFrames;
            }
            selectedFrame +=1;
            updateFramesText();
        }
     override function input_selectFrame(diff:Int = 0)
        {
            activeSprite.pauseAnimation();
            var newFrame = Std.int(FlxMath.bound(selectedFrame+diff,1,selectedAnimLength));
            //activeSprite.anim.curFrame = selectedAnimIndices[newFrame-1];
            activeSprite.anim.curFrame = newFrame-1;
            selectedFrame = newFrame;

            updateFramesText();
        }

    // Changes offset based on a DIFFERENCE
    public function input_changeOffset(xDiff:Float,yDiff:Float) {
        setOffset(curOffset[0]+xDiff,curOffset[1]+yDiff);
    }
    
    override function input_playAnim() {
        if(!activeSprite.hasAnimation(anims[selectedIndex].anim)){
            labels[selectedIndex].color = 0xFFD42727;
            return;
        }
        labels[selectedIndex].color = 0xFF09C729;
        super.input_playAnim();
        activeSprite.offset.set(curOffset[0],curOffset[1]);
        selectedFrame = 1;
    }
    function updateFramesText() {
        frameTxt.text = 'Frame (${selectedFrame}/${selectedAnimLength}) [${curOffset[0]},${curOffset[1]}]';
    }

    //ANIMS EDITOR
    
    public function set_curAnimPrefix(cur:String):String {
        anims[selectedIndex].anim = cur;
        input_playAnim();
        return cur;
    }
    public inline function get_curAnimPrefix():String {
        return anims[selectedIndex].anim;
    }
    public function set_curAnimName(name:String):String {
        anims[selectedIndex].readableName = name;
        labels[selectedIndex].text = name;
        return name;
    }
    public inline function get_curAnimName():String {
        return anims[selectedIndex].readableName;
    }
    public inline function get_curOffset() {
        return offsets[selectedIndex];
    }
    // Sets NEW offset for the current animation
    public function setOffset(x:Float,y:Float) {
        offsets[selectedIndex] = [x,y];
        activeSprite.offset.set(x,y);
        updateFramesText();
    }
    public function getAnimTitlesForSelector():Array<String>{
        var names = [];
        for (x in anims){
            names.push(x.readableName);
        }
        return names;
    }

    public function saveAnimations() {
        @:privateAccess
        var charAnims = dj.getFreeplayDJData().animations;
        charAnims.resize(0);
        for(i in 0...anims.length){
            charAnims.push({
                name: anims[i].readableName,
                prefix: anims[i].anim,
                offsets: offsets[i]
            });
        }
    }
}