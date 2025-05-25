package mikolka.stages.scripts;

import mikolka.compatibility.VsliceOptions;
import mikolka.stages.objects.TankmenBG;
#if !LEGACY_PSYCH
import substates.GameOverSubstate;
import backend.Song;
import objects.Character;
#else
import Song.SwagSong;
#end

class TankmanStagesAddons extends BaseStage {
    public var animationNotes:Array<Dynamic> = [];

    override function createPost() {
        super.createPost();
        switch (game.gf.curCharacter){
            case 'pico-speaker':
                game.gf.skipDance = true;
                loadMappedAnims(game.gf);
                game.gf.playAnim("shoot1");
             case 'otis-speaker':
                loadMappedAnims(game.gf);
                game.gf.playAnim("shoot1");
        }
    }
    override function update(elapsed:Float) {
        super.update(elapsed);
        switch(game.gf.curCharacter)
		{
			case 'pico-speaker'|'otis-speaker':
				if(animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
				{
					var noteData:Int = 1;
					if(animationNotes[0][1] > 2) noteData = 3;

					noteData += FlxG.random.int(0, 1);
					game.gf.playAnim('shoot' + noteData, true);
					animationNotes.shift();
				}
                #if LEGACY_PSYCH
				if(game.gf.animation.curAnim.finished) game.gf.playAnim(game.gf.animation.curAnim.name, false, false, game.gf.animation.curAnim.frames.length - 3);
                #else
				if(game.gf.isAnimationFinished()) game.gf.playAnim(game.gf.getAnimationName(), false, false, game.gf.animation.curAnim.frames.length - 3);
                #end
		}
    }
    override function gameOverStart(SubState:GameOverSubstate) {
        SubState.onCoolDeath = () ->{
            @:privateAccess
            SubState.coolStartDeath(0.2);
            var onEnd = function() {
                @:privateAccess
                if(!SubState.isEnding)
                {
                    FlxG.sound.music.fadeIn(0.2, 1, 4);
                }
            };
            switch (PlayState.SONG.player1){
                case "bf-holding-gf"|"bf":{
                    var exclude:Array<Int> = [];
                    if(!VsliceOptions.NAUGHTYNESS) exclude = [1, 3, 8, 13, 17, 21];
                    FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, exclude)), 1, false, null, true,onEnd);
                }
                case "pico-playable"|"pico-holding-nene":{
                    FlxG.sound.play(Paths.sound('jeffGameover-pico/jeffGameover-' + FlxG.random.int(1, 9)), 1, false, null, true,onEnd);
                }
                default:{
                    FlxG.sound.play(Paths.sound('jeffGameover-pico/jeffGameover-10'), 1, false, null, true,onEnd);
                }
            };
        }
    }
    //
    function loadMappedAnims(char:Character):Void
        {
            try
            {
                #if LEGACY_PSYCH
                var songData:SwagSong = Song.loadFromJson('picospeaker', Paths.formatToSongPath(PlayState.SONG.song));
                #else
                var songData:SwagSong = Song.getChart('picospeaker', Paths.formatToSongPath(Song.loadedSongName));
                #end
                if(songData != null)
                    for (section in songData.notes)
                        for (songNotes in section.sectionNotes)
                            animationNotes.push(songNotes);
    
                TankmenBG.animationNotes = animationNotes;
                @:privateAccess
                animationNotes.sort(char.sortAnims);
            }
            catch(e:Dynamic) {}
        }
}