package states;

import flixel.util.FlxTimer;
import game.Replay;
import utilities.MusicUtilities;
import lime.utils.Assets;
#if discord_rpc
import utilities.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import modding.PolymodHandler;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxGradient;
import utilities.CoolUtil;
import flixel.math.FlxMath;
import ui.HealthIcon;

using StringTools;

class MainPlayState extends MusicBeatState
{
	static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = ['story mode', 'freeplay', 'credits'];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var bg:FlxSprite;
	var background2:FlxSprite;
	var logoBl:FlxSprite;
	var char:FlxSprite;

	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Theme/Play/Play_Checker'), 0.2, 0.2, true, true);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFfd719b);

	override function create()
	{
		#if not web
        Paths.clearUnusedMemory();
        Paths.clearStoredMemory();
        #end
		
		if(PolymodHandler.metadataArrays.length > 0)
			optionShit.push('mods');

		if(Replay.getReplayList().length > 0)
			optionShit.push('replays');
		
		#if !web
		//optionShit.push('multiplayer');
		#end
		
		MusicBeatState.windowNameSuffix = "";
		
		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music == null || FlxG.sound.music.playing != true)
			TitleState.playTitleMusic();

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);

		if(utilities.Options.getData("menuBGs"))
			bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		else
			bg = new FlxSprite(-80).makeGraphic(1286, 730, FlxColor.fromString("#FDE871"), false, "optimizedMenuBG");
		
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.179));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = utilities.Options.getData("antialiasing");
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		if(utilities.Options.getData("menuBGs"))
			magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		else
			magenta = new FlxSprite(-80).makeGraphic(1286, 730, FlxColor.fromString("#E1E1E1"), false, "optimizedMenuDesat");

		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.179));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.antialiasing = utilities.Options.getData("antialiasing");
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);

		background2 = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		background2.scrollFactor.set();
		background2.screenCenter();
		background2.visible = false;
		background2.antialiasing = utilities.Options.getData("antialiasing");
		background2.color = FlxColor.MAGENTA;
		add(background2);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x558DE7E5, 0xAAE6F0A9], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		gradientBar.antialiasing = utilities.Options.getData("antialiasing");
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		add(checker);
		checker.scrollFactor.set(0, 0.07);
		checker.antialiasing = utilities.Options.getData("antialiasing");

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(FlxG.width + 0, (i * 140) + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('main menu/' + optionShit[i], 'preload');
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.antialiasing = utilities.Options.getData("antialiasing");
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 3)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			// menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			FlxTween.tween(menuItem,{y: 60 + (i * 160)},1 + (i * 0.25) ,{ease: FlxEase.expoInOut,
				onComplete: function(flxTween:FlxTween) 
				{
					changeItem();
				}
			});
			menuItem.updateHitbox();
			menuItem.scrollFactor.set(0, scr);
		}

		if(utilities.Options.getData("logoBL"))
		{
			logoBl = new FlxSprite(-100, -100);

			if(utilities.Options.getData("watermarks"))
				logoBl.frames = Paths.getSparrowAtlas('title/leatherLogoBumpin');
			else
				logoBl.frames = Paths.getSparrowAtlas('title/logoBumpin');

			logoBl.scrollFactor.set();
			logoBl.antialiasing = true;
			logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
			logoBl.animation.play('bump');
			logoBl.antialiasing = utilities.Options.getData("antialiasing");
			logoBl.setGraphicSize(Std.int(logoBl.width * 0.5));
			logoBl.alpha = 0;
			logoBl.angle = -4;
			logoBl.updateHitbox();
			add(logoBl);
			FlxTween.tween(logoBl, {
				y: logoBl.y + 150,
				x: logoBl.x + 150,
				angle: -4,
				alpha: 1
			}, 1.4, {ease: FlxEase.expoInOut});
		}

		/*if(utilities.Options.getData("menuIcon"))
		{
			iconBG = new FlxSprite().loadGraphic(Paths.image('iconbackground'));
			iconBG.scrollFactor.set();
			iconBG.updateHitbox();
			iconBG.antialiasing = true;
			add(iconBG);

			switch (FlxG.random.int(1, 15))
			{
				case 1:
					icon = new HealthIcon('bf');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.fromRGB(81, 201, 219);
				case 2:
					icon = new HealthIcon('gf');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.fromRGB(186, 49, 104);
				case 3:
					icon = new HealthIcon('dad');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.fromRGB(199, 111, 211);
				case 4:
					icon = new HealthIcon('mom');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.fromRGB(231, 109, 166);
				case 5:
					icon = new HealthIcon('spooky');
					icon.setGraphicSize(Std.int(icon.width * 2));
					switch (FlxG.random.int(1, 2))
					{
						case 1:
							iconBG.color = FlxColor.fromRGB(226, 147, 30);
						case 2:
							iconBG.color = FlxColor.fromRGB(225, 225, 225);
					}
				case 6:
					icon = new HealthIcon('tankman');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.fromRGB(20, 20, 20);
				case 7:
					icon = new HealthIcon('bf-old');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.fromRGB(231, 255, 48);
				case 8:
					icon = new HealthIcon('bf-pixel');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.fromRGB(81, 201, 219);
				case 9:
					icon = new HealthIcon('bf-prototype');
					icon.setGraphicSize(Std.int(icon.width * 2));
					switch (FlxG.random.int(1, 2))
					{
						case 1:
							iconBG.color = FlxColor.fromRGB(110, 194, 248);
						case 2:
							iconBG.color = FlxColor.fromRGB(235, 50, 36);
					}
				case 10:
					icon = new HealthIcon('monster');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.fromRGB(244, 255, 106);
				case 11:
					icon = new HealthIcon('pico');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.fromRGB(205, 229, 112);
				case 12:
					icon = new HealthIcon('senpai');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.fromRGB(255, 170, 111);
				case 13:
					icon = new HealthIcon('senpai-angry');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.fromRGB(255, 170, 111);
				case 14:
					icon = new HealthIcon('spirit');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.fromRGB(255, 60, 110);
				case 15:
					icon = new HealthIcon('parents-christmas');
					icon.setGraphicSize(Std.int(icon.width * 2));
					switch (FlxG.random.int(1, 2))
					{
						case 1:
							iconBG.color = FlxColor.fromRGB(199, 111, 211);
						case 2:
							iconBG.color = FlxColor.fromRGB(231, 109, 166);
					}
				case 16:
					icon = new HealthIcon('ron');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.fromRGB(240, 198, 144);
				case 17:
					icon = new HealthIcon('3dleather');
					icon.setGraphicSize(Std.int(icon.width * 2));
					iconBG.color = FlxColor.fromRGB(249, 244, 0);
			}
			icon.x = 60;
			icon.y = FlxG.height - 270;
			icon.scrollFactor.set();
			icon.updateHitbox();
			add(icon);
			trace(iconBG.color);
			trace(icon);
		}*/

		//thx to EIT for Custom Menus Tutorial UwU https://www.youtube.com/channel/UC4X_UAuj9BOpHgBHo8TvWoQ
		switch (FlxG.random.int(1, 15))
            {
            case 1:
			char = new FlxSprite(50, 250).loadGraphic(Paths.image('characters/3d leather pog', 'shared'));//put your cords and image here
			char.frames = Paths.getSparrowAtlas('characters/3d leather pog', 'shared');//here put the name of the xml
			char.animation.addByPrefix('idleLE', 'Idle instance 1', 24, true);//on 'idle normal' change it to your xml one
			char.animation.play('idleLE');//you can rename the anim however you want to
			char.antialiasing = utilities.Options.getData("antialiasing");
			char.scrollFactor.set();
			char.flipX = false;//this is for flipping it to look left instead of right you can make it however you want
			add(char);

            case 2:
			char = new FlxSprite(120, 200).loadGraphic(Paths.image('characters/totally not ron', 'shared'));
			char.frames = Paths.getSparrowAtlas('characters/totally not ron', 'shared');
			char.animation.addByPrefix('idleR', 'Idle instance 1', 24, true);
			char.animation.play('idleR');
			char.antialiasing = utilities.Options.getData("antialiasing");
			char.scrollFactor.set();
			add(char);
              
			case 3:
			char = new FlxSprite(70, 250).loadGraphic(Paths.image('characters/tankmanCaptain', 'shared'));
			char.frames = Paths.getSparrowAtlas('characters/tankmanCaptain', 'shared');
			char.animation.addByPrefix('idleT', 'Tankman Idle Dance instance 1', 24, true);
			char.animation.play('idleT');
			char.antialiasing = utilities.Options.getData("antialiasing");
			char.scrollFactor.set();
			char.flipX = true;
			add(char);

			case 4:
			char = new FlxSprite(70, 250).loadGraphic(Paths.image('characters/spooky_kids_assets', 'shared'));
			char.frames = Paths.getSparrowAtlas('characters/spooky_kids_assets', 'shared');
			char.animation.addByPrefix('idleSK', 'spooky dance idle', 24, true);
			char.animation.play('idleSK');
			char.antialiasing = utilities.Options.getData("antialiasing");
			char.scrollFactor.set();
			char.flipX = false;
			add(char);
		
			case 5:
			char = new FlxSprite(70, 250).loadGraphic(Paths.image('characters/DADDY_DEAREST', 'shared'));
			char.frames = Paths.getSparrowAtlas('characters/DADDY_DEAREST', 'shared');
			char.animation.addByPrefix('idleDAD', 'Dad idle dance', 24, true);
			char.animation.play('idleDAD');
			char.antialiasing = utilities.Options.getData("antialiasing");
			char.scrollFactor.set();
			char.flipX = false;
			add(char);

			case 6:
			char = new FlxSprite(70, 250).loadGraphic(Paths.image('characters/Pico_FNF_assetss', 'shared'));
			char.frames = Paths.getSparrowAtlas('characters/Pico_FNF_assetss', 'shared');
			char.animation.addByPrefix('idleP', 'Pico Idle Dance', 24, true);
			char.animation.play('idleP');
			char.antialiasing = utilities.Options.getData("antialiasing");
			char.scrollFactor.set();
			char.flipX = true;
			add(char);

			case 7:
			char = new FlxSprite(70, 250).loadGraphic(Paths.image('characters/bfAndGF', 'shared'));
			char.frames = Paths.getSparrowAtlas('characters/bfAndGF', 'shared');
			char.animation.addByPrefix('idleBG', 'BF idle dance w gf', 24, true);
			char.animation.play('idleBG');
			char.antialiasing = utilities.Options.getData("antialiasing");
			char.scrollFactor.set();
			char.flipX = true;
			add(char);

			case 8:
			char = new FlxSprite(200, 450).loadGraphic(Paths.image('characters/spirit', 'shared'));
			char.frames = Paths.getPackerAtlas('characters/spirit', 'shared');
			char.animation.addByPrefix('idleSP', 'idle spirit_', 24, true);
			char.animation.play('idleSP');
			char.scrollFactor.set();
			char.flipX = false;
			char.setGraphicSize(Std.int(char.width * 6));
			add(char);

			case 9:
			char = new FlxSprite(200, 450).loadGraphic(Paths.image('characters/senpai', 'shared'));
			char.frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
			char.animation.addByPrefix('idleS', 'Senpai Idle', 24, true);
			char.animation.play('idleS');
			char.scrollFactor.set();
			char.flipX = false;
			char.setGraphicSize(Std.int(char.width * 6));
			add(char);

			case 10:
			char = new FlxSprite(150, 400).loadGraphic(Paths.image('characters/senpai', 'shared'));
			char.frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
			char.animation.addByPrefix('idleAS', 'Angry Senpai Idle', 24, true);
			char.animation.play('idleAS');
			char.scrollFactor.set();
			char.flipX = false;
			char.setGraphicSize(Std.int(char.width* 6));
			add(char);

			case 11:
			char = new FlxSprite(-200, 250).loadGraphic(Paths.image('characters/mom_dad_christmas_assets', 'shared'));
			char.frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets', 'shared');
			char.animation.addByPrefix('idlePC', 'Parent Christmas Idle', 24, true);
			char.animation.play('idlePC');
			char.antialiasing = utilities.Options.getData("antialiasing");
			char.scrollFactor.set();
			char.flipX = false;
			add(char);

			case 12:
			char = new FlxSprite(200, 450).loadGraphic(Paths.image('characters/bfPixel', 'shared'));
			char.frames = Paths.getSparrowAtlas('characters/bfPixel', 'shared');
			char.animation.addByPrefix('idleBFP', 'BF IDLE', 24, true);
			char.animation.play('idleBFP');
			char.scrollFactor.set();
			char.flipX = true;
			char.setGraphicSize(Std.int(char.width * 6));
			add(char);

			case 13:
			char = new FlxSprite(70, 250).loadGraphic(Paths.image('characters/Monster_Assets', 'shared'));
			char.frames = Paths.getSparrowAtlas('characters/Monster_Assets', 'shared');
			char.animation.addByPrefix('idleM', 'monster idle', 24, true);
			char.animation.play('idleM');
			char.antialiasing = utilities.Options.getData("antialiasing");
			char.scrollFactor.set();
			char.flipX = false;
			add(char);

			case 14:
			char = new FlxSprite(70, 250).loadGraphic(Paths.image('characters/Mom_Assets', 'shared'));
			char.frames = Paths.getSparrowAtlas('characters/Mom_Assets', 'shared');
			char.animation.addByPrefix('idleMM', 'Mom Idle', 24, true);
			char.animation.play('idleMM');
			char.antialiasing = utilities.Options.getData("antialiasing");
			char.scrollFactor.set();
			char.flipX = false;
			add(char);

			case 15:
			char = new FlxSprite(70, 250).loadGraphic(Paths.image('characters/GF_assets', 'shared'));
			char.frames = Paths.getSparrowAtlas('characters/GF_assets', 'shared');
			char.animation.addByPrefix('idleGF', 'GF Dancing Beat0', 24, true);
			char.animation.play('idleGF');
			char.antialiasing = utilities.Options.getData("antialiasing");
			char.scrollFactor.set();
			char.flipX = false;
			add(char);
		}

		FlxG.camera.follow(camFollow, null, 0.06 * (60 / Main.display.currentFPS));

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
		checker.x -= 0.21;
		checker.y -= 0.51;

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		FlxG.camera.followLerp = 0.06 * (60 / Main.display.currentFPS);
		
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if(-1 * Math.floor(FlxG.mouse.wheel) != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1 * Math.floor(FlxG.mouse.wheel));
				FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(magenta, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(checker, {angle: 45}, 0.8, {ease: FlxEase.expoIn});

				if(utilities.Options.getData("logoBL"))
				{
					FlxTween.tween(logoBl, {
						alpha: 0,
						x: logoBl.x - 30,
						y: logoBl.y - 30,
						angle: 4
					}, 0.8, {ease: FlxEase.quadOut});
				}
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
				FlxG.switchState(new MainMenuState());
	
				FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(magenta, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(bg, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(magenta, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});

				if(utilities.Options.getData("logoBL"))
				{
					FlxTween.tween(logoBl, {
						alpha: 0,
						x: -100,
						y: -100,
						angle: 4
					}, 0.5, {ease: FlxEase.quadOut});					
				}

				/*if(utilities.Options.getData("menuIcon"))
				{
					FlxTween.tween(icon, {x: icon.x - 20, y: icon.y + 20}, 0.5, {ease: FlxEase.quadOut});
				}*/
	
				selectedSomethin = true;
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(magenta, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(checker, {angle: 45}, 0.8, {ease: FlxEase.expoIn});

				if(utilities.Options.getData("logoBL"))
				{
					FlxTween.tween(logoBl, {
						alpha: 0,
						x: logoBl.x - 30,
						y: logoBl.y - 30,
						angle: 4
					}, 0.8, {ease: FlxEase.quadOut});
				}

				/*if(utilities.Options.getData("menuIcon"))
				{
					FlxTween.tween(icon, {x: icon.x - 10, y: icon.y + 10}, 0.8, {ease: FlxEase.quadOut});
				}*/
				
				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
					hideit(0.6);
				});

				if(utilities.Options.getData("flashingLights"))
					FlxFlicker.flicker(background2, 1.1, 0.15, false);
					FlxFlicker.flicker(char, 1.1, 0.15, false);

				menuItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
						FlxTween.tween(spr, {x: 1500}, 1, {
							ease: FlxEase.quadOut
						});
					}
					else
					{
						spr.updateHitbox();
						// spr.x += -300;
						FlxTween.tween(spr, {x: spr.x - 240, y: 260}, 0.5, {ease: FlxEase.quadOut});
						FlxTween.tween(spr.scale, {x: 1.2, y: 1.2}, 0.8, {ease: FlxEase.quadOut});

						if(utilities.Options.getData("flashingLights"))
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(_) { fard(); });
						}
						else
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								fard();
							});
					}
				});
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
			spr.x += 240;
		});
	}

	function fard()
	{
		var daChoice:String = optionShit[curSelected];
		
		switch (daChoice)
		{
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");

			case 'freeplay':
				FlxG.switchState(new FreeplayState());

				trace("Freeplay Menu Selected");

			case 'credits':
				FlxG.switchState(new CreditsState());
				trace("Credits Menu Selected");

			/*case 'options':
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.switchState(new OptionsMenu());*/

			#if sys
			case 'mods':
				FlxG.switchState(new ModsMenu());

			case 'replays':
				FlxG.switchState(new ReplaySelectorState());
			#end
		}
	}

	function hideit(time:Float)
	{
		menuItems.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {alpha: 0.0}, time, {ease: FlxEase.quadOut});
		});
		FlxTween.tween(bg, {alpha: 0}, time, {ease: FlxEase.expoIn});
		FlxTween.tween(magenta, {alpha: 0}, time, {ease: FlxEase.expoIn});
		FlxTween.tween(checker, {alpha: 0}, time, {ease: FlxEase.expoIn});
		FlxTween.tween(gradientBar, {alpha: 0}, time, {ease: FlxEase.expoIn});
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
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if (menuItems.length > 4)
				{
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();

				if (curSelected == 3)
				{
					if (spr.y != 30)
					{
						spr.y == 30;
					}
				}
				else
					spr.y == 0;
			}
		});
	}

	override function beatHit()
	{
		super.beatHit();
	
		if (logoBl != null)
			logoBl.animation.play('bump', true);
	}
}
