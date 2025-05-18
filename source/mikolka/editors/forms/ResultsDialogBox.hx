package mikolka.editors.forms;

import mikolka.funkin.players.PlayerData.PlayerResultsAnimationData;
import mikolka.editors.editorProps.ResultsPropsGrp.ResultsProp;
import mikolka.editors.substates.ResultsScreenEdit;
import mikolka.funkin.Scoring.ScoringRank;
using mikolka.editors.PsychUIUtills;

class ResultsDialogBox extends PsychUIBox {
	public var selected_prop:ResultsProp;
	public var selected_filter:String = "none";
	private inline static final selectedColor:FlxColor = 0x9E2929;
	private static final FILTERS = ["none","naughty","safe","both"];
	
	//PAGERS
    public var resultsObjectControls_empty:FlxText;
	public var resultsObjectControls:FlxSpriteGroup;
	public var resultsObjectControls_labels:FlxSpriteGroup;

	// GENERAL
	public var list_objSelector:PsychUIDropDownMenu;
	public var list_previewFilterSelector:PsychUIDropDownMenu;
	public var input_musicPath:PsychUIInputText;
	public var btn_moveUp:PsychUIButton;
	public var btn_moveDown:PsychUIButton;
	public var btn_removeObject:PsychUIButton;
	//PROPERTIES
	public var list_filterSelector:PsychUIDropDownMenu;
	public var input_imagePath:PsychUIInputText;
	public var input_soundPath:PsychUIInputText;
	public var stepper_scale:PsychUINumericStepper;
	public var stepper_offsetY:PsychUINumericStepper;
	public var chkBox_loopable:PsychUICheckBox;
	public var stepper_offsetX:PsychUINumericStepper;
	public var stepper_delay:PsychUINumericStepper;
	public var stepper_loopFrame:PsychUINumericStepper;
	public var input_labelStart:PsychUIInputText;
	public var input_labelLoop:PsychUIInputText;
	public var btn_reload:PsychUIButton;

    public function new(host:ResultsScreenEdit) {
        super(FlxG.width - 500, FlxG.height, 270, 220, ['General', "Properties"]);
		x -= width;
		y -= height;
		scrollFactor.set();
		visible = false;

		var rankSelector = new PsychUIDropDownMenu(10, 20, ["PERFECT_GOLD", "PERFECT", "EXCELLENT", "GREAT", "GOOD", "SHIT"], (index, name) ->
		{
			host.reloadprops([PERFECT_GOLD, PERFECT, EXCELLENT, GREAT, GOOD, SHIT][index]);
			list_previewFilterSelector.selectedLabel = "none";
			showEmptyObject();
		});
		list_previewFilterSelector = new PsychUIDropDownMenu(140,160,FILTERS,(index,item) -> {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			@:privateAccess
			host.wasReset = true;
			host.propSystem.resetAll(item);
			selected_filter = item;
			FlxG.sound.music?.pause();
		});
		//FilterType.
		list_objSelector = new PsychUIDropDownMenu(140, 20, [], (index, name) -> {
			if(selected_prop?.sprite != null) selected_prop.sprite.color = 0xFFFFFF;
			selected_prop = host.propSystem.sprites[index];
			if(selected_prop.data == null){
				showEmptyObject();
				return;
			}
			else if(selected_prop.data.renderType == "animateatlas"){
				resultsObjectControls_labels.visible = true;
			}
			else resultsObjectControls_labels.visible = false;
			resultsObjectControls.visible = true;
			resultsObjectControls_empty.visible = false;
			btn_moveUp.visible = btn_moveUp.active = 
			btn_moveDown.visible = btn_moveDown.active = 
			btn_removeObject.visible = true;

			input_imagePath.text = selected_prop.data.assetPath;
			if(selected_prop.data.filter == null || selected_prop.data.filter == "") list_filterSelector.selectedLabel =  "both";
			else list_filterSelector.selectedLabel =  selected_prop.data.filter;
			input_soundPath.text = selected_prop.data.sound;
			stepper_scale.value = selected_prop.data.scale ?? 1;
			stepper_loopFrame.value = selected_prop.data.loopFrame ?? 0;
			stepper_offsetY.value = Math.round(selected_prop.data.offsets[1]);
			stepper_offsetX.value = Math.round(selected_prop.data.offsets[0]);
			stepper_delay.value = selected_prop.data.delay;
			chkBox_loopable.checked = selected_prop.data.looped ?? true;
			input_labelStart.text = selected_prop.data.startFrameLabel ?? "";
			input_labelLoop.text = selected_prop.data.loopFrameLabel ?? "";

			if(selected_prop?.sprite != null) selected_prop.sprite.color = selectedColor;
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

		
		btn_moveUp = new PsychUIButton(160, 90, "Move up", () -> {
			var curIndex = list_objSelector.selectedIndex;
			if(curIndex == 0) {
				FlxG.sound.play(Paths.sound('CS_hihat'));
				return;
			}
			list_objSelector.moveCurrentItem(-1);
			host.propSystem.moveProp(selected_prop,curIndex-1);
			host.propSystem.refresh();
			list_objSelector.selectedIndex = curIndex-1;
		}, 100);
		btn_moveDown = new PsychUIButton(160, 120, "Move down", () -> {
			var curIndex = list_objSelector.selectedIndex;
			if(curIndex == list_objSelector.list.length-1) {
				FlxG.sound.play(Paths.sound('CS_hihat'));
				return;
			}
			list_objSelector.moveCurrentItem(1);
			host.propSystem.moveProp(selected_prop,curIndex+1);
			host.propSystem.refresh();
			list_objSelector.selectedIndex = curIndex+1;
		}, 100);
		var btn_newSparrow = new PsychUIButton(10, 90, "New sparrow", () -> spawnNewObject("sparrow",host), 100);
		var btn_newAtlas = new PsychUIButton(10, 120, "New atlas", () -> spawnNewObject("animateatlas",host), 100);
		btn_removeObject = new PsychUIButton(10, 150, "Remove object", () -> {
			var curIndex = list_objSelector.selectedIndex;
			list_objSelector.removeIndex(curIndex);
			host.propSystem.removeProp(selected_prop);
			host.activePlayer.getResultsAnimationDatas(host.activeRank).remove(selected_prop.data);
			list_objSelector.selectedIndex = FlxMath.minInt(curIndex,list_objSelector.list.length-1);
			list_objSelector.onSelect(list_objSelector.selectedIndex,list_objSelector.selectedLabel);
		}, 100);
		btn_moveUp.visible = btn_moveUp.active = 
		btn_moveDown.visible = btn_moveDown.active = 
		btn_removeObject.visible = false;

		///////////////////
		selectedName = 'General';
		var tab = getTab('General').menu;
		tab.add(input_musicPath.makeLabel("Rank music path:"));
		tab.add(input_musicPath);
		tab.add(btn_moveUp);
		tab.add(btn_moveDown);
		tab.add(list_previewFilterSelector);
		tab.add(list_previewFilterSelector.makeLabel("Preview filter:"));
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

		input_imagePath = new PsychUIInputText(10,10,250);
		input_soundPath = new PsychUIInputText(80,160,100);
		list_filterSelector = new PsychUIDropDownMenu(180,50,FILTERS,(index,item) ->{
			selected_prop.data.filter = item;
			selected_prop.prop.resetAnimation(item);
		},40);
		stepper_scale = new PsychUINumericStepper(100,130,0.1,1,0,10,3);
		stepper_offsetX = new PsychUINumericStepper(25,60,1,0,-999,9999);
		stepper_offsetY = new PsychUINumericStepper(25,90,1,0,-999,9999);
		stepper_delay = new PsychUINumericStepper(10,130,0.1,0,0,20,1);
		btn_reload = new PsychUIButton(10, 160, "Reload", () -> {
			host.propSystem.reloadProp(selected_prop);
			@:privateAccess
			host.wasReset = true;
			host.propSystem.resetAll(list_filterSelector.selectedLabel);
			if(selected_prop?.sprite != null) selected_prop.sprite.color = selectedColor;
		});
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
			selected_prop.sprite.scale.set(stepper_scale.value,stepper_scale.value);
			addOffset(0,0);
		}
		
		chkBox_loopable = new PsychUICheckBox(100,60,"loopable",100,() ->{
			selected_prop.data.looped = chkBox_loopable.checked;
		});
		stepper_loopFrame = new PsychUINumericStepper(100,100);
		resultsObjectControls.add(input_imagePath);
		resultsObjectControls.add(input_imagePath.makeLabel("Image path"));
		resultsObjectControls.add(input_soundPath);
		resultsObjectControls.add(input_soundPath.makeLabel("Sound path"));
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
		resultsObjectControls.add(btn_reload);
		resultsObjectControls.add(list_filterSelector);
		resultsObjectControls.add(list_filterSelector.makeLabel("Filter"));

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

		tab.add(resultsObjectControls_labels);
		tab.add(resultsObjectControls);
		tab.add(resultsObjectControls_empty);
        selectedName = 'General';
    }
	public function addOffset(x:Int,y:Int) {
		if(selected_prop?.data == null) return;
		selected_prop.data.offsets[0] += x;
		selected_prop.data.offsets[1] += y;
		stepper_offsetX.value = Math.round(selected_prop.data.offsets[0]);
		stepper_offsetY.value = Math.round(selected_prop.data.offsets[1]);
		if(selected_prop?.prop == null) return;
		selected_prop.prop.set_offset(selected_prop.data.offsets[0],selected_prop.data.offsets[1]);
	}
	private function showEmptyObject() {
		resultsObjectControls.visible = false;
		resultsObjectControls_labels.visible = false;
		resultsObjectControls_empty.visible = true;
		btn_moveUp.visible = false;
		btn_moveDown.visible = false;
		btn_removeObject.visible = false;
	}
	private function spawnNewObject(kind:String,host:ResultsScreenEdit){
		@:privateAccess
		list_objSelector.addOption("none");
		if (list_objSelector.list.length >= 20)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				return;
			}
		var data:PlayerResultsAnimationData = {
			renderType: kind,
			filter: "",
			sound: "",
			assetPath: "none",
			zIndex: host.propSystem.sprites[host.propSystem.sprites.length-1].zIndex,
			offsets: [500,500],
			loopFrameLabel: "",
			loopFrame: 0,
			looped: false,
			startFrameLabel: "",
			scale: 1.0,
			delay: 0
		};
		host.propSystem.addProp(data);
		host.activePlayer.getResultsAnimationDatas(host.activeRank).push(data);
		list_objSelector.selectedIndex = list_objSelector.list.length-1;
		list_objSelector.onSelect(list_objSelector.selectedIndex,list_objSelector.selectedLabel);
	}
}