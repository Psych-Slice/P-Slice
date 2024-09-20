@echo off
color 0a
cd ..
@echo on 
echo Installing dependencies.
haxelib install hscript 2.5.0
haxelib install lime 8.0.1
haxelib install openfl 9.2.1
haxelib install flixel 5.2.2
haxelib install flixel-addons 3.0.2
haxelib install flixel-ui 2.5.0
haxelib install flixel-tools 1.5.1
haxelib install tjson 1.4.0
haxelib git hxcpp https://github.com/mikolka9144/pslice-hxcpp.git
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec.git 0a51aed0d9523d22a83e453ce7b593ec7fed4742
haxelib git flxanimate https://github.com/Psych-Slice/FlxAnimate.git f6669490ddbf4ad01023185aeb0e1129fe24b9f1
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc f9353b9edce10f4605d125dd1bda24ac36898bfb
haxelib git FlxPartialSound https://github.com/FunkinCrew/FlxPartialSound.git f986332ba5ab02abd386ce662578baf04904604a
echo Finished!
pause
