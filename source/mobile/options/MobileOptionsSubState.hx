package mobile.options;

import mobile.backend.MobileScaleMode;
import flixel.input.keyboard.FlxKey;
import options.BaseOptionsMenu;
import options.Option;

class MobileOptionsSubState extends BaseOptionsMenu
{
	#if android
	var storageTypes:Array<String> = ["EXTERNAL_DATA", "EXTERNAL_OBB", "EXTERNAL_MEDIA", "EXTERNAL"];
	var externalPaths:Array<String> = StorageUtil.checkExternalPaths(true);
	final lastStorageType:String = ClientPrefs.data.storageType;
	#end
	final exControlTypes:Array<String> = ["NONE", "SINGLE", "DOUBLE"];
	final hintOptions:Array<String> = ["Gradient", "No Gradient", "Hidden"];
	var option:Option;

	public function new()
	{
		#if android if (!externalPaths.contains('\n'))
			storageTypes = storageTypes.concat(externalPaths); #end
		title = 'Mobile Options';
		rpcTitle = 'Mobile Options Menu'; // for Discord Rich Presence, fuck it

		option = new Option('Extra Controls', 'Select how many extra buttons you prefere to have\nThey can be used for mechanics with LUA or HScript.',
			'extraButtons', STRING, exControlTypes);
		addOption(option);

		option = new Option('Mobile Controls Opacity',
			'Selects the opacity for the mobile buttons (carefull not to put it at 0 and loose track of your buttons).', 'controlsAlpha', PERCENT);
		option.scrollSpeed = 1;
		option.minValue = 0.001;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = () ->
		{
			touchPad.alpha = curOption.getValue();
			ClientPrefs.toggleVolumeKeys();
		};
		addOption(option);

		#if mobile
		option = new Option('Allow Phone Screensaver',
			'If checked, the phone will sleep after going inactive for few seconds.\n(The time depends on your phone\'s options)', 'screensaver', BOOL);
		option.onChange = () -> lime.system.System.allowScreenTimeout = curOption.getValue();
		addOption(option);

		option = new Option('Wide Screen Mode',
			'If checked, The game will stetch to fill your whole screen. (WARNING: Can result in bad visuals & break some mods that resizes the game/cameras)',
			'wideScreen', BOOL);
		option.onChange = () -> FlxG.scaleMode = new MobileScaleMode();
		addOption(option);
		#end

		if (MobileData.mode == 3)
		{
			option = new Option('Hitbox Design', 'Choose how your hitbox should look like.', 'hitboxType', STRING, hintOptions);
			addOption(option);

			option = new Option('Hitbox Position', 'If checked, the hitbox will be put at the bottom of the screen, otherwise will stay at the top.',
				'hitbox2', BOOL);
			addOption(option);
		}

		option = new Option('Dynamic Controls Color',
			'If checked, the mobile controls color will be set to the notes color in your settings.\n(have effect during gameplay only)', 'dynamicColors',
			BOOL);
		addOption(option);

		#if android
		option = new Option('Storage Type', 'Which folder Psych Engine should use?\n(CHANGING THIS MAKES DELETE YOUR OLD FOLDER!!)', 'storageType', STRING,
			storageTypes);
		addOption(option);
		#end

		super();
	}

	#if android
	function onStorageChange():Void
	{
		File.saveContent(lime.system.System.applicationStorageDirectory + 'storagetype.txt', ClientPrefs.data.storageType);

		var lastStoragePath:String = StorageType.fromStrForce(lastStorageType) + '/';

		try
		{
			Sys.command('rm', ['-rf', lastStoragePath]);
		}
		catch (e:haxe.Exception)
			trace('Failed to remove last directory. (${e.message})');
	}
	#end

	override public function destroy()
	{
		super.destroy();
		#if android
		if (ClientPrefs.data.storageType != lastStorageType)
		{
			onStorageChange();
			CoolUtil.showPopUp('Storage Type has been changed and you needed restart the game!!\nPress OK to close the game.', 'Notice!');
			lime.system.System.exit(0);
		}
		#end
	}
}
