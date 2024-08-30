package;


import flixel.FlxG;

#if html5
import funkin.graphics.video.FlxVideo;
#end

#if hxCodec
import hxcodec.flixel.FlxVideoSprite;
import sys.FileSystem;

using funkin.ArrayTools;
using StringTools;
#end


/**
 * After about 2 minutes of inactivity on the title screen,
 * the game will enter the Attract state, as a reference to physical arcade machines.
 *
 * In the current version, this just plays the ~~Kickstarter trailer~~ Erect teaser, but this can be changed to
 * gameplay footage, a generic game trailer, or something more elaborate.
 */
class AttractState extends MusicBeatState
{
  #if html5
  static final ATTRACT_VIDEO_PATH:String = Paths.video("commercials/"+FlxG.random.getObject([
    'toyCommercial',
    'kickstarterTrailer',
    'erectSamplers'
  ]));
  #else
  private static function collectVideos():String{
    var dirsToList = new Array<String>();
    dirsToList.push('assets/videos/commercials/');
    if(FileSystem.exists('mods/videos/commercials'))dirsToList.push('mods/videos/commercials/');
    WeekData.loadTheFirstEnabledMod();
    var modsToSearch = Paths.getGlobalMods();
    modsToSearch.pushUnique(Paths.currentModDirectory);
    modsToSearch = modsToSearch.filter(s -> FileSystem.exists('mods/$s/videos/commercials')).map(s -> 'mods/$s/videos/commercials');
    
    dirsToList = dirsToList.concat(modsToSearch);
    var commercialsToSelect = new Array<String>();
    for(potencialComercials in dirsToList){
      for (file in FileSystem.readDirectory(potencialComercials).filter(s -> s.endsWith(".mp4"))) {
        commercialsToSelect.push(potencialComercials + '/'+file);
      }
    }
    return FlxG.random.getObject(commercialsToSelect);
  }

  static var ATTRACT_VIDEO_PATH:String = '';
  #end

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


    #if hxCodec
    ATTRACT_VIDEO_PATH = collectVideos();
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

  #if hxCodec
  var vid:FlxVideoSprite;

  function playVideoNative(filePath:String):Void
  {
    // Video displays OVER the FlxState.
    vid = new FlxVideoSprite(0, 0);

    if (vid != null)
    {
      //vid.zIndex = 0;
      vid.bitmap.onEndReached.add(onAttractEnd);

      add(vid);
      vid.play(filePath, false);
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
    if (FlxG.keys.justPressed.ANY && 
        !FlxG.keys.anyJustPressed(TitleState.muteKeys) && 
        !FlxG.keys.anyJustPressed(TitleState.volumeDownKeys) && 
        !FlxG.keys.anyJustPressed(TitleState.volumeUpKeys))
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

    #if hxCodec
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
    FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.8);
    FlxG.switchState(new TitleState());
  }
}
