package mikolka.compatibility.ui;

class MainMenuHooks{
    #if ACHIEVEMENTS_ALLOWED
    public static inline function unlockFriday() {
        Achievements.unlockAchievement('friday_night_play');
    }
    public static inline function reloadAchievements() {
        Achievements.loadAchievements();
    }
    #end
}