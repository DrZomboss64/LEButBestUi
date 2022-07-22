package game;

#if polymod
import polymod.backends.PolymodAssets;
#end

#if linc_luajit
import modding.ModchartUtilities;
#end

import utilities.CoolUtil;
import lime.utils.Assets;
import haxe.Json;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import states.PlayState;
import backgrounds.DancingSprite;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import modding.CharacterConfig;

using StringTools;

class StageGroup extends FlxGroup
{
    public var stage:String = "stage";
    public var camZoom:Float = 1.05;
    private var goodElapse:Float = 0;

    public var player_1_Point:FlxPoint = new FlxPoint(1000, 800);
    public var player_2_Point:FlxPoint = new FlxPoint(300, 800);
    public var gf_Point:FlxPoint = new FlxPoint(600, 750);

    public var p1_Scroll:Float = 1.0;
    public var p2_Scroll:Float = 1.0;
    public var gf_Scroll:Float = 0.95;

    public var p1_Cam_Offset:FlxPoint = new FlxPoint(0,0);
    public var p2_Cam_Offset:FlxPoint = new FlxPoint(0,0);

    private var stage_Data:StageData;

    public var stage_Objects:Array<Array<Dynamic>> = [];

    // PHILLY STUFF
    private var phillyCityLights:FlxTypedGroup<FlxSprite>;
    private var phillyTrain:FlxSprite;
    private var trainSound:FlxSound;
    private var trainMoving:Bool = false;
    private var startedMoving:Bool = false;
    private var trainFinishing:Bool = false;
    private var trainFrameTiming:Float = 0;
    private var trainCars:Int = 8;
    private var trainCooldown:Int = 0;
    private var curLight:Int = 0;

    // MALL STUFF
    private var santa:FlxSprite;
    private var upperBoppers:FlxSprite;
    private var bottomBoppers:FlxSprite;

    // SCHOOL STUFF
    private var bgGirls:BackgroundGirls;

     // WASTELAND STUFF
     private var watchTower:FlxSprite;
     private var rollingTank:FlxSprite;
 
     private var tankAngle:Float = FlxG.random.int(-90, 45);
     private var tankSpeed:Float = FlxG.random.float(5, 7);
 
     private var tankMen:Array<FlxSprite> = [];
 
     public var tankSpeedJohn:Array<Float> = [];
     public var goingRightJohn:Array<Bool> = [];
     public var endingOffsetJohn:Array<Float> = [];
     public var strumTimeJohn:Array<Dynamic> = [];
     public var gf:Character = null;
 
     public var johns:FlxTypedGroup<FlxSprite>; //from johns to stumtimejohn is the idenifiers for the bopping shit

    // other

    private var onBeatHit_Group:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

    public var foregroundSprites:FlxGroup = new FlxGroup();
    public var infrontOfGFSprites:FlxGroup = new FlxGroup();

    #if linc_luajit
    public var stageScript:ModchartUtilities = null;
    #end

    public function updateStage(?newStage:String)
    {
        if(newStage != null)
            stage = newStage;

        var bruhStages = ['school','school-mad','evil-school','wasteland','wasteland-stress'];

        var stagesNormally = CoolUtil.coolTextFile(Paths.txt('stageList'));

        if(stage != "")
        {
            if(!bruhStages.contains(stage) && stagesNormally.contains(stage))
            {
                var JSON_Data:String = "";
    
                JSON_Data = Assets.getText(Paths.json("stage data/" + stage)).trim();
                stage_Data = cast Json.parse(JSON_Data);
            }
        }

        clear();

        if(stage != "")
        {
            switch(stage)
            {
                case "school":
                {
                    player_2_Point.x = 379;
                    player_2_Point.y = 928;
                    gf_Point.x = 709;
                    gf_Point.y = 856;
                    player_1_Point.x = 993;
                    player_1_Point.y = 944;

                    var bgSky = new FlxSprite().loadGraphic(Paths.image(stage + '/weebSky', 'stages'));
                    bgSky.scrollFactor.set(0.1, 0.1);
                    add(bgSky);

                    var repositionShit = -200;

                    var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image(stage + '/weebSchool', 'stages'));
                    bgSchool.scrollFactor.set(0.6, 0.90);
                    add(bgSchool);

                    var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image(stage + '/weebStreet', 'stages'));
                    bgStreet.scrollFactor.set(0.95, 0.95);
                    add(bgStreet);

                    var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image(stage + '/weebTreesBack', 'stages'));
                    fgTrees.scrollFactor.set(0.9, 0.9);
                    add(fgTrees);

                    var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
                    var treetex = Paths.getPackerAtlas(stage + '/weebTrees', 'stages');
                    bgTrees.frames = treetex;
                    bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
                    bgTrees.animation.play('treeLoop');
                    bgTrees.scrollFactor.set(0.85, 0.85);
                    add(bgTrees);

                    var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
                    treeLeaves.frames = Paths.getSparrowAtlas(stage + '/petals', 'stages');
                    treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
                    treeLeaves.animation.play('leaves');
                    treeLeaves.scrollFactor.set(0.85, 0.85);
                    add(treeLeaves);

                    var widShit = Std.int(bgSky.width * 6);

                    bgSky.setGraphicSize(widShit);
                    bgSchool.setGraphicSize(widShit);
                    bgStreet.setGraphicSize(widShit);
                    bgTrees.setGraphicSize(Std.int(widShit * 1.4));
                    fgTrees.setGraphicSize(Std.int(widShit * 0.8));
                    treeLeaves.setGraphicSize(widShit);

                    fgTrees.updateHitbox();
                    bgSky.updateHitbox();
                    bgSchool.updateHitbox();
                    bgStreet.updateHitbox();
                    bgTrees.updateHitbox();
                    treeLeaves.updateHitbox();

                    bgGirls = new BackgroundGirls(-100, 190);
                    bgGirls.scrollFactor.set(0.9, 0.9);

                    bgGirls.setGraphicSize(Std.int(bgGirls.width * PlayState.daPixelZoom));
                    bgGirls.updateHitbox();
                    add(bgGirls);
                }
                case "school-mad":
                {
                    stage = "school";

                    player_2_Point.x = 379;
                    player_2_Point.y = 928;
                    gf_Point.x = 709;
                    gf_Point.y = 856;
                    player_1_Point.x = 993;
                    player_1_Point.y = 944;

                    var bgSky = new FlxSprite().loadGraphic(Paths.image(stage + '/weebSky', 'stages'));
                    bgSky.scrollFactor.set(0.1, 0.1);
                    add(bgSky);

                    var repositionShit = -200;

                    var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image(stage + '/weebSchool', 'stages'));
                    bgSchool.scrollFactor.set(0.6, 0.90);
                    add(bgSchool);

                    var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image(stage + '/weebStreet', 'stages'));
                    bgStreet.scrollFactor.set(0.95, 0.95);
                    add(bgStreet);

                    var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image(stage + '/weebTreesBack', 'stages'));
                    fgTrees.scrollFactor.set(0.9, 0.9);
                    add(fgTrees);

                    var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
                    var treetex = Paths.getPackerAtlas(stage + '/weebTrees', 'stages');
                    bgTrees.frames = treetex;
                    bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
                    bgTrees.animation.play('treeLoop');
                    bgTrees.scrollFactor.set(0.85, 0.85);
                    add(bgTrees);

                    var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
                    treeLeaves.frames = Paths.getSparrowAtlas(stage + '/petals', 'stages');
                    treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
                    treeLeaves.animation.play('leaves');
                    treeLeaves.scrollFactor.set(0.85, 0.85);
                    add(treeLeaves);

                    var widShit = Std.int(bgSky.width * 6);

                    bgSky.setGraphicSize(widShit);
                    bgSchool.setGraphicSize(widShit);
                    bgStreet.setGraphicSize(widShit);
                    bgTrees.setGraphicSize(Std.int(widShit * 1.4));
                    fgTrees.setGraphicSize(Std.int(widShit * 0.8));
                    treeLeaves.setGraphicSize(widShit);

                    fgTrees.updateHitbox();
                    bgSky.updateHitbox();
                    bgSchool.updateHitbox();
                    bgStreet.updateHitbox();
                    bgTrees.updateHitbox();
                    treeLeaves.updateHitbox();

                    bgGirls = new BackgroundGirls(-100, 190);
                    bgGirls.scrollFactor.set(0.9, 0.9);

                    bgGirls.getScared();

                    bgGirls.setGraphicSize(Std.int(bgGirls.width * PlayState.daPixelZoom));
                    bgGirls.updateHitbox();
                    add(bgGirls);

                    stage = "school-mad";
                }
                case "evil-school":
                {
                    player_1_Point.x = 995;
                    player_1_Point.y = 918;
                    gf_Point.x = 645;
                    gf_Point.y = 834;
                    player_2_Point.x = 325;
                    player_2_Point.y = 918;
                    
                    var bg:FlxSprite = new FlxSprite(400, 220);
                    bg.frames = Paths.getSparrowAtlas(stage + '/animatedEvilSchool', 'stages');
                    bg.animation.addByPrefix('idle', 'background 2', 24);
                    bg.animation.play('idle');
                    bg.scrollFactor.set(0.8, 0.9);
                    bg.scale.set(6, 6);
                    add(bg);
                }
                case 'wasteland':
                {
                    camZoom = 0.9;
        
                    player_2_Point.x = 245;
                    player_2_Point.y = 900;
                    gf_Point.x = 707;
                    gf_Point.y = 750;
                    player_1_Point.x = 1050;
                    player_1_Point.y = 900;
    
                    var sky = new FlxSprite(-400, -400);
                    sky.scrollFactor.set(0, 0);
                    sky.loadGraphic(Paths.image('wasteland/tankSky', 'shared'));
                    add(sky);
        
                    var clouds = new FlxSprite(FlxG.random.int(-700, -100), FlxG.random.int(-20, 20));
                    clouds.scrollFactor.set(0.1, 0.1);
                    clouds.loadGraphic(Paths.image('wasteland/tankClouds', 'shared'));
                    clouds.velocity.set(FlxG.random.float(5, 15));
                    add(clouds);
        
                    var mountains = new FlxSprite(-300, -20);
                    mountains.scrollFactor.set(0.2, 0.2);
                    mountains.loadGraphic(Paths.image('wasteland/tankMountains', 'shared'));
                    mountains.setGraphicSize(Std.int(mountains.width * 1.2));
                    mountains.updateHitbox();
                    add(mountains);
        
                    var buildings = new FlxSprite(-200, 0);
                    buildings.scrollFactor.set(0.3, 0.3);
                    buildings.loadGraphic(Paths.image('wasteland/tankBuildings', 'shared'));
                    buildings.setGraphicSize(Std.int(buildings.width * 1.1));
                    buildings.updateHitbox();
                    add(buildings);
        
                    var ruins = new FlxSprite(-200, 0);
                    ruins.scrollFactor.set(0.35, 0.35);
                    ruins.loadGraphic(Paths.image('wasteland/tankRuins', 'shared'));
                    ruins.setGraphicSize(Std.int(ruins.width * 1.1));
                    ruins.updateHitbox();
                    add(ruins);
        
                    var leftSmoke = new FlxSprite(-200, -100);
                    leftSmoke.scrollFactor.set(0.4, 0.4);
                    leftSmoke.frames = Paths.getSparrowAtlas('wasteland/smokeLeft', 'shared');
                    leftSmoke.animation.addByPrefix("default", "SmokeBlurLeft", 24, true);
                    leftSmoke.animation.play("default");
                    add(leftSmoke);
        
                    var rightSmoke = new FlxSprite(1100, -100);
                    rightSmoke.scrollFactor.set(0.4, 0.4);
                    rightSmoke.frames = Paths.getSparrowAtlas('wasteland/smokeRight', 'shared');
                    rightSmoke.animation.addByPrefix("default", "SmokeRight", 24, true);
                    rightSmoke.animation.play("default");
                    add(rightSmoke);
        
                    watchTower = new FlxSprite(100, 50);
                    watchTower.scrollFactor.set(0.5, 0.5);
                    watchTower.frames = Paths.getSparrowAtlas('wasteland/tankWatchtower', 'shared');
                    watchTower.animation.addByPrefix("idle", "watchtower gradient color", 24, false);
                    watchTower.animation.play("idle");
                    add(watchTower);
        
                    rollingTank = new FlxSprite(300, 300);
                    rollingTank.scrollFactor.set(0.5, 0.5);
                    rollingTank.frames = Paths.getSparrowAtlas('wasteland/tankRolling', 'shared');
                    rollingTank.animation.addByPrefix("idle", "BG tank w lighting", 24, true);
                    rollingTank.animation.play("idle");
                    add(rollingTank);

                    var ground = new FlxSprite(-420, -150);
                    ground.loadGraphic(Paths.image('wasteland/tankGround', 'shared'));
                    ground.setGraphicSize(Std.int(ground.width * 1.15));
                    ground.updateHitbox();
                    add(ground);
        
                    moveTank();
        
                    // THE FRONT MENSSSS
        
                    var tankMan0 = new FlxSprite(-500, 650);
                    tankMan0.scrollFactor.set(1.7, 1.5);
                    tankMan0.frames = Paths.getSparrowAtlas('wasteland/tank0', 'shared');
                    tankMan0.animation.addByPrefix("idle", "fg", 24, false);
                    tankMan0.animation.play("idle");
                    PlayState.instance.foregroundSprites.add(tankMan0);
        
                    var tankMan1 = new FlxSprite(-300, 750);
                    tankMan1.scrollFactor.set(2, 0.2);
                    tankMan1.frames = Paths.getSparrowAtlas('wasteland/tank1', 'shared');
                    tankMan1.animation.addByPrefix("idle", "fg", 24, false);
                    tankMan1.animation.play("idle");
                    PlayState.instance.foregroundSprites.add(tankMan1);
        
                    var tankMan2 = new FlxSprite(450, 940);
                    tankMan2.scrollFactor.set(1.5, 1.5);
                    tankMan2.frames = Paths.getSparrowAtlas('wasteland/tank2', 'shared');
                    tankMan2.animation.addByPrefix("idle", "foreground", 24, false);
                    tankMan2.animation.play("idle");
                    PlayState.instance.foregroundSprites.add(tankMan2);
        
                    var tankMan3 = new FlxSprite(1300, 900);
                    tankMan3.scrollFactor.set(1.5, 1.5);
                    tankMan3.frames = Paths.getSparrowAtlas('wasteland/tank4', 'shared');
                    tankMan3.animation.addByPrefix("idle", "fg", 24, false);
                    tankMan3.animation.play("idle");
                    PlayState.instance.foregroundSprites.add(tankMan3);
        
                    var tankMan4 = new FlxSprite(1300, 1350);
                    tankMan4.scrollFactor.set(3.5, 2.5);
                    tankMan4.frames = Paths.getSparrowAtlas('wasteland/tank3', 'shared');
                    tankMan4.animation.addByPrefix("idle", "fg", 24, false);
                    tankMan4.animation.play("idle");
                    PlayState.instance.foregroundSprites.add(tankMan4);
        
                    var tankMan5 = new FlxSprite(1620, 700);
                    tankMan5.scrollFactor.set(1.5, 1.5);
                    tankMan5.frames = Paths.getSparrowAtlas('wasteland/tank5', 'shared');
                    tankMan5.animation.addByPrefix("idle", "fg", 24, false);
                    tankMan5.animation.play("idle");
                    PlayState.instance.foregroundSprites.add(tankMan5);
        
                    tankMen.push(tankMan0);
                    tankMen.push(tankMan1);
                    tankMen.push(tankMan2);
                    tankMen.push(tankMan3);
                    tankMen.push(tankMan4);
                    tankMen.push(tankMan5);
                }
                case 'wasteland-stress':
                {
                    camZoom = 0.9;

                    player_2_Point.x = 245;
                    player_2_Point.y = 900;
                    gf_Point.x = 707;
                    gf_Point.y = 750;
                    player_1_Point.x = 1050;
                    player_1_Point.y = 900;
        
                    var sky = new FlxSprite(-400, -400);
                    sky.scrollFactor.set(0, 0);
                    sky.loadGraphic(Paths.image('wasteland/tankSky', 'shared'));
                    add(sky);
        
                    var clouds = new FlxSprite(FlxG.random.int(-700, -100), FlxG.random.int(-20, 20));
                    clouds.scrollFactor.set(0.1, 0.1);
                    clouds.loadGraphic(Paths.image('wasteland/tankClouds', 'shared'));
                    clouds.velocity.set(FlxG.random.float(5, 15));
                    add(clouds);
        
                    var mountains = new FlxSprite(-300, -20);
                    mountains.scrollFactor.set(0.2, 0.2);
                    mountains.loadGraphic(Paths.image('wasteland/tankMountains', 'shared'));
                    mountains.setGraphicSize(Std.int(mountains.width * 1.2));
                    mountains.updateHitbox();
                    add(mountains);
        
                    var buildings = new FlxSprite(-200, 0);
                    buildings.scrollFactor.set(0.3, 0.3);
                    buildings.loadGraphic(Paths.image('wasteland/tankBuildings', 'shared'));
                    buildings.setGraphicSize(Std.int(buildings.width * 1.1));
                    buildings.updateHitbox();
                    add(buildings);
        
                    var ruins = new FlxSprite(-200, 0);
                    ruins.scrollFactor.set(0.35, 0.35);
                    ruins.loadGraphic(Paths.image('wasteland/tankRuins', 'shared'));
                    ruins.setGraphicSize(Std.int(ruins.width * 1.1));
                    ruins.updateHitbox();
                    add(ruins);
        
                    var leftSmoke = new FlxSprite(-200, -100);
                    leftSmoke.scrollFactor.set(0.4, 0.4);
                    leftSmoke.frames = Paths.getSparrowAtlas('wasteland/smokeLeft', 'shared');
                    leftSmoke.animation.addByPrefix("default", "SmokeBlurLeft", 24, true);
                    leftSmoke.animation.play("default");
                    add(leftSmoke);
        
                    var rightSmoke = new FlxSprite(1100, -100);
                    rightSmoke.scrollFactor.set(0.4, 0.4);
                    rightSmoke.frames = Paths.getSparrowAtlas('wasteland/smokeRight', 'shared');
                    rightSmoke.animation.addByPrefix("default", "SmokeRight", 24, true);
                    rightSmoke.animation.play("default");
                    add(rightSmoke);
        
                    watchTower = new FlxSprite(100, 50);
                    watchTower.scrollFactor.set(0.5, 0.5);
                    watchTower.frames = Paths.getSparrowAtlas('wasteland/tankWatchtower', 'shared');
                    watchTower.animation.addByPrefix("idle", "watchtower gradient color", 24, false);
                    watchTower.animation.play("idle");
                    add(watchTower);
        
                    rollingTank = new FlxSprite(300, 300);
                    rollingTank.scrollFactor.set(0.5, 0.5);
                    rollingTank.frames = Paths.getSparrowAtlas('wasteland/tankRolling', 'shared');
                    rollingTank.animation.addByPrefix("idle", "BG tank w lighting", 24, true);
                    rollingTank.animation.play("idle");
                    add(rollingTank);
                    johns = new FlxTypedGroup<FlxSprite>();
                        add(johns);
        
                    var ground = new FlxSprite(-420, -150);
                    ground.loadGraphic(Paths.image('wasteland/tankGround', 'shared'));
                    ground.setGraphicSize(Std.int(ground.width * 1.15));
                    ground.updateHitbox();
                    add(ground);
        
                    moveTank();
        
                    // THE FRONT MENSSSS
        
                    var tankMan0 = new FlxSprite(-500, 650);
                    tankMan0.scrollFactor.set(1.7, 1.5);
                    tankMan0.frames = Paths.getSparrowAtlas('wasteland/tank0', 'shared');
                    tankMan0.animation.addByPrefix("idle", "fg", 24, false);
                    tankMan0.animation.play("idle");
                    PlayState.instance.foregroundSprites.add(tankMan0);
        
                    var tankMan1 = new FlxSprite(-300, 750);
                    tankMan1.scrollFactor.set(2, 0.2);
                    tankMan1.frames = Paths.getSparrowAtlas('wasteland/tank1', 'shared');
                    tankMan1.animation.addByPrefix("idle", "fg", 24, false);
                    tankMan1.animation.play("idle");
                    PlayState.instance.foregroundSprites.add(tankMan1);
        
                    var tankMan2 = new FlxSprite(450, 940);
                    tankMan2.scrollFactor.set(1.5, 1.5);
                    tankMan2.frames = Paths.getSparrowAtlas('wasteland/tank2', 'shared');
                    tankMan2.animation.addByPrefix("idle", "foreground", 24, false);
                    tankMan2.animation.play("idle");
                    PlayState.instance.foregroundSprites.add(tankMan2);
        
                    var tankMan3 = new FlxSprite(1300, 900);
                    tankMan3.scrollFactor.set(1.5, 1.5);
                    tankMan3.frames = Paths.getSparrowAtlas('wasteland/tank4', 'shared');
                    tankMan3.animation.addByPrefix("idle", "fg", 24, false);
                    tankMan3.animation.play("idle");
                    PlayState.instance.foregroundSprites.add(tankMan3);
        
                    var tankMan4 = new FlxSprite(1300, 1350);
                    tankMan4.scrollFactor.set(3.5, 2.5);
                    tankMan4.frames = Paths.getSparrowAtlas('wasteland/tank3', 'shared');
                    tankMan4.animation.addByPrefix("idle", "fg", 24, false);
                    tankMan4.animation.play("idle");
                    PlayState.instance.foregroundSprites.add(tankMan4);
        
                    var tankMan5 = new FlxSprite(1620, 700);
                    tankMan5.scrollFactor.set(1.5, 1.5);
                    tankMan5.frames = Paths.getSparrowAtlas('wasteland/tank5', 'shared');
                    tankMan5.animation.addByPrefix("idle", "fg", 24, false);
                    tankMan5.animation.play("idle");
                    PlayState.instance.foregroundSprites.add(tankMan5);
        
                    tankMen.push(tankMan0);
                    tankMen.push(tankMan1);
                    tankMen.push(tankMan2);
                    tankMen.push(tankMan3);
                    tankMen.push(tankMan4);
                    tankMen.push(tankMan5);
                }
                // CUSTOM SHIT
                default:
                {
                    if(stage_Data != null)
                    {
                        camZoom = stage_Data.camera_Zoom;

                        if(stage_Data.camera_Offsets != null)
                        {
                            p1_Cam_Offset.set(stage_Data.camera_Offsets[0][0], stage_Data.camera_Offsets[0][1]);
                            p2_Cam_Offset.set(stage_Data.camera_Offsets[1][0], stage_Data.camera_Offsets[1][1]);
                        }
        
                        player_1_Point.set(stage_Data.character_Positions[0][0], stage_Data.character_Positions[0][1]);
                        player_2_Point.set(stage_Data.character_Positions[1][0], stage_Data.character_Positions[1][1]);
                        gf_Point.set(stage_Data.character_Positions[2][0], stage_Data.character_Positions[2][1]);

                        if(stage_Data.character_Scrolls != null)
                        {
                            p1_Scroll = stage_Data.character_Scrolls[0];
                            p2_Scroll = stage_Data.character_Scrolls[1];
                            gf_Scroll = stage_Data.character_Scrolls[2];
                        }

                        var null_Object_Name_Loop:Int = 0;
        
                        for(Object in stage_Data.objects)
                        {
                            var Sprite = new FlxSprite(Object.position[0], Object.position[1]);
        
                            if(Object.color != null && Object.color != [])
                                Sprite.color = FlxColor.fromRGB(Object.color[0], Object.color[1], Object.color[2]);
        
                            Sprite.antialiasing = Object.antialiased;
                            Sprite.scrollFactor.set(Object.scroll_Factor[0], Object.scroll_Factor[1]);

                            if(Object.object_Name != null && Object.object_Name != "")
                                stage_Objects.push([Object.object_Name, Sprite, Object]);
                            else
                            {
                                stage_Objects.push(["undefinedSprite" + null_Object_Name_Loop, Sprite, Object]);
                                null_Object_Name_Loop++;
                            }

                            if(Object.is_Animated)
                            {
                                Sprite.frames = Paths.getSparrowAtlas(stage + "/" + Object.file_Name, "stages");
        
                                for(Animation in Object.animations)
                                {
                                    var Anim_Name = Animation.name;
        
                                    if(Animation.name == "beatHit")
                                        onBeatHit_Group.add(Sprite);
        
                                    if(Animation.indices == null)
                                    {
                                        Sprite.animation.addByPrefix(
                                            Anim_Name,
                                            Animation.animation_name,
                                            Animation.fps,
                                            Animation.looped
                                        );
                                    }
                                    else if(Animation.indices.length == 0)
                                    {
                                        Sprite.animation.addByPrefix(
                                            Anim_Name,
                                            Animation.animation_name,
                                            Animation.fps,
                                            Animation.looped
                                        );
                                    }
                                    else
                                    {
                                        Sprite.animation.addByIndices(
                                            Anim_Name,
                                            Animation.animation_name,
                                            Animation.indices,
                                            "",
                                            Animation.fps,
                                            Animation.looped
                                        );
                                    }
                                }
        
                                if(Object.start_Animation != "" && Object.start_Animation != null && Object.start_Animation != "null")
                                    Sprite.animation.play(Object.start_Animation);
                            }
                            else
                                Sprite.loadGraphic(Paths.image(stage + "/" + Object.file_Name, "stages"));
        
                            if(Object.uses_Frame_Width)
                                Sprite.setGraphicSize(Std.int(Sprite.frameWidth * Object.scale));
                            else
                                Sprite.setGraphicSize(Std.int(Sprite.width * Object.scale));

                            if(Object.updateHitbox || Object.updateHitbox == null)
                                Sprite.updateHitbox();

                            if(Object.alpha != null)
                                Sprite.alpha = Object.alpha;
        
                            if(Object.layer != null)
                            {
                                switch(Object.layer.toLowerCase())
                                {
                                    case "foreground":
                                        foregroundSprites.add(Sprite);
                                    case "gf":
                                        infrontOfGFSprites.add(Sprite);
                                    default:
                                        add(Sprite);
                                }
                            }
                            else
                                add(Sprite);
                        }
                    }
                }
            }
        }
    }

    public function createLuaStuff()
    {
        #if linc_luajit
        #if polymod // change this in future whenever custom backend
        if(stage_Data != null)
        {
            if(stage_Data.scriptName != null && Assets.exists(Paths.lua("stage data/" + stage_Data.scriptName)))
                stageScript = ModchartUtilities.createModchartUtilities(PolymodAssets.getPath(Paths.lua("stage data/" + stage_Data.scriptName)));
        }
        #end
        #end
    }

    public function setCharOffsets(?p1:Character, ?gf:Character, ?p2:Character):Void
    {

        if(p1 == null)
            p1 = PlayState.boyfriend;

        if(gf == null)
            gf = PlayState.gf;

        if(p2 == null)
            p2 = PlayState.dad;

        p1.setPosition((player_1_Point.x - (p1.width / 2)) + p1.positioningOffset[0], (player_1_Point.y - p1.height) + p1.positioningOffset[1]);
        gf.setPosition((gf_Point.x - (gf.width / 2)) + gf.positioningOffset[0], (gf_Point.y - gf.height) + gf.positioningOffset[1]);
        p2.setPosition((player_2_Point.x - (p2.width / 2)) + p2.positioningOffset[0], (player_2_Point.y - p2.height) + p2.positioningOffset[1]);

        p1.scrollFactor.set(p1_Scroll, p1_Scroll);
        p2.scrollFactor.set(p2_Scroll, p2_Scroll);
        gf.scrollFactor.set(gf_Scroll, gf_Scroll);

        if(p2.curCharacter.startsWith("gf") && gf.curCharacter.startsWith("gf"))
        {
            p2.setPosition(gf.x, gf.y);
            p2.scrollFactor.set(gf_Scroll, gf_Scroll);

            if(p2.visible)
                gf.visible = false;
        }

        if(p1.otherCharacters != null)
        {
            for(character in p1.otherCharacters)
            {
                character.setPosition((player_1_Point.x - (character.width / 2)) + character.positioningOffset[0], (player_1_Point.y - character.height) + character.positioningOffset[1]);
                character.scrollFactor.set(p1_Scroll, p1_Scroll);
            }
        }

        if(gf.otherCharacters != null)
        {
            for(character in gf.otherCharacters)
            {
                character.setPosition((gf_Point.x - (character.width / 2)) + character.positioningOffset[0], (gf_Point.y - character.height) + character.positioningOffset[1]);
                character.scrollFactor.set(gf_Scroll, gf_Scroll);
            }
        }

        if(p2.otherCharacters != null)
        {
            for(character in p2.otherCharacters)
            {
                character.setPosition((player_2_Point.x - (character.width / 2)) + character.positioningOffset[0], (player_2_Point.y - character.height) + character.positioningOffset[1]);
                character.scrollFactor.set(p2_Scroll, p2_Scroll);
            }
        }
    }

    public function getCharacterPos(character:Int, char:Character = null):Dynamic
    {
        switch(character)
        {
            case 0: // bf
                if(char == null)
                    char = PlayState.boyfriend;

                return [(player_1_Point.x - (char.width / 2)) + char.positioningOffset[0], (player_1_Point.y - char.height) + char.positioningOffset[1]];
            case 1: // dad
                if(char == null)
                    char = PlayState.dad;

                return [(player_2_Point.x - (char.width / 2)) + char.positioningOffset[0], (player_2_Point.y - char.height) + char.positioningOffset[1]];
            case 2: // gf
                if(char == null)
                    char = PlayState.gf;

                return [(gf_Point.x - (char.width / 2)) + char.positioningOffset[0], (gf_Point.y - char.height) + char.positioningOffset[1]];
        }

        return [0,0];
    }

    override public function new(?stageName:String) {
        super();

        stage = stageName;
        updateStage();
    }

    public function beatHit()
    {
        if(utilities.Options.getData("animatedBGs"))
        {
            for(sprite in onBeatHit_Group)
            {
                sprite.animation.play("beatHit", true);
            }
            
            switch(stage)
            {
                case 'school' | 'school-mad':
                {
                    bgGirls.dance();
                }
                case 'wasteland':
                {
                watchTower.animation.play("idle", true);
        
                for(object in tankMen)
                    {
                        object.animation.play("idle", true);
                    }
                }
                case 'wasteland-stress':
                {
                watchTower.animation.play("idle", true);
        
                for(object in tankMen)
                    {
                        object.animation.play("idle", true);
                    }
                }
            }
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        switch(stage)
        {
            case 'wasteland':
                moveTank();
            case 'wasteland-stress':
                moveTank();
                var i = 0;
				for (spr in johns.members) {
					if (spr.x >= 1.2 * FlxG.width || spr.x <= -0.5 * FlxG.width)
						spr.visible = false;
					else
						spr.visible = true;
					if (spr.animation.curAnim.name == "run") {
						var fuck = 0.74 * FlxG.width + endingOffsetJohn[i];
						if (goingRightJohn[i]) {
							fuck = 0.02 * FlxG.width - endingOffsetJohn[i];
							spr.x = fuck + (Conductor.songPosition - strumTimeJohn[i]) * tankSpeedJohn[i];
							spr.flipX = true;
						} else {
							spr.x = fuck - (Conductor.songPosition - strumTimeJohn[i]) * tankSpeedJohn[i];
							spr.flipX = false;
						}
					}
					if (Conductor.songPosition > strumTimeJohn[i]) {
						spr.animation.play("shot");
						if (goingRightJohn[i]) {
							spr.offset.y = 200;
							spr.offset.x = 300;
						}
					}
					if (spr.animation.curAnim.name == "shot" && spr.animation.curAnim.curFrame >= spr.animation.curAnim.frames.length - 1) {
						spr.kill();
					}
					i++;
				}
        }

        goodElapse = elapsed;
    }

    function resetJohn(x:Float, y:Int, goingRight:Bool, spr:FlxSprite, johnNum:Int) { //function for the tankmen to be reset after being killed
		
		spr.x = x;
		spr.y = y;
		goingRightJohn[johnNum] = goingRight;
		endingOffsetJohn[johnNum] = FlxG.random.float(50, 200);
		tankSpeedJohn[johnNum] = FlxG.random.float(0.6, 1);
		 spr.flipX = if (goingRight) true else false;
	}

    //wasteland
    function moveTank()
    {
        var tankX = 400;
        tankAngle += FlxG.elapsed * tankSpeed;
        rollingTank.angle = tankAngle - 90 + 15;
        rollingTank.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
        rollingTank.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
    }

    // philly

    function updateTrainPos() {
        if (trainSound.time >= 4700)
        {
            startedMoving = true;
            PlayState.gf.playAnim('hairBlow');
        }

        if (startedMoving)
        {
            phillyTrain.x -= 400;

            if (phillyTrain.x < -2000 && !trainFinishing)
            {
                phillyTrain.x = -1150;
                trainCars -= 1;

                if (trainCars <= 0)
                    trainFinishing = true;
            }

            if (phillyTrain.x < -4000 && trainFinishing)
                trainReset();
        }
    }

    function trainReset()
    {
        PlayState.gf.playAnim('hairFall');
        
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
    }

    function trainStart():Void
    {
        trainMoving = true;
        if (!trainSound.playing)
            trainSound.play(true);
    }

    // LUA SHIT LOL

    override public function destroy() {
        #if linc_luajit
        if(stageScript != null)
        {
            stageScript.die();
            stageScript = null;
        }
        #end

        super.destroy();
    }
}

typedef StageData =
{
    var character_Positions:Array<Array<Float>>;
    var character_Scrolls:Array<Float>;

    var camera_Zoom:Float;
    var camera_Offsets:Array<Array<Float>>;

    var objects:Array<StageObject>;

    var scriptName:Null<String>;
}

typedef StageObject =
{
    // General Sprite Object Data //
    var position:Array<Float>;
    var scale:Float;
    var antialiased:Bool;
    var scroll_Factor:Array<Float>;

    var color:Array<Int>;

    var uses_Frame_Width:Bool;

    var object_Name:Null<String>;

    var layer:Null<String>; // default is bg, but fg is possible

    var alpha:Null<Float>;

    var updateHitbox:Null<Bool>;
    
    // Image Info //
    var file_Name:String;
    var is_Animated:Bool;

    // Animations //
    var animations:Array<CharacterAnimation>;

    var start_Animation:String;
}