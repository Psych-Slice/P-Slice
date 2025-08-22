package mobile.objects.grid;

import mikolka.compatibility.VsliceOptions;
import flixel.effects.FlxFlicker;

class GridTile extends TouchButton
{
	public var gridXPos:Int;
	public var gridYPos:Int;
	public var selectedOffset(default, never):FlxPoint = FlxPoint.get();

	final host:GridButtons;
	final callback:() -> Void;

	private function new(host:GridButtons, callback:() -> Void)
	{
		super();
		this.host = host;
		this.callback = callback;
		antialiasing = VsliceOptions.ANTIALIASING;
		onDown.callback = () ->
		{
			host.selectButton(gridXPos, gridYPos);
		}
	}

    override function update(elapsed:Float) {
        if(justReleased && host.selectedItem == this) {
			host.confirmCurrentButton();
		}
        super.update(elapsed);
    }
	public function configureBitmap(imagePath:String, anim_idle:String, anim_select:String)
	{
		frames = Paths.getSparrowAtlas(imagePath);
		animation.addByPrefix('idle', anim_idle, 24);
		animation.addByPrefix('selected', anim_select, 24);
		scale.x = 0.9;
		playIdleAnim();
	}

	public function playSelectedAnim()
	{
        host.hideButtons();
		FlxFlicker.flicker(this, 1, 0.06, false, false, function(flick:FlxFlicker)
		{
			callback();
            host.selectedSomethin = false;
		});
	}
	public function playHoverAnim() {
		animation.play("selected");
		updateHitbox();
		centerOrigin();
		offset.copyFrom(selectedOffset);
	}
	public function playIdleAnim() {
		animation.play("idle");
		updateHitbox();
		centerOrigin();
		offset.set(0,0);
	}
    public function hideTile() {
        FlxTween.tween(this, {alpha: 0}, 0.4, {
		ease: FlxEase.quadOut,
		onComplete: function(twn:FlxTween)
		{
			this.kill();
		}
	});
    }
		override function destroy() {
		selectedOffset.put();
		super.destroy();
	}
}
