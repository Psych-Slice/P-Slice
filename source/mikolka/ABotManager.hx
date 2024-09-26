package mikolka;

import states.stages.objects.ABotSpeaker;

class ABotManager {
	static var abot:ABotSpeaker;
    public static function ABot_onCreatePost() {
        abot = null;
        var game = PlayState.instance;
        if((!['nene','nene-christmas','nene-dark'].contains(PlayState.SONG.gfVersion)) 
        || PlayState.SONG.stage == 'phillyStreets' 
        || PlayState.SONG.stage == 'phillyBlazin') return;
        game.gfGroup.y -= 200;
        abot = new ABotSpeaker(game.gfGroup.x-50, game.gfGroup.y+550-30,PlayState.SONG.gfVersion == "nene-dark");
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
    public static function ABot_plink() { // silly daniel
        if(abot == null || abot.speakerAlt == null) return;
        abot.speakerAlt.alpha = 1;
        abot.speaker.alpha = 0;
        FlxTween.tween(abot.speakerAlt,{alpha:0},1.5,{
            ease: FlxEase.linear
        });
        FlxTween.tween(abot.speaker,{alpha:1},1.5,{
            ease: FlxEase.linear
        });
    }
    public static function ABot_sectionHit() {
        if(abot == null) return;
        updateABotEye(); // If this fails we probably need to dispose our ABot
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