package mikolka.editors.forms;

import mikolka.editors.substates.ResultsScreenEdit;
import mikolka.funkin.Scoring.ScoringRank;
using mikolka.editors.PsychUIUtills;

class ResultsDialogBox extends PsychUIBox {
    public var resultsObjectControls_empty:FlxText;
	public var resultsObjectControls:FlxSpriteGroup;
	public var resultsObjectControls_labels:FlxSpriteGroup;


	// GENERAL
	public var list_objSelector:PsychUIDropDownMenu;
	public var input_musicPath:PsychUIInputText;

    public function new(host:ResultsScreenEdit) {
        super(FlxG.width - 500, FlxG.height, 270, 220, ['General', "Properties"]);
		x -= width;
		y -= height;
		scrollFactor.set();
		visible = false;

		var rankSelector = new PsychUIDropDownMenu(10, 20, ["PERFECT_GOLD", "PERFECT", "EXCELLENT", "GREAT", "GOOD", "SHIT"], (index, name) ->
		{
			host.reloadprops([PERFECT_GOLD, PERFECT, EXCELLENT, GREAT, GOOD, SHIT][index]);
		});

		list_objSelector = new PsychUIDropDownMenu(140, 20, [], (index, name) -> {
			var selected_prop = host.propSystem.sprites[index];
			if(selected_prop.data == null){
				resultsObjectControls.visible = false;
				resultsObjectControls_labels.visible = false;
				resultsObjectControls_empty.visible = true;
				return;
			}
			else if(selected_prop.data.renderType == "animateatlas"){
				resultsObjectControls_labels.visible = true;
			}
			else resultsObjectControls_labels.visible = false;
			resultsObjectControls.visible = true;
			resultsObjectControls_empty.visible = false;
		});

		input_musicPath = new PsychUIInputText(10, 60, 250);
		input_musicPath.onChange = (prevText, text) ->
		{
			var data = host.activePlayer._data.results.music;
			switch (host.activeRank)
			{
				case PERFECT_GOLD:
					data.PERFECT_GOLD = text;
				case PERFECT:
					data.PERFECT = text;
				case EXCELLENT:
					data.EXCELLENT = text;
				case GREAT:
					data.GREAT = text;
				case GOOD:
					data.GOOD = text;
				case SHIT:
					data.SHIT = text;
			}
		};

		var btn_moveUp = new PsychUIButton(160, 90, "Move up", () -> {}, 100);
		var btn_moveDown = new PsychUIButton(160, 120, "Move down", () -> {}, 100);
		var btn_newSparrow = new PsychUIButton(10, 90, "New sparrow", () -> {}, 100);
		var btn_newAtlas = new PsychUIButton(10, 120, "New atlas", () -> {}, 100);
		var btn_removeObject = new PsychUIButton(10, 150, "Remove object", () -> {}, 100);
		selectedName = 'General';
		var tab = getTab('General').menu;
		tab.add(input_musicPath.makeLabel("Rank music path:"));
		tab.add(input_musicPath);
		tab.add(btn_moveUp);
		tab.add(btn_moveDown);
		tab.add(btn_newSparrow);
		tab.add(btn_newAtlas);
		tab.add(btn_removeObject);
		tab.add(rankSelector.makeLabel("Rank"));
		tab.add(rankSelector);
		tab.add(list_objSelector.makeLabel("Object:"));
		tab.add(list_objSelector);

		selectedName = 'Properties';
		var tab = getTab('Properties').menu;
		resultsObjectControls = new FlxSpriteGroup();
		resultsObjectControls.visible = false;
		var input_imagePath = new PsychUIInputText(10,20,250);
		var stepper_scale = new PsychUINumericStepper(90,130);
		var stepper_offsetX = new PsychUINumericStepper(25,60);
		var stepper_offsetY = new PsychUINumericStepper(25,90);

		var stepper_delay = new PsychUINumericStepper(10,130);
		var chkBox_loopable = new PsychUICheckBox(100,60,"loopable",100,() ->{

		});
		var stepper_loopFrame = new PsychUINumericStepper(100,100);
		resultsObjectControls.add(input_imagePath);
		resultsObjectControls.add(input_imagePath.makeLabel("Image path"));
		resultsObjectControls.add(new FlxText(10, 47, 100, "Offsets"));
		resultsObjectControls.add(new FlxText(10, 60, 100, "x:"));
		resultsObjectControls.add(stepper_offsetX);
		resultsObjectControls.add(new FlxText(10, 90, 100, "y:"));
		resultsObjectControls.add(stepper_offsetY);
		resultsObjectControls.add(stepper_scale.makeLabel("Scale:"));
		resultsObjectControls.add(stepper_scale);
		resultsObjectControls.add(stepper_delay);
		resultsObjectControls.add(stepper_delay.makeLabel("Delay"));
		resultsObjectControls.add(chkBox_loopable);
		resultsObjectControls.add(stepper_loopFrame.makeLabel("Loop frame"));
		resultsObjectControls.add(stepper_loopFrame);

		resultsObjectControls_labels = new FlxSpriteGroup();
		var chkBox_useLabels = new PsychUICheckBox(180,60,"Use labels",100,() ->{

		});
		var input_labelStart = new PsychUIInputText(180,130,80);
		var input_labelLoop = new PsychUIInputText(180,90,80);
		resultsObjectControls_labels.add(chkBox_useLabels);
		resultsObjectControls_labels.add(input_labelStart);
		resultsObjectControls_labels.add(input_labelStart.makeLabel("Start label"));
		resultsObjectControls_labels.add(input_labelLoop);
		resultsObjectControls_labels.add(input_labelLoop.makeLabel("Loop label"));
		resultsObjectControls_labels.visible = false;

		resultsObjectControls_empty = new FlxText(0, 80, 270, "You cannot edit properties for this object");
		resultsObjectControls_empty.alignment = CENTER;
		resultsObjectControls_empty.size = 10;

		tab.add(resultsObjectControls);
		tab.add(resultsObjectControls_empty);
		tab.add(resultsObjectControls_labels);
        selectedName = 'General';
    }
}