package animate;

import animate.FlxAnimateJson.AnimationJson;
import haxe.Json;
import animate.FlxAnimateController.FlxAnimateAnimation;
import animate.FlxAnimateFrames.FlxAnimateSettings;
import animate.internal.Frame;
import animate.internal.StageBG;
import animate.internal.Timeline;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxAngle;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxDestroyUtil;
import haxe.io.Path;
import openfl.display.BitmapData;

using flixel.util.FlxColorTransformUtil;

#if !flash
import animate.internal.RenderTexture;
#end
#if FLX_DEBUG
import flixel.FlxBasic;
#end

class FlxAnimate extends FlxSprite
{
	/**
	 * Whether to draw the hitboxes of limbs in a Texture Atlas animation.
	 */
	public static var drawDebugLimbs:Bool = false;

	/**
	 * Change the skew of your sprite's graphic.
	 */
	public var skew(default, null):FlxPoint;

	/**
	 * Class that handles adding and playing animations on this sprite.
	 * Can be interchanged or act as a replacement of ``animation``.
	 * Only exists as a way to access missing add animation functions for Texture Atlas.
	 */
	public var anim(default, set):FlxAnimateController = null;

	/**
	 * Class that contains all the animation data for a Texture Atlas.
	 * Can be used to get symbol items, timelines, etc.
	 */
	public var library(default, null):FlxAnimateFrames;

	/**
	 * Whether the sprite is currently handling a Texture Atlas animation or not.
	 */
	public var isAnimate(default, null):Bool = false;

	/**
	 * Current ``Timeline`` object being rendered from a Texture Atlas animation.
	 */
	public var timeline(default, null):Timeline;

	/**
	 * Whether to apply the stage matrix of the Texture Atlas.
	 * It also makes the sprite render with the bounds from Animate.
	 * Take note that these bounds may not be accurate to flixel positions.
	 */
	public var applyStageMatrix(default, set):Bool = false;

	/**
	 * Whether to render the colored background rectangle found in Adobe Animate.
	 * Only available for Texture Atlases exported using BetterTextureAtlas.
	 * @see https://github.com/Dot-Stuff/BetterTextureAtlas
	 */
	public var renderStage:Bool = false;

	/**
	 * Whether to internally use a render texture when drawing the Texture Atlas.
	 * This flattens all of the limbs into a single graphic, making effects such as alpha or shaders apply to
	 * the entire sprite instead of individual limbs.
	 * Only supported on targets that use `renderTile`.
	 */
	public var useRenderTexture:Bool = false;

	#if !flash
	var _renderTexture:RenderTexture;
	#end
	var _renderTextureDirty:Bool = true;

	/**
	 * Creates a `FlxAnimate` at a specified position with a specified one-frame graphic or Texture Atlas path.
	 * If none is provided, a 16x16 image of the HaxeFlixel logo is used.
	 *
	 * @param   x               The initial X position of the sprite.
	 * @param   y               The initial Y position of the sprite.
	 * @param   simpleGraphic   (OPTIONAL) The graphic or Texture Atlas you want to display.
	 * @param	settings		(OPTIONAL) The settings used to load the Texture Atlas from ``simpleGraphic``.
	 *
	 */
	public function new(?x:Float = 0, ?y:Float = 0, ?simpleGraphic:FlxGraphicAsset, ?settings:FlxAnimateSettings)
	{
		var loadedAnimateAtlas:Bool = false;
		if (simpleGraphic != null && simpleGraphic is String)
		{
			if (Path.extension(simpleGraphic).length == 0)
				loadedAnimateAtlas = true;
		}

		super(x, y, loadedAnimateAtlas ? null : simpleGraphic);

		if (loadedAnimateAtlas){
			var animData:AnimationJson = null;
			try
			{
				animData = Json.parse(simpleGraphic);
				frames = FlxAnimateFrames.fromAnimate(animData, null, null, null, false, settings);
			}
			catch (e)
			{
				FlxG.log.warn('Couldnt load Animation.json with input "$animation". Is the texture atlas missing?');
			}
		}
	}

	override function initVars()
	{
		super.initVars();
		anim = new FlxAnimateController(this);
		skew = new FlxPoint();
		animation = anim;
	}

	override function set_frames(frames:FlxFramesCollection):FlxFramesCollection
	{
		isAnimate = (frames != null) && (frames is FlxAnimateFrames);

		var resultFrames = super.set_frames(frames);

		if (isAnimate)
		{
			library = cast frames;
			timeline = library.timeline;
			applyStageMatrix = this.applyStageMatrix;
			resetHelpers();
		}
		else
		{
			library = null;
			timeline = null;
		}

		return resultFrames;
	}

	override function draw():Void
	{
		if (!isAnimate)
		{
			super.draw();
			return;
		}

		if (alpha <= 0.0 || Math.abs(scale.x) <= 0.0 || Math.abs(scale.y) <= 0.0)
			return;

		for (camera in #if (flixel >= "5.7.0") this.getCamerasLegacy() #else this.cameras #end)
		{
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
				continue;

			drawAnimate(camera);

			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

	function drawAnimate(camera:FlxCamera):Void
	{
		#if flash
		var willUseRenderTexture:Bool = false;
		#else
		var willUseRenderTexture:Bool = useRenderTexture && (alpha != 1 || shader != null || (blend != null && blend != NORMAL));
		#end

		var matrix = _matrix;
		matrix.identity();

		@:privateAccess
		var bounds = timeline._bounds;
		if (!willUseRenderTexture)
			matrix.translate(-bounds.x, -bounds.y);

		if (checkFlipX())
		{
			matrix.scale(-1, 1);
			matrix.translate(bounds.width, 0);
		}

		if (checkFlipY())
		{
			matrix.scale(1, -1);
			matrix.translate(0, bounds.height);
		}

		if (applyStageMatrix)
		{
			matrix.concat(library.matrix);
			matrix.translate(-library.matrix.tx, -library.matrix.ty);
		}

		matrix.translate(-origin.x, -origin.y);
		matrix.scale(scale.x, scale.y);

		if (angle != 0)
		{
			updateTrig();
			matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		if (skew.x != 0 || skew.y != 0)
		{
			updateSkew();
			matrix.concat(_skewMatrix);
		}

		getScreenPosition(_point, camera);
		_point.x += origin.x - offset.x;
		_point.y += origin.y - offset.y;
		matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera))
			preparePixelPerfectMatrix(matrix);

		if (renderStage)
			drawStage(camera);

		timeline.currentFrame = animation.frameIndex;

		#if !flash
		if (willUseRenderTexture)
		{
			if (_renderTexture == null)
				_renderTexture = new RenderTexture(Math.ceil(bounds.width), Math.ceil(bounds.height));

			if (_renderTextureDirty)
			{
				_renderTexture.init(Math.ceil(bounds.width), Math.ceil(bounds.height));
				_renderTexture.drawToCamera((camera, matrix) ->
				{
					matrix.translate(-bounds.x, -bounds.y);
					timeline.draw(camera, matrix, null, null, antialiasing, null);
				});
				_renderTexture.render();

				_renderTextureDirty = false;
			}

			camera.drawPixels(_renderTexture.graphic.imageFrame.frame, framePixels, matrix, colorTransform, blend, antialiasing, shader);
		}
		else
		#end
		{
			timeline.draw(camera, matrix, colorTransform, blend, antialiasing, shader);
		}
	}

	// I dont think theres a way to override the matrix without needing to do this lol
	#if (flixel >= "6.1.0")
	override function drawFrameComplex(frame:FlxFrame, camera:FlxCamera):Void
	#else
	override function drawComplex(camera:FlxCamera):Void
	#end
	{
		#if (flixel < "6.1.0") final frame = this._frame; #end
		final matrix = this._matrix; // TODO: Just use local?

		frame.prepareMatrix(matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		matrix.translate(-origin.x, -origin.y);
		matrix.scale(scale.x, scale.y);
		if (bakedRotationAngle <= 0)
		{
			updateTrig();
			if (angle != 0)
				matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}
		if (skew.x != 0 || skew.y != 0)
		{
			updateSkew();
			_matrix.concat(_skewMatrix);
		}
		getScreenPosition(_point, camera);
		_point.x += origin.x - offset.x;
		_point.y += origin.y - offset.y;
		matrix.translate(_point.x, _point.y);
		if (isPixelPerfectRender(camera))
			preparePixelPerfectMatrix(matrix);
		camera.drawPixels(frame, framePixels, matrix, colorTransform, blend, antialiasing, shader);
	}

	function preparePixelPerfectMatrix(matrix:FlxMatrix):Void
	{
		matrix.tx = Math.floor(matrix.tx);
		matrix.ty = Math.floor(matrix.ty);
	}

	var stageBg:StageBG;

	function drawStage(camera:FlxCamera):Void
	{
		if (stageBg == null)
			stageBg = new StageBG();

		stageBg.render(this, camera);
	}

	// semi stolen from FlxSkewedSprite
	static var _skewMatrix:FlxMatrix = new FlxMatrix();

	private inline function updateSkew():Void
	{
		_skewMatrix.setTo(1, Math.tan(skew.y * FlxAngle.TO_RAD), Math.tan(skew.x * FlxAngle.TO_RAD), 1, 0, 0);
	}

	private inline function set_applyStageMatrix(v:Bool):Bool
	{
		this.applyStageMatrix = v;

		// Like resetFrame() but for animate
		if (this.isAnimate)
			anim.updateTimelineBounds();

		return v;
	}

	override function get_numFrames():Int
	{
		if (!isAnimate)
			return super.get_numFrames();

		@:privateAccess
		{
			if (animation._curAnim != null)
				return cast(animation._curAnim, FlxAnimateAnimation).timeline.frameCount;
		}

		return 0;
	}

	private function set_anim(newController:FlxAnimateController):FlxAnimateController
	{
		anim = newController;
		animation = anim;
		return newController;
	}

	override function updateFramePixels():BitmapData
	{
		if (!isAnimate)
			return super.updateFramePixels();

		if (timeline == null || !dirty)
			return framePixels;

		if (framePixels != null)
		{
			framePixels.dispose();
			framePixels.disposeImage();
		}

		@:privateAccess
		{
			final bounds = timeline._bounds;
			final flipX = checkFlipX();
			final flipY = checkFlipY();
			final mat = new FlxMatrix(flipX ? -1 : 1, 0, 0, flipY ? -1 : 1, flipX ? bounds.width : 0, flipY ? bounds.height : 0);

			#if flash
			framePixels = animate.internal.FilterRenderer.getBitmap((cam, m) ->
			{
				m.concat(mat);
				timeline.draw(cam, m, null, NORMAL, true, null);
			}, bounds, false);
			#else
			// TODO: optimize this to use FilterRenderer stuff
			var resultMat = new FlxMatrix(1, 0, 0, 1, -bounds.x, -bounds.y);
			resultMat.concat(mat);
			mat.identity();

			var cam = new FlxCamera(0, 0, Math.ceil(bounds.width), Math.ceil(bounds.height));
			timeline.draw(cam, resultMat, null, NORMAL, true, null);
			cam.render();

			framePixels = new BitmapData(Std.int(bounds.width), Std.int(bounds.height), true, 0);
			framePixels.draw(cam.canvas, mat, null, null, null, true);
			cam.canvas.graphics.clear();
			#end
		}

		dirty = false;
		return framePixels;
	}

	override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect
	{
		var bounds = super.getScreenBounds(newRect, camera);

		if (isAnimate)
		{
			final origin = getAnimateOrigin();
			bounds.x += origin.x;
			bounds.y += origin.y;
			origin.put();
		}

		// TODO: add skewed bounds expansion

		return bounds;
	}

	override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
	{
		final point = super.getScreenPosition(result, camera);

		if (isAnimate)
		{
			final origin = getAnimateOrigin();
			point.add(origin.x, origin.y);
			origin.put();
		}

		return point;
	}

	function getAnimateOrigin(?result:FlxPoint):FlxPoint
	{
		result ??= FlxPoint.get();
		result.set();

		if (isAnimate && applyStageMatrix)
		{
			var matrix = library.matrix;
			result.add(matrix.tx, matrix.ty);
			result.add(timeline._bounds.x * matrix.a, timeline._bounds.y * matrix.d);
		}

		return result;
	}

	override function destroy():Void
	{
		super.destroy();
		_renderTexture = FlxDestroyUtil.destroy(_renderTexture);
		anim = FlxDestroyUtil.destroy(anim);
		library = null;
		timeline = null;
		stageBg = FlxDestroyUtil.destroy(stageBg);
		skew = FlxDestroyUtil.put(skew);
	}
}
