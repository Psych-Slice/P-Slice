package funkin;

import states.results.ResultState.SaveScoreData;
import flixel.graphics.FlxGraphic;

class FunkinTools
{
	public static function makeSolidColor(sprite:FlxSprite, width:Int, height:Int, color:FlxColor = FlxColor.WHITE):FlxSprite
	{
		// Create a tiny solid color graphic and scale it up to the desired size.
		var graphic:FlxGraphic = FlxG.bitmap.create(2, 2, color, false, 'solid#${color.toHexString(true, false)}');
		sprite.frames = graphic.imageFrame;
		sprite.scale.set(width / 2.0, height / 2.0);
		sprite.updateHitbox();

		return sprite;
	}

	public static function createSparrow(x:Float = 0.0, y:Float = 0.0, key:String):FlxSprite
	{
		var sprite:FlxSprite = new FlxSprite(x, y);
		sprite.antialiasing = ClientPrefs.data.antialiasing;
		sprite.frames = Paths.getSparrowAtlas(key);
		return sprite;
	}

	/**
	 * Produces a new Tallies object which represents the sum of two existing Tallies
	 * @param newTally The first tally
	 * @param baseTally The second tally
	 * @return The combined tally
	 */
	public static function combineTallies(newTally:SaveScoreData, baseTally:SaveScoreData):SaveScoreData
	{
		var combinedTally:SaveScoreData = newTali();
		combinedTally.missed = newTally.missed + baseTally.missed;
		combinedTally.shit = newTally.shit + baseTally.shit;
		combinedTally.bad = newTally.bad + baseTally.bad;
		combinedTally.good = newTally.good + baseTally.good;
		combinedTally.sick = newTally.sick + baseTally.sick;
		combinedTally.totalNotes = newTally.totalNotes + baseTally.totalNotes;
		combinedTally.totalNotesHit = newTally.totalNotesHit + baseTally.totalNotesHit;
		combinedTally.accPoints = newTally.accPoints+baseTally.accPoints;
    	combinedTally.score = newTally.score + baseTally.score;
		// Current combo = use most recent.
		combinedTally.combo = newTally.combo;
    
		// Max combo = use maximum value.
		combinedTally.maxCombo = Std.int(Math.max(newTally.maxCombo, baseTally.maxCombo));

		return combinedTally;
	}
  public static function newTali():SaveScoreData{
    return {
      score: 0,
      accPoints: 0,
	  
    combo: 0,
    missed: 0,
    shit: 0,
    bad: 0,
    good: 0,
    sick: 0,
    totalNotes: 0,
    totalNotesHit: 0,
    maxCombo: 0
      
    };
  }
	public static function extractWeeks(text:String)
	{
		if (text == null)
			return [];
		var baseStr = text.trim();
		if (baseStr == "")
			return [];
		var base_weeks = baseStr.split(",").map(s -> s.trim().toLowerCase());
		return base_weeks;
	}
}
