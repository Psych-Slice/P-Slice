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
	 * @param rangeStart what percent of the song should it start at
	 * @param rangeEnd what percent of the song should it end at
	 * @return Future<Sound>
	 */
	public static function partialLoadFromFile(path:String, ?rangeStart:Float = 0, ?rangeEnd:Float = 1, ?paddedIntro:Bool = false):Promise<Sound>
	{
		var promise:Promise<Sound> = new Promise<Sound>();

		if (Assets.cache.hasSound(path + ".partial-" + rangeStart + "-" + rangeEnd))
		{
			promise.complete(Assets.cache.getSound(path + ".partial-" + rangeStart + "-" + rangeEnd));
			return promise;
		}

		#if web
		requestContentLength(path).onComplete(function(contentLength:Int)
		{
			var startByte:Int = Std.int(contentLength * rangeStart);
			var endByte:Int = Std.int(contentLength * rangeEnd);
			var byteRange:String = startByte + '-' + endByte;

			// for ogg files, we want to get a certain amount of header info stored at the beginning of the file
			// which I believe helps initiate the audio stream properly for any section of audio
			// 0-6400 is a random guess, could be fuckie with other audio
			if (Path.extension(path) == "ogg")
				byteRange = '0-' + Std.string(16 * 400);

			var http = new HTTPRequest<Bytes>(path);
			var rangeHeader:HTTPRequestHeader = new HTTPRequestHeader("Range", "bytes=" + byteRange);
			http.headers.push(rangeHeader);

			http.load().onComplete(function(data:Bytes)
			{
				var audioBuffer:AudioBuffer = new AudioBuffer();
				switch (Path.extension(path))
				{

					case "ogg":
						var httpFull = new HTTPRequest<Bytes>(path);

						rangeHeader = new HTTPRequestHeader("Range", "bytes=" + startByte + '-' + endByte);
						httpFull.headers.push(rangeHeader);
						httpFull.load().onComplete(function(fullOggData)
						{
							var cleanIntroBytes = cleanOggBytes(data);
							var cleanFullBytes = cleanOggBytes(fullOggData);
							var fullBytes = Bytes.alloc(cleanIntroBytes.length + cleanFullBytes.length);
							fullBytes.blit(0, cleanIntroBytes, 0, cleanIntroBytes.length);
							fullBytes.blit(cleanIntroBytes.length, cleanFullBytes, 0, cleanFullBytes.length);

							audioBuffer = parseBytesOgg(fullBytes, true);
							Assets.cache.setSound(path + ".partial-" + rangeStart + "-" + rangeEnd, Sound.fromAudioBuffer(audioBuffer));
							promise.complete(Sound.fromAudioBuffer(audioBuffer));
						});

					default:
						promise.error("Unsupported file type: " + Path.extension(path));
				}
			});
		});

		return promise;
		#else
		if (!FileSystem.exists(path) && !Assets.exists(path))
		{
			FlxG.log.warn("Could not find audio file for partial playback: " + path);
			return null;
		}

		var byteNum:Int = 0;

		// on native, it will always be an ogg file, although eventually we might want to add WAV?
		loadBytes(path).onComplete(function(data:Bytes)
		{
			var input = new BytesInput(data);

			#if !hl
			@:privateAccess
			var size = input.b.length;
			#else
			var size = input.length;
			#end

			switch (Path.extension(path))
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
							@:privateAccess{
								oggBytesIntro.b.clear();
								fullAssOgg.b.clear();
							}
							input.close();

							var audioBuffer:AudioBuffer = parseBytesOgg(oggFullBytes, true);

							var sndShit = Sound.fromAudioBuffer(audioBuffer);
							Assets.cache.setSound(path + ".partial-" + rangeStart + "-" + rangeEnd, sndShit);
							promise.complete(sndShit);
						});
					});

				default:
					promise.error("Unsupported file type: " + Path.extension(path));
			}
		});

		return promise;
		#end
	}

	static function requestContentLength(path:String):Future<Int>
	{
		var promise:Promise<Int> = new Promise<Int>();
		var fileLengthInBytes:Int = 0;
		var httpFileLength = new HTTPRequest<Bytes>(path);
		httpFileLength.headers.push(new HTTPRequestHeader("Accept-Ranges", "bytes"));
		httpFileLength.method = HEAD;
		httpFileLength.enableResponseHeaders = true;

		httpFileLength.load(path).onComplete(function(data:Bytes)
		{
			var contentLengthHeader:HTTPRequestHeader = httpFileLength.responseHeaders.filter(function(header:HTTPRequestHeader)
			{
				return header.name == "content-length";
			})[0];

			promise.complete(Std.parseInt(contentLengthHeader.value));
		});

		return promise.future;
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

		@:privateAccess
		#if js
		data.b.slice(0,0);
		#else
		data.b.clear();
		#end
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
}