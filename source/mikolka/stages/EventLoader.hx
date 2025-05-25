package mikolka.stages;

import mikolka.compatibility.ModsHelper;
import mikolka.vslice.StickerSubState;
import mikolka.compatibility.VsliceOptions;
import mikolka.stages.standard.*;
import mikolka.stages.objects.*;
import mikolka.stages.scripts.*;
import mikolka.stages.erect.*;
import haxe.ds.List;
#if !LEGACY_PSYCH
#if LUA_ALLOWED
import psychlua.FunkinLua;
import mikolka.vslice.components.crash.UserErrorSubstate;
#end
#end

class EventLoader extends BaseStage {
    #if LUA_ALLOWED
    public static function implement(funk:FunkinLua)
        {
            var lua:State = funk.lua;
            funk.set('versionPS', MainMenuState.pSliceVersion.trim());
            Lua_helper.add_callback(lua, "markAsPicoCapable", function(force:Bool = false) {
                new PicoCapableStage(force);
            });
            Lua_helper.add_callback(lua, "changeTransStickers", function(stickerSet:String = null,stickerPack:String = null) {
                if(stickerSet != null && stickerSet != "") StickerSubState.STICKER_SET = stickerSet;
                if(stickerPack != null && stickerPack != "") StickerSubState.STICKER_PACK = stickerPack;
            });
            Lua_helper.add_callback(lua, "getFreeplayCharacter", function() {
                return VsliceOptions.LAST_MOD.char_name;
            });
            Lua_helper.add_callback(lua, "setFreeplayCharacter", function(character:String,modded:Bool = false) {
                VsliceOptions.LAST_MOD = {
                    mod_dir: modded? ModsHelper.getActiveMod() : "",
                    char_name: character
                }; //? save selected character
            });
        }
    #end
    public static function addstage(name:String) {
        var addNene = true;
        if(VsliceOptions.LEGACY_BAR) new LegacyScoreBars();
        new VSliceEvents();
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
			case 'tank': 
                new TankmanStagesAddons();
                new Tank();								            //Week 7 - Ugh, Guns, Stress
            #if !LEGACY_PSYCH
			case 'phillyStreets': new PhillyStreets(); 				//Weekend 1 - Darnell, Lit Up, 2Hot
			case 'phillyBlazin': new PhillyBlazin();				//Weekend 1 - Blazin
            #end
			case 'mainStageErect': new MainStageErect();			//Week 1 Special 
			case 'spookyMansionErect': new SpookyMansionErect();	//Week 2 Special 
			case 'phillyTrainErect': new PhillyTrainErect();  		//Week 3 Special 
			case 'limoRideErect': new LimoRideErect();  			//Week 4 Special 
			case 'mallXmasErect': new MallXmasErect(); 				//Week 5 Special 
			case 'schoolErect': new SchoolErect();					//Week 6 Special - Erect Mode
			case 'schoolPico': new SchoolErect();					//Week 6 Special - Pico
			case 'schoolEvilErect': new SchoolEvilErect();			//Week 6 Special - Thorns
			case 'tankmanBattlefieldErect': 
                new TankmanStagesAddons();
                new TankErect();		                            //Week 7 Special
			case 'phillyStreetsErect': new PhillyStreetsErect(); 	//Weekend 1 Special 
            default: addNene = false;
		}
        if(addNene && PicoCapableStage.instance == null) {
            var pico = new PicoCapableStage();
            var game = PlayState.instance;
            game.stages.remove(pico);
            game.stages.insert(game.stages.length-2,pico);
        }
        
    } 
}