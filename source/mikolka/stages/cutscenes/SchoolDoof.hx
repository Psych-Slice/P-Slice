package mikolka.stages.cutscenes;
#if !LEGACY_PSYCH
import cutscenes.CutsceneHandler;
#end
import mikolka.stages.cutscenes.dialogueBox.DialogueBoxPsych;
import mikolka.stages.cutscenes.dialogueBox.DialogueBoxPsych.DialogueFile;

class SchoolDoof
{
	var songName:String;
	var dialogue:DialogueFile;

	public function new(song:String)
	{
		songName = song;
		initDoof();
	}

	function initDoof()
	{
		#if LEGACY_PSYCH
		var file:String = Paths.json('$songName/${songName}Dialogue'); // Checks for vanilla/Senpai dialogue
		#else
		var file:String = Paths.json('$songName/${songName}Dialogue_${ClientPrefs.data.language}'); // Checks for vanilla/Senpai dialogue
		#end
		if (!NativeFileSystem.exists(file))
		{
			file = Paths.json('$songName/${songName}Dialogue');
		}

		if (!NativeFileSystem.exists(file))
			return;

		dialogue = DialogueBoxPsych.parseDialogue(file);
	}

	public function doSimpleDialogue()
	{
		var game:PlayState = PlayState.instance;
		if (dialogue != null)
			game.startDialogue(dialogue);
		else
			game.startCountdown();
	}

	public function doSchoolIntro():Void
	{
		var game:PlayState = PlayState.instance;
		game.inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		if (dialogue != null)
			game.add(black);

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha <= 0)
			{
				game.remove(black);
				black.destroy();
				doSimpleDialogue();
			}
			else
				tmr.reset(0.3);
		});
	}

	public function doAngryIntro()
	{
		FlxG.sound.play(Paths.sound('ANGRY'));
		doSimpleDialogue();
	}

	public function doSpiritIntro()
	{
		var game:PlayState = PlayState.instance;
        var cutscene = new CutsceneHandler();
        cutscene.endTime = 4.5+7;

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();
		game.add(red);
		cutscene.push(red);

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;
        cutscene.push(senpaiEvil);
        
		game.camHUD.visible = false;

        cutscene.timer(2.1,() ->{
            game.add(senpaiEvil);
			senpaiEvil.alpha = 0;
        });
        cutscene.timer(2.4,() ->{ //0.3 per step   needs 7 steps to complete // 2.1
            FlxTween.tween(senpaiEvil,{alpha:1},0.3*7,{
                ease: f -> {
                    if(f == 1) return 1;
                    var remainer = f % 0.15;
                    return f-remainer;
                }
            });
        });
        cutscene.timer(4.5,() ->{
            senpaiEvil.animation.play('idle');
			FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true);
        });        
        cutscene.timer(7.7,() ->{ //originally it was 3.2 timer
            FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
        });
        cutscene.finishCallback = () ->{
            game.camHUD.visible = true;
            FlxG.camera.fade(FlxColor.WHITE, 0.01, true,null, true);
			doSimpleDialogue();
		};
		#if !LEGACY_PSYCH
		cutscene.skipCallback = function()
			{
				
				game.camHUD.visible = true;
				FlxG.camera.fade(FlxColor.WHITE, 0.01, true,null, true);
				game.startCountdown();
			};
			#end
	}
}
