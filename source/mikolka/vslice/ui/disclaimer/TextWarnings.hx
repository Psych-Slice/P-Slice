package mikolka.vslice.ui.disclaimer;

import flixel.FlxState;

class OutdatedState extends WarningState
{

	public function new(newVersion:String,nextState:FlxState) {
		final bro:String = #if mobile 'kiddo' #else 'bro' #end;
		final escape:String = (controls.mobileC) ? 'B' : 'ESCAPE';

		var guh = "Sup "+bro+", looks like you're running an   \n
		outdated version of P-Slice Engine (" + MainMenuState.pSliceVersion + "),\n
		please update to " + newVersion + "!\n
		Press "+escape+" to proceed anyway.\n
		\n
		Thank you for using the Engine!";
		super(guh,() ->{
			CoolUtil.browserLoad("https://github.com/Psych-Slice/P-Slice/releases");
			if(onExit != null) onExit();
		},onExit,nextState);
	}
}
class FlashingState extends WarningState{
	public function new(nextState:FlxState) {

		final enter:String = controls.mobileC ? 'A' : 'ENTER';
		final escape:String = controls.mobileC ? 'B' : 'ESCAPE';
		var text = 	"Hey, watch out!\n
			This Mod contains some flashing lights!\n
			Press " + enter + " to disable them now or go to Options Menu.\n
			Press " + escape + " to ignore this message.\n
			You've been warned!";
		super(text,() ->{
			#if LEGACY_PSYCH
			ClientPrefs.flashing = false;
			#else
			ClientPrefs.data.flashing = false;
			#end
			ClientPrefs.saveSettings();
		},() ->{},nextState);
	}
}
