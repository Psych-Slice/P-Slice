package options;

class BaseGameOptions extends BaseOptionsMenu {
    public function new() {
        title = "V-Slice settings";
        rpcTitle = "V-Slice settings menu";
        var option:Option = new Option('Freeplay dynamic coloring',
			'Enables dynamic freeplay background color. Disable this if you prefer original V-slice freeplay menu colors',
			'vsliceFreeplayColors',
			'bool');
		addOption(option);
		#if sys
		var option:Option = new Option('Logging type',
			'Controls verbosity of the game\'s logs',
			'psliceLogging',
			'string',
			"None",
			["None","Console","File"]
			);
		addOption(option);
		#end
		var option:Option = new Option('Naughtyness',
			'If disabled, some "raunchy content" (such as swearing, etc.) will be disabled',
			'vsliceNaughtyness',
			'bool');
		addOption(option);
		var option:Option = new Option('Use results screen',
			'If disabled will skip showing the result screen',
			'vsliceResults',
			'bool');
		addOption(option);
		var option:Option = new Option('Smooth health bar',
			'If enabled makes health bar move more smoothly',
			'vsliceSmoothBar',
			'bool');
		addOption(option);
		var option:Option = new Option('Use legacy bar',
			'Makes health bar and score text much simpler',
			'vsliceLegacyBar',
			'bool',);
		addOption(option);
		var option:Option = new Option('Special freeplay cards',
			'If disabled will force every character to use BF\'s card (including pico)',
			'vsliceSpecialCards',
			'bool');
		addOption(option);
		var option:Option = new Option('Force "New" tag',
		'If enabled will force every uncompleted song to show "new" tag even if it\'s disabled',
		'vsliceForceNewTag',
		'bool');
		addOption(option);
        super();
    }
}