package options;

class BaseGameSubState extends BaseOptionsMenu {
    public function new() {
        title = "V-Slice settings";
        rpcTitle = "V-Slice settings menu";
        var option:Option = new Option('Freeplay Dynamic Coloring',
			'Enables dynamic freeplay background color. Disable this if you prefer original V-slice freeplay menu colors',
			'vsliceFreeplayColors',
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
        super();
    }
}