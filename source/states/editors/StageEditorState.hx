package states.editors;

import states.editors.boxes.StageEditorAnimationSubstate;
import states.editors.boxes.StageEditorMainBox;
import states.editors.content.FileDialogHandler;
import backend.StageData;
import objects.Character;
import flixel.FlxObject;
import flixel.util.FlxDestroyUtil;
import psychlua.ModchartSprite;
import flash.net.FileFilter;
import states.editors.content.Prompt;

@:allow(states.editors.boxes.StageEditorMainBox)
class StageEditorState extends MusicBeatState implements PsychUIEventHandler.PsychUIEvent
{
	final minZoom = 0.1;
	final maxZoom = 2;

	var gf:Character;
	var dad:Character;
	var boyfriend:Character;
	var stageJson:StageFile;

	var camGame:FlxCamera;

	public var camHUD:FlxCamera;

	var UI_stagebox:PsychUIBox;
	var UI_box:StageEditorMainBox;
	var spriteList_box:PsychUIBox;
	var stageSprites:Array<StageEditorMetaSprite> = [];

	public function new(stageToLoad:String = 'stage', cachedJson:StageFile = null)
	{
		lastLoadedStage = stageToLoad;
		stageJson = cachedJson;
		super();
	}

	var lastLoadedStage:String;
	var camFollow:FlxObject = new FlxObject(0, 0, 1, 1);

	var helpBg:FlxSprite;
	var helpTexts:FlxSpriteGroup;
	var posTxt:FlxText;
	var outputTxt:FlxText;

	var animationEditor:StageEditorAnimationSubstate;

	var fileDialog:FileDialogHandler = new FileDialogHandler();
	var unsavedProgress:Bool = false;

	var selectionSprites:FlxSpriteGroup = new FlxSpriteGroup();

	override function create()
	{
		CacheSystem.clearStoredMemory();
		CacheSystem.clearUnusedMemory();

		camGame = initPsychCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		#if DISCORD_ALLOWED
		DiscordClient.changePresence('Stage Editor', 'Stage: ' + lastLoadedStage);
		#end

		if (stageJson == null)
			stageJson = StageData.getStageFile(lastLoadedStage);
		FlxG.camera.follow(null, LOCKON, 0);

		loadJsonAssetDirectory();
		gf = new Character(0, 0, stageJson._editorMeta != null ? stageJson._editorMeta.gf : 'gf');
		gf.visible = !(stageJson.hide_girlfriend);
		gf.scrollFactor.set(0.95, 0.95);
		dad = new Character(0, 0, stageJson._editorMeta != null ? stageJson._editorMeta.dad : 'dad');
		boyfriend = new Character(0, 0, stageJson._editorMeta != null ? stageJson._editorMeta.boyfriend : 'bf', true);

		for (i in 0...4)
		{
			var spr:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.LIME);
			spr.alpha = 0.8;
			selectionSprites.add(spr);
		}

		FlxG.camera.zoom = stageJson.defaultZoom;
		repositionGirlfriend();
		repositionDad();
		repositionBoyfriend();
		var point = focusOnTarget('boyfriend');
		FlxG.camera.scroll.set(point.x - FlxG.width / 2, point.y - FlxG.height / 2);

		screenUI();
		spriteCreatePopup();
		editorUI();

		add(camFollow);
		updateSpriteList();

		addHelpScreen();
		FlxG.mouse.visible = true;
		animationEditor = new StageEditorAnimationSubstate();

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad('LEFT_FULL', 'CHARACTER_EDITOR');
		addTouchPadCamera(false);
		#end

		super.create();
	}

	function loadJsonAssetDirectory()
	{
		var directory:String = 'shared';
		var weekDir:String = stageJson.directory;
		if (weekDir != null && weekDir.length > 0 && weekDir != '')
			directory = weekDir;

		Paths.setCurrentLevel(directory);
		trace('Setting asset folder to ' + directory);
	}

	var showSelectionQuad:Bool = true;

	function addHelpScreen()
	{
		#if FLX_DEBUG
		var btn = 'F3';
		#else
		var btn = 'F2';
		#end

		var str:Array<String> = (controls.mobileC) ? ["X/Y - Camera Zoom In/Out",
			"G + Arrow Buttons - Move Camera",
			"Z - Reset Camera Zoom",
			"Arrow Buttons/Drag - Move Object",
			"",
			"S - Toggle HUD",
			// "F12 - Toggle Selection Rectangle",
			// "Hold Control - Move Objects pixel-by-pixel and Camera 4x slower",
			"Hold C - Move Objects and Camera 4x faster"
		] : [
			"E/Q - Camera Zoom In/Out",
			"J/K/L/I - Move Camera",
			"R - Reset Camera Zoom",
			"Arrow Keys/Mouse & Right Click - Move Object",
			"",
			'$btn - Toggle HUD',
			"F12 - Toggle Selection Rectangle",
			"Hold Shift - Move Objects and Camera 4x faster",
			"Hold Control - Move Objects pixel-by-pixel and Camera 4x slower"
			];

		helpBg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		helpBg.scale.set(FlxG.width, FlxG.height);
		helpBg.updateHitbox();
		helpBg.alpha = 0.6;
		helpBg.cameras = [camHUD];
		helpBg.active = helpBg.visible = false;
		add(helpBg);

		helpTexts = new FlxSpriteGroup();
		helpTexts.cameras = [camHUD];
		for (i => txt in str)
		{
			if (txt.length < 1)
				continue;

			var helpText:FlxText = new FlxText(0, 0, 680, txt, 16);
			helpText.setFormat(null, 16, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
			helpText.borderColor = FlxColor.BLACK;
			helpText.scrollFactor.set();
			helpText.borderSize = 1;
			helpText.screenCenter();
			add(helpText);
			helpText.y += ((i - str.length / 2) * 32) + 16;
			helpText.active = false;
			helpTexts.add(helpText);
		}
		helpTexts.active = helpTexts.visible = false;
		add(helpTexts);
	}

	function updateSpriteList()
	{
		for (spr in stageSprites)
			if (spr != null && !StageData.reservedNames.contains(spr.type))
				spr.sprite = FlxDestroyUtil.destroy(spr.sprite);

		stageSprites = [];
		var list:Map<String, FlxSprite> = [];
		if (stageJson.objects != null && stageJson.objects.length > 0)
		{
			list = StageData.addObjectsToState(stageJson.objects, gf, dad, boyfriend, null, true);
			for (key => spr in list)
				stageSprites[spr.ID] = new StageEditorMetaSprite(stageJson.objects[spr.ID], spr);

			/*for (num => spr in stageSprites)
				trace('$num: ${spr.type}, ${spr.name}'); */
		}

		for (character in ['gf', 'dad', 'boyfriend'])
			if (!list.exists(character))
				stageSprites.push(new StageEditorMetaSprite({type: character}, Reflect.field(this, character)));

		updateSpriteListRadio();
	}

	var spriteListRadioGroup:PsychUIRadioGroup;
	var focusRadioGroup:PsychUIRadioGroup;

	function screenUI()
	{
		var lowQualityCheckbox:PsychUICheckBox = null;
		var highQualityCheckbox:PsychUICheckBox = null;
		function visibilityFilterUpdate()
		{
			curFilters = 0;
			if (lowQualityCheckbox.checked)
				curFilters |= LOW_QUALITY;
			if (highQualityCheckbox.checked)
				curFilters |= HIGH_QUALITY;
		}

		spriteList_box = new PsychUIBox(25, 40, 250, 200, ['Sprite List']);
		spriteList_box.scrollFactor.set();
		spriteList_box.cameras = [camHUD];
		add(spriteList_box);
		addSpriteListBox();

		var bg:FlxSprite = new FlxSprite(0, FlxG.height - 60).makeGraphic(1, 1, FlxColor.BLACK);
		bg.cameras = [camHUD];
		bg.alpha = 0.4;
		bg.scale.set(FlxG.width, FlxG.height - bg.y);
		bg.updateHitbox();
		add(bg);

		var tipText:FlxText = new FlxText(0, FlxG.height - 44, 300, 'Press ${controls.mobileC ? 'F' : 'F1'} for Help', 20);
		tipText.alignment = CENTER;
		tipText.cameras = [camHUD];
		tipText.scrollFactor.set();
		tipText.screenCenter(X);
		tipText.active = false;
		add(tipText);

		var targetTxt:FlxText = new FlxText(30, FlxG.height - 52, 300, 'Camera Target', 16);
		targetTxt.alignment = CENTER;
		targetTxt.cameras = [camHUD];
		targetTxt.scrollFactor.set();
		targetTxt.active = false;
		add(targetTxt);

		focusRadioGroup = new PsychUIRadioGroup(targetTxt.x, FlxG.height - 24, ['dad', 'boyfriend', 'gf'], 10, 0, true);
		focusRadioGroup.onClick = function()
		{
			// trace('Changed focus to $target');
			var point = focusOnTarget(focusRadioGroup.labels[focusRadioGroup.checked]);
			camFollow.setPosition(point.x, point.y);
			FlxG.camera.target = camFollow;
		}
		focusRadioGroup.radios[0].label = 'Opponent';
		focusRadioGroup.radios[1].label = 'Boyfriend';
		focusRadioGroup.radios[2].label = 'Girlfriend';

		for (radio in focusRadioGroup.radios)
			radio.text.size = 11;

		focusRadioGroup.cameras = [camHUD];
		add(focusRadioGroup);

		lowQualityCheckbox = new PsychUICheckBox(FlxG.width - 240, FlxG.height - 36, 'Can see Low Quality Sprites?', 90);
		lowQualityCheckbox.cameras = [camHUD];
		lowQualityCheckbox.onClick = visibilityFilterUpdate;
		lowQualityCheckbox.checked = false;
		add(lowQualityCheckbox);

		highQualityCheckbox = new PsychUICheckBox(FlxG.width - 120, FlxG.height - 36, 'Can see High Quality Sprites?', 90);
		highQualityCheckbox.cameras = [camHUD];
		highQualityCheckbox.onClick = visibilityFilterUpdate;
		highQualityCheckbox.checked = true;
		add(highQualityCheckbox);
		visibilityFilterUpdate();

		posTxt = new FlxText(0, 50, 500, 'X: 0\nY: 0', 24);
		posTxt.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		posTxt.borderSize = 2;
		posTxt.cameras = [camHUD];
		posTxt.screenCenter(X);
		posTxt.visible = false;
		add(posTxt);

		outputTxt = new FlxText(0, 0, 800, '', 24);
		outputTxt.alignment = CENTER;
		outputTxt.borderStyle = OUTLINE_FAST;
		outputTxt.borderSize = 1;
		outputTxt.cameras = [camHUD];
		outputTxt.screenCenter();
		outputTxt.alpha = 0;
		add(outputTxt);
	}

	function addSpriteListBox()
	{
		var tab_group = spriteList_box.getTab('Sprite List').menu;
		spriteListRadioGroup = new PsychUIRadioGroup(10, 10, [], 25, 18, false, 200);
		spriteListRadioGroup.cameras = [camHUD];
		spriteListRadioGroup.onClick = function()
		{
			trace('Selected sprite: ${spriteListRadioGroup.checkedRadio.label}');
			updateSelectedUI();
		}
		tab_group.add(spriteListRadioGroup);

		var buttonX = spriteList_box.x + spriteList_box.width - 10;
		var buttonY = spriteListRadioGroup.y - 30;
		var buttonMoveUp:PsychUIButton = new PsychUIButton(buttonX, buttonY, 'Move Up', function()
		{
			var selected:Int = spriteListRadioGroup.checked;
			if (selected < 0)
				return;

			var selected:Int = spriteListRadioGroup.labels.length - selected - 1;
			var spr = stageSprites[selected];
			if (spr == null)
				return;

			var newSel:Int = Std.int(Math.min(stageSprites.length - 1, selected + 1));
			stageSprites.remove(spr);
			stageSprites.insert(newSel, spr);

			updateSpriteListRadio();
		});
		buttonMoveUp.cameras = [camHUD];
		tab_group.add(buttonMoveUp);

		var buttonMoveDown:PsychUIButton = new PsychUIButton(buttonX, buttonY + 30, 'Move Down', function()
		{
			var selected:Int = spriteListRadioGroup.checked;
			if (selected < 0)
				return;

			var selected:Int = spriteListRadioGroup.labels.length - selected - 1;
			var spr = stageSprites[selected];
			if (spr == null)
				return;

			var newSel:Int = Std.int(Math.max(0, selected - 1));
			stageSprites.remove(spr);
			stageSprites.insert(newSel, spr);

			updateSpriteListRadio();
		});
		buttonMoveDown.cameras = [camHUD];
		tab_group.add(buttonMoveDown);

		var buttonCreate:PsychUIButton = new PsychUIButton(buttonX, buttonY + 60, 'New', function() createPopup.visible = createPopup.active = true);
		buttonCreate.cameras = [camHUD];
		buttonCreate.normalStyle.bgColor = FlxColor.GREEN;
		buttonCreate.normalStyle.textColor = FlxColor.WHITE;
		tab_group.add(buttonCreate);

		var buttonDuplicate:PsychUIButton = new PsychUIButton(buttonX, buttonY + 90, 'Duplicate', function()
		{
			var selected:Int = spriteListRadioGroup.checked;
			if (selected < 0)
				return;

			var selected:Int = spriteListRadioGroup.labels.length - selected - 1;
			var spr = stageSprites[selected];
			if (spr == null || StageData.reservedNames.contains(spr.type))
				return;

			var copiedSpr = new ModchartSprite();

			if(spr.type == "square") copiedSpr.makeGraphic(1,1,0xFFFFFFFF);
			else copiedSpr.graphic = spr.sprite.graphic;

			var copiedMeta:StageEditorMetaSprite = new StageEditorMetaSprite(null, copiedSpr);
			for (field in Reflect.fields(spr))
			{
				if (field == 'sprite')
					continue; // do NOT copy sprite or it might get messy

				try
				{
					var fld:Dynamic = Reflect.getProperty(spr, field);
					if (fld is Array)
					{
						var arr:Array<Dynamic> = fld;
						arr = arr.copy();
						if (arr != null)
						{
							for (k => v in arr)
							{
								var indices:Array<Int> = v.indices;
								if (indices != null)
									indices = indices.copy();

								var offs:Array<Int> = v.offsets;
								if (offs != null)
									offs = offs.copy();

								fld[k] = {
									anim: v.anim,
									name: v.name,
									fps: v.fps,
									loop: v.loop,
									indices: indices,
									offsets: offs
								}
							}
						}
						fld = arr;
					}

					Reflect.setProperty(copiedMeta, field, fld);
					// trace('success? $field');
				}
				catch (e:Dynamic)
				{
					// trace('failed: $field');
				}
			}

			if (copiedMeta.animations != null)
			{
				for (num => anim in copiedMeta.animations)
				{
					if (anim == null || anim.anim == null)
						continue;

					if (anim.indices != null && anim.indices.length > 0)
						copiedSpr.animation.addByIndices(anim.anim, anim.name, anim.indices, '', anim.fps, anim.loop);
					else
						copiedSpr.animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);

					if (anim.offsets != null && anim.offsets.length > 1)
						copiedSpr.addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);

					if (copiedSpr.animation.curAnim == null || copiedMeta.firstAnimation == anim.anim)
						copiedSpr.playAnim(anim.anim, true);
				}
			}
			copiedMeta.setScale(copiedMeta.scale[0], copiedMeta.scale[1]);
			copiedMeta.setScrollFactor(copiedMeta.scroll[0], copiedMeta.scroll[1]);
			copiedMeta.name = findUnoccupiedName('${copiedMeta.name}_copy');
			insertMeta(copiedMeta, 1);
		});
		buttonDuplicate.cameras = [camHUD];
		buttonDuplicate.normalStyle.bgColor = FlxColor.BLUE;
		buttonDuplicate.normalStyle.textColor = FlxColor.WHITE;
		tab_group.add(buttonDuplicate);

		var buttonDelete:PsychUIButton = new PsychUIButton(buttonX, buttonY + 120, 'Delete', function()
		{
			var selected:Int = spriteListRadioGroup.checked;
			if (selected < 0)
				return;

			var selected:Int = spriteListRadioGroup.labels.length - selected - 1;
			var spr = stageSprites[selected];
			if (spr == null || StageData.reservedNames.contains(spr.type))
				return;

			stageSprites.remove(spr);
			spr.sprite = FlxDestroyUtil.destroy(spr.sprite);

			updateSpriteListRadio();
		});
		buttonDelete.cameras = [camHUD];
		buttonDelete.normalStyle.bgColor = FlxColor.RED;
		buttonDelete.normalStyle.textColor = FlxColor.WHITE;
		tab_group.add(buttonDelete);
	}

	function showOutput(txt:String, isError:Bool = false)
	{
		outputTxt.color = isError ? FlxColor.RED : FlxColor.WHITE;
		outputTxt.text = txt;
		outputTime = 3;

		if (isError)
			FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
		else
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}

	var createPopup:FlxSpriteGroup;

	function findUnoccupiedName(prefix = 'sprite')
	{
		var num:Int = 1;
		var name:String = 'unnamed';
		while (true)
		{
			var cantUseName:Bool = false;

			name = prefix + num;
			for (basic in stageSprites)
			{
				if (basic.name == name)
				{
					cantUseName = true;
					break;
				}
			}

			if (cantUseName)
			{
				num++;
				continue;
			}
			break;
		}
		return name;
	}

	function insertMeta(meta, insertOffset:Int = 0)
	{
		var num:Int = Std.int(Math.max(0,
			Math.min(spriteListRadioGroup.labels.length, spriteListRadioGroup.labels.length - spriteListRadioGroup.checked - 1 + insertOffset)));
		stageSprites.insert(num, meta);
		updateSpriteListRadio();
		createPopup.visible = createPopup.active = false;
		spriteListRadioGroup.checked = spriteListRadioGroup.labels.length - num - 1;
		updateSelectedUI();
		unsavedProgress = true;
	}

	function spriteCreatePopup()
	{
		createPopup = new FlxSpriteGroup();
		createPopup.cameras = [camHUD];

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scale.set(300, 240);
		bg.updateHitbox();
		bg.screenCenter();
		createPopup.add(bg);

		var txt:FlxText = new FlxText(0, bg.y + 10, 180, 'New Sprite', 24);
		txt.screenCenter(X);
		txt.alignment = CENTER;
		createPopup.add(txt);

		var btnY = 320;
		var btn:PsychUIButton = new PsychUIButton(0, btnY, 'No Animation', function() loadImage('sprite'));
		btn.screenCenter(X);
		createPopup.add(btn);

		btnY += 50;
		var btn:PsychUIButton = new PsychUIButton(0, btnY, 'Animated', function() loadImage('animatedSprite'));
		btn.screenCenter(X);
		createPopup.add(btn);

		btnY += 50;
		var btn:PsychUIButton = new PsychUIButton(0, btnY, 'Solid Color', function()
		{
			var meta:StageEditorMetaSprite = new StageEditorMetaSprite({type: 'square', scale: [200, 200], name: findUnoccupiedName()}, new ModchartSprite());
			meta.sprite.makeGraphic(1, 1, FlxColor.WHITE);
			meta.sprite.scale.set(200, 200);
			meta.sprite.screenCenter();
			meta.sprite.updateHitbox();
			insertMeta(meta);
		});
		btn.screenCenter(X);
		createPopup.add(btn);
		add(createPopup);
		createPopup.visible = createPopup.active = false;
	}

	function updateSpriteListRadio()
	{
		var _sel:String = (spriteListRadioGroup.checkedRadio != null ? spriteListRadioGroup.checkedRadio.label : null);
		var nameList:Array<String> = [];
		for (spr in stageSprites)
		{
			if (spr == null)
				continue;

			switch (spr.type)
			{
				case 'gf':
					nameList.push('- Girlfriend -');
				case 'boyfriend':
					nameList.push('- Boyfriend -');
				case 'dad':
					nameList.push('- Opponent -');
				default:
					nameList.push(spr.name);
			}
		}
		nameList.reverse();

		spriteListRadioGroup.labels = nameList;
		for (radio in spriteListRadioGroup.radios)
		{
			if (radio.label == _sel)
			{
				spriteListRadioGroup.checkedRadio = radio;
				break;
			}
		}

		final maxNum:Int = 19;
		spriteList_box.resize(250, Std.int(Math.min(maxNum, spriteListRadioGroup.labels.length) * 25 + 35));
	}

	function editorUI()
	{
		UI_box = new StageEditorMainBox(this);
		UI_box.cameras = [camHUD];
		UI_box.scrollFactor.set();
		add(UI_box);
		UI_box.selectedName = 'Data';

		UI_stagebox = new PsychUIBox(FlxG.width - 275, 25, 250, 100, ['Stage']);
		UI_stagebox.cameras = [camHUD];
		UI_stagebox.scrollFactor.set();
		add(UI_stagebox);
		UI_box.y += UI_stagebox.y + UI_stagebox.height;


		addStageTab();
	}


	var stageDropDown:PsychUIDropDownMenu;

	function addStageTab()
	{
		var tab_group = UI_stagebox.getTab('Stage').menu;
		var reloadStage:PsychUIButton = new PsychUIButton(140, 10, 'Reload', function()
		{
			#if DISCORD_ALLOWED
			DiscordClient.changePresence('Stage Editor', 'Stage: ' + lastLoadedStage);
			#end

			stageJson = StageData.getStageFile(lastLoadedStage);
			updateSpriteList();
			UI_box.updateStageDataUI();
			reloadCharacters();
			reloadStageDropDown();
		});

		var dummyStage:PsychUIButton = new PsychUIButton(140, 40, 'Load Template', function()
		{
			#if DISCORD_ALLOWED
			DiscordClient.changePresence('Stage Editor', 'New Stage');
			#end

			stageJson = StageData.dummy();
			updateSpriteList();
			UI_box.updateStageDataUI();
			reloadCharacters();
		});
		dummyStage.normalStyle.bgColor = FlxColor.RED;
		dummyStage.normalStyle.textColor = FlxColor.WHITE;

		stageDropDown = new PsychUIDropDownMenu(10, 30, [''], function(sel:Int, selected:String)
		{
			var characterPath:String = 'stages/$selected.json';
			var path:String = Paths.getPath(characterPath, TEXT, null, true);
			if (NativeFileSystem.exists(path))
			{
				stageJson = StageData.getStageFile(selected);
				lastLoadedStage = selected;
				#if DISCORD_ALLOWED
				DiscordClient.changePresence('Stage Editor', 'Stage: ' + lastLoadedStage);
				#end
				updateSpriteList();
				UI_box.updateStageDataUI();
				reloadCharacters();
				reloadStageDropDown();
			}
		else
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			reloadStageDropDown();
		}
		});
		reloadStageDropDown();

		tab_group.add(new FlxText(stageDropDown.x, stageDropDown.y - 18, 60, 'Stage:'));
		tab_group.add(reloadStage);
		tab_group.add(dummyStage);
		tab_group.add(stageDropDown);
	}



	function updateSelectedUI()
	{
		posTxt.visible = false;
		var selected = UI_box.getSelected(false);
		if (selected == null)
			return;

		var displayX:Float = Math.round(selected.x);
		var displayY:Float = Math.round(selected.y);

		var char:Character = cast selected.sprite;
		if (char != null)
		{
			displayX -= char.positionArray[0];
			displayY -= char.positionArray[1];
		}

		posTxt.text = 'X: $displayX\nY: $displayY';
		posTxt.visible = true;

		UI_box.updateSelectedUI();

	}

	function reloadCharacters()
	{
		if (stageJson._editorMeta != null)
		{
			gf.changeCharacter(stageJson._editorMeta.gf);
			dad.changeCharacter(stageJson._editorMeta.dad);
			boyfriend.changeCharacter(stageJson._editorMeta.boyfriend);
		}
		repositionGirlfriend();
		repositionDad();
		repositionBoyfriend();

		focusRadioGroup.checked = -1;
		FlxG.camera.target = null;
		var point = focusOnTarget('boyfriend');
		FlxG.camera.scroll.set(point.x - FlxG.width / 2, point.y - FlxG.height / 2);
		FlxG.camera.zoom = stageJson.defaultZoom;
		UI_box.oppDropdown.selectedLabel = dad.curCharacter;
		UI_box.gfDropdown.selectedLabel = gf.curCharacter;
		UI_box.plDropdown.selectedLabel = boyfriend.curCharacter;
	}

	function reloadStageDropDown()
	{
		var stageList:Array<String> = [];
		var foldersToCheck:Array<String> = Mods.directoriesWithFile(Paths.getSharedPath(), 'stages/');
		for (folder in foldersToCheck)
			for (file in NativeFileSystem.readDirectory(folder))
				if (file.toLowerCase().endsWith('.json'))
				{
					var stageToCheck:String = file.substr(0, file.length - '.json'.length);
					if (!stageList.contains(stageToCheck))
						stageList.push(stageToCheck);
				}

		if (stageList.length < 1)
			stageList.push('');
		stageDropDown.list = stageList;
		stageDropDown.selectedLabel = lastLoadedStage;
		UI_box.directoryDropDown.selectedLabel = stageJson.directory;
	}

	function checkUIOnObject()
	{
		if (UI_box.selectedName == 'Object')
		{
			var selected:Int = spriteListRadioGroup.checked;
			if (selected >= 0)
			{
				var spr = stageSprites[spriteListRadioGroup.labels.length - selected - 1];
				if (spr != null && StageData.reservedNames.contains(spr.type))
					UI_box.selectedName = 'Data';
			}
			else{
				showOutput("No object was selected!",true);
				UI_box.selectedName = 'Data';
			}
		}
	}

	public function UIEvent(id:String, sender:Dynamic)
	{
		switch (id)
		{
			case PsychUIRadioGroup.CLICK_EVENT, PsychUIBox.CLICK_EVENT:
				if (sender == spriteListRadioGroup || sender == UI_box)
					checkUIOnObject();

			case PsychUICheckBox.CLICK_EVENT:
				unsavedProgress = true;

			case PsychUIInputText.CHANGE_EVENT, PsychUINumericStepper.CHANGE_EVENT:
				unsavedProgress = true;
		}
	}

	var outputTime:Float = 0;

	override function update(elapsed:Float)
	{
		//? pulling key presses

		var pressed_I = FlxG.keys.pressed.I;
		var pressed_J = FlxG.keys.pressed.J;
		var pressed_K = FlxG.keys.pressed.K;
		var pressed_L = FlxG.keys.pressed.L;

		var pressed_E = FlxG.keys.pressed.E;
		var pressed_Q = FlxG.keys.pressed.Q;

		var justPressed_F12 = FlxG.keys.justPressed.F12;
		var justPressed_F1 = FlxG.keys.justPressed.F1;

		var justPressed_S = FlxG.keys.justPressed.S;
		var justPressed_W = FlxG.keys.justPressed.W;

		var justPressed_RESET = FlxG.keys.justPressed.R && !FlxG.keys.pressed.CONTROL;

		var pressed_SHIFT = FlxG.keys.pressed.SHIFT;
		#if TOUCH_CONTROLS_ALLOWED

		pressed_I = pressed_I || touchPad.buttonG.pressed && touchPad.buttonUp.pressed;
		pressed_J = pressed_J || touchPad.buttonG.pressed && touchPad.buttonLeft.pressed;
		pressed_K = pressed_K || touchPad.buttonG.pressed && touchPad.buttonDown.pressed;
		pressed_L = pressed_L || touchPad.buttonG.pressed && touchPad.buttonRight.pressed;

		pressed_E = pressed_E || touchPad.buttonX.pressed;
		pressed_Q = pressed_Q || touchPad.buttonY.pressed;

		justPressed_F12 = justPressed_F12 || (touchPad.buttonS.justPressed && !touchPad.buttonG.justPressed);
		justPressed_F1 = justPressed_F1 || touchPad.buttonF.justPressed;

		justPressed_W = justPressed_W || touchPad.buttonV.justPressed;
		justPressed_S = justPressed_S || touchPad.buttonD.justPressed;

		justPressed_RESET = justPressed_RESET || touchPad.buttonZ.justPressed;

		pressed_SHIFT = pressed_SHIFT || touchPad.buttonC.pressed;
		#end

		if (createPopup.visible && (FlxG.mouse.justPressedRight || (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(createPopup, camHUD))))
			createPopup.visible = createPopup.active = false;

		for (basic in stageSprites)
			basic.update(curFilters, elapsed);

		super.update(elapsed);

		outputTime = Math.max(0, outputTime - elapsed);
		outputTxt.alpha = outputTime;

		if (PsychUIInputText.focusOn != null)
			return;

		if (FlxG.keys.justPressed.ESCAPE 
			#if android || FlxG.android.justPressed.BACK #end 
			#if TOUCH_CONTROLS_ALLOWED || touchPad.buttonB.justPressed #end)
		{
			if (!unsavedProgress)
			{
				MusicBeatState.switchState(new states.editors.MasterEditorMenu());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
			else
				openSubState(new ExitConfirmationPrompt());
			return;
		}

		if (justPressed_W)
		{
			spriteListRadioGroup.checked = FlxMath.wrap(spriteListRadioGroup.checked - 1, 0, spriteListRadioGroup.labels.length - 1);
			trace(spriteListRadioGroup.checked);
			checkUIOnObject();
			updateSelectedUI();
		}
		else if (justPressed_S)
		{
			spriteListRadioGroup.checked = FlxMath.wrap(spriteListRadioGroup.checked + 1, 0, spriteListRadioGroup.labels.length - 1);
			trace(spriteListRadioGroup.checked);
			checkUIOnObject();
			updateSelectedUI();
		}

		if ((justPressed_F1) || (helpBg.visible && FlxG.keys.justPressed.ESCAPE))
		{
			#if TOUCH_CONTROLS_ALLOWED
			if (controls.mobileC)
			{
				touchPad.forEachAlive(function(button:TouchButton)
				{
					if (button.tag != 'F')
						button.visible = !button.visible;
				});
			}
			#end
			helpBg.visible = !helpBg.visible;
			helpTexts.visible = helpBg.visible;
		}

		if (#if FLX_DEBUG FlxG.keys.justPressed.F3 #else FlxG.keys.justPressed.F2 #end
			#if TOUCH_CONTROLS_ALLOWED || (touchPad.buttonS.justPressed && !touchPad.buttonF.justPressed) #end)
		{
			UI_box.visible = !UI_box.visible;
			UI_box.active = !UI_box.active;

			#if TOUCH_CONTROLS_ALLOWED
			if (controls.mobileC)
			{
				touchPad.forEachAlive(function(button:TouchButton)
				{
					if (button.tag != 'S')
						button.visible = !button.visible;
				});
			}
			#end

			var objs = [UI_stagebox, spriteListRadioGroup, spriteList_box];
			for (obj in objs)
			{
				obj.visible = UI_box.visible;
				if (!(obj is FlxText))
					obj.active = UI_box.active;
			}
			spriteListRadioGroup.updateRadioItems();
		}

		if (justPressed_F12)
			showSelectionQuad = !showSelectionQuad;

		var shiftMult:Float = 1;
		var ctrlMult:Float = 1;
		if (FlxG.keys.pressed.SHIFT #if TOUCH_CONTROLS_ALLOWED || touchPad.buttonC.pressed #end)
			shiftMult = 4;
		if (FlxG.keys.pressed.CONTROL)
			ctrlMult = 0.25;

		// CAMERA CONTROLS
		var camX:Float = 0;
		var camY:Float = 0;
		var camMove:Float = elapsed * 500 * shiftMult * ctrlMult;
		if (pressed_J)
			camX -= camMove;
		if (pressed_K)
			camY += camMove;
		if (pressed_L)
			camX += camMove;
		if (pressed_I)
			camY -= camMove;

		if (camX != 0 || camY != 0)
		{
			FlxG.camera.scroll.x += camX;
			FlxG.camera.scroll.y += camY;
			if (FlxG.camera.target != null)
				FlxG.camera.target = null;
			if (focusRadioGroup.checked > -1)
				focusRadioGroup.checked = -1;
		}

		var lastZoom = FlxG.camera.zoom;
		if (FlxG.keys.justPressed.R #if TOUCH_CONTROLS_ALLOWED || touchPad.buttonZ.justPressed #end && !FlxG.keys.pressed.CONTROL)
			FlxG.camera.zoom = stageJson.defaultZoom;
		else if (pressed_E && FlxG.camera.zoom < maxZoom)
			FlxG.camera.zoom = Math.min(maxZoom, FlxG.camera.zoom + elapsed * FlxG.camera.zoom * shiftMult * ctrlMult);
		else if (pressed_Q && FlxG.camera.zoom > minZoom)
			FlxG.camera.zoom = Math.max(minZoom, FlxG.camera.zoom - elapsed * FlxG.camera.zoom * shiftMult * ctrlMult);
		else if(FlxG.mouse.wheel != 0)
			FlxG.camera.zoom = Math.max(minZoom, FlxG.camera.zoom - elapsed * FlxG.camera.zoom * shiftMult * ctrlMult * -(FlxG.mouse.wheel*1.3));
		// SPRITE X/Y
		var shiftMult:Float = 1;
		var ctrlMult:Float = 1;
		if (pressed_SHIFT)
			shiftMult = 4;
		if (FlxG.keys.pressed.CONTROL)
			ctrlMult = 0.2;

		var moveX:Float = 0;
		var moveY:Float = 0;
		#if TOUCH_CONTROLS_ALLOWED
		if (!touchPad.buttonG.pressed)
		{
			if (FlxG.keys.justPressed.LEFT || touchPad.buttonLeft.justPressed)
				moveX -= 5 * shiftMult * ctrlMult;
			if (FlxG.keys.justPressed.RIGHT || touchPad.buttonRight.justPressed)
				moveX += 5 * shiftMult * ctrlMult;
			if (FlxG.keys.justPressed.UP || touchPad.buttonUp.justPressed)
				moveY -= 5 * shiftMult * ctrlMult;
			if (FlxG.keys.justPressed.DOWN || touchPad.buttonDown.justPressed)
				moveY += 5 * shiftMult * ctrlMult;
		}
		#else
				if (FlxG.keys.justPressed.LEFT)
					moveX -= 5 * shiftMult * ctrlMult;
				if (FlxG.keys.justPressed.RIGHT)
					moveX += 5 * shiftMult * ctrlMult;
				if (FlxG.keys.justPressed.UP)
					moveY -= 5 * shiftMult * ctrlMult;
				if (FlxG.keys.justPressed.DOWN)
					moveY += 5 * shiftMult * ctrlMult;
			
		#end

		if (FlxG.mouse.pressedRight && (FlxG.mouse.deltaScreenX != 0 || FlxG.mouse.deltaScreenY != 0))
		{
			moveX += FlxG.mouse.deltaScreenX * ctrlMult;
			moveY += FlxG.mouse.deltaScreenY * ctrlMult;
			_updateCamera();
		}

		if (moveX != 0 || moveY != 0)
		{
			var selected:Int = spriteListRadioGroup.checked;
			if (selected < 0)
				return;

			var spr = stageSprites[spriteListRadioGroup.labels.length - selected - 1];
			if (spr != null)
			{
				var displayX:Float, displayY:Float;
				spr.x = displayX = Math.round(spr.x + moveX);
				spr.y = displayY = Math.round(spr.y + moveY);
				var char:Character = cast spr.sprite;
				switch (spr.type)
				{
					case 'boyfriend':
						stageJson.boyfriend[0] = displayX = spr.x - char.positionArray[0];
						stageJson.boyfriend[1] = displayY = spr.y - char.positionArray[1];
					case 'gf':
						stageJson.girlfriend[0] = displayX = spr.x - char.positionArray[0];
						stageJson.girlfriend[1] = displayY = spr.y - char.positionArray[1];
					case 'dad':
						stageJson.opponent[0] = displayX = spr.x - char.positionArray[0];
						stageJson.opponent[1] = displayY = spr.y - char.positionArray[1];
				}
				posTxt.text = 'X: $displayX\nY: $displayY';
			}
		}
	}

	var curFilters:LoadFilters = (LOW_QUALITY) | (HIGH_QUALITY);

	override function draw()
	{
		if (persistentDraw || subState == null)
		{
			for (basic in stageSprites)
				if (basic.visible)
					basic.draw(curFilters);

			if (showSelectionQuad && spriteListRadioGroup.checkedRadio != null)
			{
				var spr = stageSprites[spriteListRadioGroup.labels.length - spriteListRadioGroup.checked - 1];
				if (spr != null)
					drawDebugOnCamera(spr.sprite,spr.type == "square");
			}
		}

		super.draw();
	}

	function focusOnTarget(target:String)
	{
		var focusPoint:FlxPoint = FlxPoint.weak(0, 0);
		switch (target)
		{
			case 'boyfriend':
				focusPoint.x += boyfriend.getMidpoint().x - boyfriend.cameraPosition[0] - 100;
				focusPoint.y += boyfriend.getMidpoint().y + boyfriend.cameraPosition[1] - 100;
				if (stageJson.camera_boyfriend != null && stageJson.camera_boyfriend.length > 1)
				{
					focusPoint.x += stageJson.camera_boyfriend[0];
					focusPoint.y += stageJson.camera_boyfriend[1];
				}
			case 'dad':
				focusPoint.x += dad.getMidpoint().x + dad.cameraPosition[0] + 150;
				focusPoint.y += dad.getMidpoint().y + dad.cameraPosition[1] - 100;
				if (stageJson.camera_opponent != null && stageJson.camera_opponent.length > 1)
				{
					focusPoint.x += stageJson.camera_opponent[0];
					focusPoint.y += stageJson.camera_opponent[1];
				}
			case 'gf':
				if (gf.visible)
				{
					focusPoint.x += gf.getMidpoint().x + gf.cameraPosition[0];
					focusPoint.y += gf.getMidpoint().y + gf.cameraPosition[1];
				}

				if (stageJson.camera_girlfriend != null && stageJson.camera_girlfriend.length > 1)
				{
					focusPoint.x += stageJson.camera_girlfriend[0];
					focusPoint.y += stageJson.camera_girlfriend[1];
				}
		}
		return focusPoint;
	}

	function repositionGirlfriend()
	{
		gf.setPosition(stageJson.girlfriend[0], stageJson.girlfriend[1]);
		gf.x += gf.positionArray[0];
		gf.y += gf.positionArray[1];
	}

	function repositionDad()
	{
		dad.setPosition(stageJson.opponent[0], stageJson.opponent[1]);
		dad.x += dad.positionArray[0];
		dad.y += dad.positionArray[1];
	}

	function repositionBoyfriend()
	{
		boyfriend.setPosition(stageJson.boyfriend[0], stageJson.boyfriend[1]);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
	}

	public function drawDebugOnCamera(spr:FlxSprite,usePureColorOffset:Bool = false):Void
	{
		if (spr == null || !spr.isOnScreen(FlxG.camera))
			return;

		@:privateAccess
		var lineSize:Int = Std.int(Math.max(2, Math.floor(3 / FlxG.camera.zoom)));

		var sprX:Float = spr.x - spr.offset.x;
		var sprY:Float = spr.y - spr.offset.y;
		var sprWidth:Int = Std.int(spr.frameWidth * spr.scale.x);
		var sprHeight:Int = Std.int(spr.frameHeight * spr.scale.y);
		for (num => sel in selectionSprites.members)
		{
			sel.x = sprX;
			sel.y = sprY;
			if(usePureColorOffset){
				sel.x -= sprHeight/2;
				sel.y -= sprWidth/2;
			}
			switch (num)
			{
				case 0: // Top
					sel.setGraphicSize(sprWidth, lineSize);
				case 1: // Bottom
					sel.setGraphicSize(sprWidth, lineSize);
					sel.y += sprHeight - lineSize;
				case 2: // Left
					sel.setGraphicSize(lineSize, sprHeight);
				case 3: // Right
					sel.setGraphicSize(lineSize, sprHeight);
					sel.x += sprWidth - lineSize;
			}
			sel.updateHitbox();
			sel.scrollFactor.set(spr.scrollFactor.x, spr.scrollFactor.y);
		}
		selectionSprites.draw();
	}

	// save

	function saveObjectsToJson()
	{
		stageJson.objects = [];
		for (basic in stageSprites)
			stageJson.objects.push(basic.formatToJson());
	}

	function _updateCamera()
	{
		if (focusRadioGroup.checked > -1)
		{
			var point = focusOnTarget(focusRadioGroup.labels[focusRadioGroup.checked]);
			camFollow.setPosition(point.x, point.y);
		}
	}
	function saveData()
	{
		if (!fileDialog.completed)
			return;

		saveObjectsToJson();
		var data = haxe.Json.stringify(stageJson, '\t');
		#if mobile
		unsavedProgress = false;
		StorageUtil.saveContent('$lastLoadedStage.json', data);
		#else
		if (data.length > 0)
		{
			fileDialog.save('$lastLoadedStage.json',data,onSaveComplete,onSaveCancel,onSaveError);
		}
		#end
	}


	function onSaveComplete():Void
	{
		if (!fileDialog.completed)
			return;
		FlxG.log.notice('Successfully saved file.');
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel():Void
	{
		if (!fileDialog.completed)
			return;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError():Void
	{
		if (!fileDialog.completed)
			return;
		FlxG.log.error('Problem saving file');
	}

	var _makeNewSprite = null;

	public function loadImage(onNewSprite:String = null)
	{
		if (!fileDialog.completed)
			return;

		_makeNewSprite = onNewSprite;
		
		final filters = [new FileFilter('PNG (Image)', '*.png')
		#if !linux
			, new FileFilter('XML (Sparrow)', '*.xml'), new FileFilter('JSON (Aseprite)', '*.json'), new FileFilter('TXT (Packer)', '*.txt')
		#end
		];
		fileDialog.open(null,"Select a graphic",filters,onLoadComplete,onLoadCancel,onLoadError);
	}

	private function onLoadComplete():Void
	{
		if (!fileDialog.completed)
			return;
		#if sys
		var fullPath:String = fileDialog.path;

		function loadSprite(imageToLoad:String)
		{
			if (_makeNewSprite != null)
			{
				if (_makeNewSprite == 'animatedSprite'
					&& !Paths.fileExists('images/$imageToLoad.xml', TEXT)
					&& !Paths.fileExists('images/$imageToLoad.json', TEXT)
					&& !Paths.fileExists('images/$imageToLoad.txt', TEXT))
				{
					showOutput('No Animation file found with the same name of the image!', true);
					_makeNewSprite = null;
					return;
				}
				insertMeta(new StageEditorMetaSprite({type: _makeNewSprite, name: findUnoccupiedName()}, new ModchartSprite()));
			}
			var selected = UI_box.getSelected();
			tryLoadImage(selected, imageToLoad);

			if (_makeNewSprite != null)
			{
				selected.sprite.x = Math.round(FlxG.camera.scroll.x + FlxG.width / 2 - selected.sprite.width / 2);
				selected.sprite.y = Math.round(FlxG.camera.scroll.y + FlxG.height / 2 - selected.sprite.height / 2);
				posTxt.visible = true;
				posTxt.text = 'X: ${selected.sprite.x}\nY: ${selected.sprite.y}';
			}
			_makeNewSprite = null;
		}

		if (fullPath != null)
		{
			fullPath = fullPath.replace('\\', '/');
			var exePath = Sys.getCwd().replace('\\', '/');

			if (fullPath.startsWith(exePath))
			{
				fullPath = fullPath.substr(exePath.length);
				if ((fullPath.startsWith('assets/') #if MODS_ALLOWED || fullPath.startsWith('mods/') #end)
					&& fullPath.contains('/images/'))
				{
					loadSprite(fullPath.substring(fullPath.indexOf('/images/') + '/images/'.length, fullPath.lastIndexOf('.')));
					// trace('Inside Psych Engine Folder');
					return;
				}
			}

			createPopup.visible = createPopup.active = false;
			#if MODS_ALLOWED
			var modFolder:String = (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0) ? Paths.mods('${Mods.currentModDirectory}/images/') : Paths.mods('images/');
			openSubState(new BasePrompt(480, 160, 'This file is not inside Psych Engine.', function(state:BasePrompt)
			{
				var txt:FlxText = new FlxText(0, state.bg.y + 60, 460, 'Copy to: "$modFolder"?', 11);
				txt.alignment = CENTER;
				txt.screenCenter(X);
				txt.cameras = state.cameras;
				state.add(txt);

				var btnY = 390;
				var btn:PsychUIButton = new PsychUIButton(0, btnY, 'OK', function()
				{
					var fileName:String = fullPath.substring(fullPath.lastIndexOf('/') + 1, fullPath.lastIndexOf('.'));
					var pathNoExt:String = fullPath.substring(0, fullPath.lastIndexOf('.'));
					function saveFile(ext:String)
					{
						var p1:String = '$pathNoExt.$ext';
						var p2:String = modFolder + '$fileName.$ext';
						trace(p1, p2);
						if (FileSystem.exists(p1))
							File.saveBytes(p2, File.getBytes(p1));
					}

					FileSystem.createDirectory(modFolder);
					saveFile('png');
					saveFile('xml');
					saveFile('txt');
					saveFile('json');
					loadSprite(fileName);
					state.close();
				});
				btn.normalStyle.bgColor = FlxColor.GREEN;
				btn.normalStyle.textColor = FlxColor.WHITE;
				btn.screenCenter(X);
				btn.x -= 100;
				btn.cameras = state.cameras;
				state.add(btn);

				var btn:PsychUIButton = new PsychUIButton(0, btnY, 'Cancel', function()
				{
					_makeNewSprite = null;
					state.close();
				});
				btn.screenCenter(X);
				btn.x += 100;
				btn.cameras = state.cameras;
				state.add(btn);
			}));
			#else
			showOutput('ERROR! File cannot be used, move it to "assets" and recompile.', true);
			#end
		}
		#else
		trace('File couldn\' t be loaded!You aren \'t on Desktop, are you?');
		#end
	}

	function tryLoadImage(spr:StageEditorMetaSprite, imgPath:String)
	{
		if (spr == null || StageData.reservedNames.contains(spr.type) || spr.type == 'square' || imgPath == null)
			return;

		spr.image = imgPath;
		updateSelectedUI();if (!fileDialog.completed)
			return;
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	private function onLoadCancel():Void
	{
		if (!fileDialog.completed)
			return;

		if (_makeNewSprite != null)
		{
			createPopup.visible = createPopup.active = false;
			_makeNewSprite = null;
		}
		trace('Cancelled file loading.');
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	private function onLoadError():Void
	{
		if (!fileDialog.completed)
			return;

		if (_makeNewSprite != null)
		{
			createPopup.visible = createPopup.active = false;
			_makeNewSprite = null;
		}
		trace('Problem loading file');
	}

	override function destroy()
	{
		destroySubStates = true;
		animationEditor.destroy();
		super.destroy();
	}
}

class StageEditorMetaSprite
{
	public var sprite:FlxSprite;
	public var visible(get, set):Bool;

	function get_visible()
		return sprite.visible;

	function set_visible(v:Bool)
		return (sprite.visible = v);

	// basic variables for all types
	public var type:String;

	// variables for all types that aren't Character
	public var name:String;
	public var filters:LoadFilters = (LOW_QUALITY) | (HIGH_QUALITY);
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var alpha(get, set):Float;
	public var angle(get, set):Float;

	function get_x()
		return sprite.x;

	function set_x(v:Float)
		return (sprite.x = v);

	function get_y()
		return sprite.y;

	function set_y(v:Float)
		return (sprite.y = v);

	function get_alpha()
		return sprite.alpha;

	function set_alpha(v:Float)
		return (sprite.alpha = v);

	function get_angle()
		return sprite.angle;

	function set_angle(v:Float)
		return (sprite.angle = v);

	public var color(default, set):String = 'FFFFFF';

	function set_color(v:String)
	{
		sprite.color = CoolUtil.colorFromString(v);
		return (color = v);
	}

	public var image(default, set):String = 'unknown';

	function set_image(v:String)
	{
		try
		{
			switch (type)
			{
				case 'sprite':
					sprite.loadGraphic(Paths.image(v));
				case 'animatedSprite':
					sprite.frames = Paths.getAtlas(v);
			}
		}
		catch (e:Dynamic)
		{
		}
		sprite.updateHitbox();
		return (image = v);
	}

	public var scroll:Array<Float> = [1, 1];

	public function setScrollFactor(scrX:Null<Float> = null, scrY:Null<Float> = null)
	{
		scroll[0] = (scrX != null ? scrX : scroll[0]);
		scroll[1] = (scrY != null ? scrY : scroll[1]);
		sprite.scrollFactor.set(scroll[0], scroll[1]);
	}

	public var scale:Array<Float> = [1, 1];
	public var antialiasing(default, set):Bool = true;

	function set_antialiasing(v:Bool)
	{
		sprite.antialiasing = (v && ClientPrefs.data.antialiasing);
		return (antialiasing = v);
	}

	public function setScale(wid:Null<Float> = null, hei:Null<Float> = null)
	{
		scale[0] = (wid != null ? wid : scale[0]);
		scale[1] = (hei != null ? hei : scale[1]);
		sprite.scale.set(scale[0], scale[1]);
		sprite.updateHitbox();
	}

	public var flipX(get, set):Bool;
	public var flipY(get, set):Bool;

	function get_flipX()
		return sprite.flipX;

	function set_flipX(v:Bool)
		return (sprite.flipX = (v && type != 'square'));

	function get_flipY()
		return sprite.flipY;

	function set_flipY(v:Bool)
		return (sprite.flipY = (v && type != 'square'));

	// "animatedSprite" only variables
	public var firstAnimation:String;
	public var animations:Array<AnimArray>;

	public function new(data:Dynamic, spr:FlxSprite)
	{
		this.sprite = spr;
		if (data == null)
			return;

		this.type = data.type;
		switch (this.type)
		{
			case 'sprite', 'square', 'animatedSprite':
				for (v in ['name', 'image', 'scale', 'scroll', 'color', 'filters', 'antialiasing'])
				{
					var dat:Dynamic = Reflect.field(data, v);
					if (dat != null)
						Reflect.setField(this, v, dat);
				}

				if (this.type == 'animatedSprite')
				{
					this.animations = data.animations;
					this.firstAnimation = data.firstAnimation;
				}
		}
	}

	public function formatToJson()
	{
		var obj:Dynamic = {type: type};
		switch (type)
		{
			case 'square', 'sprite', 'animatedSprite':
				obj.name = name;
				obj.x = x;
				obj.y = y;
				obj.scale = scale;
				obj.scroll = scroll;
				obj.alpha = alpha;
				obj.angle = angle;
				obj.color = color;
				obj.filters = filters;

				if (type != 'square')
				{
					obj.flipX = flipX;
					obj.flipY = flipY;
					obj.image = image;
					obj.antialiasing = antialiasing;
					if (type == 'animatedSprite')
					{
						obj.animations = animations;
						obj.firstAnimation = firstAnimation;
					}
				}
		}
		return obj;
	}

	public function update(curFilters:LoadFilters, elapsed:Float)
	{
		if ((curFilters & filters) != 0 || StageData.reservedNames.contains(type))
			sprite.update(elapsed);
	}

	public function draw(curFilters:LoadFilters)
	{
		if ((curFilters & filters) != 0 || StageData.reservedNames.contains(type))
			sprite.draw();
	}
}

