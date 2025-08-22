package mobile.objects.grid;

class OptionsButton extends GridTile
{
	public function new(host:GridButtons, callback:() -> Void)
	{
		super(host,callback);
        frames = Paths.getSparrowAtlas("mainmenu/optionsButton");
		animation.addByIndices('idle', 'options', [0], "", 24, false);
		animation.addByIndices('selected', 'options', [3], "", 24, false);
		animation.addByIndices('confirm', 'options', [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16], "", 24, false);

		statusIndicatorType = NONE;
		scale.set(0.7, 0.7);
		updateHitbox();
	}

	override function playHoverAnim() {
		animation.play("selected");
		updateHitbox();
		centerOrigin();
	}
	override function playIdleAnim() {
		animation.play("idle");
		updateHitbox();
		centerOrigin();
	}
	override function playSelectedAnim()
	{
		host.hideButtons();
		FlxTween.cancelTweensOf(this);
		HapticUtil.vibrate(0, 0.05, 0.5);
		animation.play('confirm');

		new FlxTimer().start(0.05, function(_)
		{
			HapticUtil.vibrate(0, 0.01, 0.2);
		}, 4);
		animation.onFinish.addOnce(function(name:String)
		{
			if (name != 'confirm')
				return;
			callback();
		});
	}
}
