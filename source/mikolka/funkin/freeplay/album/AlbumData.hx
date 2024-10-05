package mikolka.funkin.freeplay.album;


/**
 * A type definition for the data for an album of songs.
 * It includes things like what graphics to display in Freeplay.
 * @see https://lib.haxe.org/p/json2object/
 */
class AlbumData //? making this a class lets us define some defaults
{
  public function new() {}
  /**
   * Semantic version for album data.
   */
  public var version:String = "1.0";

  /**
   * Readable name of the album.
   */
  public var name:String = "";

  /**
   * Readable name of the artist(s) of the album.
   */
  public var artists:Array<String> = ["Is this even used?"];

  /**
   * Asset key for the album art.
   * The album art will be displayed in Freeplay.
   */
  public var albumArtAsset:String;

  /**
   * Asset key for the album title.
   * The album title will be displayed below the album art in Freeplay.
   */
  public var albumTitleAsset:String;

  /**
   * An optional array of animations for the album title.
   */
  public var albumTitleAnimations:Array<AnimationData> = null;
}
