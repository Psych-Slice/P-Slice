@echo off
color 0a
cd ..
@echo on
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib install lime 8.1.2
haxelib install openfl 9.3.3
haxelib install flixel-addons 3.2.2
haxelib install flixel-tools 1.5.1
haxelib install hscript-iris 1.0.2
haxelib install tjson 1.4.0
haxelib git flixel https://github.com/mikolka9144/flixel-funkin.git 901df3b291e422e6ac1ea6a838fbc32baf163197
haxelib git flxanimate https://github.com/Dot-Stuff/flxanimate 768740a56b26aa0c072720e0d1236b94afe68e3e
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit 633fcc051399afed6781dd60cbf30ed8c3fe2c5a
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc f9353b9edce10f4605d125dd1bda24ac36898bfb
haxelib git hxvlc https://github.com/MAJigsaw77/hxvlc 70e7f5f3e76d526ac6fb8f0e6665efe7dfda589d
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis d5361037efa3a02c4ab20b5bd14ca11e7d00f519
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666
haxelib git FlxPartialSound https://github.com/FunkinCrew/FlxPartialSound.git f986332ba5ab02abd386ce662578baf04904604a
echo Finished!
pause
