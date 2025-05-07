package mikolka.vslice.freeplay.backcards;

#if HSCRIPT_ALLOWED
import mikolka.vslice.components.crash.UserErrorSubstate;
import mikolka.vslice.freeplay.FreeplayState.ExitMoverData;
import mikolka.compatibility.freeplay.FreeplayHelpers;
import mikolka.compatibility.VsliceOptions;
import mikolka.vslice.freeplay.pslice.FreeplayColorTweener;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSpriteUtil;
import openfl.display.BlendMode;
import psychlua.HScript;
import crowplexus.iris.Iris;
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Printer;

class LuaCard extends BackingCard
{
	var hscript:HScript;
	public static inline function hasCustomCard(charId:String):Bool {
		return Paths.fileExists('registry/cards/$charId.hx',TEXT);
	}
	public override function new(currentCharacter:PlayableCharacter, charId:String,allowMessages:Bool = true)
	{
		super(currentCharacter);

		if (Mods.currentModDirectory != null && Mods.currentModDirectory.trim().length > 0)
		{
			var scriptPath:String = Paths.getPath('registry/cards/$charId.hx',TEXT);//'mods/${Mods.currentModDirectory}/registry/cards/$charId.hx'; // mods/My-Mod/data/LoadingScreen.hx
			if (NativeFileSystem.exists(scriptPath))
			{
				try
				{
					hscript = new HScript(null, scriptPath);
					hscript.set('backingCard', this);
					hscript.set('add',this.add);
					hscript.set('remove',this.remove);
					hscript.set('insert',this.insert);
					hscript.set('backingTextYeah',this.backingTextYeah);
					hscript.set('orangeBackShit',this.orangeBackShit);
					hscript.set('alsoOrangeLOL',this.alsoOrangeLOL);
					hscript.set('pinkBack',this.pinkBack);
					hscript.set('confirmGlow',this.confirmGlow);
					hscript.set('confirmGlow2',this.confirmGlow2);
					hscript.set('confirmTextGlow',this.confirmTextGlow);
					hscript.set('cardGlow',this.cardGlow);

					if (hscript.exists('onCreate'))
					{
						hscript.call('onCreate',[currentCharacter]);
						trace('initialized hscript interp successfully: $scriptPath');
					}
					else
					{
						trace('"$scriptPath" contains no \"onCreate" function, stopping script.');
					}
				}
				catch (e:IrisError)
				{
					var pos:HScriptInfos = cast {fileName: scriptPath, showLine: false};
					Iris.error(Printer.errorToString(e, false), pos);
					if(allowMessages) FlxTimer.wait(0.5,() ->{
						UserErrorSubstate.makeMessage("Error while compiling script",
						'Path: ${scriptPath}\n\n'+
						'Error: ${Printer.errorToString(e, false)}\n\n'+
						'In function ${pos.funcName} line  ${pos.lineNumber}\n');
					});
				}
			}
		}
	}

	public override function introDone():Void
	{
		if (hscript?.exists('introDone'))
			hscript.call('introDone');

		super.introDone();
	}
	public override function init() {
		super.init();
		if (hscript?.exists('init'))
			hscript.call('init');
	}
	public override function beatHit(curBeat:Int)
	{
		super.beatHit(curBeat);
		if (hscript?.exists('beatHit'))
			hscript.call('beatHit');
	}
	public override function disappear() {
		super.disappear();
		if (hscript?.exists('disappear'))
			hscript.call('disappear');
	}
	public override function enterCharSel() {
		super.enterCharSel();
		if (hscript?.exists('enterCharSel'))
			hscript.call('enterCharSel');
	}
	public override function confirm() {
		super.confirm();
		if (hscript?.exists('confirm'))
			hscript.call('confirm');
	}
	public override function applyExitMovers(?exitMovers:ExitMoverData, ?exitMoversCharSel:ExitMoverData) {
		super.applyExitMovers(exitMovers, exitMoversCharSel);
		if (hscript?.exists('applyExitMovers'))
			hscript.call('applyExitMovers',[exitMovers,exitMoversCharSel]);
	}
	public override function destroy() {
		hscript?.destroy();
		super.destroy();
	}
}
#end
