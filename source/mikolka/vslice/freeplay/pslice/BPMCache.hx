package mikolka.vslice.freeplay.pslice;

//? no psych. uses sys
class BPMCache {
    private var bpmMap:Map<String,Int> = [];
    public static var instance = new BPMCache();
    public function new() {
        
    }

    public function getBPM(sngDataPath:String, fileSngName:String):Int {
        if(bpmMap.exists(sngDataPath)){
            //trace("loading from cache");
            return bpmMap[sngDataPath];
        }
        bpmMap[sngDataPath] = 0;
        if(!FileSystem.exists(sngDataPath)){
            trace('Missing data folder for $fileSngName in $sngDataPath for BPM scrapping!!'); //TODO
            return 0;
        }
        var chartFiles = Paths.readDirectory(sngDataPath)
				.filter(s -> s.toLowerCase().startsWith(fileSngName) && s.endsWith(".json"));
        var chosenChartToScrap = '$sngDataPath/${chartFiles[0]}';
		
		if(FileSystem.exists(chosenChartToScrap)){
			var bpmFinder = ~/"bpm": *([0-9]+)/g; //TODO fix this regex
			var cleanChart = ~/"notes": *\[.*\]/gs.replace(File.getContent(chosenChartToScrap),"");
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
        bpmMap.clear();
    }
}