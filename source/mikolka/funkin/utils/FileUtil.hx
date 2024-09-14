package mikolka.funkin.utils;

import haxe.io.Path;
import lime.utils.Bytes;

class FileUtil
{
	/**
	 * Create a directory if it doesn't already exist.
	 * Only works on desktop.
	 *
	 * @param dir The path to the directory.
	 */
	public static function createDirIfNotExists(dir:String):Void
	{
		#if sys
		if (!doesFileExist(dir))
		{
			sys.FileSystem.createDirectory(dir);
		}
		#end
	}

	public static function doesFileExist(path:String):Bool
	{
		#if sys
		return sys.FileSystem.exists(path);
		#else
		return false;
		#end
	}
    public static function openFolder(pathFolder:String)
        {
          #if windows
          Sys.command('explorer', [pathFolder]);
          #elseif mac
          // mac could be fuckie with where the log folder is relative to the game file...
          // if this comment is still here... it means it has NOT been verified on mac yet!
          //
          // FileUtil.hx note: this was originally used to open the logs specifically!
          // thats why the above comment is there!
          Sys.command('open', [pathFolder]);
          #elseif linux
          Sys.command('xdg-open', [pathFolder]);
          #end
      
          // TODO: implement linux
          // some shit with xdg-open :thinking: emoji...
        }

        /**
   * Write byte file contents directly to a given path.
   * Only works on desktop.
   *
   * @param path The path to the file.
   * @param data The bytes to write.
   * @param mode Whether to Force, Skip, or Ask to overwrite an existing file.
   */
  public static function writeBytesToPath(path:String, data:Bytes, mode:FileWriteMode = Skip):Void
    {
      #if sys
      createDirIfNotExists(Path.directory(path));
      switch (mode)
      {
        case Force:
          sys.io.File.saveBytes(path, data);
        case Skip:
          if (!doesFileExist(path))
          {
            sys.io.File.saveBytes(path, data);
          }
          else
          {
            // Do nothing.
            // throw 'File already exists: $path';
          }
        case Ask:
          if (doesFileExist(path))
          {
            // TODO: We don't have the technology to use native popups yet.
            throw 'File already exists: $path';
          }
          else
          {
            sys.io.File.saveBytes(path, data);
          }
      }
      #else
      throw 'Direct file writing by path not supported on this platform.';
      #end
    }
}

enum FileWriteMode
{
  /**
   * Forcibly overwrite the file if it already exists.
   */
  Force;

  /**
   * Ask the user if they want to overwrite the file if it already exists.
   */
  Ask;

  /**
   * Skip the file if it already exists.
   */
  Skip;
}
