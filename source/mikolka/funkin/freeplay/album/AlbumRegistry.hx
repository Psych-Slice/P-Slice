package mikolka.funkin.freeplay.album;

import mikolka.funkin.freeplay.album.AlbumData;
using mikolka.funkin.custom.FunkinTools;

class AlbumRegistry extends PsliceRegistry
{

  public static final instance:AlbumRegistry = new AlbumRegistry();

  public function new()
  {
    super('ui/freeplay/albums');
  }

  public function fetchEntry(albumId:Null<String>):Album {
    var data = readJson(albumId);
    var album_data = new AlbumData();
    album_data.mergeWithJson(data);
    return new Album(albumId,album_data);
  }
}
