package mikolka.vslice.freeplay.capsule;

import mikolka.funkin.Scoring.ScoringRank;
import openfl.display.BlendMode;


class FreeplayRank extends FlxSprite
{
	public var rank(default, set):Null<ScoringRank> = null;

	function set_rank(val:Null<ScoringRank>):Null<ScoringRank>
	{
		rank = val;

		if (rank == null || val == null)
		{
			this.visible = false;
		}
		else
		{
			this.visible = true;

			animation.play(val.getFreeplayRankIconAsset(), true, false);

			centerOffsets(false);

			switch (val)
			{
				case SHIT:
					// offset.x -= 1;
				case GOOD:
					// offset.x -= 1;
					offset.y -= 8;
				case GREAT:
					// offset.x -= 1;
					offset.y -= 8;
				case EXCELLENT:
					// offset.y += 5;
				case PERFECT:
					// offset.y += 5;
				case PERFECT_GOLD:
					// offset.y += 5;
				default:
					centerOffsets(false);
					this.visible = false;
			}
			updateHitbox();
		}

		return rank = val;
	}

	public var baseX:Float = 0;
	public var baseY:Float = 0;

	public function new(x:Float, y:Float)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('freeplay/rankbadges');

		animation.addByPrefix('PERFECT', 'PERFECT rank0', 24, false);
		animation.addByPrefix('EXCELLENT', 'EXCELLENT rank0', 24, false);
		animation.addByPrefix('GOOD', 'GOOD rank0', 24, false);
		animation.addByPrefix('PERFECTSICK', 'PERFECT rank GOLD', 24, false);
		animation.addByPrefix('GREAT', 'GREAT rank0', 24, false);
		animation.addByPrefix('LOSS', 'LOSS rank0', 24, false);

		blend = BlendMode.ADD;

		this.rank = null;

		// setGraphicSize(Std.int(width * 0.9));
		scale.set(0.9, 0.9);
		updateHitbox();
	}
}


