#!/bin/bash
echo Making the haxelib and setuping folder in same time...
#haxelib newrepo
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib git hxcpp https://github.com/Psych-Slice/hxcpp-mobile.git  --quiet
haxelib git lime https://github.com/Psych-Slice/lime-mobile.git --quiet 
haxelib install flixel 6.0.0 --quiet --skip-dependencies
haxelib install openfl  9.4.1 --quiet --skip-dependencies
haxelib install flixel-addons 3.3.2 --quiet --skip-dependencies
haxelib install flixel-tools 1.5.1 --quiet --skip-dependencies
haxelib install hscript-iris 1.1.3 --quiet 
haxelib install tjson 1.4.0 --quiet 
haxelib git flxanimate https://github.com/Psych-Slice/FlxAnimate.git 42f1b5d193b4345ca7d6933380ab3105985b44a3 --quiet
haxelib git linc_luajit https://github.com/Psych-Slice/linc_luajit-mobile.git --quiet
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc f9353b9edce10f4605d125dd1bda24ac36898bfb --quiet --skip-dependencies
haxelib git hxvlc https://github.com/Psych-Slice/hxvlc-mobile.git --quiet --skip-dependencies
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90 --quiet --skip-dependencies
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666 --quiet
haxelib git FlxPartialSound https://github.com/FunkinDroidTeam/FlxPartialSound.git 2b7943ba50eb41cf8f70e1f2089a5bd7ef242947 --quiet
echo Finished!
