@echo off
color 0a
@echo on
echo Installing dependencies...

:: Uniwersal
haxelib git flixel https://github.com/Psych-Slice/p-slice-1.0-flixel.git 9b1192a23fcfb456123efa14c63c8506ded20e5e --quiet --skip-dependencies
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666
haxelib git flixel-animate https://github.com/MaybeMaru/flixel-animate.git 7d271b0017df2606a31e7736f20450ef65f999b4 --skip-dependencies
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90
haxelib git hxcpp https://github.com/Psych-Slice/hxcpp.git 66cae339ce60c21c8d605c7673091fdc47ae1ef1 --quiet --skip-dependencies
haxelib install hxp 1.3.1 --quiet  --skip-dependencies

haxelib git openfl https://github.com/FunkinCrew/openfl.git c4fa1dcfc384f07bb537e08cae671f9507fe49e6 --quiet --skip-dependencies
haxelib git lime https://github.com/Psych-Slice/lime-pslice.git 66f28d158ac03d000ce8234203f5b8f0b1756d0f --quiet

haxelib install flixel-addons 3.3.2 --quiet --skip-dependencies
haxelib install flixel-tools 1.5.1 --quiet --skip-dependencies
haxelib install hscript-iris 1.1.3 --quiet --skip-dependencies
haxelib install tjson 1.4.0 --quiet --skip-dependencies
haxelib install format 3.8.0 --quiet

:: Specific
haxelib install hxdiscord_rpc 1.2.4 --quiet
haxelib install hxvlc 2.2.2 --quiet --skip-dependencies
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit 1906c4a96f6bb6df66562b3f24c62f4c5bba14a7
echo Finished!
pause
