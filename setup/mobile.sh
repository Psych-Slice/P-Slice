#!/bin/bash
echo Making the haxelib and setuping folder in same time...
#haxelib newrepo
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib install flixel-addons 3.3.2 --quiet --skip-dependencies
haxelib install flixel-tools 1.5.1 --quiet --skip-dependencies
haxelib install hscript-iris 1.1.3 --quiet 
haxelib install hxvlc 2.2.2 --quiet --skip-dependencies
haxelib install tjson 1.4.0 --quiet 
haxelib git openfl https://github.com/FunkinCrew/openfl.git a0df7c3afe360c9af59a76e45007dbf4e53b5131 --quiet --skip-dependencies
haxelib git hxcpp https://github.com/Psych-Slice/hxcpp-mobile.git  --quiet
haxelib git flixel https://github.com/Psych-Slice/p-slice-1.0-flixel.git 9b1192a23fcfb456123efa14c63c8506ded20e5e --quiet --skip-dependencies
haxelib git lime https://github.com/Psych-Slice/lime-mobile.git --quiet 
haxelib git flxanimate https://github.com/Psych-Slice/FlxAnimate.git 82a720663f9ed6328d91a727c2b17501d91e3b11 --quiet
haxelib git linc_luajit https://github.com/Psych-Slice/linc_luajit-mobile.git --quiet
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc f9353b9edce10f4605d125dd1bda24ac36898bfb --quiet --skip-dependencies
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90 --quiet --skip-dependencies
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666 --quiet
haxelib git FlxPartialSound https://github.com/FunkinDroidTeam/FlxPartialSound.git 2b7943ba50eb41cf8f70e1f2089a5bd7ef242947 --quiet
echo Finished!
