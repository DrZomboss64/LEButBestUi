package states;

import flixel.input.FlxInput.FlxInputState;
import flixel.FlxSprite;
import flixel.FlxBasic;
import openfl.Lib;
import lime.app.Application;
import game.Conductor;
import utilities.PlayerSettings;
import game.Conductor.BPMChangeEvent;
import utilities.Controls;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.util.FlxColor;


class MusicBeatState extends FlxUIState
{
	public var lastBeat:Float = 0;
	public var lastStep:Float = 0;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;
	private var controls(get, never):Controls;

	public static var windowNameSuffix:String = "";
	public static var windowNamePrefix:String = "Leather Engine";

	public static var fullscreenBind:String = "F11";

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override public function new()
	{
		#if polymod
		polymod.Polymod.clearCache();
		#end

		super();
	}

	var array:Array<FlxColor> = [
		FlxColor.fromRGB(148, 0, 211),
		FlxColor.fromRGB(75, 0, 130),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(255, 127, 0),
		FlxColor.fromRGB(255, 0 , 0)
	];

	var skippedFrames = 0;

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		Main.watermark.x = Lib.application.window.width - 10 - Main.watermark.width;
		Main.watermark.y = Lib.application.window.height - 10 - Main.watermark.height;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		if (utilities.Options.getData("rainbowFPS") && skippedFrames >= 6)
			{
				if (currentColor >= array.length)
					currentColor = 0;
				(cast (Lib.current.getChildAt(0), Main)).changeFPSColor(array[currentColor]);
				currentColor++;
				skippedFrames = 0;
			}
			else
				skippedFrames++;

		if ((cast (Lib.current.getChildAt(0), Main)).getFPSCap != FlxG.save.data.fpsCap && FlxG.save.data.fpsCap <= 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		super.update(elapsed);

		if(FlxG.stage != null)
			FlxG.stage.frameRate = utilities.Options.getData("maxFPS");

		if(!utilities.Options.getData("antialiasing"))
		{
			forEachAlive(function(basic:FlxBasic) {
				if(Std.isOfType(basic, FlxSprite))
					Reflect.setProperty(basic, "antialiasing", false);
			}, true);
		}

		if(FlxG.keys.checkStatus(FlxKey.fromString(utilities.Options.getData("fullscreenBind", "binds")), FlxInputState.JUST_PRESSED))
			FlxG.fullscreen = !FlxG.fullscreen;

		Application.current.window.title = windowNamePrefix + windowNameSuffix;
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / Conductor.timeScale[1]);
	}

	public static var currentColor = 0;

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		
		for(i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		var dumb:TimeScaleChangeEvent = {
			stepTime: 0,
			songTime: 0,
			timeScale: [4,4]
		};

		var lastTimeChange:TimeScaleChangeEvent = dumb;

		for(i in 0...Conductor.timeScaleChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.timeScaleChangeMap[i].songTime)
				lastTimeChange = Conductor.timeScaleChangeMap[i];
		}

		if(lastTimeChange != dumb)
			Conductor.timeScale = lastTimeChange.timeScale;

		var multi:Float = 1;

		if(FlxG.state == PlayState.instance)
			multi = PlayState.songMultiplier;

		Conductor.recalculateStuff(multi);

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);

		updateBeat();
	}

	public function stepHit():Void
	{
		if (curStep % Conductor.timeScale[0] == 0)
			beatHit();
	}

	public function beatHit():Void { /* do literally nothing dumbass */ }

	public function fancyOpenURL(schmancy:String)
		{
			#if linux
			Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
			#else
			FlxG.openURL(schmancy);
			#end
		}
}