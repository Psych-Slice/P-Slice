package mikolka.editors.editorProps;

import mikolka.funkin.freeplay.FreeplayStyle;
import mikolka.funkin.freeplay.FreeplayStyleRegistry;
import shaders.AngleMask;
import mikolka.vslice.freeplay.backcards.BoyfriendCard;

class FreeplayEditSubstate extends MusicBeatSubstate {
    
    var data:PlayableCharacter;
	var style:Null<FreeplayStyle>;
    var animsList:Array<AnimationData>;
    var loaded:Bool = false;
    
    var dj:FlxAtlasSprite;
    var dj_anim:DJAnimPreview;
	var backingCard:BoyfriendCard;
    var angleMaskShader:AngleMask = new AngleMask();
	var bgDad:FlxSprite;
    

    var UI_box:PsychUIBox;
    //GENERAL
	var input_assetPath:PsychUIInputText;
	var btn_reload:PsychUIButton;
	var steper_charSelectDelay:PsychUINumericStepper;
	var input_text1:PsychUIInputText;
	var input_text2:PsychUIInputText;
	var input_text3:PsychUIInputText;
    //DJ EDITOR
	var steper_introStartFrame:PsychUINumericStepper;
	var steper_introEndFrame:PsychUINumericStepper;
	var steper_loopStartFrame:PsychUINumericStepper;
	var steper_loopEndFrame:PsychUINumericStepper;
	var steper_introBadStartFrame:PsychUINumericStepper;
	var steper_loopBadEndFrame:PsychUINumericStepper;
	var steper_loopBadStartFrame:PsychUINumericStepper;
	var steper_introBadEndFrame:PsychUINumericStepper;
    //ANIMATION
	var list_animations:PsychUIDropDownMenu;
	var input_animName:PsychUIInputText;
	var input_animPrefix:PsychUIInputText;
	var btn_newAnim:PsychUIButton;
	var btn_trashAnim:PsychUIButton;
	var stepper_offset_x:PsychUINumericStepper;
	var stepper_offset_y:PsychUINumericStepper;

    public function new(player:PlayableCharacter) {
        super();
        data = player;
        style = FreeplayStyleRegistry.instance.fetchEntry(data.getFreeplayStyleID());
        if(style == null) style = FreeplayStyleRegistry.instance.fetchEntry("bf");
    }
    override function create() {
        backingCard = new BoyfriendCard(data);
        backingCard.init();
        add(backingCard);

        var blackOverlayBullshitLOLXD:FlxSprite = new FlxSprite(FlxG.width, 0, Paths.image("back"));
		blackOverlayBullshitLOLXD.alpha = 1; // ? graphic because shareds are shit
		add(blackOverlayBullshitLOLXD); // used to mask the text lol!

        bgDad = new FlxSprite(backingCard.pinkBack.width * 0.74, 0);
        setDadBG();
        bgDad.shader = angleMaskShader;
		bgDad.visible = false;
        add(bgDad);

		// this makes the texture sizes consistent, for the angle shader
		bgDad.setGraphicSize(0, FlxG.height);
		blackOverlayBullshitLOLXD.setGraphicSize(0, FlxG.height);

		bgDad.updateHitbox();
		blackOverlayBullshitLOLXD.updateHitbox();
        FlxTween.tween(blackOverlayBullshitLOLXD,{x:350},0.75,{
            ease: FlxEase.quintOut
        });
        FlxTimer.wait(0.8,onLoadAnimDone);

        

        dj = new FlxAtlasSprite(640, 366 -300,data.getFreeplayDJData().getAtlasPath());
        add(dj);
        dj.playAnimation(data.getFreeplayDJData().getAnimationPrefix("idle"));
        dj_anim = new DJAnimPreview(100,100);
        dj_anim.dj = data;
        dj_anim.attachSprite(dj);
        add(dj_anim);
        
        @:privateAccess
        animsList = data.getFreeplayDJData().animations;
        //anims = new AnimPreview(200,200);
        //anims.attachSprite(dj);
        addEditorBox();
        super.create();
    }
    function onLoadAnimDone() {
        add(UI_box);
        loaded = true;
        bgDad.visible = true;
        backingCard.introDone();
    }
    override function update(elapsed:Float) {
        super.update(elapsed);
        if(!loaded) return;
        if(PsychUIInputText.focusOn == null)
            {
                ClientPrefs.toggleVolumeKeys(true);
                var b_tapped = false;
                
                #if TOUCH_CONTROLS_ALLOWED
                b_tapped = touchPad.buttonB.justPressed;
                #end

                if((controls.BACK || b_tapped) && loaded){
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    close();
                }
            }
        else ClientPrefs.toggleVolumeKeys(false);
		
		if(dj_anim.activeSprite != null){
			if(controls.UI_DOWN_P) dj_anim.selectAnim(1);
			if(controls.UI_UP_P) dj_anim.selectAnim(-1);
			if(FlxG.keys.justPressed.SPACE) dj_anim.playAnim();
			if(controls.UI_LEFT_P) dj_anim.selectFrame(-1);
			if(controls.UI_RIGHT_P) dj_anim.selectFrame(1);
			
		}
    }
    function addEditorBox()
    {
            UI_box = new PsychUIBox(FlxG.width, FlxG.height, 300, 250, ['General',"DJ Editor", "Animation", 'Style']);
            UI_box.x -= UI_box.width;
            UI_box.y -= UI_box.height;
            UI_box.scrollFactor.set();
    
            // GENERAL
            @:privateAccess
            input_assetPath = new PsychUIInputText(10, 20, 150, data._data.freeplayDJ.assetPath);
    
            btn_reload = new PsychUIButton(180, 20, "Reload", () ->
            {
                remove(dj);
                dj.destroy();
                dj = new FlxAtlasSprite(640, 366,data.getFreeplayDJData().getAtlasPath());
            });
            @:privateAccess
            steper_charSelectDelay = new PsychUINumericStepper(20, 60, 0.05, data._data.freeplayDJ.charSelect.transitionDelay,0,10,0,100);
            
            @:privateAccess{
                input_text1 = new PsychUIInputText(10,50,150,data._data.freeplayDJ.text1);
                input_text2 = new PsychUIInputText(10,70,150,data._data.freeplayDJ.text2);
                input_text3 = new PsychUIInputText(10,90,150,data._data.freeplayDJ.text3);
            }
            //DJ EDITOR
            var dj_editor_desc_txt = new FlxText(10,10,400,"Pick frames (start,end)");
            dj_editor_desc_txt.setFormat(Paths.font("vcr.ttf"),20,FlxColor.WHITE,LEFT,OUTLINE_FAST,FlxColor.BLACK);
            
            var txt_introStart = new FlxText(10,50,0,"Victory intro:",10);
            steper_introStartFrame = new PsychUINumericStepper(100,50,1,data.getFreeplayDJData().getFistPumpIntroStartFrame(),0,100);
            steper_introEndFrame = new PsychUINumericStepper(170,50,1,data.getFreeplayDJData().getFistPumpIntroEndFrame(),-1,100);

            var txt_introLoop = new FlxText(10,90,0,"Victory loop:",10);
            steper_loopStartFrame = new PsychUINumericStepper(100,90,1,data.getFreeplayDJData().getFistPumpLoopStartFrame(),0,100);
            steper_loopEndFrame = new PsychUINumericStepper(170,90,1,data.getFreeplayDJData().getFistPumpLoopEndFrame(),-1,100);

            var txt_introBadStart = new FlxText(10,130,0,"Loss intro:",10);
            steper_introBadStartFrame = new PsychUINumericStepper(100,130,1,data.getFreeplayDJData().getFistPumpIntroBadStartFrame(),0,100);
            steper_introBadEndFrame = new PsychUINumericStepper(170,130,1,data.getFreeplayDJData().getFistPumpIntroBadEndFrame(),-1,100);

            var txt_introBadLoop = new FlxText(10,170,0,"Loss loop:",10);
            steper_loopBadStartFrame = new PsychUINumericStepper(100,170,1,data.getFreeplayDJData().getFistPumpLoopBadStartFrame(),0,100);
            steper_loopBadEndFrame = new PsychUINumericStepper(170,170,1,data.getFreeplayDJData().getFistPumpLoopBadEndFrame(),-1,100);
            //Animation
            list_animations = new PsychUIDropDownMenu(10,10,["lol"],(index,name) ->{
                trace(name);
            });
            btn_newAnim = new PsychUIButton(140,10,"New",() -> {

            },50);
            btn_trashAnim = new PsychUIButton(200,10,"Delete",() -> {

            },50);
            input_animName = new PsychUIInputText(10,50,150,"Name");
            input_animPrefix = new PsychUIInputText(10,90,150,"Prefix");
            stepper_offset_x = new PsychUINumericStepper(20,130,1,0);
            stepper_offset_y = new PsychUINumericStepper(85,130,1,0);
            //?
    
            //GENERAL
            UI_box.selectedName = 'General';
            var tab = UI_box.getTab('General').menu;
    
            tab.add(newLabel(input_assetPath, 'Asset path:'));
            tab.add(input_assetPath);
            tab.add(btn_reload);
    
            tab.add(newLabel(input_text1, "Scroll texts:"));
            tab.add(input_text1);
            tab.add(input_text2);
            tab.add(input_text3);
    
            //DJ EDITOR
            var tab = UI_box.getTab("DJ Editor").menu;
            tab.add(dj_editor_desc_txt);
            tab.add(txt_introStart);
            tab.add(steper_introStartFrame);
            tab.add(steper_introStartFrame);
            tab.add(txt_introLoop);
            tab.add(steper_loopStartFrame);
            tab.add(steper_loopEndFrame);
            tab.add(txt_introBadStart);
            tab.add(steper_introBadStartFrame);
            tab.add(steper_introBadEndFrame);
            tab.add(txt_introBadLoop);
            tab.add(steper_loopBadStartFrame);
            tab.add(steper_loopBadEndFrame);
            tab.add(steper_introEndFrame);
            //tab.add(btn_player_prev);
            
            //GF
            var tab = UI_box.getTab("Animation").menu;
            tab.add(btn_newAnim);
            tab.add(btn_trashAnim);
            tab.add(newLabel(input_animName,"Name"));
            tab.add(input_animName);
            tab.add(newLabel(input_animPrefix,"Prefix"));
            tab.add(input_animPrefix);
            tab.add(new FlxText(10, 110, 100, "Offsets (x,y)"));
            tab.add(stepper_offset_x);
            tab.add(stepper_offset_y);
            tab.add(list_animations);
        }
    function newLabel(ref:FlxSprite, text:String)
    {
        return new FlxText(ref.x, ref.y - 10, 100, text);
    }
    function setDadBG() {
        var graphic = style.getBgAssetGraphic();
        bgDad.loadGraphic(graphic == null ? Paths.image('charEdit/freeplayBGmissing') : graphic);
    }
}