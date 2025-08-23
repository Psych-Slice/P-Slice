package mikolka.funkin.sound;

import flixel.FlxG;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.Path;
import lime.app.Future;
import lime.app.Promise;
import lime.media.AudioBuffer;
import lime.net.HTTPRequest;
import lime.net.HTTPRequestHeader;
import openfl.media.Sound;
import openfl.utils.Assets;
#if (target.threaded)
import lime.system.ThreadPool;
#end
#if sys
import sys.io.File;
import sys.FileSystem;
#end
#if lime_vorbis
import lime.media.vorbis.VorbisFile;
#end
#if lime_vorbis
import lime.media.vorbis.VorbisFile;
#end

using StringTools;

class FlxPartialSound
{
	/**
	 * Loads partial sound bytes from a file, returning a Sound object.
	 * Will play the sound after loading via FlxG.sound.play()
	 * @param path
	 * @param rangeStart what percent of the song should it start at
	 * @param rangeEnd what percent of the song should it end at
	 * @return Future<Sound>
	 */
	public static function partialLoadAndPlayFile(path:String, ?rangeStart:Float = 0, ?rangeEnd:Float = 1):Future<Sound>
	{
		return partialLoadFromFile(path, rangeStart, rangeEnd).future.onComplete(function(sound:Sound)
		{
			FlxG.sound.play(sound);
		});
	}

	/**
	 * Loads partial sound bytes from a file, returning a Sound object.
	 * Will load via HTTP Range header on HTML5, and load the bytes from the file on native.
	 * On subsequent calls, will return a cached Sound object from Assets.cache
	 * @param path
	 * @param rangeStart what percent of the song (between 0 and 1) should it start at
	 * @param rangeEnd what percent of the song should it end at
	 * @return Future<Sound>
	 */
	public static function partialLoadFromFile(audioPath:String, ?rangeStart:Float = 0, ?rangeEnd:Float = 1, ?paddedIntro:Bool = false):Promise<Sound>
	{
		var promise:Promise<Sound> = new Promise<Sound>();
		var cacheName:String = audioPath + ".partial-" + rangeStart + "-" + rangeEnd;

		#if sys
		if (FileSystem.exists(getCacheDir() + cacheName.replace(':', '/') + '.ogg') && !Assets.cache.hasSound(cacheName))
		{
			var oggFullBytes:Bytes = File.getBytes(getCacheDir() + cacheName.replace(':', '/') + '.ogg');
			var audioBuffer:AudioBuffer = parseBytesOgg(oggFullBytes, true);
			Assets.cache.setSound(cacheName, Sound.fromAudioBuffer(audioBuffer));
		}
		#end

		if (Assets.cache.hasSound(cacheName))
		{
			promise.complete(Assets.cache.getSound(cacheName));
			return promise;
		}

		#if web
		partialLoadHttp(audioPath, promise, rangeStart, rangeEnd, cacheName);
		#else
		if (!FileSystem.exists(audioPath) && !Assets.exists(audioPath))
		{
			FlxG.log.warn("Could not find audio file for partial playback: " + audioPath);
			return null;
		}

		// streaming audio has been iffy on windows, need to investigate further
		#if (lime_vorbis && !windows)
		var vorb:VorbisFile = VorbisFile.fromFile(audioPath);
		var snd = Sound.fromAudioBuffer(AudioBuffer.fromVorbisFile(vorb));
		promise.complete(snd);
		#else
		var byteNum:Int = 0;
		// on native, it will always be an ogg file, although eventually we might want to add WAV?
		loadBytes(audioPath).onComplete(function(data:Bytes)
		{
			var input = new BytesInput(data);

			#if !hl
			@:privateAccess
			var size = input.b.length;
			#else
			var size = input.length;
			#end

			switch (Path.extension(audioPath))
			{
				case "ogg":
					var oggBytesAsync = new Future<Bytes>(function()
					{
						var oggBytesIntro = Bytes.alloc(16 * 400);
						while (byteNum < 16 * 400)
						{
							oggBytesIntro.set(byteNum, input.readByte());
							byteNum++;
						}
						return cleanOggBytes(oggBytesIntro);
					}, true);

					oggBytesAsync.onComplete(function(oggBytesIntro:Bytes)
					{
						var oggRangeMin:Float = rangeStart * size;
						var oggRangeMax:Float = rangeEnd * size;
						var oggBytesFull = Bytes.alloc(Std.int(oggRangeMax - oggRangeMin));

						byteNum = 0;

						input.position = Std.int(oggRangeMin);

						var fullBytesAsync = new Future<Bytes>(function()
						{
							while (byteNum < oggRangeMax - oggRangeMin)
							{
								oggBytesFull.set(byteNum, input.readByte());
								byteNum++;
							}

							return cleanOggBytes(oggBytesFull);
						}, true);

						fullBytesAsync.onComplete(function(fullAssOgg:Bytes)
						{
							var oggFullBytes = Bytes.alloc(oggBytesIntro.length + fullAssOgg.length);
							oggFullBytes.blit(0, oggBytesIntro, 0, oggBytesIntro.length);
							oggFullBytes.blit(oggBytesIntro.length, fullAssOgg, 0, fullAssOgg.length);
							input.close();

							FileSystem.createDirectory(Path.directory(getCacheDir() + audioPath.replace(':', '/')));
							File.saveBytes(getCacheDir() + cacheName.replace(':', '/') + '.ogg', oggFullBytes);

							var audioBuffer:AudioBuffer = parseBytesOgg(oggFullBytes, true);
							var sndShit = Sound.fromAudioBuffer(audioBuffer);
							Assets.cache.setSound(cacheName, sndShit);
							promise.complete(sndShit);
						});
					});

				default:
					promise.error("Unsupported file type: " + Path.extension(audioPath));
			}
		});
		#end
		#end
		return promise;
	}

	static function partialLoadHttp(audioPath:String, promise:Promise<Sound>, rangeStart, rangeEnd, cacheName)
	{
		requestContentLength(audioPath).onComplete(function(contentLength:Int)
		{
			var startByte:Int = Std.int(contentLength * rangeStart);
			var endByte:Int = Std.int(contentLength * rangeEnd);
			var byteRange:String = startByte + '-' + endByte;

			// for ogg files, we want to get a certain amount of header info stored at the beginning of the file
			// which I believe helps initiate the audio stream properly for any section of audio
			// 0-6400 is a random guess, could be fuckie with other audio
			if (Path.extension(audioPath) == "ogg")
				byteRange = '0-' + Std.string(16 * 400);

			var rangeHeader:HTTPRequestHeader = new HTTPRequestHeader("Range", "bytes=" + byteRange);
			var http = new HTTPRequest<Bytes>(audioPath);
			http.headers.push(rangeHeader);

			http.load().onComplete(function(data:Bytes)
			{
				switch (Path.extension(audioPath))
				{
					case "mp3":
						var mp3Data = parseBytesMp3(data, startByte);
						var snd = Sound.fromAudioBuffer(mp3Data.buf);
						Assets.cache.setSound(cacheName, snd);
						PartialSoundMetadata.instance.set(audioPath + rangeStart, {kbps: mp3Data.kbps, introOffsetMs: mp3Data.introLengthMs});
						promise.complete(snd);

					case "ogg":
						rangeHeader = new HTTPRequestHeader("Range", "bytes=" + startByte + '-' + endByte);

						var httpFull = new HTTPRequest<Bytes>(audioPath);
						httpFull.headers.push(rangeHeader);
						httpFull.load().onComplete(function(fullOggData)
						{
							var cleanIntroBytes = cleanOggBytes(data);
							var cleanFullBytes = cleanOggBytes(fullOggData);
							var fullBytes = Bytes.alloc(cleanIntroBytes.length + cleanFullBytes.length);
							fullBytes.blit(0, cleanIntroBytes, 0, cleanIntroBytes.length);
							fullBytes.blit(cleanIntroBytes.length, cleanFullBytes, 0, cleanFullBytes.length);

							var snd = Sound.fromAudioBuffer(parseBytesOgg(fullBytes, true));
							Assets.cache.setSound(cacheName, snd);
							promise.complete(snd);
						});

					default:
						promise.error("Unsupported file type: " + Path.extension(audioPath));
				}
			});
		});
	}

	static function requestContentLength(path:String):Future<Int>
	{
		var promise:Promise<Int> = new Promise<Int>();
		var httpFileLength = new HTTPRequest<Bytes>(path);
		httpFileLength.headers.push(new HTTPRequestHeader("Accept-Ranges", "bytes"));
		httpFileLength.method = HEAD;
		httpFileLength.enableResponseHeaders = true;

		httpFileLength.load(path).onComplete(_ ->
		{
			var contentLengthHeader:HTTPRequestHeader = httpFileLength.responseHeaders.filter(function(header:HTTPRequestHeader)
			{
				return header.name == "content-length";
			})[0];

			promise.complete(Std.parseInt(contentLengthHeader.value));
		});

		return promise.future;
	}

	/**
	 * Parses bytes from a partial mp3 file, and returns an AudioBuffer with proper sound data.
	 * @param data bytes from an MP3 file
	 * @param startByte how many bytes into the original audio are we reading from, to use to calculate extra metadata (introLengthMs)
	 * @return {buf:AudioBuffer, kbps:Int, introLengthMs:Int} AudioBuffer, kbps of the audio, and the length of the intro in milliseconds
	 */
	public static function parseBytesMp3(data:Bytes, ?startByte:Int = 0):{buf:AudioBuffer, ?kbps:Int, ?introLengthMs:Int}
	{
		// need to find the first "frame" of the mp3 data, which would be a byte with the value 255
		// followed by a byte with the value where the value is 251, 250, or 243
		// reading
		// http://www.multiweb.cz/twoinches/mp3inside.htm#FrameHeaderA
		// http://mpgedit.org/mpgedit/mpeg_format/MP3Format.html
		// we start it as -1 so we can check the very first frame bytes (byte 0)
		var frameSyncBytePos = -1;
		// unsure if we need to keep track of the last frame, but doing so just in case
		var lastFrameSyncBytePos = 0;

		// BytesInput to read front to back of the data easier
		var byteInput:BytesInput = new BytesInput(data);

		// How many mp3 frames we found
		var frameCount:Int = 0;

		var bitrateAvg:Map<Int, Int> = new Map();

		for (byte in 0...data.length)
		{
			var byteValue = byteInput.readByte();
			var nextByte = data.get(byte + 1);

			// the start of a frame sync, which should be a byte with all bits set to 1 (255)
			if (byteValue == 255)
			{
				var mpegVersion = (nextByte & 0x18) >> 3; // gets the 4th and 5th bits of the next byte, for MPEG version
				var nextFrameSync = (nextByte & 0xE0) >> 5; // gets the first 3 bits of the next byte, which should be 111

				// i stole the values from "nextByte" from how Lime checks for valid mp3 frame data
				if (nextFrameSync == 7 && (nextByte == 251 || nextByte == 250 || nextByte == 243))
				{
					frameCount++;

					var byte2 = data.get(byte + 2);
					var bitrateIndex = (byte2 & 0xF0) >> 4;
					var bitrateArray = [0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320];
					var bitrate = bitrateArray[bitrateIndex];

					var samplingRateIndex = (byte2 & 0x0C) >> 2;
					var sampleRateArray = [44100, 48000, 32000];
					var sampleRate = sampleRateArray[samplingRateIndex];

					bitrateAvg[bitrate] = bitrateAvg.exists(bitrate) ? bitrateAvg.get(bitrate) + 1 : 1;

					if (frameSyncBytePos == -1)
						frameSyncBytePos = byte;

					// assume this byte is the last frame sync byte we'll find
					lastFrameSyncBytePos = byte;
				}
			}
		}

		// what we'll actually return
		var outputInfo:Dynamic = {};

		var mostCommonBitrate = 0;
		for (bitrate in bitrateAvg.keys())
		{
			if (bitrateAvg.get(bitrate) > bitrateAvg.get(mostCommonBitrate))
				mostCommonBitrate = bitrate;
		}

		// bitrate is in bits rather than kilobits, so we're getting the milliseconds of the intro
		// also since it's in bits, we divide by 8 to get bytes
		var introLengthMs:Int = Math.round(startByte / (mostCommonBitrate / 8));

		// length of an mp3 frame in milliseconds
		var frameLengthMs:Float = 26;

		// how many frames we need to pad the intro with
		var framesNeeded = Math.floor(introLengthMs / frameLengthMs);

		outputInfo.introLengthMs = introLengthMs;
		outputInfo.kbps = mostCommonBitrate;

		var bytesLength = lastFrameSyncBytePos - frameSyncBytePos;
		var bufferBytes = Bytes.alloc(bytesLength + 1);
		bufferBytes.blit(0, data, frameSyncBytePos, bytesLength);

		outputInfo.buf = AudioBuffer.fromBytes(bufferBytes);
		return outputInfo;
	}

	public static function parseBytesOgg(data:Bytes, skipCleaning:Bool = false):AudioBuffer
	{
		var cleanedBytes = skipCleaning ? data : cleanOggBytes(data);
		return AudioBuffer.fromBytes(cleanedBytes);
	}

	static function cleanOggBytes(data:Bytes):Bytes
	{
		var byteInput:BytesInput = new BytesInput(data);
		var firstByte:Int = -1;
		var lastByte:Int = -1;
		var oggString:String = "";

		for (byte in 0...data.length)
		{
			var byteValue = byteInput.readByte();

			if (byteValue == "O".code || byteValue == "g".code || byteValue == "S".code)
				oggString += String.fromCharCode(byteValue);
			else
				oggString = "";

			if (oggString == "OggS")
			{
				if (firstByte == -1)
				{
					firstByte = byte - 3;
					data.set(byte + 2, 2);
				}

				lastByte = byte - 3;

				var version = data.get(byte + 1);
				var headerType = data.get(byte + 2);
			}
		}

		var byteLength = lastByte - firstByte;
		var output = Bytes.alloc(byteLength + 1);
		output.blit(0, data, firstByte, byteLength);

		return output;
	}

	#if (target.threaded)
	public static function loadBytes(path:String):Future<Bytes>
	{
		var promise = new Promise<Bytes>();
		var threadPool = new ThreadPool();
		var bytes:Null<Bytes> = null;

		function doWork(state:Dynamic)
		{
			if ((!FileSystem.exists(path) && !Assets.exists(path)) || path == null)
				threadPool.sendError({path: path, promise: promise, error: "ERROR: Failed to load bytes for Asset " + path + " Because it dosen't exist."});
			else
			{
				if (FileSystem.exists(path))
				{
					bytes = File.getBytes(path);
				}
				else
				{
					bytes = Assets.getBytes(path);
				}

				if (bytes != null)
				{
					threadPool.sendProgress({
						path: path,
						promise: promise,
						bytesLoaded: bytes.length,
						bytesTotal: bytes.length
					});

					threadPool.sendComplete({path: path, promise: promise, result: bytes});
				}
				else
				{
					threadPool.sendError({path: path, promise: promise, error: "Cannot load file: " + path});
				}
			}
		}

		function onProgress(state:Dynamic)
		{
			if (promise.isComplete || promise.isError)
				return;
			promise.progress(state.bytesLoaded, state.bytesTotal);
		}

		function onComplete(state:Dynamic)
		{
			if (promise.isError)
				return;
			promise.complete(bytes);
		}

		threadPool.doWork.add(doWork);
		threadPool.onProgress.add(onProgress);
		threadPool.onComplete.add(onComplete);
		threadPool.onError.add((state:Dynamic) -> promise.error({error: state.error, responseData: null}));

		threadPool.queue({});

		return promise.future;
	}
	#end

	/**
	 * @return String the platforms temp/cache directory.
	 */
	static function getCacheDir():String
	{
		#if sys
		#if windows
		return Path.addTrailingSlash(Sys.getEnv("TEMP"));
		#elseif (android || iphoneos)
		return Path.addTrailingSlash(PathTool.getCacheDirectory());
		#elseif mac
		return Path.addTrailingSlash(Sys.getEnv("TMPDIR"));
		#elseif linux
		return "/tmp/";
		#else
		return ".cache/";
		#end
		#end
	}
}

#if (android || (iphoneos && cpp))
#if (iphoneos && cpp)
@:buildXml('<include name="${haxelib:FlxPartialSound}/extern/Build.xml" />')
@:include('PathTool.hpp')
@:unreflective
#end
private #if (iphoneos && cpp) extern #end class PathTool
{
	#if (iphoneos && cpp)
	@:native('getCacheDirectory')
	static function getCacheDirectory():cpp.ConstCahrStar;
	#end

	#if android
	@:noCompletion
	public static inline function getCacheDirectory():String
	{
		var context:Dynamic = lime.system.JNI.createStaticField('org/libsdl/app/SDL', 'mContext', 'Landroid/content/Context;').get();
		var dir:Dynamic = lime.system.JNI.callMember(lime.system.JNI.createMemberMethod('android/content/Context', 'getCacheDir', '()Ljava/io/File;'),
			context, []);
		return getAbsolutePath(dir);
	}

	@:noCompletion
	private static inline function getAbsolutePath(file:Dynamic):String
	{
		return lime.system.JNI.callMember(lime.system.JNI.createMemberMethod('java/io/File', 'getAbsolutePath', '()Ljava/lang/String;'), file, []);
	}
	#end
}
#end
