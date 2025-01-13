package options;

class BaseGameSubState extends BaseOptionsMenu {
    public function new() {
        title = Language.getPhrase("vslice_menu","V-Slice settings");
        rpcTitle = "V-Slice settings menu";
        var option:Option = new Option('Freeplay dynamic coloring',
			'Enables dynamic freeplay background color. Disable this if you prefer original V-slice freeplay menu colors',
			'vsliceFreeplayColors',
			BOOL);
		addOption(option);

		var option:Option = new Option('Use results screen',
			'If disabled will skip showing the result screen',
			'vsliceResults',
			BOOL);
		addOption(option);
		var option:Option = new Option('Smooth health bar',
			'If enabled makes health bar move more smoothly',
			'vsliceSmoothBar',
			BOOL,);
		addOption(option);
		var option:Option = new Option('Special freeplay cards',
			'If disabled will force every character to use BF\'s card (including pico)',
			'vsliceSpecialCards',
			BOOL);
		addOption(option);
		var option:Option = new Option('Force "New" tag',
			'If enabled will force every uncompleted song to show "new" tag even if it\'s disabled',
			'vsliceForceNewTag',
			BOOL);
		addOption(option);
        super();
    }
}