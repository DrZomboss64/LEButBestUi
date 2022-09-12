package states;

#if discord_rpc
import utilities.Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import lime.utils.Assets;
import ui.Alphabet;
import utilities.CoolUtil;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;

	override function create()
	{
		#if not web
        Paths.clearUnusedMemory();
        Paths.clearStoredMemory();
        #end
		
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		var pisspoop:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
			['Leather Engine But Better Ui'],
			['Que Pro / DrZomboss64', 'quepro', 'Main Programmer of \nLeather Engine But Better Ui', 'https://twitter.com/Shadow_Mario_', 'FFD800'],
			[''],
			['Leather Engine Team'],
			['Leather128', 'leather128', 'Creator & Artist of Leather Engine', 'https://gamebanana.com/members/1799813', 'F9F400'],
			[''],
			['Tutorial Credits'],
			['SilverSpringing', 'silverSpringing', 'How To Make a CUSTOM Combo Counter!', 'https://gamebanana.com/members/1823951', 'E9A91F'],
			[''],
			['Pull requests from LE'],
			['Vortex2Oblivion', 'vortex2Oblivion', 'Timer bar colors option, polymod 1.6.0, \nOptimized shit and unhardcoded \nall the base game characters', 'https://github.com/Vortex2Oblivion', 'E9A91F'],
			['MCagabe19', 'mcagabe19', 'improve ram clean shit', 'https://github.com/mcagabe19', 'FFFFFF'],
			['Sayofthelor', 'sayofthelor', 'a few cool changes', 'https://github.com/sayofthelor', 'AF1FAA'],
			[''],
			['Others Engine Credits'],
			['Verwex', 'Verwex', 'Main Programmer of Micd Up', 'https://github.com/Verwex/Funkin-Mic-d-Up-SC', 'E9A91F'],
			['M.A. Jigsaw', 'jigsaw', 'Main Programmer of Saw Engine', 'https://gamebanana.com/members/1969244', 'FFFFFF'],
			['YOUK-dev', 'youk', 'Main Programmer of Kade!Engine', 'https://gamebanana.com/members/1887764', 'AF1FAA'],
			['Shadow Mario', 'shadowmario', 'Main Programmer of Psych Engine', 'https://twitter.com/Shadow_Mario_',	'444444'],
			[''],
			['Leather Engine Special Thanks'],
			['Ronezkj15', 'ronezkj15', 'Artist & Some Ideas', 'https://gamebanana.com/members/1842880', '283FD6'],
			['Kade Dev', 'kade', 'Code for Downscroll & Modcharts', 'https://twitter.com/KadeDeveloper', '4A6747'],
			['srPerez', 'perez', '6, 7 and 9 Key Designs', 'https://twitter.com/NewSrPerez', 'FF9E00'],
			['Larsiusprime', 'larsiusprime', 'Scrollable Drop Down Menus', 'https://gamebanana.com/members/1842880', 'FFFFFF'],
			['PolybiusProxy', 'polybiusproxy', 'Video Loader Extension', 'https://gamebanana.com/members/1833635', 'FFFFFF'],
			['Video LAN Team', 'um', 'People who made VLC Media Player \n(the thing the game uses to play videos)', 'https://www.youtube.com/watch?v=c5hYA7wbC2M', 'FFFFFF'],
			[''],
			["Funkin' Crew"],
			['ninjamuffin99', 'ninjamuffin99', "Programmer of Friday Night Funkin'", 'https://twitter.com/ninja_muffin99', 'F73838'],
			['PhantomArcade', 'phantomarcade', "Animator of Friday Night Funkin'", 'https://twitter.com/PhantomArcade3K', 'FFBB1B'],
			['evilsk8r', 'evilsk8r', "Artist of Friday Night Funkin'", 'https://twitter.com/evilsk8r', '53E52C'],
			['kawaisprite', 'kawaisprite', "Composer of Friday Night Funkin'", 'https://twitter.com/kawaisprite', '6475F3']
		];
		
		for(i in pisspoop){
			creditsStuff.push(i);
		}
	
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			optionText.yAdd -= 70;
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			//optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable) {

				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);

				if(curSelected == -1) curSelected = i;
			}
		}
		
		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UP_P;
				var downP = controls.DOWN_P;

				if (upP)
				{
					changeSelection(-1 * shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(1 * shiftMult);
					holdTime = 0;
				}

				if(controls.DOWN_P || controls.UP_P)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UP_P ? -shiftMult : shiftMult));
					}
				}
			}

			if(controls.ACCEPT) {
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}
			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(new MainPlayState());
				quitting = true;
			}
		}
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int =  getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if(moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	function getCurrentBGColor() {
		var bgColor:String = creditsStuff[curSelected][4];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}