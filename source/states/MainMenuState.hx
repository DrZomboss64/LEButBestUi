package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxGradient;
#if discord_rpc
import utilities.Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['play', 'support', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;

	public static var nightly:String = "";

	var bg:FlxSprite = new FlxSprite(-89).loadGraphic(Paths.image('Theme/Main/mBG_Main'));
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Theme/Main/Main_Checker'), 0.2, 0.2, true, true);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);
	
	var camFollow:FlxObject;
	var camLerp:Float = 0.1;

	override function create()
	{
		#if not web
        Paths.clearUnusedMemory();
        Paths.clearStoredMemory();
        #end

		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;

		if(utilities.Options.getData("menuBGs"))
			bg = new FlxSprite(-80).loadGraphic(Paths.image('Theme/Main/mBG_Main'));
		else
			bg = new FlxSprite(-80).makeGraphic(1286, 730, FlxColor.fromString("0xFFAA00AA"), false, "optimizedMenuBG");

		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.16;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = utilities.Options.getData("antialiasing");
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55AE59E4, 0xAA19ECFF], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		gradientBar.antialiasing = utilities.Options.getData("antialiasing");
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		add(checker);
		checker.scrollFactor.set(0, 0.07);
		checker.antialiasing = utilities.Options.getData("antialiasing");

		var side:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('Theme/Main/Main_Side'));
		side.scrollFactor.x = 0;
		side.scrollFactor.y = 0;
		side.antialiasing = utilities.Options.getData("antialiasing");
		add(side);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('main menu/FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(-800, 40 + (i * 200));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " idle", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " select", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			FlxTween.tween(menuItem, {x: menuItem.width / 4 + (i * 210) - 30}, 1.3, {ease: FlxEase.expoInOut});
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = utilities.Options.getData("antialiasing");
			menuItem.scale.set(0.8, 0.8);
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

		FlxG.camera.zoom = 3;
		side.alpha = 0;
		FlxTween.tween(FlxG.camera, {zoom: 1}, 1.1, {ease: FlxEase.expoInOut});
		FlxTween.tween(bg, {angle: 0}, 1, {ease: FlxEase.quartInOut});
		FlxTween.tween(side, {alpha: 1}, 0.9, {ease: FlxEase.quartInOut});

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, (utilities.Options.getData("watermarks") ? TitleState.version : "v0.2.7.1"), 16);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.scale.set(FlxMath.lerp(spr.scale.x, 0.8, camLerp), FlxMath.lerp(spr.scale.y, 0.8, 0.4));
			spr.y = FlxMath.lerp(spr.y, 40 + (spr.ID * 200), 0.4);

			if (spr.ID == curSelected)
			{
				spr.scale.set(FlxMath.lerp(spr.scale.x, 1.1, camLerp), FlxMath.lerp(spr.scale.y, 1.1, 0.4));
				spr.y = FlxMath.lerp(spr.y, -10 + (spr.ID * 200), 0.4);
			}

			spr.updateHitbox();
		});
		
		checker.x -= 0.45;
		checker.y -= 0.16;

		if (!selectedSomethin)
		{
			if(-1 * Math.floor(FlxG.mouse.wheel) != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1 * Math.floor(FlxG.mouse.wheel));
			}

			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'support')
				{
					fancyOpenURL("https://ninja-muffin24.itch.io/funkin");
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(spr:FlxSprite)
					{
						FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
						FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
						FlxTween.tween(spr, {x: -600}, 0.6, {
							ease: FlxEase.backIn,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
						new FlxTimer().start(0.5, function(tmr:FlxTimer)
						{
							var daChoice:String = optionShit[curSelected];

							switch (daChoice)
							{
								case 'play':
									FlxG.switchState(new MainPlayState());
								case 'options':
									FlxG.switchState(new OptionsMenu());
							}
						});
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curSelected)
			{
				camFollow.y = FlxMath.lerp(camFollow.y, spr.getGraphicMidpoint().y, camLerp);
				camFollow.x = spr.getGraphicMidpoint().x;
			}
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;
				
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
			}

			spr.updateHitbox();
		});
	}
}
