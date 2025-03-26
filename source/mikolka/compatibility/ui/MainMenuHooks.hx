package mikolka.compatibility.ui;

class MainMenuHooks{
    #if ACHIEVEMENTS_ALLOWED
    public static inline function unlockFriday() {
        Achievements.unlock('friday_night_play');
    }
    
    public static function reloadAchievements() {
        #if MODS_ALLOWED
        Achievements.reloadList();
        #end
    }
    #end
}