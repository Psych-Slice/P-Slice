package mikolka.vslice;

#if html5
import funkin.graphics.video.FlxVideo;
#else
import mikolka.compatibility.ModsHelper;
#if hxCodec
import hxcodec.flixel.FlxVideoSprite;
#else
import hxvlc.flixel.FlxVideoSprite;
#end
using mikolka.funkin.utils.ArrayTools;
#end

/**
 * After about 2 minutes of inactivity on the title screen,
 * the game will enter the Attract state, as a reference to physical arcade machines.
 *
 * In the current version, this just plays the ~~Kickstarter trailer~~ Erect teaser, but this can be changed to
 * gameplay footage, a generic game trailer, or something more elaborate.
 */
class AttractState extends MusicBeatSubstate
{
  #if html5
  var ATTRACT_VIDEO_PATH:String = Paths.video("commercials/"+FlxG.random.getObject([
    'toyCommercial',
    'kickstarterTrailer',
    'erectSamplers'
  ]));
  #else
   var ATTRACT_VIDEO_PATH:String = '';
  #end

  public function new(video:String = null) {
    if(video != null) ATTRACT_VIDEO_PATH = video;
    super();
  }
  public override function create():Void
  {
    // Pause existing music.
    if (FlxG.sound.music != null)
    {
      FlxG.sound.music.destroy();
      FlxG.sound.music = null;
    }

    #if html5
    trace('Playing web video ${ATTRACT_VIDEO_PATH}');
    playVideoHTML5(ATTRACT_VIDEO_PATH);
    #end

    #if (hxvlc || hxCodec)
    if (ATTRACT_VIDEO_PATH == '') ATTRACT_VIDEO_PATH = ModsHelper.collectVideos();
    trace('Playing native video ${ATTRACT_VIDEO_PATH}');
    playVideoNative(ATTRACT_VIDEO_PATH);
    #end
  }

  #if html5
  var vid:FlxVideo;

  function playVideoHTML5(filePath:String):Void
  {
    // Video displays OVER the FlxState.
    vid = new FlxVideo(filePath);
    if (vid != null)
    {
      vid.zIndex = 0;

      vid.finishCallback = onAttractEnd;

      add(vid);
    }
    else
    {
      trace('ALERT: Video is null! Could not play cutscene!');
    }
  }
  #end

  #if VIDEOS_ALLOWED
  var vid:FlxVideoSprite;

  function playVideoNative(filePath:String):Void
  {
    // Video displays OVER the FlxState.
    vid = new FlxVideoSprite(0, 0);

    if (vid != null)
    {
      //vid.zIndex = 0;
      vid.bitmap.onEndReached.add(onAttractEnd);

      #if hxvlc
      vid.bitmap.onFormatSetup.add(function()
      #else
      vid.bitmap.onTextureSetup.add(function()
      #end
        {
          vid.setGraphicSize(FlxG.width);
          vid.updateHitbox();
          vid.screenCenter();
        });

      add(vid);
      #if hxvlc
      vid.load(filePath, null);
      vid.play();
      #else
      vid.play(filePath, false);
      #end
    }
    else
    {
      trace('ALERT: Video is null! Could not play cutscene!');
    }
  }
  #end

  public override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    // If the user presses any button, skip the video.
    #if LEGACY_PSYCH
    if (TouchUtil.justPressed || FlxG.keys.justPressed.ANY && 
      !FlxG.keys.anyJustPressed(TitleState.muteKeys) && 
      !FlxG.keys.anyJustPressed(TitleState.volumeDownKeys) && 
      !FlxG.keys.anyJustPressed(TitleState.volumeUpKeys))
    #else
    if (TouchUtil.justPressed || FlxG.keys.justPressed.ANY && !controls.justPressed("volume_up") && !controls.justPressed("volume_down") && !controls.justPressed("volume_mute"))
    #end
    {
      onAttractEnd();
    }
  }

  /**
   * When the attraction state ends (after the video ends or the user presses any button),
   * switch immediately to the title screen.
   */
  function onAttractEnd():Void
  {
    #if html5
    if (vid != null)
    {
      remove(vid);
    }
    #end

    #if (hxvlc || hxCodec)
    if (vid != null)
      {
        vid.stop();
        remove(vid);
      }
    #end

    #if (html5 || hxCodec)
    vid.destroy();
    vid = null;
    #end
    if(FlxG.state.subState == this){
      close();
    }
    else{
      FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
      #if LEGACY_PSYCH
      FlxG.switchState(new TitleState());
      #else
      FlxG.switchState(() -> new states.TitleState());
      #end
    }
  }
}
