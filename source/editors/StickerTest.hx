package editors;

import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIInputText;
import mikolka.compatibility.ModsHelper;
import substates.StickerSubState;

class StickerTest extends MusicBeatState {
    private var stickerSet:String;
    private var stickerPack:String;
    private var stickerSubState:StickerSubState;
	var stickerSetInput:FlxUIInputText;
	var stickerPackInput:FlxUIInputText;

	public function new(?stickers:StickerSubState = null,set:String = "stickers-set-1",pack:String = "all"){
        stickerPack = pack;
        stickerSet = set;
        if (stickers != null)
        {
            stickerSubState = stickers;
        }
        super();
    }
    override function create() {
        FlxG.sound.music.pause();
        FlxG.mouse.visible = true;
        Paths.clearUnusedMemory();
        if (stickerSubState != null)
			{
              ModsHelper.clearStoredWithoutStickers();
			  openSubState(stickerSubState);
			  stickerSubState.degenStickers();
			}
		else Paths.clearStoredMemory();
        

        var BG = new FlxSprite(0,0,Paths.image("freeplay/freeplayBGdad"));
        BG.setGraphicSize(FlxG.width,FlxG.height);
        BG.updateHitbox();
        add(BG);
        addEditorBox();
        super.create();
    }
    var UI_box:FlxUITabMenu;
	function addEditorBox() {
		UI_box = new FlxUITabMenu(null,[{name: "Sticker", label: 'Sticker'}],true);
        UI_box.resize(200,250);
		UI_box.x = FlxG.width-200-50;
		UI_box.y = FlxG.height-250-50;
		UI_box.scrollFactor.set();
		add(UI_box);

        stickerSetInput = new FlxUIInputText(20,50,100,stickerSet);
        stickerPackInput = new FlxUIInputText(20,100,100,stickerPack);
		
        var tab = new FlxUI(null, UI_box);
        tab.name = 'Sticker';
		add(UI_box);

        tab.add(new FlxText(stickerSetInput.x, stickerSetInput.y - 15, 100, 'Sticker set:'));
		tab.add(stickerSetInput);

        tab.add(new FlxText(stickerPackInput.x, stickerPackInput.y - 15, 100, 'Sticker pack:'));
		tab.add(stickerPackInput);


		var loadWeekButton:FlxUIButton = new FlxUIButton(20, 150, "Play", function() {
            StickerSubState.STICKER_PACK = stickerPackInput.text;
            StickerSubState.STICKER_SET = stickerSetInput.text;
            openSubState(new StickerSubState(null,s -> new StickerTest(s,stickerSetInput.text,stickerPackInput.text)));
        });
		tab.add(loadWeekButton);
        UI_box.addGroup(tab);
	}
    override function update(elapsed:Float) {
        super.update(elapsed);
        if(!stickerSetInput.hasFocus&&!stickerPackInput.hasFocus)
            {
                enableVolume();
                if(FlxG.keys.justPressed.ESCAPE){
                    FlxG.sound.playMusic(Paths.music('freakyMenu'));
                    FlxG.mouse.visible = false;
                    MusicBeatState.switchState(new MasterEditorMenu());
                }
            }
            else disableVolume();
    }
    private function enableVolume(){
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
    }
    private function disableVolume(){
        FlxG.sound.muteKeys = [];
		FlxG.sound.volumeDownKeys = [];
		FlxG.sound.volumeUpKeys = [];
    }
}