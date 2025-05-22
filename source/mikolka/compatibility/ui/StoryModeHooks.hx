package mikolka.compatibility.ui;

import mikolka.vslice.ui.StoryMenuState;

class StoryModeHooks {
    public static function prepareWeek(sory:StoryMenuState):Bool{
        if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();

				for (char in grpWeekCharacters.members)
				{
					if (char.character != '' && char.hasConfirmAnimation)
					{
						char.animation.play('confirm');
					}
				}
				stopspamming = true;
			}

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if(diffic == null) diffic = '';

			// Nevermind that's stupid lmao
			     //? We load erect songs (because yes)
				 if(diffic == "-erect" || diffic == "-nightmare") PlayState.storyPlaylist = songArray.convertToErectVariants();
				 else PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			

			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyDifficultyColor = CoolUtil.dominantColor(sprDifficulty);

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.storyCampaignTitle = txtWeekTitle.text == "" ? "Untitled week" : txtWeekTitle.text;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
            return true;
    }
}