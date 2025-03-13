package mikolka.stages.objects;

import flixel.util.FlxStringUtil;

class LecacyScoreBars extends BaseStage {
    var lerpScore:Int;
    override function createPost() {
        super.createPost();
        var scoreBg = #if LEGACY_PSYCH game.healthBarBG #else game.healthBar #end;
        game.updateScoreText = updateScoreText;
        game.scoreTxt.setPosition(scoreBg.x + scoreBg.width - 190,scoreBg.y + 30);
        game.scoreTxt.size = 20;
        game.scoreTxt.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        updateScoreText();
    }
    public function updateScoreText() {
        if(game.cpuControlled) game.scoreTxt.text = "Bot Play enabled";
        else game.scoreTxt.text = 'Score: ${FlxStringUtil.formatMoney(game.songScore, false, true)}';
    }
}