package mikolka.funkin.custom;

import mikolka.vslice.results.Tallies.SaveScoreData;
import mikolka.funkin.Scoring.ScoringRank;
import flixel.graphics.FlxGraphic;

//? P-Slice utility class (I think)
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
		combinedTally.accPoints = newTally.accPoints + baseTally.accPoints;
		combinedTally.score = newTally.score + baseTally.score;
		// Current combo = use most recent.
		combinedTally.combo = newTally.combo;

		// Max combo = use maximum value.
		combinedTally.maxCombo = Std.int(Math.max(newTally.maxCombo, baseTally.maxCombo));

		return combinedTally;
	}

	public static function newTali():SaveScoreData
	{
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
	public static function mergeWithJson<T>(target:T,source:Dynamic,?ignoreFields:Array<String>):T{
		if(ignoreFields == null) ignoreFields = [];
		var fillInFields = Type.getInstanceFields(Type.getClass(target)).filter(s -> !ignoreFields.contains(s));

		if(source == null) return target;
		for (field in Reflect.fields(source)){
			if(fillInFields.contains(field)) Reflect.setField(target,field,Reflect.field(source,field));
			#if debug
			else if (!ignoreFields.contains(field)) throw 'Class ${Type.getClassName(Type.getClass(target))} doesn\'t contain field field $field';
			#else
			else if (!ignoreFields.contains(field)) trace('Class ${Type.getClassName(Type.getClass(target))} doesn\'t contain field field $field');
			#end
		}
		return target;
	}
}
