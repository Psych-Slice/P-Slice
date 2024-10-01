package funkin.data.freeplay.album;

class AlbumRegistry extends PsliceRegistry
{

  public static final instance:AlbumRegistry = new AlbumRegistry();

  public function new()
  {
    super('albums');
  }

  /**
   * Read, parse, and validate the JSON data and produce the corresponding data object.
   * @param id The ID of the entry to load.
   * @return The parsed data object.
   */
  public function parseEntryData(id:String):Null<AlbumData>
  {
    
  }

}
