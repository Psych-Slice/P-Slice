#if !macro


//Psych
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end


#if sys
import sys.*;
import sys.io.*;
#end

//P-Slice
import mikolka.funkin.*;
import mikolka.funkin.utils.*;
import mikolka.funkin.players.*;
import mikolka.funkin.custom.*;
import mikolka.stages.misc.BaseStage;
import flxanimate.PsychFlxAnimate as FlxAnimate;

//P-Slice stage system
import mikolka.stages.objects.*;
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

using StringTools;
#end
