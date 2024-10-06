package mobile.states;

#if mobile
import states.TitleState;
import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets as OpenFLAssets;
import flixel.addons.util.FlxAsyncLoop;
import openfl.utils.ByteArray;
import haxe.io.Path;

/**
 * ...
 * @author: Karim Akra
 */
class CopyState extends MusicBeatState
{
	private static final textFilesExtensions:Array<String> = ['ini', 'txt', 'xml', 'hxs', 'hx', 'lua', 'json', 'frag', 'vert'];
	public static final IGNORE_FOLDER_FILE_NAME:String = "ignore.txt";
	private static var directoriesToIgnore:Array<String> = [];
	public static var locatedFiles:Array<String> = [];
	public static var maxLoopTimes:Int = 0;

	public var loadingImage:FlxSprite;
	public var bottomBG:FlxSprite;
	public var loadedText:FlxText;
	public var copyLoop:FlxAsyncLoop;

	var failedFilesStack:Array<String> = [];
	var failedFiles:Array<String> = [];
	var shouldCopy:Bool = false;
	var canUpdate:Bool = true;
	var loopTimes:Int = 0;

	override function create()
	{
		locatedFiles = [];
		maxLoopTimes = 0;
		checkExistingFiles();
		if (maxLoopTimes <= 0)
		{
			MusicBeatState.switchState(new TitleState());
			return;
		}

		#if (!ios || !iphoneos || !iphonesim)
		CoolUtil.showPopUp("Seems like you have some missing files that are necessary to run the game\nPress OK to begin the copy process", "Notice!");
		#end

		shouldCopy = true;

		add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d));

		loadingImage = new FlxSprite(0, 0, Paths.image('funkay'));
		loadingImage.setGraphicSize(0, FlxG.height);
		loadingImage.updateHitbox();
		loadingImage.screenCenter();
		add(loadingImage);

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		loadedText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, '', 16);
		loadedText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		add(loadedText);

		var ticks:Int = 15;
		if (maxLoopTimes <= 15)
			ticks = 1;

		copyLoop = new FlxAsyncLoop(maxLoopTimes, copyAsset, ticks);
		add(copyLoop);
		copyLoop.start();

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (shouldCopy && copyLoop != null)
		{
			if (copyLoop.finished && canUpdate)
			{
				if (failedFiles.length > 0)
				{
					#if (!ios || !iphoneos || !iphonesim)
					CoolUtil.showPopUp(failedFiles.join('\n'), 'Failed To Copy ${failedFiles.length} File.');
					#end
					if (!FileSystem.exists('logs'))
						FileSystem.createDirectory('logs');
					File.saveContent('logs/' + Date.now().toString().replace(' ', '-').replace(':', "'") + '-CopyState' + '.txt', failedFilesStack.join('\n'));
				}
				canUpdate = false;
				FlxG.sound.play(Paths.sound('confirmMenu')).onComplete = () ->
				{
					MusicBeatState.switchState(new TitleState());
				};
			}

			if (maxLoopTimes == 0)
				loadedText.text = "Completed!";
			else
				loadedText.text = '$loopTimes/$maxLoopTimes';
		}
		super.update(elapsed);
	}

	public function copyAsset()
	{
		var file = locatedFiles[loopTimes];
		loopTimes++;
		if (!FileSystem.exists(file))
		{
			var directory = Path.directory(file);
			if (!FileSystem.exists(directory))
				StorageUtil.createDirectories(directory);
			try
			{
				if (OpenFLAssets.exists(getFile(file)))
				{
					if (textFilesExtensions.contains(Path.extension(file)))
						createContentFromInternal(file);
					else
						File.saveBytes(file, getFileBytes(getFile(file)));
				}
				else
				{
					failedFiles.push(getFile(file) + " (File Dosen't Exist)");
					failedFilesStack.push('Asset ${getFile(file)} does not exist.');
				}
			}
			catch (e:haxe.Exception)
			{
				failedFiles.push('${getFile(file)} (${e.message})');
				failedFilesStack.push('${getFile(file)} (${e.stack})');
			}
		}
	}

	public function createContentFromInternal(file:String)
	{
		var fileName = Path.withoutDirectory(file);
		var directory = Path.directory(file);
		try
		{
			var fileData:String = OpenFLAssets.getText(getFile(file));
			if (fileData == null)
				fileData = '';
			if (!FileSystem.exists(directory))
				StorageUtil.createDirectories(directory);
			File.saveContent(Path.join([directory, fileName]), fileData);
		}
		catch (e:haxe.Exception)
		{
			failedFiles.push('${getFile(file)} (${e.message})');
			failedFilesStack.push('${getFile(file)} (${e.stack})');
		}
	}

	public function getFileBytes(file:String):ByteArray
	{
		switch (Path.extension(file))
		{
			case 'otf' | 'ttf':
				return ByteArray.fromFile(file);
			default:
				return OpenFLAssets.getBytes(file);
		}
	}

	public static function getFile(file:String):String
	{
		if (OpenFLAssets.exists(file))
			return file;

		@:privateAccess
		for (library in LimeAssets.libraries.keys())
		{
			if (OpenFLAssets.exists('$library:$file') && library != 'default')
				return '$library:$file';
		}

		return file;
	}

	public static function checkExistingFiles():Bool
	{
		locatedFiles = OpenFLAssets.list();

		// removes unwanted assets
		var assets = locatedFiles.filter(folder -> folder.startsWith('assets/'));
		var mods = locatedFiles.filter(folder -> folder.startsWith('mods/'));
		locatedFiles = assets.concat(mods);
		locatedFiles = locatedFiles.filter(file -> !FileSystem.exists(file));

		var filesToRemove:Array<String> = [];

		for (file in locatedFiles)
		{
			if (filesToRemove.contains(file))
				continue;

			if(file.endsWith(IGNORE_FOLDER_FILE_NAME) && !directoriesToIgnore.contains(Path.directory(file)))
				directoriesToIgnore.push(Path.directory(file));

			if (directoriesToIgnore.length > 0)
			{
				for (directory in directoriesToIgnore)
				{
					if (file.startsWith(directory))
						filesToRemove.push(file);
				}
			}
		}

		locatedFiles = locatedFiles.filter(file -> !filesToRemove.contains(file));

		maxLoopTimes = locatedFiles.length;

		return (maxLoopTimes <= 0);
	}
}
#end
