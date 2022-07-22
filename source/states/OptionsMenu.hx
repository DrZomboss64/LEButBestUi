package states;

import utilities.CoolUtil;
import substates.UISkinSelect;
import substates.ControlMenuSubstate;
import modding.CharacterCreationState;
import utilities.MusicUtilities;
import ui.Option;
import ui.Checkbox;
import flixel.group.FlxGroup;
import debuggers.ChartingState;
import debuggers.StageMakingState;
import flixel.system.FlxSound;
import debuggers.AnimationDebug;
import utilities.Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import ui.Alphabet;
import game.Song;
import debuggers.StageMakingState;
import game.Highscore;
import openfl.utils.Assets as OpenFLAssets;
import debuggers.ChartingStateDev;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxGradient;


class OptionsMenu extends MusicBeatState
{
	var curSelected:Int = 0;

	public static var inMenu = false;

	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Theme/Play/Play_Checker'), 0.2, 0.2, true, true);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFfd719b);

	public var pages:Array<Dynamic> = [
		[
			"Categories",
			new PageOption("Gameplay", 0, "Gameplay"),
			new PageOption("Graphics", 1, "Graphics"),
			new PageOption("Tools (Very WIP)", 2, "Tools"),
			new PageOption("Misc", 3, "Misc"),
		],
		[
			"Gameplay",
			new PageOption("Back", 0, "Categories"),
			new PageOption("Miscellaneous", 1, "Miscellaneous"),
			//new PageOption("Rythm Games additions", 2, "Rythm Games additions"),
			new PageOption("Sound Effects", 3, "Sound Effects"),
			new BoolOption("Bot", "botplay", 4),
			new BoolOption("Quick Restart", "quickRestart", 5),
			new BoolOption("No Death", "noDeath", 6),
			new BoolOption("Use Custom Scrollspeed", "useCustomScrollSpeed", 7),
			new ScrollSpeedMenuOption("Custom Scroll Speed", 8),
			new StringSaveOption("Hitsound", CoolUtil.coolTextFile(Paths.txt("hitsoundList")), 9, "hitsound")
		],
		[
			"Graphics",
			new PageOption("Back", 0, "Categories"),
			new PageOption("Note Options", 1, "Note Options"),
			new PageOption("Info Display", 2, "Info Display"),
			new PageOption("Optimizations", 3, "Optimizations"),
			new PageOption("Appearance", 4, "Appearance"),
			new MaxFPSOption("Max FPS", 5),
			new BoolOption("Bigger Score Text", "biggerScoreInfo", 6),
			new BoolOption("Bigger Info Text", "biggerInfoText", 7),
			new StringSaveOption("Time Bar Style", ["leather engine", "psych engine", "new kade engine", "old kade engine"], 8, "timeBarStyle"),
			new PageOption("Screen Effects", 9, "Screen Effects")
		],
		[
			"Tools",
			new PageOption("Back", 0, "Categories"),
			new GameStateOption("Charter", 1, new ChartingState()),
			#if debug
			new GameStateOption("Charter Dev", 1, new ChartingStateDev()),
			#end
			new GameStateOption("Animation Debug", 2, new AnimationDebug("dad")),
			new GameStateOption("Stage Editor", 3, new StageMakingState("stage")),
			new GameStateOption("Character Creator", 4, new CharacterCreationState("bf"))
		],
		[
			"Misc",
			new PageOption("Back", 0, "Categories"),
			new BoolOption("Prototype Title Screen", "oldTitle", 1),
			new BoolOption("Friday Night Title Music", "nightMusic", 2),
			new BoolOption("Watermarks", "watermarks", 3),
			new BoolOption("Freeplay Music", "freeplayMusic", 4),
			#if discord_rpc
			new BoolOption("Discord RPC", "discordRPC", 5),
			#end
			new StringSaveOption("Cutscenes Play On", ["story","freeplay","both"], 6, "cutscenePlaysOn"),
			new StringSaveOption("Play As", ["bf", "opponent"], 7, "playAs"),
			new BoolOption("Disable Debug Menus", "disableDebugMenus", 10),
			new BoolOption("Invisible Notes", "invisibleNotes", 11),
			new ImportOldHighscoreOption("Import Old Scores", "Import Old Scores", 12)

		],
		[
			"Optimizations",
			new PageOption("Back", 0, "Graphics"),
			new BoolOption("Antialiasing", "antialiasing", 1),
			new BoolOption("Health Icons", "healthIcons", 2),
			new BoolOption("Chars And BGs", "charsAndBGs", 3),
			new BoolOption("Menu Backgrounds", "menuBGs", 4),
			new BoolOption("Optimized Characters", "optimizedChars", 5),
			new BoolOption("Animated Backgrounds", "animatedBGs", 6),
			new BoolOption("Preload Stage Events", "preloadChangeBGs", 7),
			new BoolOption("Title Logo Play Menu", "logoBL", 8),
			new BoolOption("Icon in Play Menu", "menuIcon", 9)
		],
		[
			"Info Display",
			new PageOption("Back", 0, "Graphics"),
			new DisplayFontOption("Display Font", ["_sans", OpenFLAssets.getFont(Paths.font("vcr.ttf")).fontName, OpenFLAssets.getFont(Paths.font("Koda135759-vmm2O.ttf")).fontName, OpenFLAssets.getFont(Paths.font("pixel.otf")).fontName], 6, "infoDisplayFont"),
			new BoolOption("FPS Counter", "fpsCounter", 3),
			new BoolOption("Memory Counter", "memoryCounter", 4),
			new BoolOption("Version Display", "versionDisplay", 4)
		],
		[
			"Judgements",
			new PageOption("Back", 0, "Gameplay"),
			new JudgementMenuOption("Timings", 1),
			new StringSaveOption("Rating Mode", ["psych", "mic'd up", "simple", "simple +", "modding plus", "complex"], 2, "ratingType"),
			new BoolOption("Marvelous Ratings", "marvelousRatings", 3),
			new BoolOption("Show Rating Count", "sideRatings", 4)
		],
		[
			"Input Options",
			new PageOption("Back", 0, "Gameplay"),
			new StringSaveOption("Input Mode", ["standard", "rhythm"], 3, "inputSystem"),
			new BoolOption("Anti Mash", "antiMash", 4),
			new BoolOption("Shit gives Miss", "missOnShit", 5),
			new BoolOption("Ghost Tapping", "ghostTapping", 9),
			new BoolOption("Gain Misses on Sustains", "missOnHeldNotes", 10),
			new BoolOption("No Miss", "noHit", 6),
			new BoolOption("Reset Button", "resetButton", 7)
		],
		[
			"Note Options",
			new PageOption("Back", 0, "Graphics"),
			new NoteBGAlphaMenuOption("Note BG Alpha", 1),
			new BoolOption("Enemy Note Glow", "enemyStrumsGlow", 2),
			new BoolOption("Player Note Splashes", "playerNoteSplashes", 3),
			new BoolOption("Enemy Note Splashes", "opponentNoteSplashes", 3),
			new BoolOption("Note Accuracy Text", "displayMs", 4),
			new BoolOption("Notes Per Second", "notesperSecond", 5),
			new NoteColorMenuOption("Note Colors", 6),
			new UISkinSelectOption("UI Skin", 7)
		],
		[
			"Screen Effects",
			new PageOption("Back", 0, "Graphics"),
			new BoolOption("Camera Tracks Direction", "cameraTracksDirections", 1),
			new BoolOption("Camera Bounce", "cameraZooms", 2),
			new BoolOption("Flashing Lights", "flashingLights", 3),
			new BoolOption("Screen Shake", "screenShakes", 4)
		],
		[
			"Miscellaneous",
			new PageOption("Back", 0, "Gameplay"),
			new ControlMenuSubStateOption("Binds", 1),
			new BoolOption("Key Bind Reminders", "extraKeyReminders", 2),
			new SongOffsetOption("Song Offset", 2),
			new PageOption("Judgements", 3, "Judgements"),
			new PageOption("Input Options", 4, "Input Options"),
			new BoolOption("Downscroll", "downscroll", 4),
			new BoolOption("Middlescroll", "middlescroll", 5),
			new BoolOption("Use Custom Scrollspeed", "useCustomScrollSpeed", 11),
			new ScrollSpeedMenuOption("Custom Scroll Speed", 12)
		],
		[
			"Rythm Games additions",
			new PageOption("Back", 0, "Gameplay"),
			new BoolOption("Combo Flash", "comboFlash", 1)
		],
		[
			"Sound Effects",
			new PageOption("Back", 0, "Gameplay"),
			new BoolOption("Miss Sounds", "missSounds", 1),
			new BoolOption("Combo Sound", "comboSound", 2)
		],
		[
			"Appearance",
			new PageOption("Back", 0, "Appearance"),
			new BoolOption("FPS Rainbow", "rainbowFPS", 1)
		]
	];

	public var page:FlxTypedGroup<Option> = new FlxTypedGroup<Option>();

	public static var instance:OptionsMenu;

	override function create()
	{
		if(PlayState.instance == null)
			pages[3][2] = null;

		#if debug
		if(PlayState.instance == null)
			pages[3][3] = null;
		#end
		
		MusicBeatState.windowNameSuffix = "";
		
		instance = this;

		var menuBG:FlxSprite;

		if(utilities.Options.getData("menuBGs"))
			menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		else
			menuBG = new FlxSprite().makeGraphic(1286, 730, FlxColor.fromString("#E1E1E1"), false, "optimizedMenuDesat");

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x558DE7E5, 0xAAE6F0A9], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		add(checker);
		checker.scrollFactor.set(0, 0.07);

		super.create();

		add(page);

		LoadPage("Categories");

		if(FlxG.sound.music == null)
			FlxG.sound.playMusic(MusicUtilities.GetOptionsMenuMusic(), 0.7, true);
	}

	public static function LoadPage(Page_Name:String)
	{
		inMenu = true;
		instance.curSelected = 0;

		var bruh = 0;

		for (x in instance.page.members)
		{
			x.Alphabet_Text.targetY = bruh - instance.curSelected;
			bruh++;
		}

		var curPage = instance.page;

		curPage.clear();

		var selectedPage:Array<Dynamic> = [];

		for(i in 0...instance.pages.length)
		{
			if(instance.pages[i][0] == Page_Name)
			{
				for(x in 0...instance.pages[i].length)
				{
					if(instance.pages[i][x] != Page_Name)
						selectedPage.push(instance.pages[i][x]);
				}
			}
		}

		for(x in selectedPage)
		{
			curPage.add(x);
		}

		inMenu = false;
	}

	override function update(elapsed:Float)
	{
		checker.x -= 0.21;
		checker.y -= 0.51;
		
		super.update(elapsed);

		if (!inMenu)
		{
			if(-1 * Math.floor(FlxG.mouse.wheel) != 0)
			{
				curSelected -= 1 * Math.floor(FlxG.mouse.wheel);
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			}

			if (controls.UP_P)
			{
				curSelected -= 1;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			}

			if (controls.DOWN_P)
			{
				curSelected += 1;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			}

			if (controls.BACK)
				FlxG.switchState(new MainMenuState());
		}
		else
		{
			if(controls.BACK)
				inMenu = false;
		}

		if (curSelected < 0)
			curSelected = page.length - 1;

		if (curSelected >= page.length)
			curSelected = 0;

		var bruh = 0;

		for (x in page.members)
		{
			x.Alphabet_Text.targetY = bruh - curSelected;
			bruh++;
		}

		for (x in page.members)
		{
			if(x.Alphabet_Text.targetY != 0)
			{
				for(item in x.members)
				{
					item.alpha = 0.6;
				}
			}
			else
			{
				for(item in x.members)
				{
					item.alpha = 1;
				}
			}
		}
	}
}