package mikolka.vslice.freeplay;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxSignal.FlxTypedSignal;
import mikolka.compatibility.freeplay.FreeplaySongData;
import mikolka.funkin.freeplay.FreeplayStyle;

// This is not a sprite group!
class SongCapsuleGroup extends FlxTypedGroup<SongMenuItem> {

    @:allow(mikolka.vslice.freeplay.SongMenuItem)
    static var BIG_NUMBER_FRAMES:FlxAtlasFrames;
    @:allow(mikolka.vslice.freeplay.SongMenuItem)
    static var SMALL_NUMBER_FRAMES:FlxAtlasFrames;
    
    public final onRandomSelected:FlxTypedSignal<SongMenuItem -> Void> = new FlxTypedSignal<SongMenuItem -> Void>();
    public final onSongSelected:FlxTypedSignal<SongMenuItem -> Void> = new FlxTypedSignal<SongMenuItem -> Void>();
	final randomCapsule:SongMenuItem;

	public final activeSongItems:Array<SongMenuItem> = new Array<SongMenuItem>();

    var styleData:Null<FreeplayStyle>;
    public function new(styleData:Null<FreeplayStyle> = null) {
        super();
        this.styleData = styleData;
		randomCapsule = new SongMenuItem(0,0);
		randomCapsule.init(FlxG.width, 0, null, styleData);
		randomCapsule.onConfirm = function()
		{
			onRandomSelected.dispatch(randomCapsule);
		};
		randomCapsule.alpha = 0;
		randomCapsule.songText.visible = false;
		randomCapsule.favIcon.visible = false;
		randomCapsule.favIconBlurred.visible = false;
		randomCapsule.ranking.visible = false;
		randomCapsule.blurredRanking.visible = false;
		randomCapsule.hsvShader = SongMenuItem.static_hsvShader;
		randomCapsule.updateWeekText("Random!");
		add(randomCapsule);

        BIG_NUMBER_FRAMES = Paths.getSparrowAtlas('freeplay/freeplayCapsule/bignumbers');
        SMALL_NUMBER_FRAMES = Paths.getSparrowAtlas('freeplay/freeplayCapsule/smallnumbers');
    }


    override function destroy() {
        BIG_NUMBER_FRAMES = null;
        SMALL_NUMBER_FRAMES = null;
        super.destroy();
    }

    public function updateSongDifficulties(currentDifficulty:String) {
        // Update the song capsules to reflect the new difficulty info.
			for (songCapsule in members)
			{
				if (songCapsule == null)
					continue;
				if (songCapsule.songData != null)
				{
					songCapsule.songData.currentDifficulty = currentDifficulty;
					songCapsule.refreshDisplayDifficulty();
					//songCapsule.checkClip();
				}
				else
				{
					songCapsule.init(null, null, null);
				}
			}
    }
    	/**
	 * Rebuilds the entire song list.
	 */
	public function generateFullSongList(songList:Array<Null<FreeplaySongData>>,currentDifficulty:String,fromCharSelect = false, force:Bool = false):Void
	{
		
		for (cap in members)
		{
			if(cap.songData == null) continue; // Exclude "Random" card from cleanup
			cap.songText.resetText();
			cap.kill();
		}
		activeSongItems.resize(0);
		var recycledSongCards = findSongItems(songList);

		randomCapsule.init(FlxG.width, 0, null, styleData);
		randomCapsule.y = randomCapsule.intendedY(0) + 10;
		randomCapsule.targetPos.x = randomCapsule.x;
		if (fromCharSelect == false)
			randomCapsule.initJumpIn(0, force);
		else
			randomCapsule.forcePosition();
		
		activeSongItems.push(randomCapsule);
		add(randomCapsule);

		for (i in 0...songList.length)
		{
			var tempSong = songList[i];
			if (tempSong == null)
				continue;

			//? Update difficulty as part of difficulty change action;
			tempSong.currentDifficulty = currentDifficulty;

			var funnyMenu:SongMenuItem = recycledSongCards.get(tempSong);
			if(funnyMenu == null){
				funnyMenu = recycle(SongMenuItem);
				funnyMenu.init(FlxG.width,0,tempSong);
				// This actually protects from adding the card twice!
				add(funnyMenu); 
			}
			else{
				funnyMenu.refreshDisplayDifficulty();
			}
			funnyMenu.onConfirm = function()
			{
				onSongSelected.dispatch(funnyMenu);
			};
			funnyMenu.targetPos.x = funnyMenu.x; // This is target position on X
			funnyMenu.y = funnyMenu.intendedY(i + 1) + 10; 
			funnyMenu.ID = i;
			funnyMenu.capsule.alpha = 0.5;
			funnyMenu.songText.visible = false;
			funnyMenu.favIcon.visible = tempSong.isFav;
			funnyMenu.favIconBlurred.visible = tempSong.isFav;
			funnyMenu.hsvShader = SongMenuItem.static_hsvShader;
			funnyMenu.checkClip();
			
			funnyMenu.forcePosition();

			activeSongItems.push(funnyMenu);
			
		}
	}
	/**
	 * Sets initial positions for all cards.
	 * 
	 * Useful after setting their target positions via "targetPos" property
	 */
	inline public function setInitialAnimPosition() {
		for (card in activeSongItems){
			card.x = FlxG.width;// This is starting position on X
			card.y = card.targetPos.y;// This is starting position on X
		}
	}

	/**
	 * Given the song data list, searches for corresponding dead cards.
	 * Such cards will have most elements reads (like song name and charIcon),
	 * but will need to be refreshed with "refreshDisplayDifficulty" to update difficulty data.
	 * @return A map of found song cards. If a cord for a given song wasn't found, there won't be a corresponding key in the map!
	 */
	function findSongItems(songData:Array<FreeplaySongData>):Map<FreeplaySongData,Null<SongMenuItem>> {
		var foundSongItem = new Map<FreeplaySongData,Null<SongMenuItem>>();
		forEachDead(tomb ->{
			if(songData.contains(tomb.songData) && !foundSongItem.exists(tomb.songData)){
				tomb.revive();
				foundSongItem.set(tomb.songData,tomb);
			}
		});
		return foundSongItem;
	}
}