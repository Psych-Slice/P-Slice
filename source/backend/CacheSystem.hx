package backend;

import openfl.utils.AssetCache;
import flixel.util.FlxStringUtil;
import flixel.system.FlxAssets;
import openfl.media.Sound;
import openfl.Assets;
import haxe.io.Path;
import openfl.display.BitmapData;
import openfl.system.System;
import flixel.graphics.FlxGraphic;

typedef ImageLine =
{
	size:Int,
	text:String
};

@:access(openfl.display.BitmapData)
class CacheSystem
{
	/**
	 * A list of all cached graphics
	 */
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];

	/**
	 * A list of cached sounds
	 */
	public static var currentTrackedSounds:Map<String, Sound> = [];

	/**
	 * define the locally tracked assets
	 * Those assets are used in the current context.
	**/
	public static var localTrackedAssets:Array<String> = [];

	/**
	 * A global list of assets to exclude from memory purges.
	 * Effectively, they stay loaded forever.
	 */
	public static var dumpExclusions:Array<String> = ['music/freakyMenu.${Paths.SOUND_EXT}'];

	public static function excludeAsset(key:String)
	{
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	/**
	 * Removes every graphic and sound not contained in the local context.
	 * This means, that if you've requested any cached assets in this context,
	 * they won't be purged.
	 */
	public static function clearUnusedMemory()
	{
				// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys())
		{
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				destroyGraphic(currentTrackedAssets.get(key)); // get rid of the graphic
				currentTrackedAssets.remove(key); // and remove the key from local cache map
			}
		}
		// clear all sounds that are cached
		for (key => asset in currentTrackedSounds)
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && asset != null)
			{
				Assets.cache.clear(key);
				var snd = currentTrackedSounds.get(key);
				currentTrackedSounds.remove(key);
				// @:privateAccess(){
				// 	snd.__buffer.data.buffer.b.clear();
				// 	snd.__buffer.data.buffer = null;
				// 	snd.__buffer = null;
				// }
			}
		}

		System.gc();
	}

	#if debug
	public static function cacheStatus():String
	{
		var str = new StringBuf();
		str.add('-- Cache dump start --');
		str.add("\n");
		str.add('( openfl caches are ${openfl.utils.Assets.cache.enabled})');
		str.add("\n");
		var totalMemory = 0;

		str.add("-- Managed bitmaps --");
		str.add("\n");
		var entries:Array<ImageLine> = [];
		@:privateAccess
		for (key => texture in FlxG.bitmap._cache)
		{
			var inStored = currentTrackedAssets.exists(key) ? "S" : "-";
			var inLocal = localTrackedAssets.contains(key) ? "L" : "-";
			var memory = texture?.bitmap?.image?.data?.byteLength ?? 0;
			entries.push({
				size: memory,
				text: '[ $inStored $inLocal ](${FlxStringUtil.formatBytes(memory)}) $key'
			});
			totalMemory += memory;
		}
		entries.sort((x, y) -> cast y.size - x.size);
		for (entry in entries)
		{
			str.add(entry.text);
			str.add("\n");
		}
		str.add('Total: ${FlxStringUtil.formatBytes(totalMemory)}');
		str.add("\n");

		str.add("-- Managed sounds --");
		str.add("\n");
		totalMemory = 0;
		@:privateAccess
		for (key => snd in currentTrackedSounds)
		{
			var inLocal = localTrackedAssets.contains(key) ? "L" : "-";
			var memory = snd.bytesLoaded;
			str.add('[ $inLocal ](${FlxStringUtil.formatBytes(memory)}}/${FlxStringUtil.formatBytes(snd.bytesTotal)}) $key');
			str.add("\n");
			totalMemory += memory;
		}
		str.add('Total: ${FlxStringUtil.formatBytes(totalMemory)}');
		str.add("\n");

		str.add("-- OPENFL sounds --");
		str.add("\n");
		totalMemory = 0;
		@:privateAccess
		for (key => snd in currentTrackedSounds)
		{
			var memory = snd.__buffer.data.length;
			str.add(' (${FlxStringUtil.formatBytes(memory)}) $key');
			str.add("\n");
			totalMemory += memory;
		}
		str.add('Total: ${FlxStringUtil.formatBytes(totalMemory)}');
		str.add("\n");

		str.add("-- END --");
		return str.toString();
	}
	#end

	/**
	 * Clears up internal remnants of graphics not cached by this system.
	 * It also clears the current context.
	 * 
	 * This means that the next ``clearUnusedMemory`` call will purge them
	 * (unless you load them from cache before that)
	 */
	@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
	public static function clearStoredMemory()
	{
		// clear anything not in the tracked assets list
		for (key in FlxG.bitmap._cache.keys())
		{
			if (!currentTrackedAssets.exists(key) && !dumpExclusions.contains(key)){

				destroyGraphic(FlxG.bitmap.get(key));
				
			}
		}

		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		#if !html5 openfl.Assets.cache.clear("songs"); #end
	}

	public static function loadBitmap(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxGraphic
	{
		if (currentTrackedAssets.exists(key))
		{
			localTrackedAssets.push(key);
			return currentTrackedAssets.get(key);
		}
		var bitmap = __loadBitmap(key, parentFolder);
		return cacheBitmap(key, bitmap, allowGPU);
	}

	public static function cacheBitmap(key:String, bitmap:BitmapData, ?allowGPU:Bool = true):FlxGraphic
	{
		if (bitmap == null)
			return null;
		if (allowGPU && ClientPrefs.data.cacheOnGPU && bitmap?.image != null)
		{
			bitmap.lock(); // This does nothing on cpp
			if (bitmap.__texture == null)
			{
				bitmap.image.premultiplied = true;
				bitmap.getTexture(FlxG.stage.context3D);
			}
			#if ATSC_SUPPORT
			if (!Std.isOfType(bitmap.__texture, openfl.display3D.textures.ASTCTexture))
			{
			#end

				bitmap.getSurface();
				bitmap.disposeImage();
				bitmap.image.data = null;
				bitmap.image = null;
				bitmap.readable = true;

			#if ATSC_SUPPORT
			}
			#end
		}

		var graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
		graph.persist = true;
		graph.destroyOnNoUse = false;

		currentTrackedAssets.set(key, graph);
		localTrackedAssets.push(key);
		return graph;
	}

	/**
		 * Loads and caches a sound from the given path.
		 * @param file 
		 * @param requestName 
		 * @return Sound
		 */
	public static function loadSound(file:String, ?beepOnNull:Bool = true, requestName:String = ""):Sound
	{
		// trace('precaching sound: $file');
		if (!currentTrackedSounds.exists(file))
		{
			var isTrackingSound = false;
			var sound = NativeFileSystem.getSound(file);
			if (sound != null)
			{
				currentTrackedSounds.set(file, sound);
				isTrackingSound = true;
			}
			else if (beepOnNull && !isTrackingSound)
			{
				trace('SOUND NOT FOUND: $requestName');
				return FlxAssets.getSound('flixel/sounds/beep');
			}
		}
		localTrackedAssets.push(file);
		return currentTrackedSounds.get(file);
	}

	/**
		 * I believe this ose is used to clear graphics cache while preserving graphics used by
		 * the current state.
		 */
	public static function freeGraphicsFromMemory()
	{
		var protectedGfx:Array<FlxGraphic> = [];
		function checkForGraphics(spr:Dynamic)
		{
			try
			{
				var grp:Array<Dynamic> = Reflect.getProperty(spr, 'members');
				if (grp != null)
				{
					// trace('is actually a group');
					for (member in grp)
					{
						checkForGraphics(member);
					}
					return;
				}
			}

			try
			{
				var gfx:FlxGraphic = Reflect.getProperty(spr, 'graphic');
				if (gfx != null)
				{
					protectedGfx.push(gfx);
					// trace('gfx added to the list successfully!');
				}
			}
			// catch(haxe.Exception) {}
		}

		for (member in FlxG.state.members)
			checkForGraphics(member);

		if (FlxG.state.subState != null)
			for (member in FlxG.state.subState.members)
				checkForGraphics(member);

		for (key in currentTrackedAssets.keys())
		{
			// if it is not currently contained within the used local assets
			if (!dumpExclusions.contains(key))
			{
				var graphic:FlxGraphic = currentTrackedAssets.get(key);
				if (!protectedGfx.contains(graphic))
				{
					destroyGraphic(graphic); // get rid of the graphic
					currentTrackedAssets.remove(key); // and remove the key from local cache map
					// trace('deleted $key');
				}
			}
		}
	}

	/**
		 * Destroys a given graphic. Make sure to dereference it as well to avoid any issues.
		 * @param graphic 
		 */
	private inline static function destroyGraphic(graphic:FlxGraphic)
	{
		// free some gpu memory
		if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null)
		graphic.bitmap.__texture.dispose();
		FlxG.bitmap.remove(graphic);
	}

	private inline static function __loadBitmap(key:String, ?parentFolder:String = null):BitmapData
	{
		// A ton of stuff uses .png internally, so we fake it for ATSC
		var intarnalFile = Path.withoutExtension(key);
		var file:String = getTexturePath(intarnalFile, parentFolder);
		var bitmap = NativeFileSystem.getBitmap(file);
		if (bitmap == null)
		{
			trace('Bitmap not found: $file | key: $key');
		}

		return bitmap;
	}

	/**
		 * Finds a graphic in the given path. Can give either PNG or ASTC file path.
		 * @param file 
		 * @param parentfolder 
		 * @return String
		 */
	private static function getTexturePath(file:String, ?parentfolder:String):String
	{
		function astcGetSharedPath(path:String)
		{
			#if ATSC_SUPPORT
			if (Native.isASTCSupported())
			{
				var assetPath = Paths.getSharedPath('$path.astc');
				if (NativeFileSystem.exists(assetPath))
					return assetPath;
			}
			#end
			return Paths.getSharedPath('$path.png');
		}

		function astcGetFolderPath(file:String, folder:String)
		{
			#if ATSC_SUPPORT
			if (Native.isASTCSupported())
			{
				var assetPath = Paths.getFolderPath('$file.astc', folder);
				if (NativeFileSystem.exists(assetPath))
					return assetPath;
			}
			#end
			return Paths.getFolderPath('$file.png', folder);
		}
		#if MODS_ALLOWED
		
		function astcModFolders(path:String)
		{
			#if ATSC_SUPPORT
			if (Native.isASTCSupported())
			{
				var assetPath = Paths.modFolders('$path.astc');
				if (NativeFileSystem.exists(assetPath))
					return assetPath;
			}
			#end
			return Paths.modFolders('$path.png');
		}

		var customFile:String = file;
		if (parentfolder != null)
			customFile = '$parentfolder/$file';

		// Load from level folder in a mod
		if (Paths.currentLevel != null && Paths.currentLevel != 'shared')
		{
			var levelPath = astcModFolders('${Paths.currentLevel}/$customFile');
			if (NativeFileSystem.exists(levelPath))
				return levelPath;
		}

		var modded:String = astcModFolders(customFile);
		if (NativeFileSystem.exists(modded))
			return modded;
		#end
		if (parentfolder == "mobile")
			return astcGetSharedPath('mobile/$file');

		if (parentfolder != null)
			return astcGetFolderPath(file, parentfolder);

		// Load from a level folder
		if (Paths.currentLevel != null && Paths.currentLevel != 'shared')
		{
			var levelPath = astcGetFolderPath(file, Paths.currentLevel);
			if (NativeFileSystem.exists(levelPath))
				return levelPath;
		}
		return astcGetSharedPath(file);
	}
}
