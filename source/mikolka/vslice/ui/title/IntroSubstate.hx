package mikolka.vslice.ui.title;

import mikolka.compatibility.VsliceOptions;
import flixel.group.FlxGroup;

class IntroSubstate extends MusicBeatSubstate
{
    var credGroup:FlxGroup = new FlxGroup();
	var textGroup:FlxGroup = new FlxGroup();
	var blackScreen:FlxSprite;
	var credTextShit:Alphabet;
	var ngSpr:FlxSprite;

    var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
    public function new() {
        super();
        curWacky = FlxG.random.getObject(getIntroTextShit()); 
    }
    override function create() {
        super.create();
        blackScreen = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		blackScreen.scale.set(FlxG.width, FlxG.height);
		blackScreen.updateHitbox();
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();
		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52);

		if (FlxG.random.bool(1))
		{
			ngSpr.loadGraphic(Paths.image('newgrounds_logo_classic'));
		}
		else if (FlxG.random.bool(30))
		{
			ngSpr.loadGraphic(Paths.image('newgrounds_logo_animated'), true, 600);
			ngSpr.animation.add('idle', [0, 1], 4);
			ngSpr.animation.play('idle');
			ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.55));
			ngSpr.y += 25;
		}
		else
		{
			ngSpr.loadGraphic(Paths.image('newgrounds_logo'));
			ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		}
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = VsliceOptions.FLASHBANG;
		ngSpr.visible = false;

        add(credGroup);
		add(ngSpr);
    }

	private var sickBeats:Int = 0; // Basically curBeat but won't be skipped if you hold the tab or resize the screen
	override function beatHit()
	{
		super.beatHit();
		sickBeats++;
		switch (sickBeats)
		{

			case 2:
				createCoolText(['Funkin Crew Inc', 'Shadow Mario', 'mikolka9144']);
			case 4:
				addMoreText('present');
			case 5:
				deleteCoolText();
			case 6:
				createCoolText(['Not associated', 'with'], -40);
			case 8:
				addMoreText('newgrounds', -40);
				ngSpr.visible = true;
			case 9:
				deleteCoolText();
				ngSpr.visible = false;
			case 10:
				createCoolText([curWacky[0]]);
			case 12:
				addMoreText(curWacky[1]);
			case 13:
				deleteCoolText();
			case 14:
				addMoreText('Friday');
			case 15:
				addMoreText('Night');
			case 16:
				addMoreText('Funkin'); // credTextShit.text += '\nFunkin';


		}
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			#if !LEGACY_PSYCH
			if (ClientPrefs.data.vibrating)
				lime.ui.Haptic.vibrate(100, 100);
			#end

			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;

			if (credGroup != null && textGroup != null)
			{
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if (textGroup != null && credGroup != null)
		{
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	function getIntroTextShit():Array<Array<String>>
	{
		#if (MODS_ALLOWED && !LEGACY_PSYCH)
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt');
		#else
		var fullText:String = lime.utils.Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}
}
