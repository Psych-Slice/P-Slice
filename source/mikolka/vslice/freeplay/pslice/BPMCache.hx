package mikolka.vslice.freeplay.pslice;

//? no psych. uses sys
class BPMCache {
    private static final DEFAULT_BPM_MAP:Map<String,Int> = [
        "tutorial" => 100,
        "bopeebo" => 100,
        "fresh" => 120,
        "dad-battle" => 180,
        "spookeez" => 150,
        "south" => 165,
        "monster" => 95,
        "pico" => 150,
        "philly-nice" => 175,
        "blammed" => 165,
        "satin-panties" => 110,
        "high" => 125,
        "milf" => 180,
        "cocoa" => 100,
        "eggnog" => 150,
        "winter-horrorland" => 159,
        "senpai" => 144,
        "roses" => 120,
        "thorns" => 190,
        "ugh" => 160,
        "guns" => 125,
        "stress" => 178,
    ];
    private var bpmMap:Map<String,Int> ;
    public static var instance = new BPMCache();
    public function new() {
        bpmMap = DEFAULT_BPM_MAP.copy();
    }

    public function getBPM(sngDataPath:String, fileSngName:String):Int {
        if(bpmMap.exists(sngDataPath)){
            //trace("loading from cache");
            return bpmMap[sngDataPath];
        }
        bpmMap[sngDataPath] = 0;
        if(!NativeFileSystem.exists(sngDataPath)){
            trace('Missing data folder for $fileSngName in $sngDataPath for BPM scrapping!!'); //TODO
            return 0;
        }
        var chartFiles = NativeFileSystem.readDirectory(sngDataPath);

        chartFiles = chartFiles.filter(s -> s.toLowerCase().startsWith(fileSngName) && s.endsWith(".json"));
        var chosenChartToScrap = sngDataPath+"/"+chartFiles[0];
        
        
		
		if(NativeFileSystem.exists(chosenChartToScrap)){
			var bpmFinder = ~/"bpm": *([0-9]+)/g; //TODO fix this regex
			var cleanChart = ~/"notes": *\[.*\]/gs.replace(NativeFileSystem.getContent(chosenChartToScrap),"");
			if(bpmFinder.match(cleanChart)){
                bpmMap[sngDataPath] = Std.parseInt(bpmFinder.matched(1));
            } 
                
			else trace('failed to scrap initial BPM for $fileSngName');
		}
		else{
			trace('Missing chart of $fileSngName in $chosenChartToScrap for BPM scrapping!!'); //TODO
			
		}
        return bpmMap[sngDataPath];
    }
    public function clearCache() {
        bpmMap = DEFAULT_BPM_MAP.copy();
    }
}