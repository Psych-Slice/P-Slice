#if !macro

import haxe.Exception;

//Discord API
#if DISCORD_ALLOWED
import backend.Discord;
#end

//Psych
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end

#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
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
import mobile.objects.TouchZone;
import mobile.objects.ScrollableObject;
#end
// Android
#if android
import extension.androidtools.content.Context as AndroidContext;
import extension.androidtools.widget.Toast as AndroidToast;
import extension.androidtools.os.Environment as AndroidEnvironment;
import extension.androidtools.Permissions as AndroidPermissions;
import extension.androidtools.Settings as AndroidSettings;
import extension.androidtools.Tools as AndroidTools;
import extension.androidtools.os.Build.VERSION as AndroidVersion;
import extension.androidtools.os.Build.VERSION_CODES as AndroidVersionCode;
//? Is this even used???
//import android.os.BatteryManager as AndroidBatteryManager;
#end

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

//P-Slice
import mikolka.funkin.custom.NativeFileSystem as NativeFileSystem;
import mikolka.funkin.*;
import mikolka.funkin.utils.*;
import mikolka.funkin.custom.*;
import mikolka.funkin.players.*;
import states.FreeplayState as C_;

//P-Slice Dialouges
import mikolka.stages.cutscenes.dialogueBox.*;
import mikolka.stages.cutscenes.dialogueBox.DialogueBoxPsych.DialogueFile;
import mikolka.stages.cutscenes.dialogueBox.styles.*;

//utils
using StringTools;
using mikolka.funkin.utils.ArrayTools;
using mikolka.funkin.utils.custom.FunkinTools;
import mikolka.funkin.utils.custom.FunkinTools;
using mikolka.funkin.utils.ArrayTools;
using mikolka.funkin.utils.SpriteTools;
using mikolka.funkin.utils.custom.PsychUITools;
using mikolka.funkin.utils.StringTools;



// Stage imports (for compatibility)
import states.stages.objects.*;

import backend.Paths;
import backend.CacheSystem;
import backend.Controls;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.CustomFadeTransition;
import backend.ClientPrefs;
import backend.Conductor;
import backend.BaseStage;
import backend.Difficulty;
import backend.Mods;
import backend.Highscore;
import backend.Language;
import mobile.backend.StorageUtil;

import backend.ui.*; //Psych-UI

import objects.Alphabet;
import objects.BGSprite;

import states.PlayState;
import mikolka.vslice.ui.*;
import states.LoadingState;

#if flxanimate
import flxanimate.*;
import flxanimate.PsychFlxAnimate as FlxAnimate;
#end

// Mod libs
import flixel.ui.FlxBar;

//Flixel
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.system.FlxAssets.FlxShader;


#end
