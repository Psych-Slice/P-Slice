#!/bin/bash
echo Making the haxelib and setuping folder in same time...
#haxelib newrepo
echo Installing dependencies...

#Universal
haxelib git flixel https://github.com/Psych-Slice/p-slice-1.0-flixel.git 9b1192a23fcfb456123efa14c63c8506ded20e5e --quiet --skip-dependencies
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666 --quiet --skip-dependencies
haxelib install tink_core 1.26.0
haxelib install hxp 1.3.1 --quiet
haxelib git flixel-animate https://github.com/MaybeMaru/flixel-animate.git c61476f4b3a3d225631ab3065e4e925a4b63c076 --skip-dependencies
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90 --quiet --skip-dependencies
haxelib git hxcpp https://github.com/Psych-Slice/hxcpp.git 66cae339ce60c21c8d605c7673091fdc47ae1ef1 --quiet --skip-dependencies

haxelib git openfl https://github.com/FunkinCrew/openfl.git c4fa1dcfc384f07bb537e08cae671f9507fe49e6 --quiet --skip-dependencies
haxelib git lime https://github.com/Psych-Slice/lime-pslice.git 66f28d158ac03d000ce8234203f5b8f0b1756d0f --quiet

haxelib install flixel-addons 3.3.2 --quiet --skip-dependencies
haxelib install flixel-tools 1.5.1 --quiet --skip-dependencies
haxelib install hscript-iris 1.1.3 --quiet 
haxelib install tjson 1.4.0 --quiet 

#Specific
haxelib git astc-compressor https://github.com/KarimAkra/astc-compressor.git --skip-dependencies
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc f9353b9edce10f4605d125dd1bda24ac36898bfb --quiet --skip-dependencies
haxelib install hxvlc 2.2.2 --quiet --skip-dependencies
haxelib install extension-haptics 1.0.4 --quiet --skip-dependencies
haxelib git extension-firebase-crashlytics https://github.com/mikolka9144/extension-firebase-crashlytics.git d9e783f83e0c2b15b6ef0770672f677f00e98153 --quiet --skip-dependencies
haxelib install extension-androidtools 2.2.2 --quiet --skip-dependencies
haxelib git linc_luajit https://github.com/Psych-Slice/linc_luajit-mobile.git --quiet
echo Finished!
