package mikolka.editors.editorProps;

import mikolka.vslice.freeplay.backcards.BoyfriendCard;
import mikolka.vslice.freeplay.DJBoyfriend.FreeplayDJ;

class FreeplayEditSubstate extends MusicBeatSubstate {
    
	var UI_box:PsychUIBox;
    var data:PlayableCharacter;
    var anims:AnimPreview;
    var animsList:Array<AnimationData>;

    var dj:FlxAtlasSprite;
	var backingCard:BoyfriendCard;

    //GENERAL
	var input_assetPath:PsychUIInputText;
	var btn_reload:PsychUIButton;
	var steper_charSelectDelay:PsychUINumericStepper;
	var input_text1:PsychUIInputText;
	var input_text2:PsychUIInputText;
	var input_text3:PsychUIInputText;

    public function new(player:PlayableCharacter) {
        super();
        data = player;
    }
    override function create() {
        backingCard = new BoyfriendCard(data);
        backingCard.init();
        add(backingCard);

        dj = new FlxAtlasSprite(640, 366,data.getFreeplayDJData().getAtlasPath());
        add(dj);
        
        @:privateAccess
        animsList = data.getFreeplayDJData().animations;
        //anims = new AnimPreview(200,200);
        //anims.attachSprite(dj);
        addEditorBox();
        super.create();
    }
    override function update(elapsed:Float) {
        super.update(elapsed);
        if(PsychUIInputText.focusOn == null)
            {
                ClientPrefs.toggleVolumeKeys(true);
                var b_tapped = false;
                
                #if TOUCH_CONTROLS_ALLOWED
                b_tapped = touchPad.buttonB.justPressed;
                #end

                if(controls.BACK || b_tapped){
                    FlxG.sound.playMusic(Paths.music('freakyMenu'));
                    closeSubState();
                }
            }
        else ClientPrefs.toggleVolumeKeys(false);
		
		// if(anims.activeSprite != null){
		// 	if(controls.UI_DOWN_P) anims.selectAnim(1);
		// 	if(controls.UI_UP_P) anims.selectAnim(-1);
		// 	if(FlxG.keys.justPressed.SPACE) anims.playAnim();
		// 	if(controls.UI_LEFT_P) anims.selectFrame(-1);
		// 	if(controls.UI_RIGHT_P) anims.selectFrame(1);
			
		// }
    }
    function addEditorBox()
        {
            UI_box = new PsychUIBox(FlxG.width, FlxG.height, 300, 250, ['General',"DJ Editor", "Animation", 'Style']);
            UI_box.x -= UI_box.width;
            UI_box.y -= UI_box.height;
            UI_box.scrollFactor.set();
            add(UI_box);
    
            // GENERAL
            @:privateAccess
            input_assetPath = new PsychUIInputText(20, 20, 100, data._data.freeplayDJ.assetPath);
    
            btn_reload = new PsychUIButton(20, 60, "Reload", () ->
            {
                remove(dj);
                dj.destroy();
                dj = dj = new FreeplayDJ(0,0,data);
            });
            @:privateAccess
            steper_charSelectDelay = new PsychUINumericStepper(20, 60, 0.05, data._data.freeplayDJ.charSelect.transitionDelay,0,10,0,100);
    
            var btn_save:PsychUIButton = new PsychUIButton(20, 150, "Save", ()->
            {
            });
            //BF

            @:privateAccess{
                input_text1 = new PsychUIInputText(20,50,150,data._data.freeplayDJ.text1);
                input_text2 = new PsychUIInputText(20,90,150,data._data.freeplayDJ.text2);
                input_text3 = new PsychUIInputText(20,130,150,data._data.freeplayDJ.text3);
            }
            //GF

            // var btn_gf_prev:PsychUIButton = new PsychUIButton(20, 20, "Anims preview", ()->
            //     {
            //         animPreview.attachSprite(gfChill); 
            //         PsychUIInputText.focusOn = null;
            //     });
            // var btn_gf_reload:PsychUIButton = new PsychUIButton(120, 20, "Reload", ()->
            //     {
            //         switchEditorGF(activePlayer._data.charSelect.gf);
            //     });
            // input_gfAssetPath = new PsychUIInputText(20, 60, 100, activePlayer._data.charSelect.gf.assetPath);
            // input_gfAssetPath.onChange = (p,next) -> {
            //     activePlayer._data.charSelect.gf.assetPath = next;
            // };
            // input_gfAnimInfoPath = new PsychUIInputText(20, 120, 100, activePlayer._data.charSelect.gf.animInfoPath);
            // input_gfAnimInfoPath.onChange = (prev,next) ->{
            //     activePlayer._data.charSelect.gf.animInfoPath = next;
            // };
            // chkBox_visualiser = new PsychUICheckBox(20,150,"Use visualiser",100,() -> {
            //     activePlayer._data.charSelect.gf.visualizer = chkBox_visualiser.checked;
            // });
            // chkBox_visualiser.checked = activePlayer._data.charSelect.gf.visualizer;

            //?
    
            //GENERAL
            UI_box.selectedName = 'General';
            var tab = UI_box.getTab('General').menu;
            add(UI_box);
    
            tab.add(newLabel(input_assetPath, 'Asset path:'));
            tab.add(input_assetPath);
            tab.add(btn_reload);
    
            tab.add(newLabel(input_text1, "Scroll text:"));
            tab.add(input_text1);
            tab.add(input_text2);
            tab.add(input_text3);
    
            //BF
    
            var tab = UI_box.getTab("DJ Editor").menu;
            //tab.add(btn_player_prev);
    
            //GF
            var tab = UI_box.getTab("Animation").menu;
            // tab.add(btn_gf_prev);
            // tab.add(btn_gf_reload);
            // tab.add(newLabel(input_gfAssetPath, "Asset path:"));
            // tab.add(input_gfAssetPath);
            // tab.add(newLabel(input_gfAnimInfoPath, "JSFL anim folder:"));
            // tab.add(input_gfAnimInfoPath);
            // tab.add(chkBox_visualiser);
            //
        }
        function newLabel(ref:FlxSprite, text:String)
            {
                return new FlxText(ref.x, ref.y - 10, 100, text);
            }
}