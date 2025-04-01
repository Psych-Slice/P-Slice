package mikolka.editors.forms;

import mikolka.editors.editorProps.ResultsPropsGrp.ResultsProp;
import mikolka.editors.substates.ResultsScreenEdit;
import mikolka.funkin.Scoring.ScoringRank;
using mikolka.editors.PsychUIUtills;

class ResultsDialogBox extends PsychUIBox {
	public var selected_prop:ResultsProp;
	
	//PAGERS
    public var resultsObjectControls_empty:FlxText;
	public var resultsObjectControls:FlxSpriteGroup;
	public var resultsObjectControls_labels:FlxSpriteGroup;

	// GENERAL
	public var list_objSelector:PsychUIDropDownMenu;
	public var input_musicPath:PsychUIInputText;
	//PROPERTIES
	var input_imagePath:PsychUIInputText;
	var stepper_scale:PsychUINumericStepper;
	var stepper_offsetY:PsychUINumericStepper;
	var chkBox_loopable:PsychUICheckBox;
	var stepper_offsetX:PsychUINumericStepper;
	var stepper_delay:PsychUINumericStepper;
	var stepper_loopFrame:PsychUINumericStepper;
	var input_labelStart:PsychUIInputText;
	var input_labelLoop:PsychUIInputText;

    public function new(host:ResultsScreenEdit) {
        super(FlxG.width - 500, FlxG.height, 270, 220, ['General', "Properties"]);
		x -= width;
		y -= height;
		scrollFactor.set();
		visible = false;

		var rankSelector = new PsychUIDropDownMenu(10, 20, ["PERFECT_GOLD", "PERFECT", "EXCELLENT", "GREAT", "GOOD", "SHIT"], (index, name) ->
		{
			host.reloadprops([PERFECT_GOLD, PERFECT, EXCELLENT, GREAT, GOOD, SHIT][index]);
			resultsObjectControls.visible = false;
			resultsObjectControls_labels.visible = false;
			resultsObjectControls_empty.visible = true;
		});

		list_objSelector = new PsychUIDropDownMenu(140, 20, [], (index, name) -> {
			selected_prop = host.propSystem.sprites[index];
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

			input_imagePath.text = selected_prop.data.assetPath;
			stepper_scale.value = selected_prop.data.scale;
			stepper_loopFrame.value = selected_prop.data.loopFrame;
			stepper_offsetY.value = selected_prop.data.offsets[1];
			stepper_offsetX.value = selected_prop.data.offsets[0];
			stepper_delay.value = selected_prop.data.delay;
			chkBox_loopable.checked = selected_prop.data.looped;
			input_labelStart.text = selected_prop.data.startFrameLabel;
			input_labelLoop.text = selected_prop.data.loopFrameLabel;
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

		var btn_moveUp = new PsychUIButton(160, 90, "Move up", () -> {
			
		}, 100);
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

		input_imagePath = new PsychUIInputText(10,20,250);
		stepper_scale = new PsychUINumericStepper(90,130,0.1);
		stepper_offsetX = new PsychUINumericStepper(25,60,1,0,-9999,9999);
		stepper_offsetY = new PsychUINumericStepper(25,90,1,0,-9999,9999);
		stepper_delay = new PsychUINumericStepper(10,130);
		input_imagePath.onChange = (old,cur) ->{
			selected_prop.data.assetPath = cur;
			list_objSelector.updateCurrentItem(selected_prop.get_name());
		};
		stepper_delay.onValueChange = () -> {
			selected_prop.data.delay = stepper_delay.value;
		}
		stepper_offsetX.onValueChange = () -> {
			selected_prop.data.offsets[0] = stepper_offsetX.value;
			selected_prop.prop.set_offset(selected_prop.data.offsets[0],selected_prop.data.offsets[1]);
		}
		stepper_offsetY.onValueChange = () -> {
			selected_prop.data.offsets[1] = stepper_offsetY.value;
			selected_prop.prop.set_offset(selected_prop.data.offsets[0],selected_prop.data.offsets[1]);
		}
		stepper_scale.onValueChange = () -> {
			selected_prop.data.scale = stepper_scale.value;
			selected_prop.sprite.scale.set(stepper_scale.value);
		}
		
		chkBox_loopable = new PsychUICheckBox(100,60,"loopable",100,() ->{
			selected_prop.data.looped = chkBox_loopable.checked;
		});
		stepper_loopFrame = new PsychUINumericStepper(100,100);
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

		input_labelStart = new PsychUIInputText(180,130,80);
		input_labelLoop = new PsychUIInputText(180,90,80);
		input_labelStart.onChange = (old,cur) ->{
			selected_prop.data.startFrameLabel = cur;
		};
		input_labelLoop.onChange = (old,cur) ->{
			selected_prop.data.loopFrameLabel = cur;
		};
		
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