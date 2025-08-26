

package mobile.backend;

import lime.system.System as LimeSystem;
import haxe.io.Path;
import haxe.Exception;
import sys.FileSystem;

/**
 * A storage class for mobile.
 * @author Karim Akra and Lily Ross (mcagabe19)
 * @author Mikolka9144
 */
class StorageUtil
{
	#if sys
	// root directory, used for handling the saved storage type and path
	private static final rootDir:String = LimeSystem.applicationStorageDirectory;

	public static function getStorageDirectory(?force:Bool = false):String
	{
		var daPath:String = '';
		#if android
		if (!FileSystem.exists(rootDir + 'storagetype.txt'))
			File.saveContent(rootDir + 'storagetype.txt', ClientPrefs.data.storageType);
		var curStorageType:String = File.getContent(rootDir + 'storagetype.txt');
		if(curStorageType == "EXTERNAL_DATA"){
			curStorageType = "INTERNAL";
			ClientPrefs.data.storageType = "INTERNAL";
		}
		daPath = force ? StorageType.fromStrForce(curStorageType) : StorageType.fromStr(curStorageType);
		daPath = Path.addTrailingSlash(daPath);
		#elseif ios
		daPath = LimeSystem.documentsDirectory;
		#else
		daPath = Sys.getCwd();
		#end
		return daPath;
	}

	public static function saveContent(fileName:String, fileData:String, ?alert:Bool = true):Void
	{
		try
		{
			if (!FileSystem.exists('saves'))
				FileSystem.createDirectory('saves');

			File.saveContent('saves/$fileName', fileData);
			if (alert)
				CoolUtil.showPopUp('$fileName has been saved.', "Success!");
		}
		catch (e:Exception)
			if (alert)
				CoolUtil.showPopUp('$fileName couldn\'t be saved.\n(${e.message})', "Error!")
			else
				trace('$fileName couldn\'t be saved. (${e.message})');
	}

	#if android
	public static function requestPermissions():Void
	{
		var requiresUserPermissions = AndroidVersion.SDK_INT >= AndroidVersionCode.M;
		if(requiresUserPermissions) checkUserStoragePermissions();
		else trace("We are on Lolipop?? No need to beg for permissions then");

		trace("Checking game directory...");
		try
		{
			if (!FileSystem.exists(StorageUtil.getStorageDirectory()))
				FileSystem.createDirectory(StorageUtil.getStorageDirectory());
		}
		catch (e:Exception)
		{
			trace(e);
			CoolUtil.showPopUp(e.message+'\nPlease create directory to\n' + StorageUtil.getStorageDirectory(true) + '\nPress OK to close the game', 'Error!');
			//LimeSystem.exit(1);
		}
	}

	public static function checkUserStoragePermissions() {
		var isAPI33 = AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU;
		trace("Check perms...");

		if (!isAPI33){
			trace("Requesting EXTERNAL_STORAGE");
			AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);
		}

		if (!AndroidEnvironment.isExternalStorageManager())
		{
			// if (AndroidVersion.SDK_INT >= AndroidVersionCode.S)
			// 	AndroidSettings.requestSetting('REQUEST_MANAGE_MEDIA');
			AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		}
		var has_MANAGE_EXTERNAL_STORAGE = AndroidEnvironment.isExternalStorageManager();
		var has_READ_EXTERNAL_STORAGE = AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE');
		//var has_READ_MEDIA_IMAGES = AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_MEDIA_IMAGES');
		if ((isAPI33 && !has_MANAGE_EXTERNAL_STORAGE)
			|| (!isAPI33 && !has_READ_EXTERNAL_STORAGE))
			CoolUtil.showPopUp('If you accepted the permissions you are all good!' + '\nIf you didn\'t then expect a crash' + '\nPress OK to see what happens',
				'Notice!');
	}

	public static function checkExternalPaths(?splitStorage = false):Array<String>
	{
		var process = new Process('grep -o "/storage/....-...." /proc/mounts | paste -sd \',\'');
		var paths:String = process.stdout.readAll().toString();
		if (splitStorage)
			paths = paths.replace('/storage/', '');
		return paths.split(',');
	}

	public static function getExternalDirectory(externalDir:String):String
	{
		var daPath:String = '';
		for (path in checkExternalPaths())
			if (path.contains(externalDir))
				daPath = path;

		daPath = Path.addTrailingSlash(daPath.endsWith("\n") ? daPath.substr(0, daPath.length - 1) : daPath);
		return daPath;
	}
	#end
	#end
}

#if android
@:runtimeValue
enum abstract StorageType(String) from String to String
{
	final forcedPath = '/storage/emulated/0/';
	final packageNameLocal = 'com.mikolka9144.pslice';
	final fileLocal = 'PSliceEngine';

	var INTERNAL = "INTERNAL";
	var EXTERNAL = "EXTERNAL";

	public static function fromStr(str:String):StorageType
	{
		try{
			return switch (str)
			{
				case "INTERNAL": 
					final INTERNAL = AndroidContext.getExternalFilesDir();
					INTERNAL;
				case "EXTERNAL": 
					final EXTERNAL = AndroidEnvironment.getExternalStorageDirectory() + '/.' + lime.app.Application.current.meta.get('file');
					EXTERNAL;
				default: StorageUtil.getExternalDirectory(str) + '.' + fileLocal;
			}
		}
		catch(x:Exception){
			trace("Failed to read storage. Forcing paths!");
			trace(x);
			return fromStrForce(str);
		}
	}

	public static function fromStrForce(str:String):StorageType
	{
		final INTERNAL = forcedPath + 'Android/data/' + packageNameLocal + '/files';
		final EXTERNAL = forcedPath + '.' + fileLocal;

		return switch (str)
		{
			case "INTERNAL": INTERNAL;
			case "EXTERNAL": EXTERNAL;
			default: StorageUtil.getExternalDirectory(str) + '.' + fileLocal;
		}
	}
}
#end
