package mikolka.stages.scripts;

import flixel.util.FlxStringUtil;

class LegacyScoreBars extends BaseStage {
    var lerpScore:Int;
    override function createPost() {
        super.createPost();
        #if LEGACY_PSYCH
        @:privateAccess
        var scoreBg =  game.healthBarBG;
        game.updateScore = updateScore;
        #else 
        var scoreBg = game.healthBar; 
        game.updateScoreText = updateScoreText;
        #end
        game.scoreTxt.setPosition(scoreBg.x + scoreBg.width - 190,scoreBg.y + 30);
        game.scoreTxt.size = 20;
        game.scoreTxt.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        updateScoreText();
    }

    public function updateScoreText() {
        if(game.cpuControlled) game.scoreTxt.text = "Bot Play enabled";
        else game.scoreTxt.text = 'Score: ${FlxStringUtil.formatMoney(game.songScore, false, true)}';
    }
    #if LEGACY_PSYCH
    public function updateScore(miss:Bool = false){
        updateScoreText();
        game.callOnLuas('onUpdateScore', [miss]);
    }
    #end
}