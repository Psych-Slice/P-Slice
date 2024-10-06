package mobile.objects;

import openfl.display.BitmapData;
import openfl.display.Shape;
import flixel.graphics.FlxGraphic;

/**
 * A zone with 4 hint's (A hitbox).
 * It's really easy to customize the layout.
 *
 * @author: Mihai Alexandru and Karim Akra
 */
class Hitbox extends MobileInputManager implements IMobileControls
{
	final offsetFir:Int = (ClientPrefs.data.hitbox2 ? Std.int(FlxG.height / 4) * 3 : 0);
	final offsetSec:Int = (ClientPrefs.data.hitbox2 ? 0 : Std.int(FlxG.height / 4));

	public var buttonLeft:TouchButton = new TouchButton(0, 0, [MobileInputID.HITBOX_LEFT, MobileInputID.NOTE_LEFT]);
	public var buttonDown:TouchButton = new TouchButton(0, 0, [MobileInputID.HITBOX_DOWN, MobileInputID.NOTE_DOWN]);
	public var buttonUp:TouchButton = new TouchButton(0, 0, [MobileInputID.HITBOX_UP, MobileInputID.NOTE_UP]);
	public var buttonRight:TouchButton = new TouchButton(0, 0, [MobileInputID.HITBOX_RIGHT, MobileInputID.NOTE_RIGHT]);
	public var buttonExtra:TouchButton = new TouchButton(0, 0);
	public var buttonExtra2:TouchButton = new TouchButton(0, 0);

	public var instance:MobileInputManager;

	var storedButtonsIDs:Map<String, Array<MobileInputID>> = new Map<String, Array<MobileInputID>>();

	/**
	 * Create the zone.
	 */
	public function new(?extraMode:ExtraActions = NONE)
	{
		super();

		for (button in Reflect.fields(this))
		{
			var field = Reflect.field(this, button);
			if (Std.isOfType(field, TouchButton))
				storedButtonsIDs.set(button, Reflect.getProperty(field, 'IDs'));
		}

		switch (extraMode)
		{
			case NONE:
				add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFFC24B99));
				add(buttonDown = createHint(FlxG.width / 4, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFF00FFFF));
				add(buttonUp = createHint(FlxG.width / 2, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFF12FA05));
				add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, Std.int(FlxG.width / 4), FlxG.height, 0xFFF9393F));
			case SINGLE:
				add(buttonLeft = createHint(0, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFFC24B99));
				add(buttonDown = createHint(FlxG.width / 4, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF00FFFF));
				add(buttonUp = createHint(FlxG.width / 2, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF12FA05));
				add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3,
					0xFFF9393F));
				add(buttonExtra = createHint(0, offsetFir, FlxG.width, Std.int(FlxG.height / 4), 0xFF0066FF));
			case DOUBLE:
				add(buttonLeft = createHint(0, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFFC24B99));
				add(buttonDown = createHint(FlxG.width / 4, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF00FFFF));
				add(buttonUp = createHint(FlxG.width / 2, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF12FA05));
				add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3,
					0xFFF9393F));
				add(buttonExtra2 = createHint(Std.int(FlxG.width / 2), offsetFir, Std.int(FlxG.width / 2), Std.int(FlxG.height / 4), 0xA6FF00));
				add(buttonExtra = createHint(0, offsetFir, Std.int(FlxG.width / 2), Std.int(FlxG.height / 4), 0xFF0066FF));
		}

		for (button in Reflect.fields(this))
		{
			if (Std.isOfType(Reflect.field(this, button), TouchButton))
				Reflect.setProperty(Reflect.getProperty(this, button), 'IDs', storedButtonsIDs.get(button));
		}

		storedButtonsIDs.clear();
		scrollFactor.set();
		updateTrackedButtons();

		instance = this;
	}

	/**
	 * Clean up memory.
	 */
	override function destroy()
	{
		super.destroy();

		for (fieldName in Reflect.fields(this))
		{
			var field = Reflect.field(this, fieldName);
			if (Std.isOfType(field, TouchButton))
				Reflect.setField(this, fieldName, FlxDestroyUtil.destroy(field));
		}
	}

	private function createHint(X:Float, Y:Float, Width:Int, Height:Int, Color:Int = 0xFFFFFF):TouchButton
	{
		var hint = new TouchButton(X, Y);
		hint.statusAlphas = [];
		hint.statusIndicatorType = NONE;
		hint.loadGraphic(createHintGraphic(Width, Height));

		if (ClientPrefs.data.hitboxType != "Hidden")
		{
			var hintTween:FlxTween = null;

			hint.onDown.callback = function()
			{
				if (hintTween != null)
					hintTween.cancel();

				hintTween = FlxTween.tween(hint, {alpha: ClientPrefs.data.controlsAlpha}, ClientPrefs.data.controlsAlpha / 100, {
					ease: FlxEase.circInOut,
					onComplete: (twn:FlxTween) -> hintTween = null
				});
			}

			hint.onOut.callback = hint.onUp.callback = function()
			{
				if (hintTween != null)
					hintTween.cancel();

				hintTween = FlxTween.tween(hint, {alpha: 0.00001}, ClientPrefs.data.controlsAlpha / 10, {
					ease: FlxEase.circInOut,
					onComplete: (twn:FlxTween) -> hintTween = null
				});
			}
		}

		hint.immovable = hint.multiTouch = true;
		hint.solid = hint.moves = false;
		hint.alpha = 0.00001;
		hint.antialiasing = ClientPrefs.data.antialiasing;
		hint.color = Color;
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}

	function createHintGraphic(Width:Int, Height:Int):FlxGraphic
	{
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0xFFFFFF);

		if (ClientPrefs.data.hitboxType == 'Gradient')
		{
			shape.graphics.lineStyle(3, 0xFFFFFF, 1);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.lineStyle(0, 0, 0);
			shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			shape.graphics.endFill();
			shape.graphics.beginGradientFill(RADIAL, [0xFFFFFF, FlxColor.TRANSPARENT], [1, 0], [0, 255], null, null, null, 0.5);
			shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			shape.graphics.endFill();
		}
		else
		{
			shape.graphics.lineStyle(10, 0xFFFFFF, 1);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.endFill();
		}

		var bitmap:BitmapData = new BitmapData(Width, Height, true, 0);
		bitmap.draw(shape);

		return FlxG.bitmap.add(bitmap);
	}
}
