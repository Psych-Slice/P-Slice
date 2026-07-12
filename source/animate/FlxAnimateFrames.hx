package animate;

import animate.FlxAnimateJson;
import animate.internal.SymbolItem;
import animate.internal.Timeline;
import animate.internal.elements.SymbolInstance;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection.FlxFrameCollectionType;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import haxe.Json;
import haxe.ds.Vector;
import haxe.io.Path;

using StringTools;

/**
 * Settings used when first loading a texture atlas.
 *
 * @param swfMode 			Used if the movieclips of the symbol should render similarly to SWF files. Disabled by default.
 * 							See ``animate.internal.elements.MovieClipInstance`` for more.
 *
 * @param cacheOnLoad		If to cache all necessary filters and masks when the texture atlas is first loaded. Disabled by default.
 *							This setting may be useful for reducing lag on filter heavy atlases. But take into account that
 *							it can also heavily increase loading times.
 *
 * @param filterQuality		Level of compression used to render filters. Set to ``MEDIUM`` by default.
 *							``HIGH`` 	-> Will render filters at their full quality, with no resolution loss.
 *							``MEDIUM`` 	-> Will apply some lossless compression to the filter, most recommended option.
 *							``LOW`` 	-> Will use heavy and easily noticeable compression, use with precausion.
 *							``RUDY``	-> Having your eyes closed probably has better graphics than this.
 *
 * @param onSymbolCreate	An optional callback that gets called when a ``SymbolItem`` is created and added to the library.
 * 							This setting can be used as a intermeddiate point in the Texture Atlas loading process to add
 * 							any custom changes that may want to be applied before any baking is applied to the Texture Atlas.
 */
typedef FlxAnimateSettings =
{
	?swfMode:Bool,
	?cacheOnLoad:Bool,
	?filterQuality:FilterQuality,
	?onSymbolCreate:SymbolItem->Void
}

/**
 * Class used to store all the data needed for texture atlases, such as spritemaps, symbols...
 *
 * Note that this engine does **NOT** convert texture atlases into spritesheets, therefore trying to get
 * frames from a ``FlxAnimateFrames`` will result in getting the limb frames of the spritemap.
 *
 * If you need an actual frame of the texture atlas animation I recommend manually creating it using
 * ``framePixels`` on a ``FlxAnimate``. Though it may cause performance issues, so use with precaution.
 */
class FlxAnimateFrames extends FlxAtlasFrames
{
	// TODO:
	// public var instance:SymbolInstance;
	// public var stageInstance:SymbolInstanceJson;

	/**
	 * The main ``Timeline`` that the Texture Atlas was exported from.
	 */
	public var timeline:Timeline;

	/**
	 * Rectangle with the resolution of the Animate stage background.
	 * Defaults to 1280x720 if the Texture Atlas wasnt exported using BetterTA.
	 */
	public var stageRect:FlxRect;

	/**
	 * Color of the Animate stage background.
	 * Defaults to WHITE if the Texture Atlas wasnt exported using BetterTA.
	 */
	public var stageColor:FlxColor;

	/**
	 * Matrix of the Texture Atlas on the Animate stage.
	 * Defaults to an empty matrix if not exported from an instanced symbol.
	 */
	public var matrix:FlxMatrix; // TODO: to be replaced with library.instance

	/**
	 * Default frame rate that the Texture Atlas was exported from.
	 */
	public var frameRate:Float;

	public function new(graphic:FlxGraphic)
	{
		super(graphic);
		this.dictionary = [];
		this.addedCollections = [];
	}

	/**
	 * Returns a ``SymbolItem`` object contained inside the texture atlas dictionary/library.
	 *
	 * @param name Name of the symbol item to return.
	 * @return ``SymbolItem`` found with the given name, null if not found.
	 */
	public function getSymbol(name:String):Null<SymbolItem>
	{
		if (existsSymbol(name))
			return dictionary.get(name);

		if (_isInlined)
		{
			var sd = _symbolDictionary;
			if (sd != null)
			{
				for (i in 0...sd.length)
				{
					var data = sd[i];
					if (data.SN == name)
					{
						var timeline = new Timeline(data.TL, this, name);
						var symbol = new SymbolItem(timeline);
						dictionary.set(timeline.name, symbol);
						return symbol;
					}
				}
			}
		}
		else
		{
			if (_libraryList.contains(name))
			{
				var data:TimelineJson = Json.parse(getTextFromPath(path + "/LIBRARY/" + name + ".json"));
				var timeline = new Timeline(data, this, name);
				var symbol = new SymbolItem(timeline);
				dictionary.set(timeline.name, symbol);
				return symbol;
			}
		}

		for (collection in addedCollections)
		{
			if (collection.dictionary.exists(name))
				return collection.dictionary.get(name);
		}

		FlxG.log.warn('SymbolItem with name "$name" doesnt exist.');
		return null;
	}

	/**
	 * Returns if a ``SymbolItem`` object is contained inside the texture atlas dictionary/library.
	 *
	 * @param name Name of the symbol item to check for.
	 * @return Whether the symbol exists in the dictionary or not.
	 */
	public function existsSymbol(name:String):Bool
	{
		return (dictionary.exists(name));
	}

	/**
	 * Adds a ``SymbolItem`` object to the texture atlas dictionary/library.
	 *
	 * @param name Name of the symbol item to add.
	 */
	public function setSymbol(name:String, symbolItem:SymbolItem):Void
	{
		dictionary.set(name, symbolItem);
	}

	/**
	 * Parsing method for Adobe Animate texture atlases
	 *
	 * @param   animData  	Json object for Animation.json contents. You need to load it yourself.
	 * @param   spritemaps	Optional, array of the spritemaps to load for the texture atlas
	 * @param   metadata	Optional, string of the metadata.json contents string.
	 * @param   key			Optional, force the cache to use a specific Key to index the texture atlas.
	 * @param   unique  	Optional, ensures that the texture atlas uses a new slot in the cache.
	 * @return  Newly created `FlxAnimateFrames` collection.
	 */
	public static function fromAnimate(animData:AnimationJson, ?spritemaps:Array<SpritemapInput>, ?metadata:String, ?key:String, ?unique:Bool = false,
			?settings:FlxAnimateSettings):FlxAnimateFrames
	{
		var key:String = key ?? "";

		if (!unique && _cachedAtlases.exists(key))
		{
			var cachedAtlas = _cachedAtlases.get(key);
			var isAtlasDestroyed = false;

			// Check if the atlas is complete
			// For most cases this shouldnt be an issue but theres a ton of people who make their
			// own flixel caching systems that dont work nice with this.
			// For anyone out there listening, if theres a better option, PLEASE help, this is crap
			// - maru
			for (spritemap in cast(cachedAtlas.parent, FlxAnimateSpritemapCollection).spritemaps)
			{
				if (#if (flixel >= "5.6.0") spritemap.isDestroyed #else spritemap.shader == null #end)
				{
					isAtlasDestroyed = true;
					break;
				}
			}

			// Another check for individual frames (may have combined frames from a Sparrow)
			if (!isAtlasDestroyed)
			{
				for (frame in cachedAtlas.frames)
				{
					if (frame == null || frame.parent == null || frame.frame == null)
					{
						isAtlasDestroyed = true;
						break;
					}
				}
			}

			// Destroy previously cached atlas if incomplete, and create a new instance
			if (isAtlasDestroyed)
			{
				FlxG.log.warn('Texture Atlas with the key "$key" was previously cached, but incomplete. Was it incorrectly destroyed?');
				cachedAtlas.destroy();
				_cachedAtlases.remove(key);
			}
			else
			{
				return cachedAtlas;
			}
		}

		return _fromAnimateInput(animData, spritemaps, metadata, key, settings);
	}

	static function getTextFromPath(path:String):String
	{
		return FlxAnimateAssets.getText(path).replace(String.fromCharCode(0xFEFF), "");
	}

	static function listWithFilter(path:String, filter:String->Bool, includeSubDirectories:Bool = false)
	{
		var list = FlxAnimateAssets.list(path, null, path.substring(0, path.indexOf(':')), includeSubDirectories);
		return list.filter(filter);
	}

	static function getGraphic(path:String):FlxGraphic
	{
		if (FlxG.bitmap.checkCache(path))
			return FlxG.bitmap.get(path);

		return FlxG.bitmap.add(FlxAnimateAssets.getBitmapData(path), false, path);
	}

	var _symbolDictionary:Null< #if flash Array<SymbolJson> #else Vector<SymbolJson> #end>;
	var _isInlined:Bool;
	var _libraryList:Array<String>;
	var _settings:Null<FlxAnimateSettings>;

	// since FlxAnimateFrames can have more than one graphic im gonna need use do this
	// TODO: use another method that works closer to flixel's frame collection crap
	static var _cachedAtlases:Map<String, FlxAnimateFrames> = [];

	static function _fromAnimatePath(path:String, ?key:String, ?settings:FlxAnimateSettings)
	{
		var hasAnimation:Bool = FlxAnimateAssets.exists(path + "/Animation.json", TEXT);
		if (!hasAnimation)
		{
			FlxG.log.warn('No Animation.json file was found for path "$path".');
			return null;
		}

		var animation = getTextFromPath(path + "/Animation.json");
		var isInlined = !FlxAnimateAssets.exists(path + "/metadata.json", TEXT);
		var libraryList:Null<Array<String>> = null;
		var spritemaps:Array<SpritemapInput> = [];
		var metadata:Null<String> = isInlined ? null : getTextFromPath(path + "/metadata.json");

		if (!isInlined)
		{
			var list = listWithFilter(path + "/LIBRARY", (str) -> str.endsWith(".json"), true);
			libraryList = list.map((str) ->
			{
				str = str.split("/LIBRARY/").pop();
				return Path.withoutExtension(str);
			});
		}

		// Load all spritemaps
		var spritemapList = listWithFilter(path, (file) -> file.startsWith("spritemap"), false);
		var jsonList = spritemapList.filter((file) -> file.endsWith(".json"));

		for (sm in jsonList)
		{
			var id = sm.split("spritemap")[1].split(".")[0];
			var imageFile = spritemapList.filter((file) -> file.startsWith('spritemap$id') && !file.endsWith(".json"))[0];

			spritemaps.push({
				source: getGraphic('$path/$imageFile'),
				json: getTextFromPath('$path/$sm')
			});
		}

		if (spritemaps.length <= 0)
		{
			FlxG.log.warn('No spritemaps were found for key "$path". Is the texture atlas incomplete?');
			return null;
		}

        var animData:AnimationJson = null;
		try
		{
			animData = Json.parse(animation);
		}
		catch (e)
		{
			FlxG.log.warn('Couldnt load Animation.json with input "$animation". Is the texture atlas missing?');
			return null;
		}
		return _fromAnimateInput(animData, spritemaps, metadata, key ?? path, isInlined, libraryList, settings);
	}

    //? animData should be already loaded
	static function _fromAnimateInput(animData:AnimationJson, spritemaps:Array<SpritemapInput>, ?metadata:String, ?path:String, ?isInlined:Bool = true,
			?libraryList:Array<String>, settings:FlxAnimateSettings):FlxAnimateFrames
	{
		if (spritemaps == null || spritemaps.length <= 0)
		{
			FlxG.log.warn('No spritemaps were added for key "$path".');
			return null;
		}

		var frames = new FlxAnimateFrames(null);
		frames.path = path;
		frames._symbolDictionary = animData.SD;
		frames._isInlined = isInlined;
		frames._libraryList = libraryList;
		frames._settings = settings;

		var spritemapCollection = new FlxAnimateSpritemapCollection(frames);
		frames.parent = spritemapCollection;

		// Load all spritemaps
		for (spritemap in spritemaps)
		{
			var graphic = FlxG.bitmap.add(spritemap.source);
			if (graphic == null)
				continue;

			var atlas = new FlxAtlasFrames(graphic);
			var spritemap:SpritemapJson = Json.parse(spritemap.json);

			for (sprite in spritemap.ATLAS.SPRITES)
			{
				var sprite = sprite.SPRITE;
				var rect = FlxRect.get(sprite.x, sprite.y, sprite.w, sprite.h);
				var size = FlxPoint.get(sprite.w, sprite.h);
				atlas.addAtlasFrame(rect, size, FlxPoint.get(), sprite.name, sprite.rotated ? ANGLE_NEG_90 : ANGLE_0);
			}

			frames.addAtlas(atlas);
			spritemapCollection.addSpritemap(graphic);
		}

		var metadata:MetadataJson = (metadata == null) ? animData.MD : Json.parse(metadata);

		frames.frameRate = metadata.FRT;
		frames.timeline = new Timeline(animData.AN.TL, frames, animData.AN.SN);
		frames.dictionary.set(frames.timeline.name, new SymbolItem(frames.timeline)); // Add main symbol to the library too

		// stage background color
		var w = metadata.W;
		var h = metadata.H;
		frames.stageRect = (w > 0 && h > 0) ? FlxRect.get(0, 0, w, h) : FlxRect.get(0, 0, 1280, 720);
		frames.stageColor = FlxColor.fromString(metadata.BGC);

		// stage instance of the main symbol
		var stageInstance:Null<SymbolInstanceJson> = animData.AN.STI;
		frames.matrix = (stageInstance != null) ? stageInstance.MX.toMatrix() : new FlxMatrix();

		// clear the temp data crap
		frames._symbolDictionary = null;
		frames._libraryList = [];
		frames._settings = null;

		_cachedAtlases.set(path, frames);

		return frames;
	}

	@:allow(animate.FlxAnimateController)
	var dictionary:Map<String, SymbolItem>;

	@:allow(animate.FlxAnimateController)
	var path:String;

	@:allow(animate.FlxAnimateController)
	var addedCollections:Array<FlxAnimateFrames>;

	override function addAtlas(collection:FlxAtlasFrames, overwriteHash:Bool = false):FlxAtlasFrames
	{
		if (collection is FlxAnimateFrames)
		{
			// Add the texture atlas collection
			var animateCollection:FlxAnimateFrames = cast collection;
			addedCollections.push(animateCollection);

			// Add other non-texture atlas frames that could've been added to the animate frames, such as Sparrow
			var spritemap:FlxAnimateSpritemapCollection = cast animateCollection.parent;
			for (graphic in animateCollection.usedGraphics)
			{
				if (!spritemap.spritemaps.contains(graphic)) // Graphic isnt part of the texture atlas spritemap, check for atlas frames
				{
					var atlasFrames = FlxAtlasFrames.findFrame(graphic);
					if (atlasFrames != null)
						super.addAtlas(atlasFrames, overwriteHash);
				}
			}

			return this;
		}

		return super.addAtlas(collection, overwriteHash);
	}

	/**
	 * Combines two ``FlxAtlasFrames`` into one.
	 * Recommended to use over manually calling ``frames.addAtlas`` when working with
	 * ``FlxAnimateFrames`` and other mixed frame types, due to some special merge order conditions it requires.
	 * 
	 * @param atlasA First atlas to combine.
	 * @param atlasB Second atlas to combine.
	 * @return Newly merged ``FlxAtlasFrames`` object.
	 */
	public static extern overload inline function combineAtlas(atlasA:FlxAtlasFrames, atlasB:FlxAtlasFrames):Null<FlxAtlasFrames>
	{
		return _combineAtlas(atlasA, atlasB);
	}

	/**
	 * Combines a list of ``FlxAtlasFrames`` into one.
	 * Recommended to use over manually calling ``frames.addAtlas`` when working with
	 * ``FlxAnimateFrames`` and other mixed frame types, due to some special merge order conditions it requires.
	 * 
	 * @param atlasList List of atlas frames to combine.
	 * @return Newly merged ``FlxAtlasFrames`` object.
	 */
	public static extern overload inline function combineAtlas(atlasList:Array<FlxAtlasFrames>):Null<FlxAtlasFrames>
	{
		if (atlasList.length <= 0)
		{
			FlxG.log.warn('No frames were found to be combined together.');
			return null;
		}

		var i = 1;
		var frames:FlxAtlasFrames = atlasList[0];
		while (i < atlasList.length)
			frames = _combineAtlas(frames, atlasList[i++]);

		return frames;
	}

	@:noCompletion
	static inline function _combineAtlas(atlasA:FlxAtlasFrames, atlasB:FlxAtlasFrames):FlxAtlasFrames
	{
		if (atlasA is FlxAnimateFrames)
			return atlasA.addAtlas(atlasB);

		return atlasB.addAtlas(atlasA);
	}

	var checkedDirtySymbols:Array<String> = [];

	function setSymbolDirty(targetSymbol:String)
	{
		// Doing this so in a batch of setSymbolDirty, symbols dont get double checked
		if (checkedDirtySymbols.contains(targetSymbol))
			return;

		var checkForSymbol:Timeline->Void;
		checkForSymbol = (timeline:Timeline) ->
		{
			if (timeline == null || timeline.name.length <= 0)
				return;

			checkedDirtySymbols.push(timeline.name);

			for (layer in timeline)
			{
				for (frame in layer)
				{
					@:privateAccess
					if (!frame._requireBake)
						continue;

					var wasFrameSetDirty:Bool = false;
					for (element in frame)
					{
						switch (element.elementType)
						{
							case GRAPHIC | MOVIECLIP | BUTTON:
								var foundSymbol = element.toSymbolInstance().libraryItem;
								if (foundSymbol.name == targetSymbol)
								{
									if (!wasFrameSetDirty)
										frame.setDirty();
									wasFrameSetDirty = true;
								}
								else
								{
									checkForSymbol(foundSymbol.timeline);
								}
							default:
						}
					}
				}
			}
		}

		checkForSymbol(timeline);
		checkedDirtySymbols.resize(0);
	}

	override function destroy():Void
	{
		if (_cachedAtlases.exists(path))
			_cachedAtlases.remove(path);

		super.destroy();

		if (dictionary != null)
		{
			for (symbol in dictionary.iterator())
				symbol.destroy();
		}

		stageRect = FlxDestroyUtil.put(stageRect);
		timeline = FlxDestroyUtil.destroy(timeline);
		checkedDirtySymbols = null;
		dictionary = null;
		matrix = null;
	}
}

/**
 * This class is used as a temporal graphic for texture atlas frame caching.
 * Mainly used to work with flixel's method of destroying FlxFramesCollection
 * while keeping the ability to reused cached atlases where possible.
 */
@:allow(animate.FlxAnimateFrames)
class FlxAnimateSpritemapCollection extends FlxGraphic
{
	public function new(parentFrames:FlxAnimateFrames)
	{
		super("", null);
		this.spritemaps = [];
		this.parentFrames = parentFrames;
	}

	var spritemaps:Array<FlxGraphic>;
	var parentFrames:FlxAnimateFrames;

	public function addSpritemap(graphic:FlxGraphic):Void
	{
		if (this.bitmap == null)
			this.bitmap = graphic.bitmap;

		if (spritemaps.indexOf(graphic) == -1)
			spritemaps.push(graphic);
	}

	override function checkUseCount():Void
	{
		if (useCount <= 0 && destroyOnNoUse && !persist)
		{
			for (spritemap in spritemaps)
				FlxG.bitmap.remove(spritemap);

			spritemaps.resize(0);
			parentFrames = FlxDestroyUtil.destroy(parentFrames);
		}
	}

	override function destroy():Void
	{
		bitmap = null; // Turning null early to let the og spritemap graphic remove the bitmap
		super.destroy();
		parentFrames = null;

		if (spritemaps != null)
		{
			for (spritemap in spritemaps)
				FlxG.bitmap.remove(spritemap);
		}

		spritemaps = null;
	}
}

typedef SpritemapInput =
{
	source:FlxGraphicAsset,
	json:String
}

enum abstract FilterQuality(Int) to Int
{
	var HIGH = 0;
	var MEDIUM = 1;
	var LOW = 2;
	var RUDY = 3;

	public inline function getQualityFactor():Float
	{
		return switch (this)
		{
			case FilterQuality.MEDIUM: 1.75;
			case FilterQuality.LOW: 2.0;
			case FilterQuality.RUDY: 2.25;
			default: 1.0;
		}
	}

	public inline function getPixelFactor():Float
	{
		return switch (this)
		{
			case FilterQuality.MEDIUM: 16.0;
			case FilterQuality.LOW: 12.0;
			case FilterQuality.RUDY: 8.0;
			default: 1.0;
		}
	}
}
