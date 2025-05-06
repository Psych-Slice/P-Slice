package mikolka.vslice.components;

import lime.system.System;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
#if android
import lime.system.JNI;
#end

/*
A class that simply points OpenALSoft to a custom configuration file when the game starts up.
The config overrides a few global OpenALSoft settings with the aim of improving audio quality on desktop targets.
*/
#if (!macro && android)
@:build(mikolka.vslice.components.ALSoftConfig.setupConfig())
#end
class ALSoftConfig
{
	#if (desktop || android)
	#if android
	private static final ANDROID_OPENAL_CONFIG:String = '';
	#end

	public static function init():Void
	{
		var origin:String = #if android System.applicationStorageDirectory #elseif hl Sys.getCwd() #else Sys.programPath() #end;

		var configPath:String = Path.directory(Path.withoutExtension(origin));
		#if windows
		configPath += "/plugins/alsoft.ini";
		#elseif mac
		configPath = Path.directory(configPath) + "/Resources/plugins/alsoft.conf";
		#elseif android
		configPath = origin + 'openal/alsoft.conf';
		FileSystem.createDirectory(Path.directory(configPath));
		File.saveContent(configPath, ANDROID_OPENAL_CONFIG);
		JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'nativeSetenv', '(Ljava/lang/String;Ljava/lang/String;)V')("ALSOFT_CONF", configPath);
		#else
		configPath += "/plugins/alsoft.conf";
		#end

		#if !android
		Sys.putEnv("ALSOFT_CONF", configPath);
		#end
	}
	#end

	#if macro
	public static function setupConfig()
	{
		var fields = Context.getBuildFields();
		var pos = Context.currentPos();

		if (!FileSystem.exists('alsoft.txt')) return fields;

		var newFields = fields.copy();
		for (i => field in fields)
		{
			if (field.name == 'ANDROID_OPENAL_CONFIG')
			{
				newFields[i] = {
					name: 'ANDROID_OPENAL_CONFIG',
					access: [APrivate, AStatic, AFinal],
					kind: FVar(macro :String, macro $v{File.getContent('alsoft.txt')}),
					pos: pos,
				};
			}
		}

		return newFields;
	}
	#end
}