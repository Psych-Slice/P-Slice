package mobile.objects;

/**
 * ...
 * @author: Karim Akra and Lily Ross (mcagabe19)
 */
@:access(mobile.objects.TouchButton)
class TouchPad extends MobileInputManager implements IMobileControls
{
	public var buttonLeft:TouchButton = new TouchButton(0, 0, [MobileInputID.LEFT, MobileInputID.NOTE_LEFT]);
	public var buttonUp:TouchButton = new TouchButton(0, 0, [MobileInputID.UP, MobileInputID.NOTE_UP]);
	public var buttonRight:TouchButton = new TouchButton(0, 0, [MobileInputID.RIGHT, MobileInputID.NOTE_RIGHT]);
	public var buttonDown:TouchButton = new TouchButton(0, 0, [MobileInputID.DOWN, MobileInputID.NOTE_DOWN]);
	public var buttonLeft2:TouchButton = new TouchButton(0, 0, [MobileInputID.LEFT2, MobileInputID.NOTE_LEFT]);
	public var buttonUp2:TouchButton = new TouchButton(0, 0, [MobileInputID.UP2, MobileInputID.NOTE_UP]);
	public var buttonRight2:TouchButton = new TouchButton(0, 0, [MobileInputID.RIGHT2, MobileInputID.NOTE_RIGHT]);
	public var buttonDown2:TouchButton = new TouchButton(0, 0, [MobileInputID.DOWN2, MobileInputID.NOTE_DOWN]);
	public var buttonA:TouchButton = new TouchButton(0, 0, [MobileInputID.A]);
	public var buttonB:TouchButton = new TouchButton(0, 0, [MobileInputID.B]);
	public var buttonC:TouchButton = new TouchButton(0, 0, [MobileInputID.C]);
	public var buttonD:TouchButton = new TouchButton(0, 0, [MobileInputID.D]);
	public var buttonE:TouchButton = new TouchButton(0, 0, [MobileInputID.E]);
	public var buttonF:TouchButton = new TouchButton(0, 0, [MobileInputID.F]);
	public var buttonG:TouchButton = new TouchButton(0, 0, [MobileInputID.G]);
	public var buttonH:TouchButton = new TouchButton(0, 0, [MobileInputID.H]);
	public var buttonI:TouchButton = new TouchButton(0, 0, [MobileInputID.I]);
	public var buttonJ:TouchButton = new TouchButton(0, 0, [MobileInputID.J]);
	public var buttonK:TouchButton = new TouchButton(0, 0, [MobileInputID.K]);
	public var buttonL:TouchButton = new TouchButton(0, 0, [MobileInputID.L]);
	public var buttonM:TouchButton = new TouchButton(0, 0, [MobileInputID.M]);
	public var buttonN:TouchButton = new TouchButton(0, 0, [MobileInputID.N]);
	public var buttonO:TouchButton = new TouchButton(0, 0, [MobileInputID.O]);
	public var buttonP:TouchButton = new TouchButton(0, 0, [MobileInputID.P]);
	public var buttonQ:TouchButton = new TouchButton(0, 0, [MobileInputID.Q]);
	public var buttonR:TouchButton = new TouchButton(0, 0, [MobileInputID.R]);
	public var buttonS:TouchButton = new TouchButton(0, 0, [MobileInputID.S]);
	public var buttonT:TouchButton = new TouchButton(0, 0, [MobileInputID.T]);
	public var buttonU:TouchButton = new TouchButton(0, 0, [MobileInputID.U]);
	public var buttonV:TouchButton = new TouchButton(0, 0, [MobileInputID.V]);
	public var buttonW:TouchButton = new TouchButton(0, 0, [MobileInputID.W]);
	public var buttonX:TouchButton = new TouchButton(0, 0, [MobileInputID.X]);
	public var buttonY:TouchButton = new TouchButton(0, 0, [MobileInputID.Y]);
	public var buttonZ:TouchButton = new TouchButton(0, 0, [MobileInputID.Z]);
	public var buttonExtra:TouchButton = new TouchButton(0, 0);
	public var buttonExtra2:TouchButton = new TouchButton(0, 0);

	public var instance:MobileInputManager;

	/**
	 * Create a gamepad.
	 *
	 * @param   DPadMode     The D-Pad mode. `LEFT_FULL` for example.
	 * @param   ActionMode   The action buttons mode. `A_B_C` for example.
	 */
	public function new(DPad:String, Action:String, ?Extra:ExtraActions = NONE)
	{
		super();

		if (DPad != "NONE")
		{
			if (!MobileData.dpadModes.exists(DPad))
				throw 'The touchPad dpadMode "$DPad" doesn\'t exists.';

			for (buttonData in MobileData.dpadModes.get(DPad).buttons)
			{
				Reflect.setField(this, buttonData.button,
					createButton(buttonData.x, buttonData.y, buttonData.graphic, CoolUtil.colorFromString(buttonData.color),
						Reflect.getProperty(this, buttonData.button).IDs));
				add(Reflect.field(this, buttonData.button));
			}
		}

		if (Action != "NONE")
		{
			if (!MobileData.actionModes.exists(Action))
				throw 'The touchPad actionMode "$Action" doesn\'t exists.';

			for (buttonData in MobileData.actionModes.get(Action).buttons)
			{
				Reflect.setField(this, buttonData.button,
					createButton(buttonData.x, buttonData.y, buttonData.graphic, CoolUtil.colorFromString(buttonData.color),
						Reflect.getProperty(this, buttonData.button).IDs));
				add(Reflect.field(this, buttonData.button));
			}
		}

		switch (Extra)
		{
			case SINGLE:
				add(buttonExtra = createButton(0, FlxG.height - 137, 's', 0xFF0066FF));
				setExtrasPos();
			case DOUBLE:
				add(buttonExtra = createButton(0, FlxG.height - 137, 's', 0xFF0066FF));
				add(buttonExtra2 = createButton(FlxG.width - 132, FlxG.height - 137, 'g', 0xA6FF00));
				setExtrasPos();
			case NONE: // nothing
		}

		alpha = ClientPrefs.data.controlsAlpha;
		scrollFactor.set();
		updateTrackedButtons();

		instance = this;
	}

	override public function destroy()
	{
		super.destroy();

		for (fieldName in Reflect.fields(this))
		{
			var field = Reflect.field(this, fieldName);
			if (Std.isOfType(field, TouchButton))
				Reflect.setField(this, fieldName, FlxDestroyUtil.destroy(field));
		}
	}

	public function setExtrasDefaultPos()
	{
		var int:Int = 0;

		if (MobileData.save.data.extraData == null)
			MobileData.save.data.extraData = new Array();

		for (button in Reflect.fields(this))
		{
			var field = Reflect.field(this, button);
			if (button.toLowerCase().contains('extra') && Std.isOfType(field, TouchButton))
			{
				// if (MobileData.save.data.extraData[int] == null)
				// 	MobileData.save.data.extraData.push(FlxPoint.get(field.x, field.y));
				// else
				MobileData.save.data.extraData[int] = FlxPoint.get(field.x, field.y);
				++int;
			}
		}
		MobileData.save.flush();
	}

	public function setExtrasPos()
	{
		var int:Int = 0;
		if (MobileData.save.data.extraData == null)
			setExtrasDefaultPos();

		for (button in Reflect.fields(this))
		{
			var field = Reflect.field(this, button);
			if (button.toLowerCase().contains('extra') && Std.isOfType(field, TouchButton))
			{
				if (MobileData.save.data.extraData.length > int)
					setExtrasDefaultPos();
				var point = MobileData.save.data.extraData[int];
				field.x = point.x;
				field.y = point.y;
				int++;
			}
		}
	}

	private function createButton(X:Float, Y:Float, Graphic:String, ?Color:FlxColor = 0xFFFFFF, ?IDs:Array<MobileInputID>):TouchButton
	{
		var button = new TouchButton(X, Y, IDs);
		button.label = new FlxSprite();
		button.loadGraphic(Paths.image('touchpad/bg', "mobile"));
		button.label.loadGraphic(Paths.image('touchpad/${Graphic.toUpperCase()}', "mobile"));

		button.scale.set(0.243, 0.243);
		button.updateHitbox();
		button.updateLabelPosition();

		button.statusBrightness = [1, 0.8, 0.4];
		button.statusIndicatorType = BRIGHTNESS;
		button.indicateStatus();

		button.bounds.makeGraphic(Std.int(button.width - 50), Std.int(button.height - 50), FlxColor.TRANSPARENT);
		button.centerBounds();

		button.immovable = true;
		button.solid = button.moves = false;
		button.label.antialiasing = button.antialiasing = ClientPrefs.data.antialiasing;
		button.tag = Graphic.toUpperCase();
		button.color = Color;
		button.parentAlpha = button.alpha;
		return button;
	}

	override function set_alpha(Value):Float
	{
		forEachAlive((button:TouchButton) -> button.parentAlpha = Value);
		return super.set_alpha(Value);
	}
}
