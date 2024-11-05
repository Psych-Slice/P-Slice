#if !macro
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
#end

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
#elseif js
import js.html.*;
#end

//P-Slice
import mikolka.funkin.*;
import mikolka.funkin.utils.*;
import mikolka.funkin.custom.*;
import mikolka.funkin.players.*;

// Stage imports (for compatibility)
import states.stages.objects.*;

import backend.Paths;
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
import states.MainMenuState;
import states.StoryMenuState;
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
import shaders.flixel.system.FlxShader;

using StringTools;
#end
