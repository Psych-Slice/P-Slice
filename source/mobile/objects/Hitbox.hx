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

 import openfl.display.BitmapData;
 import openfl.display.Shape;
 import flixel.util.FlxSignal.FlxTypedSignal;
 import flixel.graphics.FlxGraphic;
 import flixel.util.FlxSignal.FlxTypedSignal;
 import openfl.geom.Matrix;
 
 /**
  * A zone with 4 hint's (A hitbox).
  * It's really easy to customize the layout.
  *
  * @author: Karim Akra and Lily Ross (mcagabe19)
  */
 class Hitbox extends MobileInputManager
 {
	 final offsetFir:Int = (ClientPrefs.data.hitbox2 ? Std.int(FlxG.height / 4) * 3 : 0);
	 final offsetSec:Int = (ClientPrefs.data.hitbox2 ? 0 : Std.int(FlxG.height / 4));
 
	 public var buttonLeft:TouchButton = new TouchButton(0, 0, [MobileInputID.HITBOX_LEFT, MobileInputID.NOTE_LEFT]);
	 public var buttonDown:TouchButton = new TouchButton(0, 0, [MobileInputID.HITBOX_DOWN, MobileInputID.NOTE_DOWN]);
	 public var buttonUp:TouchButton = new TouchButton(0, 0, [MobileInputID.HITBOX_UP, MobileInputID.NOTE_UP]);
	 public var buttonRight:TouchButton = new TouchButton(0, 0, [MobileInputID.HITBOX_RIGHT, MobileInputID.NOTE_RIGHT]);
	 public var buttonExtra:TouchButton = new TouchButton(0, 0, [MobileInputID.EXTRA_1]);
	 public var buttonExtra2:TouchButton = new TouchButton(0, 0, [MobileInputID.EXTRA_2]);
 
	 public var instance:MobileInputManager;
	 public var onButtonDown:FlxTypedSignal<TouchButton->Void> = new FlxTypedSignal<TouchButton->Void>();
	 public var onButtonUp:FlxTypedSignal<TouchButton->Void> = new FlxTypedSignal<TouchButton->Void>();
 
 
	 var storedButtonsIDs:Map<String, Array<MobileInputID>> = new Map<String, Array<MobileInputID>>();
 
	 /**
	  * Create the zone.
	  */
	 public function new(?extraMode:ExtraActions = NONE,colorMap:Array<FlxColor>)
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
				 add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 4), FlxG.height, colorMap[0]));
				 add(buttonDown = createHint(FlxG.width / 4, 0, Std.int(FlxG.width / 4), FlxG.height, colorMap[1]));
				 add(buttonUp = createHint(FlxG.width / 2, 0, Std.int(FlxG.width / 4), FlxG.height, colorMap[2]));
				 add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, Std.int(FlxG.width / 4), FlxG.height, colorMap[3]));
			 case SINGLE:
				 add(buttonLeft = createHint(0, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, colorMap[0]));
				 add(buttonDown = createHint(FlxG.width / 4, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, colorMap[1]));
				 add(buttonUp = createHint(FlxG.width / 2, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, colorMap[2]));
				 add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3,
				 colorMap[3]));
				 add(buttonExtra = createHint(0, offsetFir, FlxG.width, Std.int(FlxG.height / 4), colorMap[4]));
			 case DOUBLE:
				 add(buttonLeft = createHint(0, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, colorMap[0]));
				 add(buttonDown = createHint(FlxG.width / 4, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, colorMap[1]));
				 add(buttonUp = createHint(FlxG.width / 2, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, colorMap[2]));
				 add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3,
				 colorMap[3]));
				 add(buttonExtra2 = createHint(Std.int(FlxG.width / 2), offsetFir, Std.int(FlxG.width / 2), Std.int(FlxG.height / 4), colorMap[5]));
				 add(buttonExtra = createHint(0, offsetFir, Std.int(FlxG.width / 2), Std.int(FlxG.height / 4), colorMap[4]));
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
		 onButtonUp.destroy();
		 onButtonDown.destroy();
 
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
 
		 hint.label = new FlxSprite();
		 hint.labelStatusDiff = (ClientPrefs.data.hitboxType != "Hidden") ? ClientPrefs.data.controlsAlpha : 0.00001;
		 hint.label.loadGraphic(createHintGraphic(Width, Math.floor(Height * 0.035), true));
		 if (ClientPrefs.data.hitbox2)
			 hint.label.offset.y -= (hint.height - hint.label.height) / 2;
		 else
			 hint.label.offset.y += (hint.height - hint.label.height) / 2;
 
		 if (ClientPrefs.data.hitboxType != "Hidden")
		 {
			 var hintTween:FlxTween = null;
			 var hintLaneTween:FlxTween = null;
 
			 hint.onDown.callback = function()
			 {
				 onButtonDown.dispatch(hint);
 
				 if (hintTween != null)
					 hintTween.cancel();
 
				 if (hintLaneTween != null)
					 hintLaneTween.cancel();
 
				 hintTween = FlxTween.tween(hint, {alpha: ClientPrefs.data.controlsAlpha}, ClientPrefs.data.controlsAlpha / 100, {
					 ease: FlxEase.circInOut,
					 onComplete: (twn:FlxTween) -> hintTween = null
				 });
 
				 hintLaneTween = FlxTween.tween(hint.label, {alpha: 0.00001}, ClientPrefs.data.controlsAlpha / 10, {
					 ease: FlxEase.circInOut,
					 onComplete: (twn:FlxTween) -> hintTween = null
				 });
			 }
 
			 hint.onOut.callback = hint.onUp.callback = function()
			 {
				 onButtonUp.dispatch(hint);
 
				 if (hintTween != null)
					 hintTween.cancel();
 
				 if (hintLaneTween != null)
					 hintLaneTween.cancel();
 
				 hintTween = FlxTween.tween(hint, {alpha: 0.00001}, ClientPrefs.data.controlsAlpha / 10, {
					 ease: FlxEase.circInOut,
					 onComplete: (twn:FlxTween) -> hintTween = null
				 });
 
				 hintLaneTween = FlxTween.tween(hint.label, {alpha: ClientPrefs.data.controlsAlpha}, ClientPrefs.data.controlsAlpha / 100, {
					 ease: FlxEase.circInOut,
					 onComplete: (twn:FlxTween) -> hintTween = null
				 });
			 }
		 }
		 else
		 {
			 hint.onDown.callback = () -> onButtonDown.dispatch(hint);
			 hint.onOut.callback = hint.onUp.callback = () -> onButtonUp.dispatch(hint);
		 }
 
		 hint.immovable = hint.multiTouch = true;
		 hint.solid = hint.moves = false;
		 hint.alpha = 0.00001;
		 hint.label.alpha = (ClientPrefs.data.hitboxType != "Hidden") ? ClientPrefs.data.controlsAlpha : 0.00001;
		 hint.canChangeLabelAlpha = false;
		 hint.label.antialiasing = hint.antialiasing = ClientPrefs.data.antialiasing;
		 hint.color = Color;
		 #if FLX_DEBUG
		 hint.ignoreDrawDebug = true;
		 #end
		 return hint;
	 }
 
	 function createHintGraphic(Width:Int, Height:Int, ?isLane:Bool = false):FlxGraphic
	 {
		 var shape:Shape = new Shape();
		 shape.graphics.beginFill(0xFFFFFF);
 
		 if (ClientPrefs.data.hitboxType == "No Gradient")
		 {
			 var matrix:Matrix = new Matrix();
			 matrix.createGradientBox(Width, Height, 0, 0, 0);
 
			 if (isLane)
				 shape.graphics.beginFill(0xFFFFFF);
			 else
				 shape.graphics.beginGradientFill(RADIAL, [0xFFFFFF, 0xFFFFFF], [0, 1], [60, 255], matrix, PAD, RGB, 0);
			 shape.graphics.drawRect(0, 0, Width, Height);
			 shape.graphics.endFill();
		 }
		 else if (ClientPrefs.data.hitboxType == "No Gradient (Old)")
		 {
			 shape.graphics.lineStyle(10, 0xFFFFFF, 1);
			 shape.graphics.drawRect(0, 0, Width, Height);
			 shape.graphics.endFill();
		 }
		 else // if (ClientPrefs.data.hitboxType == 'Gradient')
		 {
			 shape.graphics.lineStyle(3, 0xFFFFFF, 1);
			 shape.graphics.drawRect(0, 0, Width, Height);
			 shape.graphics.lineStyle(0, 0, 0);
			 shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			 shape.graphics.endFill();
			 if (isLane)
				 shape.graphics.beginFill(0xFFFFFF);
			 else
				 shape.graphics.beginGradientFill(RADIAL, [0xFFFFFF, FlxColor.TRANSPARENT], [1, 0], [0, 255], null, null, null, 0.5);
			 shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			 shape.graphics.endFill();
		 }
 
		 var bitmap:BitmapData = new BitmapData(Width, Height, true, 0);
		 bitmap.draw(shape);
 
		 return FlxG.bitmap.add(bitmap);
	 }
 }
 