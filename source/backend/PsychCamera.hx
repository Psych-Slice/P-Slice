package backend;

import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;

// PsychCamera handles followLerp based on elapsed
// and stops camera from snapping at higher framerates

class PsychCamera extends FlxCamera
{
	
	var camName:String;

	public var X:Int;
	public var Y:Int;

	public var ForcePos:Bool = false;

	var resetActive:Bool = false;
	var resetTarget:FlxPoint = FlxPoint.get();
	var resetEpsilon:Float = 0.5;

	override public function update(elapsed:Float):Void {
		if (ForcePos) {
			
			scroll.set(resetTarget.x, resetTarget.y);
			resetActive = false;
		} else {
			if (target != null && !resetActive) updateFollowDelta(elapsed);

			if (resetActive) {
				var m:Float = 1 - Math.exp(-elapsed * followLerp / (1 / 60));
				scroll.x += (resetTarget.x - scroll.x) * m;
				scroll.y += (resetTarget.y - scroll.y) * m;
				if (Math.abs(scroll.x - resetTarget.x) <= resetEpsilon && Math.abs(scroll.y - resetTarget.y) <= resetEpsilon) {
					scroll.set(resetTarget.x, resetTarget.y);
					resetActive = false;
				}
			}
		}

		updateScroll();
		updateFlash(elapsed);
		updateFade(elapsed);
		updateShake(elapsed);
	}

	public function new(name:String, X:Int = 0, Y:Int = 0, Width:Int = 0, Height:Int = 0, Zoom:Float = 0) {
		camName = name;
		this.X = X;
		this.Y = Y;
		super(X, Y, Width, Height, Zoom);
	}

	public function updateFollowDelta(?elapsed:Float = 0):Void
	{
		// Either follow the object closely,
		// or double check our deadzone and update accordingly.
		if (deadzone == null)
		{
			target.getMidpoint(_point);
			_point.addPoint(targetOffset);
			_scrollTarget.set(_point.x - width * 0.5, _point.y - height * 0.5);
		}
		else
		{
			var edge:Float;
			var targetX:Float = target.x + targetOffset.x;
			var targetY:Float = target.y + targetOffset.y;

			if (style == SCREEN_BY_SCREEN)
			{
				if (targetX >= viewRight)
				{
					_scrollTarget.x += viewWidth;
				}
				else if (targetX + target.width < viewLeft)
				{
					_scrollTarget.x -= viewWidth;
				}

				if (targetY >= viewBottom)
				{
					_scrollTarget.y += viewHeight;
				}
				else if (targetY + target.height < viewTop)
				{
					_scrollTarget.y -= viewHeight;
				}
				
				// without this we see weird behavior when switching to SCREEN_BY_SCREEN at arbitrary scroll positions
				bindScrollPos(_scrollTarget);
			}
			else
			{
				edge = targetX - deadzone.x;
				if (_scrollTarget.x > edge)
				{
					_scrollTarget.x = edge;
				}
				edge = targetX + target.width - deadzone.x - deadzone.width;
				if (_scrollTarget.x < edge)
				{
					_scrollTarget.x = edge;
				}

				edge = targetY - deadzone.y;
				if (_scrollTarget.y > edge)
				{
					_scrollTarget.y = edge;
				}
				edge = targetY + target.height - deadzone.y - deadzone.height;
				if (_scrollTarget.y < edge)
				{
					_scrollTarget.y = edge;
				}
			}

			if ((target is FlxSprite))
			{
				if (_lastTargetPosition == null)
				{
					_lastTargetPosition = FlxPoint.get(target.x, target.y); // Creates this point.
				}
				_scrollTarget.x += (target.x - _lastTargetPosition.x) * followLead.x;
				_scrollTarget.y += (target.y - _lastTargetPosition.y) * followLead.y;

				_lastTargetPosition.x = target.x;
				_lastTargetPosition.y = target.y;
			}
		}

		var mult:Float = 1 - Math.exp(-elapsed * followLerp / (1/60));
		scroll.x += (_scrollTarget.x - scroll.x) * mult;
		scroll.y += (_scrollTarget.y - scroll.y) * mult;
		//trace('lerp on this frame: $mult');
	}
	// Fixes some scripts assuming we are on the filxel 5.6.2
	public function setFilters(newShaders:Array<ShaderFilter>) {
		this.filters = cast newShaders;
	}
	// override function set_followLerp(value:Float)
	// {
	// 	return followLerp = value;
	// }

	public inline function resetToPoint(p:FlxPoint):Void {
		resetTo(p.x, p.y);
		if (ForcePos) {

			scroll.set(resetTarget.x, resetTarget.y);
			resetActive = false;
		}
	}

	public inline function resetTo(x:Float, y:Float):Void {
		resetTarget.set(x, y);
		if (ForcePos) {

			scroll.set(resetTarget.x, resetTarget.y);
			resetActive = false;
		} else {
			resetActive = true;
		}
	}

	public inline function GoZero():Void {
		resetTarget.set(X, Y);
		if (ForcePos) {
			scroll.set(resetTarget.x, resetTarget.y);
			resetActive = false;
		} else {
			resetActive = true;
		}
	}

}