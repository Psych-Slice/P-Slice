#if !macro

import haxe.Exception;

//Psych
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end

// Mobile Controls
import mobile.input.MobileInputID;
import mobile.backend.SwipeUtil;
import mobile.backend.TouchUtil;
#if TOUCH_CONTROLS_ALLOWED
import mobile.objects.Hitbox;
import mobile.objects.TouchPad;
import mobile.objects.TouchButton;
import mobile.backend.MobileData;
import mobile.input.MobileInputManager;
#end
import mobile.backend.StorageUtil;

// Android
#if android
import android.content.Context as AndroidContext;
import android.widget.Toast as AndroidToast;
import android.os.Environment as AndroidEnvironment;
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
import android.Tools as AndroidTools;
import android.os.Build.VERSION as AndroidVersion;
import android.os.Build.VERSION_CODES as AndroidVersionCode;
import android.os.BatteryManager as AndroidBatteryManager;
#end

#if sys
import sys.*;
import sys.io.*;
#end

import Paths as CacheSystem;
//P-Slice
import mikolka.funkin.*;
import mikolka.compatibility.ui.*;
import mikolka.funkin.utils.*;
import mikolka.funkin.players.*;
import mikolka.funkin.custom.*;
import mikolka.vslice.ui.StoryMenuState;
import mikolka.vslice.ui.title.TitleState;
import mikolka.compatibility.stages.misc.BaseStage;
import flxanimate.PsychFlxAnimate as FlxAnimate;

//P-Slice stage system
import mikolka.compatibility.stages.objects.*;
import mikolka.compatibility.stages.misc.*;
import mobile.*;

#if flxanimate
import flxanimate.*;
#end

// Mod libs
import flixel.ui.FlxBar;
#if hxCodec
import hxcodec.flixel.FlxVideo;
#end

//Flixel
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.system.FlxAssets.FlxShader;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;

using StringTools;
#end
