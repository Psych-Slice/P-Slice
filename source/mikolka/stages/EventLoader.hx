package mikolka.stages;

import mikolka.stages.standard.*;
import mikolka.stages.objects.*;
import mikolka.stages.erect.*;
import haxe.ds.List;
import psychlua.FunkinLua;

class EventLoader extends BaseStage {

    public static function implement(funk:FunkinLua)
        {
            var lua:State = funk.lua;
            Lua_helper.add_callback(lua, "loadFeature", function(type:String,name:String) {
                switch(type){
                    case "feature":
                        switch(name){
                            case "ABot": {
                                new PicoCapableStage();
                            }
                        }
                    case "stage":
                        addstage(name);
                }
            });
        }
    public static function addstage(name:String) {
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
			case 'phillyBlazin': new PhillyBlazin();				//Weekend 1 - Blazin
            #end
			case 'mainStageErect': new MainStageErect();			//Week 1 Special 
			case 'spookyMansionErect': new SpookyMansionErect();	//Week 2 Special 
			case 'phillyTrainErect': new PhillyTrainErect();  		//Week 3 Special 
			case 'limoRideErect': new LimoRideErect();  			//Week 4 Special 
			case 'mallXmasErect': new MallXmasErect(); 				//Week 5 Special 
			case 'phillyStreetsErect': new PhillyStreetsErect(); 	//Weekend 1 Special 
		}
    } 
}