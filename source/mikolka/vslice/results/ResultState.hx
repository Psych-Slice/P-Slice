package mikolka.vslice.results;

import haxe.Exception;
import mikolka.compatibility.ModsHelper;
import mikolka.compatibility.VsliceOptions;
import mikolka.funkin.FlxAtlasSprite;
import mikolka.funkin.FunkinSprite;
import mikolka.funkin.players.PlayerData;
import flixel.FlxSubState;
import mikolka.compatibility.freeplay.FreeplayHelpers;
import mikolka.compatibility.funkin.FunkinPath as Paths;
import mikolka.vslice.results.Tallies.SaveScoreData;
import mikolka.compatibility.funkin.FunkinCamera;
import mikolka.vslice.freeplay.FreeplayState;
import flixel.addons.transition.FlxTransitionableState;
import mikolka.vslice.StickerSubState;
import mikolka.funkin.Scoring;
import shaders.LeftMaskShader;
import flixel.FlxSprite;

import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;

import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;

import flixel.util.FlxColor;
import flixel.tweens.FlxEase;

import flixel.tweens.FlxTween;
import flixel.addons.display.FlxBackdrop;

import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import mikolka.funkin.players.*;
import mikolka.funkin.players.PlayerData.PlayerFreeplayDJData;
import mikolka.funkin.custom.VsliceSubState as MusicBeatSubState;
using mikolka.funkin.custom.FunkinTools;

/**
 * The state for the results screen after a song or week is finished.
 */
//TODO  documented?
class ResultState extends MusicBeatSubState
{
  final params:ResultsStateParams;

  final rank:ScoringRank;
  final songName:FlxBitmapText;
  final difficulty:FlxBitmapText; //? turned this to text
  final clearPercentSmall:ClearPercentCounter;

  final maskShaderSongName:LeftMaskShader = new LeftMaskShader();
  final maskShaderDifficulty:LeftMaskShader = new LeftMaskShader();

  final resultsAnim:FunkinSprite;
  final ratingsPopin:FunkinSprite;
  final scorePopin:FunkinSprite;

  final bgFlash:FlxSprite;

  final highscoreNew:FlxSprite;
  final score:ResultScore;

  var characterAtlasAnimations:Array<
    {
      sprite:FlxAtlasSprite,
      delay:Float,
      forceLoop:Bool,
      startFrameLabel:String,
      sound:String
    }> = [];
  var characterSparrowAnimations:Array<
    {
      sprite:FunkinSprite,
      delay:Float
    }> = [];

  var playerCharacterId:Null<String>;

  var rankBg:FunkinSprite;
  final cameraBG:FunkinCamera;
  final cameraScroll:FunkinCamera;
  final cameraEverything:FunkinCamera;

  public function new(params:ResultsStateParams)
  {
    super();

    this.params = params;

    rank = Scoring.calculateRank(params.scoreData) ?? SHIT;

    cameraBG = new FunkinCamera('resultsBG', 0, 0, FlxG.width, FlxG.height);
    cameraScroll = new FunkinCamera('resultsScroll', 0, 0, FlxG.width, FlxG.height);
    cameraEverything = new FunkinCamera('resultsEverything', 0, 0, FlxG.width, FlxG.height);

    // We build a lot of this stuff in the constructor, then place it in create().
    // This prevents having to do `null` checks everywhere.

    var fontLetters:String = "AaBbCcDdEeFfGgHhiIJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz:1234567890";
    songName = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("resultScreen/tardlingSpritesheet"), fontLetters, FlxPoint.get(49, 62)));
    songName.text = params.title;
    songName.letterSpacing = -15;
    songName.angle = -4.4;
    songName.zIndex = 1000;
    var difColor = PlayState.storyDifficultyColor; //? support for difficulty text
    var fractal = difColor.redFloat*0.33;
    difColor.greenFloat = Math.max(difColor.greenFloat,fractal);

    difficulty = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("resultScreen/tardlingSpritesheet"), fontLetters, FlxPoint.get(49, 62)));
    difficulty.text = FreeplayHelpers.getDifficultyName();
    difficulty.color = difColor;
    difficulty.letterSpacing = -11; //!!!
    difficulty.angle = -4.4;
    difficulty.zIndex = 1000;

    clearPercentSmall = new ClearPercentCounter(FlxG.width / 2 + 300, FlxG.height / 2 - 100, 100, true);
    clearPercentSmall.zIndex = 1000;
    clearPercentSmall.visible = false;

    bgFlash = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFFFFF1A6, 0xFFFFF1BE], 90);

    resultsAnim = FunkinSprite.createSparrow(-200, -10, "resultScreen/results");

    ratingsPopin = FunkinSprite.createSparrow(-135, 135, "resultScreen/ratingsPopin");

    scorePopin = FunkinSprite.createSparrow(-180, 515, "resultScreen/scorePopin");

    highscoreNew = new FlxSprite(44, 557);

    score = new ResultScore(35, 305, 10, params.scoreData.score);

    rankBg = new FunkinSprite(0, 0);

    var sngMeta = FreeplayMeta.getMeta(params.songId);
    
    if(sngMeta.freeplayCharacter != '' ){
      playerCharacterId = sngMeta.freeplayCharacter;
    }
    else if (!PlayState.isStoryMode){
      var mod_char = VsliceOptions.LAST_MOD;
      playerCharacterId = mod_char.char_name;
      ModsHelper.loadModDir(mod_char.mod_dir);
    }
    else{
      playerCharacterId = "bf";
    }
    //? moved this line so we can edit it in debug options
  }

  override function create():Void
  {
    if (FlxG.sound.music != null) FlxG.sound.music.stop();

    // We need multiple cameras so we can put one at an angle.
    cameraScroll.angle = -3.8;

    cameraBG.bgColor = FlxColor.MAGENTA;
    cameraScroll.bgColor = FlxColor.TRANSPARENT;
    cameraEverything.bgColor = FlxColor.TRANSPARENT;

    FlxG.cameras.add(cameraBG, false);
    FlxG.cameras.add(cameraScroll, false);
    FlxG.cameras.add(cameraEverything, false);

    FlxG.cameras.setDefaultDrawTarget(cameraEverything, true);
    this.camera = cameraEverything;

    // Reset the camera zoom on the results screen.
    FlxG.camera.zoom = 1.0;

    var bg:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFFFECC5C, 0xFFFDC05C], 90);
    bg.scrollFactor.set();
    bg.zIndex = 10;
    bg.cameras = [cameraBG];
    add(bg);

    bgFlash.scrollFactor.set();
    bgFlash.visible = false;
    bgFlash.zIndex = 20;
    // bgFlash.cameras = [cameraBG];
    add(bgFlash);

    // The sound system which falls into place behind the score text. Plays every time!
    var soundSystem:FlxSprite = FunkinSprite.createSparrow(-15, -180, 'resultScreen/soundSystem');
    soundSystem.animation.addByPrefix("idle", "sound system", 24, false);
    soundSystem.visible = false;
    new FlxTimer().start(8 / 24, _ -> {
      soundSystem.animation.play("idle");
      soundSystem.visible = true;
    });
    soundSystem.zIndex = 1100;
    add(soundSystem);

    // Fetch playable character data. Default to BF on the results screen if we can't find it.
    //? changed a little code here

    
    var playerCharacter:Null<PlayableCharacter> = PlayerRegistry.instance.fetchEntry(playerCharacterId ?? 'bf');

    //trace('Got playable character: ${playerCharacter?.getName()}');
    // Query JSON data based on the rank, then use that to build the animation(s) the player sees.
    var playerAnimationDatas:Array<PlayerResultsAnimationData> = playerCharacter != null ? playerCharacter.getResultsAnimationDatas(rank) : [];

    for (animData in playerAnimationDatas)
    {
      if (animData == null) continue;

      //? Rework available flags
      switch (animData.filter){
        case ""|"both"|null: // Do nothing 
        case "naughty":
          if(!VsliceOptions.NAUGHTYNESS) continue;        
        case "safe":
          if(VsliceOptions.NAUGHTYNESS) continue;
        default: 
          trace(animData.filter+" is not a valid filter!");
          continue; 
      }

      var animPath:String = "";
      var animLibrary:String = "";

      if (animData.assetPath != null)
      {
        animPath = Paths.stripLibrary(animData.assetPath);
        animLibrary = "";
      }
      var offsets = animData.offsets ?? [0, 0];
      try{

      
      switch (animData.renderType)
      {
        case 'animateatlas':
          //? Scaling offsets because Pico decided to be annoying
          var xDiff = offsets[0] - (offsets[0]* (animData.scale ?? 1.0));
          var yDiff = offsets[1] - (offsets[1]* (animData.scale ?? 1.0));
          offsets[0] -= xDiff*1.8;
          offsets[1] -= yDiff*1.8;

          var animation:FlxAtlasSprite = new FlxAtlasSprite(offsets[0], offsets[1], animPath);
          animation.zIndex = animData.zIndex ?? 500;
          animation.scale.set(animData.scale ?? 1.0, animData.scale ?? 1.0);

          if (!(animData.looped ?? true))
            {
              // Animation is not looped.
              animation.onAnimationComplete.add((_name:String) -> {
                trace("AHAHAH 2");
                if (animation != null)
                {
                  animation.anim.pause();
                }
              });
            }
            else if (animData.loopFrameLabel != null)
            {
              animation.onAnimationComplete.add((_name:String) -> {
                trace("AHAHAH 2");
                if (animation != null)
                {
                  animation.playAnimation(animData.loopFrameLabel ?? '', true, false, true); // unpauses this anim, since it's on PlayOnce!
                }
              });
            }
            else if (animData.loopFrame != null)
            {
              animation.onAnimationComplete.add((_name:String) -> {
                if (animation != null)
                {
                  trace("AHAHAH");
                  animation.anim.curFrame = animData.loopFrame ?? 0;
                  animation.anim.play(); // unpauses this anim, since it's on PlayOnce!
                }
              });
            }

          // Hide until ready to play.
          animation.visible = false;
          // Queue to play.
          characterAtlasAnimations.push(
            {
              sprite: animation,
              delay: animData.delay ?? 0.0,
              forceLoop: (animData.loopFrame ?? -1) == 0,
              startFrameLabel: (animData.startFrameLabel ?? ""),
              sound: (animData.sound ?? "")
            });
          // Add to the scene.
          add(animation);
        case 'sparrow':
          var animation:FunkinSprite = FunkinSprite.createSparrow(offsets[0], offsets[1], animPath);
          animation.animation.addByPrefix('idle', '', 24, false, false, false);

          if (animData.loopFrame != null)
          {
            animation.animation.finishCallback = (_name:String) -> {
              if (animation != null)
              {
                animation.animation.play('idle', true, false, animData.loopFrame ?? 0);
              }
            }
          }

          // Hide until ready to play.
          animation.visible = false;
          // Queue to play.
          characterSparrowAnimations.push(
            {
              sprite: animation,
              delay: animData.delay ?? 0.0
            });
          // Add to the scene.
          add(animation);
      }
      }
      catch(error:Exception){
        trace("Failed to load "+animPath);
        trace(error);
      }
    }

    var diffSpr:String = 'diff_${params?.difficultyId ?? 'Normal'}';
    difficulty.loadGraphic(Paths.image("resultScreen/" + diffSpr));
    add(difficulty);

    add(songName);

    var angleRad = songName.angle * Math.PI / 180;
    speedOfTween.x = -1.0 * Math.cos(angleRad);
    speedOfTween.y = -1.0 * Math.sin(angleRad);

    timerThenSongName(1.0, false);
    //! Watch out with this one 
    //songName.shader = maskShaderSongName;
    //difficulty.shader = maskShaderDifficulty;

    // maskShaderSongName.swagMaskX = difficulty.x - 15;
    //maskShaderDifficulty.swagMaskX = difficulty.x - 15;

    var blackTopBar:FlxSprite = new FlxSprite().loadGraphic(Paths.image("resultScreen/topBarBlack"));
    blackTopBar.y = -blackTopBar.height;
    FlxTween.tween(blackTopBar, {y: 0}, 7 / 24, {ease: FlxEase.quartOut, startDelay: 3 / 24});
    blackTopBar.zIndex = 1010;
    add(blackTopBar);

    resultsAnim.animation.addByPrefix("result", "results instance 1", 24, false);
    resultsAnim.visible = false;
    resultsAnim.zIndex = 1200;
    add(resultsAnim);
    new FlxTimer().start(6 / 24, _ -> {
      resultsAnim.visible = true;
      resultsAnim.animation.play("result");
    });

    ratingsPopin.animation.addByPrefix("idle", "Categories", 24, false);
    ratingsPopin.visible = false;
    ratingsPopin.zIndex = 1200;
    add(ratingsPopin);
    new FlxTimer().start(21 / 24, _ -> {
      ratingsPopin.visible = true;
      ratingsPopin.animation.play("idle");
    });

    scorePopin.animation.addByPrefix("score", "tally score", 24, false);
    scorePopin.visible = false;
    scorePopin.zIndex = 1200;
    add(scorePopin);
    new FlxTimer().start(36 / 24, _ -> {
      scorePopin.visible = true;
      scorePopin.animation.play("score");
      scorePopin.animation.finishCallback = anim -> {};
    });

    new FlxTimer().start(37 / 24, _ -> {
      score.visible = true;
      score.animateNumbers();
      startRankTallySequence();
    });

    new FlxTimer().start(rank.getBFDelay(), _ -> {
      afterRankTallySequence();
    });

    new FlxTimer().start(rank.getFlashDelay(), _ -> {
      displayRankText();
    });

    highscoreNew.frames = Paths.getSparrowAtlas("resultScreen/highscoreNew");
    highscoreNew.animation.addByPrefix("new", "highscoreAnim0", 24, false);
    highscoreNew.visible = false;
    // highscoreNew.setGraphicSize(Std.int(highscoreNew.width * 0.8));
    highscoreNew.updateHitbox();
    highscoreNew.zIndex = 1200;
    add(highscoreNew);

    new FlxTimer().start(rank.getHighscoreDelay(), _ -> {
      if (params.isNewHighscore ?? false)
      {
        highscoreNew.visible = true;
        highscoreNew.animation.play("new");
        highscoreNew.animation.finishCallback = _ -> highscoreNew.animation.play("new", true, false, 16);
      }
      else
      {
        highscoreNew.visible = false;
      }
    });

    var hStuf:Int = 50;

    var ratingGrp:FlxTypedGroup<TallyCounter> = new FlxTypedGroup<TallyCounter>();
    ratingGrp.zIndex = 1200;
    add(ratingGrp);

    /**
     * NOTE: We display how many notes were HIT, not how many notes there were in total.
     *
     */
    var totalHit:TallyCounter = new TallyCounter(375, hStuf * 3, params.scoreData.totalNotesHit);
    ratingGrp.add(totalHit);

    var maxCombo:TallyCounter = new TallyCounter(375, hStuf * 4, params.scoreData.maxCombo);
    ratingGrp.add(maxCombo);

    hStuf += 2;
    var extraYOffset:Float = 7;

    hStuf += 2;

    var tallySick:TallyCounter = new TallyCounter(230, (hStuf * 5) + extraYOffset, params.scoreData.sick, 0xFF89E59E);
    ratingGrp.add(tallySick);

    var tallyGood:TallyCounter = new TallyCounter(210, (hStuf * 6) + extraYOffset, params.scoreData.good, 0xFF89C9E5);
    ratingGrp.add(tallyGood);

    var tallyBad:TallyCounter = new TallyCounter(190, (hStuf * 7) + extraYOffset, params.scoreData.bad, 0xFFE6CF8A);
    ratingGrp.add(tallyBad);

    var tallyShit:TallyCounter = new TallyCounter(220, (hStuf * 8) + extraYOffset, params.scoreData.shit, 0xFFE68C8A);
    ratingGrp.add(tallyShit);

    var tallyMissed:TallyCounter = new TallyCounter(260, (hStuf * 9) + extraYOffset, params.scoreData.missed, 0xFFC68AE6);
    ratingGrp.add(tallyMissed);

    score.visible = false;
    score.zIndex = 1200;
    add(score);

    for (ind => rating in ratingGrp.members)
    {
      rating.visible = false;
      new FlxTimer().start((0.3 * ind) + 1.20, _ -> {
        rating.visible = true;
        FlxTween.tween(rating, {curNumber: rating.neededNumber}, 0.5, {ease: FlxEase.quartOut});
      });
    }

    // if (params.isNewHighscore ?? false)
    // {
    //   highscoreNew.visible = true;
    //   highscoreNew.animation.play("new");
    //   //FlxTween.tween(highscoreNew, {y: highscoreNew.y + 10}, 0.8, {ease: FlxEase.quartOut});
    // }
    // else
    // {
    //   highscoreNew.visible = false;
    // }

    new FlxTimer().start(rank.getMusicDelay(), _ -> {
      //? Changed a little sound loading
      var introMusic:String = getMusicPath(playerCharacter, rank) + '/' + getMusicPath(playerCharacter, rank) + '-intro';
      if (Paths.exists('music/$introMusic.ogg'))
      {
        // Play the intro music.
        FlxG.sound.music = FunkinSound.load(Paths.music(introMusic), 1.0, false, true, true, () -> {
          FunkinSound.playMusic(getMusicPath(playerCharacter, rank),
            {
              startingVolume: 1.0,
              overrideExisting: true,
              restartTrack: true
            });
        });
      }
      else
      {
        FunkinSound.playMusic(getMusicPath(playerCharacter, rank),
          {
            startingVolume: 1.0,
            overrideExisting: true,
            restartTrack: true
          });
      }
    });

    rankBg.makeSolidColor(FlxG.width, FlxG.height, 0xFF000000);
    rankBg.zIndex = 99999;
    add(rankBg);

    rankBg.alpha = 0;

    refresh();

    super.create();
  }

  function getMusicPath(playerCharacter:Null<PlayableCharacter>, rank:ScoringRank):String
  {
    return playerCharacter?.getResultsMusicPath(rank) ?? 'resultsNORMAL';
  }

  var rankTallyTimer:Null<FlxTimer> = null;
  var clearPercentTarget:Int = 100;
  var clearPercentLerp:Int = 0;

  function startRankTallySequence():Void
  {
    bgFlash.visible = true;
    FlxTween.tween(bgFlash, {alpha: 0}, 5 / 24);
    var clearPercentFloat = (params.scoreData.accPoints/params.scoreData.totalNotesHit)* 100; //? different rating system 
    if(params.scoreData.totalNotesHit == 0) clearPercentFloat = 0;
    clearPercentTarget = Math.floor(clearPercentFloat);

    // Prevent off-by-one errors.

    clearPercentLerp = Std.int(Math.max(0, clearPercentTarget - 36));

    trace('Clear percent target: ' + clearPercentFloat + ', round: ' + clearPercentTarget);

    var clearPercentCounter:ClearPercentCounter = new ClearPercentCounter(FlxG.width / 2 + 190, FlxG.height / 2 - 70, clearPercentLerp);
    FlxTween.tween(clearPercentCounter, {curNumber: clearPercentTarget}, 58 / 24,
      {
        ease: FlxEase.quartOut,
        onUpdate: _ -> {
          // Only play the tick sound if the number increased.
          if (clearPercentLerp != clearPercentCounter.curNumber)
          {
            clearPercentLerp = clearPercentCounter.curNumber;
            FunkinSound.playOnce(Paths.sound('scrollMenu'));
          }
        },
        onComplete: _ -> {
          // Play confirm sound.
          FunkinSound.playOnce(Paths.sound('confirmMenu'));

          // Just to be sure that the lerp didn't mess things up.
          clearPercentCounter.curNumber = clearPercentTarget;

          clearPercentCounter.flash(true);
          new FlxTimer().start(0.4, _ -> {
            clearPercentCounter.flash(false);
          });

          // displayRankText();

          // previously 2.0 seconds
          new FlxTimer().start(0.25, _ -> {
            FlxTween.tween(clearPercentCounter, {alpha: 0}, 0.5,
              {
                startDelay: 0.5,
                ease: FlxEase.quartOut,
                onComplete: _ -> {
                  remove(clearPercentCounter);
                }
              });

            // afterRankTallySequence();
          });
        }
      });
    clearPercentCounter.zIndex = 450;
    add(clearPercentCounter);

    if (ratingsPopin == null)
    {
      trace("Could not build ratingsPopin!");
    }
    else
    {
      // ratingsPopin.animation.play("idle");
      // ratingsPopin.visible = true;

      ratingsPopin.animation.finishCallback = anim -> {
        // scorePopin.animation.play("score");

        // scorePopin.visible = true;

        if (params.isNewHighscore ?? false)
        {
          highscoreNew.visible = true;
          highscoreNew.animation.play("new");
        }
        else
        {
          highscoreNew.visible = false;
        }
      };
    }

    refresh();
  }

  function displayRankText():Void
  {
    bgFlash.visible = true;
    bgFlash.alpha = 1;
    FlxTween.tween(bgFlash, {alpha: 0}, 14 / 24);

    var rankTextVert:FlxBackdrop = new FlxBackdrop(Paths.image(rank.getVerTextAsset()), Y, 0, 30);
    rankTextVert.x = FlxG.width - 44;
    rankTextVert.y = 100;
    rankTextVert.zIndex = 990;
    add(rankTextVert);

    FlxFlicker.flicker(rankTextVert, 2 / 24 * 3, 2 / 24, true);

    // Scrolling.
    new FlxTimer().start(30 / 24, _ -> {
      rankTextVert.velocity.y = -80;
    });

    for (i in 0...12)
    {
      var rankTextBack:FlxBackdrop = new FlxBackdrop(Paths.image(rank.getHorTextAsset()), X, 10, 0);
      rankTextBack.x = FlxG.width / 2 - 320;
      rankTextBack.y = 50 + (135 * i / 2) + 10;
      // rankTextBack.angle = -3.8;
      rankTextBack.zIndex = 100;
      rankTextBack.cameras = [cameraScroll];
      add(rankTextBack);

      // Scrolling.
      rankTextBack.velocity.x = (i % 2 == 0) ? -7.0 : 7.0;
    }

    refresh();
  }

  function afterRankTallySequence():Void
  {
    showSmallClearPercent();

    for (atlas in characterAtlasAnimations)
    {
      new FlxTimer().start(atlas.delay, _ -> {
        if (atlas.sprite == null) return;
        atlas.sprite.visible = true;
        atlas.sprite.playAnimation(atlas.startFrameLabel);
        if (atlas.sound != "")
        {
          var sndPath:String = Paths.stripLibrary(atlas.sound);
          var sndLibrary:String = "";

          FunkinSound.playOnce(Paths.sound(sndPath), 1.0);
        }
      });
    }

    for (sprite in characterSparrowAnimations)
    {
      new FlxTimer().start(sprite.delay, _ -> {
        if (sprite.sprite == null) return;
        sprite.sprite.visible = true;
        sprite.sprite.animation.play('idle', true);
      });
    }
  }

  function timerThenSongName(timerLength:Float = 3.0, autoScroll:Bool = true):Void
  {
    movingSongStuff = false;

    difficulty.x = 555;

    var diffYTween:Float = 122;

    difficulty.y = -difficulty.height;
    FlxTween.tween(difficulty, {y: diffYTween}, 0.5, {ease: FlxEase.expoOut, startDelay: 0.8});

    if (clearPercentSmall != null)
    {
      clearPercentSmall.x = (difficulty.x + difficulty.width) + 60;
      clearPercentSmall.y = -clearPercentSmall.height;
      FlxTween.tween(clearPercentSmall, {y: 122 - 5}, 0.5, {ease: FlxEase.expoOut, startDelay: 0.85});
    }

    songName.y = -songName.height;
    var fuckedupnumber = (10) * (songName.text.length / 15);
    FlxTween.tween(songName, {y: diffYTween - 25 - fuckedupnumber}, 0.5, {ease: FlxEase.expoOut, startDelay: 0.9});
    songName.x = clearPercentSmall.x + 94;

    new FlxTimer().start(timerLength, _ -> {
      var tempSpeed = FlxPoint.get(speedOfTween.x, speedOfTween.y);

      speedOfTween.set(0, 0);
      FlxTween.tween(speedOfTween, {x: tempSpeed.x, y: tempSpeed.y}, 0.7, {ease: FlxEase.quadIn});

      movingSongStuff = (autoScroll);
    });
  }

  function showSmallClearPercent():Void
  {
    if (clearPercentSmall != null)
    {
      add(clearPercentSmall);
      clearPercentSmall.visible = true;
      clearPercentSmall.flash(true);
      new FlxTimer().start(0.4, _ -> {
        clearPercentSmall.flash(false);
      });

      clearPercentSmall.curNumber = clearPercentTarget;
      clearPercentSmall.zIndex = 1000;
      refresh();
    }

    new FlxTimer().start(2.5, _ -> {
      movingSongStuff = true;
    });
  }

  var movingSongStuff:Bool = false;
  var speedOfTween:FlxPoint = FlxPoint.get(-1, 1);

  override function draw():Void
  {
    super.draw();

    songName.clipRect = FlxRect.get(Math.max(0, 520 - songName.x), 0, FlxG.width, songName.height);

    // PROBABLY SHOULD FIX MEMORY FREE OR WHATEVER THE PUT() FUNCTION DOES !!!! FEELS LIKE IT STUTTERS!!!

    // if (songName != null && songName.frame != null)
    // maskShaderSongName.frameUV = songName.frame.uv;
  }

  override function update(elapsed:Float):Void
  {
    maskShaderDifficulty.swagSprX = difficulty.x;

    if (movingSongStuff)
    {
      var deltaScale = elapsed*190; //? fix framerate
      songName.x += speedOfTween.x*deltaScale;
      difficulty.x += speedOfTween.x*deltaScale;
      clearPercentSmall.x += speedOfTween.x*deltaScale;
      songName.y += speedOfTween.y*deltaScale;
      difficulty.y += speedOfTween.y*deltaScale;
      clearPercentSmall.y += speedOfTween.y*deltaScale;

      if (songName.x + songName.width < 100)
      {
        timerThenSongName();
      }
    }

    if (FlxG.keys.justPressed.RIGHT) speedOfTween.x += 0.1;

    if (FlxG.keys.justPressed.LEFT)
    {
      speedOfTween.x -= 0.1;
    }

    if (TouchUtil.justPressed || controls.PAUSE)
    {
      if (FlxG.sound.music != null)
      {
        FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.8);
        FlxTween.tween(FlxG.sound.music, {pitch: 3}, 0.1,
          {
            onComplete: _ -> {
              FlxTween.tween(FlxG.sound.music, {pitch: 0.5}, 0.4);
            }
          });
      }

      // Determining the target state(s) to go to.
      // Default to main menu because that's better than `null`.
      var targetState:flixel.FlxState = new MainMenuState(); //TODO Why do we create a state here???
      var shouldTween = false;
      var shouldUseSubstate = false;

      if (params.storyMode)
      {
        FlxG.sound.pause(); //? fix sound
        //TODO re-enable this
        // if (PlayerRegistry.instance.hasNewCharacter())
        // {
        //   // New character, display the notif.
        //   targetState = new StoryMenuState(null);

        //   var newCharacters = PlayerRegistry.instance.listNewCharacters();

        //   for (charId in newCharacters)
        //   {
        //     shouldTween = true;
        //     // This works recursively, ehe!
        //     targetState = new funkin.ui.charSelect.CharacterUnlockState(charId, targetState);
        //   }
        // }
        // else
        // {
          // No new characters.
          shouldTween = false;
          shouldUseSubstate = true;
          targetState = new StickerSubState(null, (sticker) -> new StoryMenuState(sticker));
        //}
      }
      else
      {
        if (rank > params.prevScoreRank) //? refactor this???
        {
          trace('THE RANK IS Higher.....');

          shouldTween = true;
          controls.isInSubstate = FlxTransitionableState.skipNextTransOut = true;
          targetState = FreeplayState.build(
            {
              {
                fromResults:
                  {
                    oldRank: params.prevScoreRank,
                    newRank: rank,
                    songId: params.songId,
                    difficultyId: params.difficultyId,
                    playRankAnim: true
                  }
              }
            });
        }
        else
        {
          FlxG.sound.pause(); //? fix sound
          shouldTween = false;
          controls.isInSubstate = shouldUseSubstate = true;
          targetState = new StickerSubState(null, (sticker) -> FreeplayState.build(null, sticker));
        }
      }

      if (shouldTween)
      {
        FlxTween.tween(rankBg, {alpha: 1}, 0.5,
          {
            ease: FlxEase.expoOut,
            onComplete: function(_) {
              if (shouldUseSubstate && targetState is FlxSubState)
              {
                openSubState(cast targetState);
              }
              else
              {
                FlxG.sound.pause(); //? fix sound
                FlxG.switchState(targetState);
              }
            }
          });
      }
      else
      {
        if (shouldUseSubstate && targetState is FlxSubState)
        {
          openSubState(cast targetState);
        }
        else
        {
          FlxG.switchState(targetState);
        }
      }
    }

    super.update(elapsed);
  }
}

typedef ResultsStateParams =
{
  /**
   * True if results are for a level, false if results are for a single song.
   */
  var storyMode:Bool;

  /**
   * Either "Song Name by Artist Name" or "Week Name"
   */
  var title:String;

  var songId:String;

  /**
   * The character ID for the song we just played.
   * @default `bf`
   */
   var ?characterId:String;

  /**
   * Whether the displayed score is a new highscore
   */
  var ?isNewHighscore:Bool;

  /**
   * The difficulty ID of the song/week we just played.
   * @default Normal
   */
  var ?difficultyId:String;

  /**
   * The score, accuracy, and judgements.
   */
  var scoreData:SaveScoreData;

  /**
   * The previous score data, used for rank comparision.
   */
  var prevScoreRank:ScoringRank; //? Added this field
};
