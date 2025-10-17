@echo off
color 0a
cd ..
@echo on 
echo Installing dependencies.
haxelib install hscript 2.5.0 --quiet
haxelib install lime 8.0.1 --quiet
haxelib install openfl 9.2.1 --quiet
haxelib install flixel 5.2.2 --quiet
haxelib install flixel-addons 3.0.2 --quiet
haxelib install flixel-ui 2.5.0 --quiet
haxelib install flixel-tools 1.5.1 --quiet
haxelib install tjson 1.4.0 --quiet
haxelib git hxcpp https://github.com/Psych-Slice/hxcpp.git e48576506a270237ec2ec6501c0bedbd03034af1 --quiet --skip-dependencies
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec.git 0a51aed0d9523d22a83e453ce7b593ec7fed4742
haxelib git flxanimate https://github.com/Psych-Slice/FlxAnimate.git 18091dfeb629ba2805a5f3e10f5de80433080359
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit 1906c4a96f6bb6df66562b3f24c62f4c5bba14a7
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc f9353b9edce10f4605d125dd1bda24ac36898bfb
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666
echo Finished!
pause
