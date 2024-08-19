@echo off
color 0a
cd ..
@echo on
echo Installing dependencies.
haxelib install lime 8.1.3
haxelib install openfl 9.3.4
haxelib install flixel 5.6.2
haxelib install flixel-addons 3.2.3
haxelib install flixel-ui 2.6.1
haxelib install flixel-tools 1.5.1
haxelib install tjson 1.4.0
haxelib git SScript https://github.com/mikolka9144/sscript-funkin.git master
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec.git 0a51aed0d9523d22a83e453ce7b593ec7fed4742
haxelib git flxanimate https://github.com/ShadowMario/flxanimate dev
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc
haxelib git FlxPartialSound https://github.com/FunkinCrew/FlxPartialSound.git f986332ba5ab02abd386ce662578baf04904604a
echo Finished!
pause
