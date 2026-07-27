package;

import sys.io.File;
import haxe.io.Bytes;
import hxp.*;
import lime.tools.*;
import sys.FileSystem;

using StringTools;

class Project extends HXProject
{
	/**
	 * The relative location of the templates folder.
	 */
	static final TEMPLATES_DIR:String = "templates";

	/**
	 * A package name used for identifying the app on various app stores.
	 */
	static final PACKAGE_NAME:String = "me.funkin.fnf";

	/**
	 * The game's version number, as a Semantic Versioning string with no prefix.
	 * REMEMBER TO CHANGE THIS WHEN THE GAME UPDATES!
	 * You only have to change it here, the rest of the game will query this value.
	 */
	static final VERSION:String = "3.5-dev";

	/**
	 * The build's number and version code.
	 * Used when publishing the game to mobile app stores. Should increment with each patch.
	 */
	static final BUILD_NUMBER:Int = 342;

	//
	// ASSET FILTERS
	//

	/**
	 * Asset path globs to always exclude from asset libraries.
	 */
	static final EXCLUDE_ASSETS:Array<String> = [".*", "cvs", "thumbs.db", "desktop.ini", "*.hash", "*.md"];

	/**
	 * Asset path globs to exclude on web platforms.
	 */
	static final EXCLUDE_ASSETS_WEB:Array<String> = ["*.ogg"];

	/**
	 * Asset path globs to exclude on native platforms.
	 */
	static final EXCLUDE_ASSETS_NATIVE:Array<String> = ["*.mp3"];

	/// EXPERIMENTS
	/// Features not globally rolled out. Use with caution

	/**
	 * `-DEXPERIMENT_PROFILE_BUILD`
	 * If enabled, adds **tracy** support for profiling this build.
	 * Only use for build used for assessing performance.
	 *
	 * *NOTE: Using tracy fills up memory VERY quickly, so make your time count with it! 
	 */
	static final EXPERIMENT_PROFILE_BUILD:FeatureFlag = "EXPERIMENT_PROFILE_BUILD";

	/**
	 * `-DEXPERIMENT_CRASH_TOOLS`
	 * If enabled, adds additional options int o a debug state to crash the game.
	 * Used for thesting build-in crash handler
	 */
	static final EXPERIMENT_CRASH_TOOLS:FeatureFlag = "EXPERIMENT_CRASH_TOOLS";

	/**
	 * `-DEXPERIMENT_O3_OPTIM`
	 * If enabled, compiles the game with more aggressive optimalisation.
	 */
	static final EXPERIMENT_O3_OPTIM:FeatureFlag = "EXPERIMENT_O3_OPTIM";

	/**
	 * `-DEXPERIMENT_COMPRESSED_TEXTURES`
	 * If this flag is enabled, ASTC compressed textures will be used over uncompressed PNGs.
	 * Compressed ASTC textures provide lower memory usage but at the cost of a slightly higher files size & more GPU usage.
	 * ASTC textures are GPU Rendered so they have a few cons:
	 * - Pixel Data of bitmaps cannot be read nor edited directly.
	 * - Some filters specifically the ones in openfl.filters package won't work properly because they directly modify the bitmap pixels.
	 * - ASync loading for GPU Compressed Textures doesn't work due to OpenGL being single-threaded. (Looking online there seem to be some workarounds but it's pretty complicated...).
	 * One thing to note is that ASTC textures aren't available on all platforms:
	 * - For iOS, it's available starting from phones with A8 chips, so anything from iPhone 6 and beyond has it.
	 * - For Android, it's sorta mixed, but mostly any mid range phone that came after 2017 does support ASTC.
	 * - For desktop, it appears to be only supported on Intergrated Graphics from our testing.
	 */
	static final EXPERIMENT_COMPRESSED_TEXTURES:FeatureFlag = "EXPERIMENT_COMPRESSED_TEXTURES";

	// ============================================================
	// Feature flags
	// ============================================================
	// Every flag this script reads or writes is declared here so call sites
	// get autocomplete + compile-time checking instead of bare strings.
	// Each flag's on/off state lives directly in `haxedefs`/`defines` via
	// FeatureFlag.isEnabled()/enable()/disable() -- see FeatureFlag.project,
	// which is wired up to `this` at the top of the constructor below.
	// -- external / passed in from the command line, never set by this script --

	/**
	 * `-D32bits`
	 * Whether to build a 32-bit binary.
	 * Never set by this script; passed in via the command line.
	 */
	static final THIRTY_TWO_BITS:FeatureFlag = "32bits";

	/**
	 * `-DBUILD_LINUX_V3`
	 * Whether to build against the x86-64-v3 Linux lime ndll/march.
	 * Never set by this script; passed in via the command line.
	 */
	static final BUILD_LINUX_V3:FeatureFlag = "BUILD_LINUX_V3";

	// -- <define> flags --

	/**
	 * `-DMODS_ALLOWED`
	 * Compiles mod support for P-Slice. Feel free to disable if you're making a source mod.
	 * Enabled on desktop and mobile.
	 */
	static final MODS_ALLOWED:FeatureFlag = "MODS_ALLOWED";

	/**
	 * `-DOPENFL_LOOKUP`
	 * Adds the ability to use OpenFL asset lookup (defaults to sys if disabled).
	 */
	static final OPENFL_LOOKUP:FeatureFlag = "OPENFL_LOOKUP";

	/**
	 * `-DNATIVE_LOOKUP`
	 * Adds the ability to use NativeFileSystem on the computer to access files.
	 */
	static final NATIVE_LOOKUP:FeatureFlag = "NATIVE_LOOKUP";

	/**
	 * `-DHSCRIPT_ALLOWED`
	 * Adds support for Psych's HScript files. Enabled on desktop and mobile.
	 */
	static final HSCRIPT_ALLOWED:FeatureFlag = "HSCRIPT_ALLOWED";

	/**
	 * `-DLUA_ALLOWED`
	 * Adds support for Psych's lua files. Enabled when compiling to C++.
	 */
	static final LUA_ALLOWED:FeatureFlag = "LUA_ALLOWED";

	/**
	 * `-DDISCORD_ALLOWED`
	 * Enables Discord's Rich Presence integration. Enabled on desktop, excluding HashLink.
	 */
	static final DISCORD_ALLOWED:FeatureFlag = "DISCORD_ALLOWED";

	/**
	 * `-DBASE_GAME_FILES`
	 * Adds the base game content to your build. Feel free to disable if you're making a source mod.
	 * Enabled everywhere except web.
	 */
	static final BASE_GAME_FILES:FeatureFlag = "BASE_GAME_FILES";

	/**
	 * `-DTOUCH_CONTROLS_ALLOWED`
	 * Adds support for touchscreen devices (like mobiles).
	 */
	static final TOUCH_CONTROLS_ALLOWED:FeatureFlag = "TOUCH_CONTROLS_ALLOWED";

	/**
	 * `-DCHECK_FOR_UPDATES`
	 * Whether to check for P-Slice updates. Disabled on web and HashLink.
	 */
	static final CHECK_FOR_UPDATES:FeatureFlag = "CHECK_FOR_UPDATES";

	/**
	 * `-DVIDEOS_ALLOWED`
	 * Whether to support playing videos in your build.
	 */
	static final VIDEOS_ALLOWED:FeatureFlag = "VIDEOS_ALLOWED";

	/**
	 * `-DATSC_SUPPORT`
	 * Enables the build to use ASTC textures if provided (and supported by the device)
	 */
	static final ATSC_SUPPORT:FeatureFlag = "ATSC_SUPPORT";

	/**
	 * `-DFIREBASE_CRASH_HANDLER`
	 * Enables a special crash handler in case you don't trust your players to report issues properly.
	 * Enabled on mobile.
	 */
	static final FIREBASE_CRASH_HANDLER:FeatureFlag = "FIREBASE_CRASH_HANDLER";

	/**
	 * `-DTOUCH_HERE_TO_PLAY`
	 * Displays a "Touch here to play" screen.
	 */
	static final TOUCH_HERE_TO_PLAY:FeatureFlag = "TOUCH_HERE_TO_PLAY";

	/**
	 * `-DACHIEVEMENTS_ALLOWED`
	 * Enables achievements.
	 */
	static final ACHIEVEMENTS_ALLOWED:FeatureFlag = "ACHIEVEMENTS_ALLOWED";

	/**
	 * `-DTRANSLATIONS_ALLOWED`
	 * Enables translation support. Disabled on web.
	 */
	static final TRANSLATIONS_ALLOWED:FeatureFlag = "TRANSLATIONS_ALLOWED";

	/**
	 * `-DSHOW_LOADING_SCREEN`
	 * Allows the game to display a loading screen when loading songs.
	 */
	static final SHOW_LOADING_SCREEN:FeatureFlag = "SHOW_LOADING_SCREEN";

	/**
	 * `-DSTRICT_LOADING_SCREEN`
	 * Forces the game to unload UI assets before loading the song assets.
	 */
	static final STRICT_LOADING_SCREEN:FeatureFlag = "STRICT_LOADING_SCREEN";

	/**
	 * `-DMULTITHREADED_LOADING`
	 * Improves loading times, but with a low chance for the game to freeze on song load.
	 * Enabled when compiling to C++.
	 */
	static final MULTITHREADED_LOADING:FeatureFlag = "MULTITHREADED_LOADING";

	/**
	 * `-DPSYCH_WATERMARKS`
	 * Shows the Psych logo on the loading screen. Delete this flag's usage to remove it.
	 */
	static final PSYCH_WATERMARKS:FeatureFlag = "PSYCH_WATERMARKS";

	/**
	 * `-DTITLE_SCREEN_EASTER_EGG`
	 * Enables the title screen easter egg.
	 */
	static final TITLE_SCREEN_EASTER_EGG:FeatureFlag = "TITLE_SCREEN_EASTER_EGG";

	/**
	 * `-DIRIS_DEBUG`
	 * Debug utility, useful when testing the game. Enabled in debug builds.
	 */
	static final IRIS_DEBUG:FeatureFlag = "IRIS_DEBUG";

	/**
	 * `-DFEATURE_DEBUG_FUNCTIONS`
	 * Debug utility, useful when testing the game. Enabled in debug builds.
	 */
	static final FEATURE_DEBUG_FUNCTIONS:FeatureFlag = "FEATURE_DEBUG_FUNCTIONS";

	/**
	 * `-Dpico_always_kill`
	 * Pico will always kill the other (unless you skip the cutscene).
	 * Enabled in debug and profiling builds.
	 */
	static final PICO_ALWAYS_KILL:FeatureFlag = "pico_always_kill";

	/**
	 * `-DHXCPP_TRACY`
	 * Enables Tracy profiling. Enabled in profiling builds.
	 */
	static final HXCPP_TRACY:FeatureFlag = "HXCPP_TRACY";

	/**
	 * `-DHXCPP_TELEMETRY`
	 * Enables hxcpp telemetry. Enabled in profiling builds.
	 */
	static final HXCPP_TELEMETRY:FeatureFlag = "HXCPP_TELEMETRY";

	/**
	 * `-DHXCPP_TRACY_MEMORY`
	 * Enables Tracy memory profiling. Enabled in profiling builds.
	 */
	static final HXCPP_TRACY_MEMORY:FeatureFlag = "HXCPP_TRACY_MEMORY";

	/**
	 * `-DHXCPP_TRACY_ON_DEMAND`
	 * Enables on-demand Tracy profiling. Enabled in profiling builds.
	 */
	static final HXCPP_TRACY_ON_DEMAND:FeatureFlag = "HXCPP_TRACY_ON_DEMAND";

	/**
	 * `-DNO_FIREBASE_ANDROID_PATCHES`
	 * Skips the Firebase Android patches. Enabled whenever FIREBASE_CRASH_HANDLER is.
	 */
	static final NO_FIREBASE_ANDROID_PATCHES:FeatureFlag = "NO_FIREBASE_ANDROID_PATCHES";

	/**
	 * `-Dx86_BUILD`
	 * Set whenever compiling a 32-bit binary.
	 */
	static final X86_BUILD:FeatureFlag = "x86_BUILD";

	// -- <haxedef> flags (compiler-only, no XML-conditional semantics) --

	/**
	 * `-DLINC_LUA_RELATIVE_DYNAMIC_LIB`
	 * Uses a relative path for linc_lua's dynamic library. Always enabled.
	 */
	static final LINC_LUA_RELATIVE_DYNAMIC_LIB:FeatureFlag = "LINC_LUA_RELATIVE_DYNAMIC_LIB";

	/**
	 * `-DSHARE_MOBILE_FILES`
	 * Lets the user access P-Slice files. Enabled on mobile.
	 */
	static final SHARE_MOBILE_FILES:FeatureFlag = "SHARE_MOBILE_FILES";

	/**
	 * `-DFLX_NO_DEBUG`
	 * Disable the Flixel core debugger. Automatically set whenever you compile
	 * outside of debug/profiling mode.
	 */
	static final FLX_NO_DEBUG:FeatureFlag = "FLX_NO_DEBUG";

	/**
	 * `-Danalyzer-optimize`
	 * Enables the Haxe analyzer optimizer. Enabled outside of debug builds.
	 */
	static final ANALYZER_OPTIMIZE:FeatureFlag = "analyzer-optimize";

	/**
	 * `-DNAPE_RELEASE_BUILD`
	 * Enable this for Nape release builds for a serious performance improvement.
	 * Enabled outside of debug builds.
	 */
	static final NAPE_RELEASE_BUILD:FeatureFlag = "NAPE_RELEASE_BUILD";

	/**
	 * `-DHXCPP_ARM64`
	 * Compile for ARM (hopefully should fix the sim screaming about libs). Enabled on iOS.
	 */
	static final HXCPP_ARM64:FeatureFlag = "HXCPP_ARM64";

	/**
	 * `-Dno-deprecation-warnings`
	 * Disable deprecated warnings. Always enabled.
	 */
	static final NO_DEPRECATION_WARNINGS:FeatureFlag = "no-deprecation-warnings";

	/**
	 * `-DhscriptPos`
	 * Makes HScript errors more verbose. Enabled whenever HSCRIPT_ALLOWED is.
	 */
	static final HSCRIPT_POS:FeatureFlag = "hscriptPos";

	/**
	 * A list of asset file globs to exclude from ASTC compression when creating optimized mobile builds.
	 */
	static var astcExcludes:Array<String> = [];

	public function new()
	{
		super();

		// Let FeatureFlag instances read/write this project's defines.
		FeatureFlag.project = this;

		// --------------------------------------------------------------
		// Condition flags (replicate the XML's if=/unless= vocabulary)
		// --------------------------------------------------------------
		// "cpp" in the XML means "this build is compiling to C++" (i.e. every native target).
		var cpp = isCPP();
		var bits32 = THIRTY_TWO_BITS.isEnabled() || is32Bit();

		configureApp();
		configureWindow();
		configureASTCTextures();
		// ============================================================
		// PSYCH ENGINE CUSTOMIZATION
		// ============================================================
		EXPERIMENT_CRASH_TOOLS.apply();
		EXPERIMENT_PROFILE_BUILD.apply();
		EXPERIMENT_COMPRESSED_TEXTURES.apply();
		// Compiles mod support for P-Slice. Feel free to disable if you're making a source mod
		MODS_ALLOWED.apply(isDesktop() || isMobile());

		if (!debug)
		{
			OPENFL_LOOKUP.enable();
			NATIVE_LOOKUP.apply(MODS_ALLOWED.isEnabled());
		}

		HSCRIPT_ALLOWED.apply(isDesktop() || isMobile());
		LUA_ALLOWED.apply(isCPP());

		DISCORD_ALLOWED.apply(isDesktop() && !isHashLink());
		BASE_GAME_FILES.apply(true);
		TOUCH_CONTROLS_ALLOWED.apply(isMobile() || isWeb() || isDebug());
		// CHECK_FOR_UPDATES.apply(!isWeb() && !isHashLink());
		CHECK_FOR_UPDATES.apply();

		VIDEOS_ALLOWED.apply((isDesktop() || isMobile() || isWeb()) && !bits32 && !isHashLink());
		ATSC_SUPPORT.apply(!isWeb() || EXPERIMENT_COMPRESSED_TEXTURES.isEnabled());
		FIREBASE_CRASH_HANDLER.apply(isMobile());
		TOUCH_HERE_TO_PLAY.apply(TOUCH_CONTROLS_ALLOWED.isEnabled() && debug);
		ACHIEVEMENTS_ALLOWED.apply(true);
		TRANSLATIONS_ALLOWED.apply(!isWeb());

		SHOW_LOADING_SCREEN.apply(true);
		STRICT_LOADING_SCREEN.apply(isMobile() && SHOW_LOADING_SCREEN.isEnabled());

		MULTITHREADED_LOADING.apply(isCPP());
		PSYCH_WATERMARKS.apply(true); // DELETE THIS TO REMOVE THE PSYCH LOGO FROM LOADING SCREEN
		TITLE_SCREEN_EASTER_EGG.apply(true);
		// Debug utilities (useful when testing the game)
		if (debug)
		{
			// For testing file access times
			OPENFL_LOOKUP.enable();
			if (!isWeb())
				NATIVE_LOOKUP.enable();
			else
				NATIVE_LOOKUP.disable();

			IRIS_DEBUG.enable();
			FEATURE_DEBUG_FUNCTIONS.enable();
			setHaxedef("HXVLC_VERBOSE", "2");
			setHaxedef("HXVLC_LOGGING", "");
			// Pico will always kill the other (unless you skip the cutscene)
			PICO_ALWAYS_KILL.enable();
		}

		// Flags for the profile builds (used for assessing performance and such)
		if (EXPERIMENT_PROFILE_BUILD.isEnabled())
		{
			// Enables tracy
			HXCPP_TRACY.enable();
			HXCPP_TELEMETRY.enable();
			HXCPP_TRACY_MEMORY.enable();
			HXCPP_TRACY_ON_DEMAND.enable();
			STRICT_LOADING_SCREEN.enable();
			// HXCPP_TRACY_INCLUDE_CALLSTACKS.enable ();

			// Pico will always kill the other (unless you skip the cutscene)
			PICO_ALWAYS_KILL.enable();
		}

		// HXCPP_OPTIMIZE_FOR_SIZE
		if(EXPERIMENT_O3_OPTIM.isEnabled()){
			setHaxedef("HXCPP_OPTIMIZE_FOR_FAST");
		}

		if (BUILD_LINUX_V3.isEnabled())
		{
			assets.push(new Asset("setup/ndll/linux/lime.v3.ndll", "lime.ndll", null, true));
			if (cpp)
			{
				setHaxedef("HXCPP_EXACT_MARCH", "x86-64-v3");
			}
		}

		// ============================================================
		// Path Settings
		// ============================================================

		if (debug)
			app.path = "export/debug";
		if (HXCPP_TRACY.isEnabled())
			app.path = "export/tracy";
		if (!debug && !HXCPP_TRACY.isEnabled())
			app.path = "export/release";
		if (bits32)
			app.path = "export/32bit";

		sources.push("source"); // <classpath name="source" />

		// ============================================================
		// Game Assets & Etc.
		// ============================================================

		// Delete the assets folder from the export folder before adding anything.
		clearAssets();

		// FNF is changing openAL config, because the default one is broken.
		if (isDesktop())
		{
			var targetExt = isWindows() ? ".ini" : ".conf";
			assets.push(new Asset("alsoft.txt", "plugins/alsoft" + targetExt, AssetType.TEXT));
		}

		// Assets
		addAssetPath("assets/fonts");
		if (TOUCH_CONTROLS_ALLOWED.isEnabled())
		{
			addAssetPath("assets/mobile", "assets/shared/mobile");
		}
		if (VIDEOS_ALLOWED.isEnabled())
		{
			addAssetPath("assets/videos");
		}

		if (!isWeb())
		{
			addAssetPath("assets/shared");
		}
		else
		{
			embedAssetPath("assets/shared");
		}

		if (isWeb())
		{
			embedAssetPath("assets/embed",);
		}
		if (!isWeb() && !OPENFL_LOOKUP.isEnabled())
		{
			addAssetPath("assets/embed");
		}
		if (OPENFL_LOOKUP.isEnabled() && !isWeb())
		{
			embedAssetPath("assets/embed");
		}

		if (isWeb())
		{
			addAssetPath("assets/week_assets", "assets");
		}
		else
		{
			addAssetPath("assets/week_assets", "assets");
		}

		if (TITLE_SCREEN_EASTER_EGG.isEnabled())
		{
			if (isWeb())
			{
				addAssetPath("assets/secrets", "assets/shared", null, null, null, "*.ogg");
			}
			else
			{
				addAssetPath("assets/secrets", "assets/shared");
			}
		}

		if (TRANSLATIONS_ALLOWED.isEnabled())
		{
			if (isWeb())
			{
				addAssetPath("assets/translations", "assets", null, null, null, "*.ogg");
			}
			else
			{
				addAssetPath("assets/translations", "assets");
			}
		}

		if (BASE_GAME_FILES.isEnabled())
		{
			if (isWeb())
			{
				addAssetPath("assets/base_game/week_data", "assets", null, false, "*.png|*.ogg|*.mp4");
				addAssetPath("assets/base_game/week_data", "assets", null, true, "*.xml|*.json");
				addAssetPath("assets/base_game/characters", "assets/shared/images/characters", null, true, "*.xml|*.json");
				addAssetPath("assets/base_game/characters", "assets/shared/images/characters", null, false, "*.png");
				addAssetPath("assets/base_game/characters_pixel", "assets/shared/images/characters", null, true, "*.xml|*.json");
				addAssetPath("assets/base_game/characters_pixel", "assets/shared/images/characters", null, false, "*.png");
				addAssetPath("assets/base_game/shared", "assets/shared", null, true);
			}
			if (!isWeb())
			{
				addAssetPath("assets/base_game/week_data", "assets");
				addAssetPath("assets/base_game/characters", "assets/shared/images/characters");
				addAssetPath("assets/base_game/characters_pixel", "assets/shared/images/characters");
				addAssetPath("assets/base_game/shared", "assets/shared");
			}
		}

		if (MODS_ALLOWED.isEnabled())
		{
			addAssetPath("example_mods", "mods");
		}

		// ============================================================
		// Haxe libs / Libraries
		// ============================================================

		addHaxelib("flixel");
		addHaxelib("flixel-addons", "3.3.2");
		addHaxelib("hxcpp");

		addHaxelib("tjson", "1.4.0");
		addHaxelib("grig.audio");
		addHaxelib("funkin.vis");

		// Psych stuff needed
		if (LUA_ALLOWED.isEnabled())
		{
			addHaxelib("linc_luajit");
			// stable luas PUT AFTER FIRST LINE WITH APP NAME AND ETC
			LINC_LUA_RELATIVE_DYNAMIC_LIB.enable();
			// I hate you @superpowers04 for changing commits like that
			setHaxedef("SHUT_UP_LINC_LUAJIT");
		}

		if (VIDEOS_ALLOWED.isEnabled() && !isWeb())
		{
			var videoHaxelib = isLinux() ? "hxCodec" : "hxvlc";
			addHaxelib(videoHaxelib);
		}

		addHaxelib("flixel-animate");

		config.set("mac.category_type", "public.app-category.music-games");

		// Disable Discord IO Thread
		if (DISCORD_ALLOWED.isEnabled())
		{
			addHaxelib("hxdiscord_rpc");
			setHaxedef("DISCORD_DISABLE_IO_THREAD");
			if (isLinux())
				setHaxedef("NO_PRECOMPILED_HEADERS");
		}

		if (debug)
		{
			// These defines are mostly for testing (aren't required to be used)
			addHaxelib("hxcpp-debug-server");
			addHaxelib("flixel-studio");
			addHaxelib("hscript");
		}

		if (bits32)
			X86_BUILD.enable();

		// Disable the Flixel core focus lost screen
		setHaxedef("FLX_NO_FOCUS_LOST_SCREEN");

		SHARE_MOBILE_FILES.apply(isMobile());

		// Disable the Flixel core debugger. Automatically gets set whenever
		// you compile in release mode!
		if (EXPERIMENT_PROFILE_BUILD.isDisabled() && !debug)
			FLX_NO_DEBUG.enable();
		// Enable this for Nape release builds for a serious performance improvement
		if (!debug)
		{
			ANALYZER_OPTIMIZE.enable();
			NAPE_RELEASE_BUILD.enable();
		}

		// Used for crash handler
		if (isCPP())
		{
			// !DO NOT ENABLE THIS
			// HXCPP_GC_MOVING.enable (); // unless HXCPP_TRACY_MEMORY
			// This will break the GC and delete textures on its own
			setHaxedef("HXCPP_CHECK_POINTER");
			setHaxedef("HXCPP_STACK_LINE");
			setHaxedef("HXCPP_STACK_TRACE");
			setHaxedef("HXCPP_CATCH_SEGV");
		}

		// Disable deprecated warnings
		NO_DEPRECATION_WARNINGS.enable();
		// for lime to not recompile asset cache on every build
		setHaxedef("lime_disable_assets_version");
		// Disable deprecated warnings
		if (isHashLink())
			setHaxedef("no_ssl");

		// Haxe 4.3.0+: Enable pretty syntax errors and stuff.
		// pretty (haxeflixel default), indent, classic (haxe compiler default)
		setHaxedef("message.reporting", "pretty");

		// Macro fixes
		addHaxeMacro("allowPackage('flash')");
		addHaxeMacro("include('my.pack')");
		// This macro allows addition of new functionality to existing Flixel.
		addHaxeMacro("addMetadata('@:build(mikolka.FlxMacro.buildFlxBasic())', 'flixel.FlxBasic')");

		// more verbose HScript
		if (HSCRIPT_ALLOWED.isEnabled())
		{
			addHaxelib("hscript-iris", "1.1.3");
			HSCRIPT_POS.enable();
		}

		this.templatePaths.push(TEMPLATES_DIR);
		if (isMobile())
			configureMobile();
		addPsliceIcons();
	}

	//
	// STAGES
	//
	function configureApp()
	{
		app.main = "Main";
		meta.version = VERSION;
		meta.company = "mikolka9144";
		meta.packageName = "com.mikolka9144.pslice"; // TODO(verify field name: packageName vs package)
		app.file = "PSliceEngine";
		if (EXPERIMENT_PROFILE_BUILD.isEnabled())
		{
			meta.title = "P-Slice Engine Profiling build";
			meta.packageName = "com.mikolka9144.testPslice";
		}
		else if (isMobile())
		{
			meta.title = "P-Slice Engine";
		}
		else
		{
			meta.title = "Friday Night Funkin': P-Slice Engine";
		}

		// Switch: Export with Unique ApplicationID and Icon
		environment.set("APP_ID", "0x0100f6c013bbc000");

		meta.buildNumber = Std.string(BUILD_NUMBER);

		// TODO(verify android config API for your Lime version):
		// <config type="android" gradle-version="8.10.2" gradle-plugin="8.8.0"
		//         ndkVersion="27.3" minimum-sdk-version="26" target-sdk-version="35" />
		// e.g. something like:

		// The flixel preloader is not accurate in Chrome. You can use it
		// regularly if you embed the swf into an html file, or set the
		// actual file size manually at "FlxPreloaderBase-onUpdate-bytesTotal".
		// app.preloader = "Preloader";
		app.preloader = "mikolka.vslice.FunkinPreloader";

		// Minimum without FLX_NO_GAMEPAD: 11.8, without FLX_NO_NATIVE_CURSOR: 11.2
		environment.set("SWF_VERSION", "11.8");
	}

	function configureWindow()
	{
		// ============================================================
		// Window Settings
		// ============================================================

		// These window settings apply to all targets
		window.width = 1280;
		window.height = 720;
		window.fps = 60;
		window.background = 0x000000;
		window.hardware = true;
		window.vsync = false;
		window.allowHighDPI = true;
		window.resizable = !isMobile();
		window.fullscreen = !isDesktop();
		window.orientation = Orientation.LANDSCAPE;

		// isDesktop()-specific
		if (isDesktop())
		{
			window.vsync = false;
		}

		// Mobile-specific
		if (isMobile())
		{
			window.allowShaders = true;
			window.requireShaders = true;
		}

		// Switch-specific
		if (isSwitch())
		{
			window.fullscreen = true;
			window.width = 0;
			window.height = 0;
			window.resizable = true;
		}
	}

	function configureMobile()
	{
		addHaxelib("extension-haptics");

		if (isAndroid())
		{
			addHaxelib("extension-androidtools");
			config.set("android.gradle-version", "8.10.2");
			config.set("android.gradle-plugin", "8.8.0");
			config.set("android.ndk-version", "27.3");
			config.set("android.minimum-sdk-version", "26");
			config.set("android.target-sdk-version", "37");
			// TODO(verify): <java if="android" path="source/external/android/java" />
			javaPaths.push("source/external/android/java");
			if (!debug)
				keystore = new Keystore("key.keystore", "pslice", "pslice", "pslice");
		}
		if (isIOS())
		{
			config.set("ios.category_type", "public.app-category.music-games");
			// Compile for ARM (hopefully should fix the sim screaming about libs)
			HXCPP_ARM64.enable();
		}
		if (FIREBASE_CRASH_HANDLER.isEnabled())
		{
			// TODO(verify template API):
			NO_FIREBASE_ANDROID_PATCHES.enable();
			addHaxelib("extension-firebase-crashlytics");
			// <template path="setup/google-services.json" rename="app/google-services.json"/>
			// <config:android pslice-firebase-sdk-path="yes" />
			// <template path="setup/GoogleService-Info.plist" rename="GoogleService-Info.plist" if="ios"/>
			// <template path="setup/GoogleService-Info.plist" rename="../GoogleService-Info.plist" if="ios"/>
			config.set("android.pslice-firebase-sdk-path", "yes");
		}
	}

	function addPsliceIcons()
	{
		if (EXPERIMENT_PROFILE_BUILD.isEnabled())
		{
			if (isLinux())
				addAsset("art/desktop/icon16.png", "icon.png");
			addIcon("art/desktop/icon16.png");
			return;
		}
		if (isMac())
		{
			addAsset("art/desktop/mac-icon-assets.car", "Assets.car");
		}

		if (isMobile())
		{
			// TODO(verify config API):
			// <config type="android" pslice-mono-icon="art/mobile/iconMono.png" />
			// <config type="ios" pslice-icon-dir="art/mobile/PSlice.appiconset" />
			config.set("android.pslice-mono-icon", "art/mobile/iconMono.png");
			config.set("ios.pslice-icon-dir", "art/mobile/PSlice.appiconset");
			if (isAndroid())
				addIcon("art/mobile/iconAdaptive.png");
			if (!isAndroid())
				addIcon("art/mobile/iconMobile.png");
		}
		if (!isMobile())
		{
			if (isLinux())
				addAsset("art/desktop/iconOG.png", "icon.png");
			addIcon("art/desktop/icon16.png", 16);
			addIcon("art/desktop/icon32.png", 32);
			addIcon("art/desktop/icon64.png", 64);
			addIcon("art/desktop/iconOG.png");
		}
	}

	// Asset cleaner

	function clearAssets():Void
	{
		// Don't run on non-build commands.
		if (!isBuild())
			return;

		var exportPath:Null<String> = app.path ?? "";

		// mac target uses `macos` for the export folder instead of `mac`
		var platform:String = (!isMac() ? Std.string(this.target) : 'macos');
		var basePath:String = Path.join([exportPath, platform, "bin"]);
		var assetsPath:String = "";

		switch (platformType)
		{
			case PlatformType.DESKTOP:
				if (isMac())
				{
					assetsPath = Path.join([basePath, '${this.app.file}.app', "Contents", "Resources", "assets"]);
				}
				else
				{
					assetsPath = Path.join([basePath, "assets"]);
				}
			case PlatformType.MOBILE:
				if (isAndroid())
				{
					assetsPath = Path.join([basePath, "app", "src", "main", "assets", "assets"]);
				}
				else
				{
					return;
				}
			default:
				// Don't do this for other platform types yet.
				return;
		}

		if (sys.FileSystem.exists(assetsPath))
		{
			info('Deleting assets folder from export folder ($assetsPath)');

			// this is fucking shitty i know but you can't just delete the whole assets folder with `sys.FileSystem.deleteDirectory`
			// this is because the assets folder is usually not empty.....deleting a folder that isn't empty throws an error i fucking hate lime......grrr......
			deleteDirectoryRecursive(assetsPath);
		}
		else
		{
			info('Assets folder does not exist ($assetsPath)');
		}
	}

	  /**
   * Recursively delete a directory and its contents.
   * @param path The path to the directory to delete.
   */
  function deleteDirectoryRecursive(path:String):Void
  {
    if (!sys.FileSystem.exists(path)) return;

    for (file in sys.FileSystem.readDirectory(path))
    {
      var fullPath:String = Path.join([path, file]);
      if (sys.FileSystem.isDirectory(fullPath))
      {
        deleteDirectoryRecursive(fullPath);
      }
      else
      {
        sys.FileSystem.deleteFile(fullPath);
      }
    }

    sys.FileSystem.deleteDirectory(path);
  }
	//
	// EXPERIMENTS
	// Easy functions to make the code more readable.
	//

	/**
	 * Configure the astc textures.
	 */
	function configureASTCTextures()
	{
		if (!(isDisplay() || isClean()))
		{
			readASTCExclusion();

			if (EXPERIMENT_COMPRESSED_TEXTURES.isEnabled())
			{
				runASTCCompressor();
			}
		}
	}

	public function runASTCCompressor():Void
	{
		info('Compressing ASTC textures...');

		var args:Array<String> = ['run', 'astc-compressor', 'compress-from-json'];
		args = args.concat(['-json', './setup/astc/astc-compression-data.json']);

		Sys.command('haxelib', args);

		info('Done compressing ASTC textures.');
	}

	public function readASTCExclusion():Void
	{
		@:nullSafety(Off)
		astcExcludes = haxe.Json.parse(File.getContent('./setup/astc/astc-compression-data.json')).excludes;

		for (i in 0...astcExcludes.length)
			astcExcludes[i] = astcExcludes[i].trim();
	}

	public function isASTCExcluded(file:String):Bool
	{
		for (exclusion in astcExcludes)
		{
			if (exclusion.endsWith("/"))
			{
				var normalizedFilePath = Path.normalize(file);
				var normalizedExclusion = Path.normalize(exclusion);

				if (normalizedFilePath.startsWith(normalizedExclusion))
					return true;
			}
			else if (exclusion.endsWith("/*"))
			{
				var normalizedExclusion = Path.normalize(exclusion.substr(0, exclusion.length - 2));
				var fileDirectory = Path.directory(Path.normalize(file));

				if (fileDirectory == normalizedExclusion)
					return true;
			}
			else
			{
				if (file == exclusion)
					return true;
			}
		}

		return false;
	}

	//
	// HELPER FUNCTIONS
	// Easy functions to make the code more readable.
	//

	public function isWeb():Bool
	{
		return this.platformType == PlatformType.WEB;
	}

	public function isMobile():Bool
	{
		return this.platformType == PlatformType.MOBILE;
	}

	public function isDesktop():Bool
	{
		return this.platformType == PlatformType.DESKTOP;
	}

	public function isConsole():Bool
	{
		return this.platformType == PlatformType.CONSOLE;
	}

	public function is32Bit():Bool
	{
		return this.architectures.contains(Architecture.X86);
	}

	public function is64Bit():Bool
	{
		return this.architectures.contains(Architecture.X64);
	}

	public function isWindowsHost():Bool
	{
		return System.hostPlatform == WINDOWS;
	}

	function isSwitch()
	{
		return targetFlags.exists("switch");
	}

	public function isMacHost():Bool
	{
		return System.hostPlatform == MAC;
	}

	public function isLinuxHost():Bool
	{
		return System.hostPlatform == LINUX;
	}

	public function isWindows():Bool
	{
		return this.target == Platform.WINDOWS;
	}

	public function isMac():Bool
	{
		return this.target == Platform.MAC;
	}

	public function isLinux():Bool
	{
		return this.target == Platform.LINUX;
	}

	public function isAndroid():Bool
	{
		return this.target == Platform.ANDROID;
	}

	public function isIOS():Bool
	{
		return this.target == Platform.IOS;
	}

	public function isIOSSimulator():Bool
	{
		return this.target == Platform.IOS && this.targetFlags.exists("simulator");
	}

	public function isHashLink():Bool
	{
		return this.targetFlags.exists("hl");
	}

	public function isNeko():Bool
	{
		return this.targetFlags.exists("neko");
	}

	public function isJava():Bool
	{
		return this.targetFlags.exists("java");
	}

	public function isNodeJS():Bool
	{
		return this.targetFlags.exists("nodejs");
	}

	public function isCSharp():Bool
	{
		return this.targetFlags.exists("cs");
	}

	public function isCPP():Bool
	{
		return this.defines.exists("cpp");
	}

	public function isDisplay():Bool
	{
		return this.command == "display";
	}

	public function isClean():Bool
	{
		return this.command == "clean";
	}

	public function isBuild():Bool
	{
		return this.command == "test" || this.command == "build";
	}

	public function isDebug():Bool
	{
		return this.debug;
	}

	public function isRelease():Bool
	{
		return !isDebug();
	}

	//
	// LOGGING FUNCTIONS
	//

	/**
	 * Display an error message. This should stop the build process.
	 */
	public function error(message:String):Void
	{
		Sys.stderr().write(Bytes.ofString(' ERROR ' + " " + message));
		Sys.exit(1);
	}

	/**
	 * Display an info message. This should not interfere with the build process.
	 */
	public function info(message:String):Void
	{
		if (!(isDisplay() || isClean()))
		{
			Sys.println(' INFO ' + " " + message);
		}
	}

	/**
	 * Display a warning message. This should not interfere with the build process.
	 */
	public function warn(message:String):Void
	{
		if (!(isDisplay() || isClean()))
		{
			Sys.println(' WARNING ' + " " + message);
		}
	}

	/**
	 * Call a Haxe build macro.
	 */
	public function addHaxeMacro(value:String):Void
	{
		addHaxeFlag('--macro ${value}');
	}

	/**
	 * Add an icon to the project.
	 * @param icon The path to the icon.
	 * @param size The size of the icon. Optional.
	 */
	public function addIcon(icon:String, ?size:Int):Void
	{
		this.icons.push(new Icon(icon, size));
	}

	/**
	 * Add a `haxeflag` to the project.
	 */
	public function addHaxeFlag(value:String):Void
	{
		this.haxeflags.push(value);
	}

	// --------------------------------------------------------------
	// FeatureFlag helpers
	// --------------------------------------------------------------

	/**
	 * Set a haxedef by name. Used by FeatureFlag.enable() via `project.setHaxedef()`.
	 */
	public function setHaxedef(name:String, value:String = ""):Void
	{
		haxedefs.set(name, value);
	}

	/**
	 * Remove a haxedef by name. Used by FeatureFlag.disable() via `project.unsetHaxedef()`.
	 */
	public function unsetHaxedef(name:String):Void
	{
		haxedefs.remove(name);
	}

	// --------------------------------------------------------------
	// addHaxelib
	// Replaces `haxelibs.push (new Haxelib (name, version))` call sites
	// with a single helper that also accepts an inline condition, so a
	// <haxelib name="X" if="..."/> becomes one line instead of an
	// if-block wrapping a push.
	// --------------------------------------------------------------
	function addHaxelib(name:String, version:String = null):Void
	{
		haxelibs.push(new Haxelib(name, version));
	}

	function embedAssetPath(path:String, rename:Null<String> = null)
	{
		addAssetPath(path, rename, null, true);
	}

	/**
	 * Add an asset to the game build.
	 * @param path The path the asset is located at.
	 * @param rename The path the asset should be placed.
	 * @param library The asset library to add the asset to. `null` = "default"
	 * @param embed Whether to embed the asset in the executable.
	 * @param padName The name of the Play Assets Delivery that this asset will be added to. (Android only)
	 */
	public function addAsset(path:String, ?rename:String, ?library:String, embed:Bool = false):Void
	{
		if(rename == null) rename == path;
		// path, rename, type, embed, setDefaults
		if (Path.extension(path) == 'png' && EXPERIMENT_COMPRESSED_TEXTURES.isEnabled())
		{
			final astcPath:String = "astc-textures/" + path.substr(0, path.length - 3) + "astc";
			if (!isASTCExcluded(path) && FileSystem.exists(astcPath))
			{
				path = astcPath;

				if (rename != null)
					rename = rename.substr(0, rename.length - 3) + "astc";
			}
		}
		
		var asset = new Asset(path, rename, null, embed, true);
		@:nullSafety(Off)
		{
			asset.library = library ?? "default";
		}
		this.assets.push(asset);
	}

	/**
	 * Remove an asset from the game build.
	 * @param path The path the asset is located at.
	 */
	public function removeAsset(path:String, ?library:String):Void
	{
		for (asset in this.assets)
		{
			if (asset.sourcePath == path)
			{
				if (library != null && asset.library != library)
					continue;

				this.assets.remove(asset);
				// info("Removed asset: " + path);
				break;
			}
		}
	}

	/**
	 * Add an entire path of assets to the game build.
	 * @param path The path the assets are located at.
	 * @param rename The path the assets should be placed.
	 * @param library The asset library to add the assets to. `null` = "default"
	 * @param include An optional array to include specific asset names.
	 * @param exclude An optional array to exclude specific asset names.
	 * @param embed Whether to embed the assets in the executable.
	 * @param padName The name of the Play Assets Delivery that this asset path will be added to. (Android only)
	 */
	public function addAssetPath(path:String, ?rename:String, ?library:String, ?include:Array<String>, ?exclude:Array<String>, embed:Bool = false,
			?padName:String):Void
	{
		// Argument parsing.
		if (path == "")
			return;

		if (include == null)
			include = ["*"];

		if (exclude == null)
			exclude = [];

		//? Added this
		exclude = exclude.concat(EXCLUDE_ASSETS);

		var targetPath = rename ?? path;
		if (targetPath != "")
			targetPath += "/";

		// Validate path.
		if (!sys.FileSystem.exists(path))
		{
			error('Could not find asset path "${path}".');
		}
		else if (!sys.FileSystem.isDirectory(path))
		{
			error('Could not parse asset path "${path}", expected a directory.');
		}
		else
		{
			//info(' Found asset path "${path}".');
		}

		for (file in sys.FileSystem.readDirectory(path))
		{
			if (sys.FileSystem.isDirectory('${path}/${file}'))
			{
				// Attempt to recursively add all assets in the directory.
				if (this.filter(file, ["*"], exclude))
				{
					addAssetPath('${path}/${file}', '${targetPath}${file}', library, include, exclude, embed);
				}
			}
			else
			{
				if (this.filter(file, include, exclude))
				{
					addAsset('${path}/${file}', '${targetPath}${file}', library, embed);
				}
			}
		}
	}

	/**
	 * Remove all assets in a path recursively from the game build.
	 * @param path The path the assets are located at.
	 * @param library (optional) The asset library to remove the assets from. Defaults to all libraries.
	 */
	public function removeAssetPath(path:String, ?library:String):Void
	{
		// Argument parsing.
		if (path == "")
			return;

		// Validate path.
		if (!sys.FileSystem.exists(path))
		{
			error('Could not find asset path "${path}".');
		}
		else if (!sys.FileSystem.isDirectory(path))
		{
			error('Could not parse asset path "${path}", expected a directory.');
		}
		else
		{
			// info('  Found asset path "${path}".');
		}

		for (exclude in EXCLUDE_ASSETS)
		{
			// Surely Eric got a better way to solve this.
			if (path.contains(exclude.replace('*', '')))
				return;
		}

		for (file in sys.FileSystem.readDirectory(path))
		{
			if (sys.FileSystem.isDirectory('${path}/${file}'))
			{
				// Attempt to recursively remove all assets in the directory.
				removeAssetPath('${path}/${file}', library);
			}
			else
			{
				removeAsset('${path}/${file}', library);
			}
		}
	}
}

/**
 * An object representing a feature flag, which can be enabled or disabled.
 * Includes features such as automatic generation of compile defines and inversion.
 */
abstract FeatureFlag(String) from String to String
{
	public static final INVERSE_PREFIX:String = "NO_";
	public static var project:Project;

	public function new(input:String)
	{
		this = input;
	}

	@:from
	public static function fromString(input:String):FeatureFlag
	{
		return new FeatureFlag(input);
	}

	/**
	 * Enable/disable a feature flag if it is unset, and handle the inverse flag.
	 * Doesn't override a feature flag that was set explicitly.
	 * @param enableByDefault Whether to enable this feature flag if it is unset.
	 */
	public function apply(enableByDefault:Bool = false):Void
	{
		if (isEnabled())
		{
			// If this flag was already enabled, disable the inverse.
			getInverse().disable(false);
		}
		else if (getInverse().isEnabled())
		{
			// If the inverse flag was already enabled, disable this flag.
			disable(false);
		}
		else
		{
			if (enableByDefault)
			{
				// Enable this flag if it was unset, and disable the inverse.
				enable(true);
			}
			else
			{
				// Disable this flag if it was unset, and enable the inverse.
				disable(true);
			}
		}
	}

	/**
	 * Enable this feature flag by setting the appropriate compile define.
	 * @param andInverse Also disable the feature flag's inverse.
	 */
	public function enable(andInverse:Bool = true)
	{
		project.setHaxedef(this, "");
		if (andInverse)
		{
			getInverse().disable(false);
		}
	}

	/**
	 * Disable this feature flag by removing the appropriate compile define.
	 * @param andInverse Also enable the feature flag's inverse.
	 */
	public function disable(andInverse:Bool = true)
	{
		project.unsetHaxedef(this);
		if (andInverse)
		{
			getInverse().enable(false);
		}
	}

	/**
	 * Query if this feature flag is enabled.
	 */
	public function isEnabled():Bool
	{
		// Check both Haxedefs and Defines for this flag.
		return project.haxedefs.exists(this) || project.defines.exists(this);
	}

	/**
	 * Query if this feature flag's inverse is enabled.
	 */
	public function isDisabled():Bool
	{
		return getInverse().isEnabled();
	}

	/**
	 * Return the inverse of this feature flag.
	 * @return A new feature flag that is the inverse of this one.
	 */
	public function getInverse():FeatureFlag
	{
		if (this.startsWith(INVERSE_PREFIX))
		{
			return this.substring(INVERSE_PREFIX.length);
		}
		return INVERSE_PREFIX + this;
	}
}
