/*
 * Copyright (C) 2025 Mobile Porting Team
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

 package mobile.objects;

 import flixel.util.FlxSignal.FlxTypedSignal;
 
 /**
  * ...
  * @author: Karim Akra and Lily Ross (mcagabe19)
  */
 @:access(mobile.objects.TouchButton)
 class TouchPad extends MobileInputManager
 {
	 public var buttonLeft:TouchButton = new TouchButton(0, 0, [MobileInputID.LEFT]);
	 public var buttonUp:TouchButton = new TouchButton(0, 0, [MobileInputID.UP]);
	 public var buttonRight:TouchButton = new TouchButton(0, 0, [MobileInputID.RIGHT]);
	 public var buttonDown:TouchButton = new TouchButton(0, 0, [MobileInputID.DOWN]);
	 public var buttonLeft2:TouchButton = new TouchButton(0, 0, [MobileInputID.LEFT2]);
	 public var buttonUp2:TouchButton = new TouchButton(0, 0, [MobileInputID.UP2]);
	 public var buttonRight2:TouchButton = new TouchButton(0, 0, [MobileInputID.RIGHT2]);
	 public var buttonDown2:TouchButton = new TouchButton(0, 0, [MobileInputID.DOWN2]);
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
	 public var buttonExtra:TouchButton = new TouchButton(0, 0, [MobileInputID.EXTRA_1]);
	 public var buttonExtra2:TouchButton = new TouchButton(0, 0, [MobileInputID.EXTRA_2]);
 
	 public var instance:MobileInputManager;
	 public var onButtonDown:FlxTypedSignal<TouchButton->Void> = new FlxTypedSignal<TouchButton->Void>();
	 public var onButtonUp:FlxTypedSignal<TouchButton->Void> = new FlxTypedSignal<TouchButton->Void>();
 
	 /**
	  * Create a gamepad.
	  *
	  * @param   DPadMode     The D-Pad mode. `LEFT_FULL` for example.
	  * @param   ActionMode   The action buttons mode. `A_B_C` for example.
	  */
	 public function new(DPad:String, Action:String)
	 {
		 super();
 
		 if (DPad != "NONE")
		 {
			 if (!MobileData.dpadModes.exists(DPad))
				 throw Language.getPhrase('touchpad_dpadmode_missing', 'The touchPad dpadMode "{1}" doesn\'t exist.', [DPad]);
 
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
				 throw Language.getPhrase('touchpad_actionmode_missing', 'The touchPad actionMode "{1}" doesn\'t exist.', [DPad]);
 
			 for (buttonData in MobileData.actionModes.get(Action).buttons)
			 {
				 Reflect.setField(this, buttonData.button,
					 createButton(buttonData.x, buttonData.y, buttonData.graphic, CoolUtil.colorFromString(buttonData.color),
						 Reflect.getProperty(this, buttonData.button).IDs));
				 add(Reflect.field(this, buttonData.button));
			 }
		 }
 
		 alpha = ClientPrefs.data.controlsAlpha;
		 scrollFactor.set();
		 updateTrackedButtons();
 
		 instance = this;
	 }
 
	 override public function destroy()
	 {
		 super.destroy();
		 onButtonUp.destroy();
		 onButtonDown.destroy();
 
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
 
		 button.onDown.callback = () -> onButtonDown.dispatch(button);
		 button.onOut.callback = button.onUp.callback = () -> onButtonUp.dispatch(button);
		 return button;
	 }
 
	 override function set_alpha(Value):Float
	 {
		 forEachAlive((button:TouchButton) -> button.parentAlpha = Value);
		 return super.set_alpha(Value);
	 }
 }
 