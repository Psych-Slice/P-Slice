package mikolka.stages;

import mikolka.stages.standard.*;
import mikolka.stages.objects.*;
import mikolka.stages.erect.*;
import haxe.ds.List;
#if !LEGACY_PSYCH
#if LUA_ALLOWED
import psychlua.FunkinLua;
import mikolka.vslice.components.crash.UserErrorSubstate;
#end
import states.MainMenuState;
#end

class EventLoader extends BaseStage {
    #if LUA_ALLOWED
    public static function implement(funk:FunkinLua)
        {
            var lua:State = funk.lua;
            funk.set('versionPS', MainMenuState.pSliceVersion.trim());
            Lua_helper.add_callback(lua, "markAsPicoCapable", function() {
                new PicoCapableStage();
            });
        }
    #end
    public static function addstage(name:String) {
        var addNene = true;
        switch (name)
		{
			case 'stage': new StageWeek1(); 						//Week 1
			case 'spooky': new Spooky();							//Week 2
			case 'philly': new Philly();							//Week 3
			case 'limo': new Limo();								//Week 4
			case 'mall': new Mall();								//Week 5 - Cocoa, Eggnog
			case 'mallEvil': new MallEvil();						//Week 5 - Winter Horrorland
			case 'school': new School();							//Week 6 - Senpai, Roses
			case 'schoolEvil': new SchoolEvil();					//Week 6 - Thorns
			case 'tank': new Tank();								//Week 7 - Ugh, Guns, Stress
            #if !LEGACY_PSYCH
			case 'phillyStreets': new PhillyStreets(); 				//Weekend 1 - Darnell, Lit Up, 2Hot
			case 'phillyBlazin': 
                new PhillyBlazin(new PicoCapableStage());				//Weekend 1 - Blazin
                return;
            #end
			case 'mainStageErect': new MainStageErect();			//Week 1 Special 
			case 'spookyMansionErect': 
                new SpookyMansionErect(new PicoCapableStage());	//Week 2 Special 
                return;
			case 'phillyTrainErect': new PhillyTrainErect();  		//Week 3 Special 
			case 'limoRideErect': new LimoRideErect();  			//Week 4 Special 
			case 'mallXmasErect': new MallXmasErect(); 				//Week 5 Special 
			case 'phillyStreetsErect': new PhillyStreetsErect(); 	//Weekend 1 Special 
            default: addNene = false;
		}
        if(addNene) new PicoCapableStage();
    } 
}