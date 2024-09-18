package mikolka;

import states.stages.objects.ABotSpeaker;

class ABotManager {
	static var abot:ABotSpeaker;
    public static function ABot_onCreatePost() {
        var game = PlayState.instance;
        if((PlayState.SONG.gfVersion != 'nene' && PlayState.SONG.gfVersion != 'nene-christmas') || PlayState.SONG.stage == 'phillyStreets' || PlayState.SONG.stage == 'phillyBlazin') return;
        game.gfGroup.y -= 200;
        abot = new ABotSpeaker(game.gfGroup.x-50, game.gfGroup.y+550-30);
		updateABotEye(true);
		game.addBehindGF(abot);
        
    }
    public static function ABot_songStart() {
        if(abot == null) return;
        // FlxG.signals.postStateSwitch.addOnce(() -> {
        //     abot = null; // cleaning reference
        // });
        abot.snd = FlxG.sound.music;
    }
    public static function ABot_sectionHit() {
        if(abot == null) return;
        updateABotEye();
    }
    static function updateABotEye(finishInstantly:Bool = false)
        {
            @:privateAccess // lol
            if(PlayState.SONG.notes[Std.int(FlxMath.bound(PlayState.instance.curSection, 0, PlayState.SONG.notes.length - 1))].mustHitSection == true)
                abot.lookRight();
            else
                abot.lookLeft();
    
            if(finishInstantly) abot.eyes.anim.curFrame = abot.eyes.anim.length - 1;
        }
    
}