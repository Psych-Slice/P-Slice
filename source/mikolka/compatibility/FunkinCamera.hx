package mikolka.compatibility;

import openfl.filters.BitmapFilter;

class FunkinCamera extends FlxCamera {
    var camName:String;
    public var filters(never,set):Array<BitmapFilter>;
    public function set_filters(value:Array<BitmapFilter>) {
        this.setFilters(value);
        return value;
    }
    public function new(name:String,X:Int = 0, Y:Int = 0, Width:Int = 0, Height:Int = 0, Zoom:Float = 0) {
        camName = name;
        super(X,Y,Width,Height,Zoom);
    }

    override public function update(elapsed:Float):Void
        {
            // follow the target, if there is one
            if (target != null)
            {
                updateFollowDelta(elapsed);
            }
    
            updateScroll();
            updateFlash(elapsed);
            updateFade(elapsed);
    
            updateFlashSpritePosition();
            updateShake(elapsed);
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
    
        override function set_followLerp(value:Float)
        {
            return followLerp = value;
        }
        
        function bindScrollPos(scrollPos:FlxPoint)
            {
                var minX:Null<Float> = minScrollX == null ? null : minScrollX - (zoom - 1) * width / (2 * zoom);
                var maxX:Null<Float> = maxScrollX == null ? null : maxScrollX + (zoom - 1) * width / (2 * zoom);
                var minY:Null<Float> = minScrollY == null ? null : minScrollY - (zoom - 1) * height / (2 * zoom);
                var maxY:Null<Float> = maxScrollY == null ? null : maxScrollY + (zoom - 1) * height / (2 * zoom);
        
                // keep point with bounds
                scrollPos.x = FlxMath.bound(scrollPos.x, minX, (maxX != null) ? maxX - width : null);
                scrollPos.y = FlxMath.bound(scrollPos.y, minY, (maxY != null) ? maxY - height : null);
                return scrollPos;
            }
}