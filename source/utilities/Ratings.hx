package utilities;

import game.Conductor;
import states.PlayState;
import haxe.macro.Type;

class Ratings
{
    private static var scores:Array<Dynamic> = [
        ['marvelous', 400],
        ['sick', 350],
        ['good', 200],
        ['bad', 50],
        ['shit', -150]
    ];

    public static function getRating(time:Float)
    {
        var judges = utilities.Options.getData("judgementTimings");

        var timings:Array<Array<Dynamic>> = [
            [judges[0], "marvelous"],
            [judges[1], "sick"],
            [judges[2], "good"],
            [judges[3], "bad"]
        ];

        var rating:String = 'bruh';

        for(x in timings)
        {
            if(x[1] == "marvelous" && utilities.Options.getData("marvelousRatings") || x[1] != "marvelous")
            {
                if(time <= x[0] * PlayState.songMultiplier && rating == 'bruh')
                {
                    rating = x[1];
                }
            }
        }

        if(rating == 'bruh')
            rating = "shit";

        return rating;
    }

    public static var timingPresets:Map<String, Array<Int>> = [];
    public static var presets:Array<String> = [];

    public static function returnPreset(name:String = "leather engine"):Array<Int>
    {
        if(timingPresets.exists(name))
            return timingPresets.get(name);

        return [25, 50, 70, 100];
    }

    public static function loadPresets()
    {
        presets = [];
        timingPresets = [];

        var timingPresetsArray = CoolUtil.coolTextFile(Paths.txt("timingPresets"));

        for(array in timingPresetsArray)
        {
            var values = array.split(",");

            timingPresets.set(values[0], [Std.parseInt(values[1]), Std.parseInt(values[2]), Std.parseInt(values[3]), Std.parseInt(values[4])]);
            presets.push(values[0]);
        }
    }

    public static function getRank(accuracy:Float, ?misses:Int)
    {
        // yeah this is kinda taken from kade engine but i didnt use the etterna 'wife3' ranking system (instead just my own custom values)
        var conditions:Array<Bool>;

        switch(utilities.Options.getData("ratingType").toLowerCase())
        {
            case "complex":
                conditions = [
                    accuracy == 100, // SSSS
                    accuracy >= 98, // SSS
                    accuracy >= 95, // SS
                    accuracy >= 92, // S
                    accuracy >= 89, // AA
                    accuracy >= 85, // A
                    accuracy >= 80, // B+
                    accuracy >= 70, // B
                    accuracy >= 65, // C
                    accuracy >= 50, // D
                    accuracy >= 10, // E
                    accuracy >= 5, // F
                    accuracy < 4, // G
                ];
            case "andromeda":
                conditions = [
                    accuracy == 100, // ☆☆☆☆
                    accuracy >= 99, // ☆☆☆
                    accuracy >= 98, // ☆☆
                    accuracy >= 96, // ☆
                    accuracy >= 94, // S+
                    accuracy >= 89, // S
                    accuracy >= 86, // S-
                    accuracy >= 83, // A+
                    accuracy >= 80, // A
                    accuracy >= 76, // A-
                    accuracy >= 72, // B+
                    accuracy >= 68, // B-
                    accuracy < 64, // C+
                    accuracy < 60, // C
                    accuracy < 55, // C-
                    accuracy < 50, // D+
                    accuracy < 45, // D
                ];
            case "simple +":
                conditions = [
                    accuracy == 100, // S+
                    accuracy >= 85, // S
                    accuracy >= 60, // A
                    accuracy >= 50, // B
                    accuracy >= 35, // C
                    accuracy >= 10, // D
                    accuracy >= 2, // F
                    accuracy >= 0 // HOW
                ];
            case "mania": //Stolen From Grafex
                conditions = [
                    accuracy == 100, // X
                    accuracy >= 95, // S
                    accuracy >= 90, // A
                    accuracy >= 80, // B
                    accuracy >= 70, // C
                    accuracy >= 60, // D
                ];
            case "grafex": //Stolen From Grafex again Also best engine https://github.com/JustXale/fnf-grafex
                conditions = [
                    accuracy == 100, // SS
                    accuracy >= 98, // S+
                    accuracy >= 97, // S
                    accuracy >= 95, // S-
                    accuracy >= 93, // A
                    accuracy >= 85, // B
                    accuracy >= 75, // C
                    accuracy >= 65, // D
                    accuracy >= 40, // F
                ];
            case "forever":
                conditions = [
                    accuracy >= 100, // S+
                    accuracy >= 99.9, // S
                    accuracy >= 90, // A
                    accuracy >= 85, // B
                    accuracy >= 80, // C
                    accuracy >= 75, // D
                    accuracy >= 70, // E
                    accuracy >= 65, // F
                ];
            case "modding plus":
                conditions = [
                    accuracy >= 100, // AAAAA
                    accuracy >= 99, // AAAA:
                    accuracy >= 98, // AAAA.
                    accuracy >= 97, // AAAA
                    accuracy >= 96, // AAA:
                    accuracy >= 95, // AAA.
                    accuracy >= 94, // AAA
                    accuracy >= 93, // AA:
                    accuracy >= 92, // AA.
                    accuracy >= 91, // AA
                    accuracy >= 90, // A:
                    accuracy >= 85, // A.
                    accuracy >= 80, // A
                    accuracy >= 70, // B
                    accuracy >= 60, // C
                    accuracy < 60 // D
                ];
            case "psych":
                conditions = [
                    accuracy == 100, // Perfect!!
                    accuracy >= 90, // Sick!
                    accuracy >= 80, // Great
                    accuracy >= 70, // Good
                    accuracy >= 69, // Nice
                    accuracy >= 60, // Meh
                    accuracy >= 50, // Bruh
                    accuracy >= 40, // Bad
                    accuracy >= 20, // Shit
                    accuracy >= 0 // You Suck!
                ];
            case "mic'd up":
                conditions = [
                    accuracy == 100, // X
                    accuracy >= 99, // X-
                    accuracy >= 98, // SS+
                    accuracy >= 97, // SS
                    accuracy >= 96, // SS-
                    accuracy >= 95, // S+
                    accuracy >= 94, // S
                    accuracy >= 93, // S-
                    accuracy >= 90, // A+
                    accuracy >= 80, // A
                    accuracy >= 79, // A-
                    accuracy >= 60, // B
                    accuracy >= 50, // C
                    accuracy >= 40, // D
                    accuracy >= 20, // E
                    accuracy >= 10 // F
                ];
            default:
                conditions = [
                    accuracy == 100, // PERFECT
                    accuracy >= 85, // SICK
                    accuracy >= 60, // GOOD
                    accuracy >= 50, // OK
                    accuracy >= 35, // BAD
                    accuracy >= 10, // REALLY BAD
                    accuracy >= 2, // OOF
                    accuracy >= 0 // wow you really suck
                ];
        }

        var missesRating:String = "";

        var ratingsArray:Array<Int> = [
            PlayState.instance.ratings.get("marvelous"),
            PlayState.instance.ratings.get("sick"),
            PlayState.instance.ratings.get("good"),
            PlayState.instance.ratings.get("bad"),
            PlayState.instance.ratings.get("shit")
        ];

        switch(utilities.Options.getData("ratingType").toLowerCase())
        {
            case "complex":
                if(misses != null)
                {
                    if(misses == 0)
                    {
                        missesRating = "FC - ";
        
                        if(ratingsArray[3] < 10 && ratingsArray[4] == 0)
                            missesRating = "SDB - ";
        
                        if(ratingsArray[3] == 0 && ratingsArray[4] == 0)
                            missesRating = "GFC - ";
        
                        if(ratingsArray[2] < 10 && ratingsArray[3] == 0 && ratingsArray[4] == 0)
                            missesRating = "SDG - ";
        
                        if(ratingsArray[2] == 0 && ratingsArray[3] == 0 && ratingsArray[4] == 0)
                            missesRating = "PFC - ";
        
                        if(ratingsArray[1] < 10 && ratingsArray[2] == 0 && ratingsArray[3] == 0 && ratingsArray[4] == 0)
                            missesRating = "SDP - ";
        
                        if(ratingsArray[1] == 0 && ratingsArray[2] == 0 && ratingsArray[3] == 0 && ratingsArray[4] == 0)
                            missesRating = "MFC - ";
                    }
        
                    if(misses > 0 && misses < 10)
                        missesRating = "SDCB - ";
        
                    if(misses >= 10)
                        missesRating = "CLEAR - ";
                }
            case "mic'd up":
                if(misses != null)
                {
                    if(ratingsArray[0] > 0)
                        missesRating = " - " + "MFC";
                    if(ratingsArray[1] > 0)
                        missesRating = " - " + "GFC";
                    if(ratingsArray[2] > 0 || ratingsArray[3] > 0)
                        missesRating = " - " + "FC";
                    if(misses > 0 && misses < 10)
                        missesRating = " - " + "SDCB";
                    else if(misses >= 10)
                        missesRating = " - " + "Clear";
                }
            case "modding plus":
                if(misses != null)
                {
                    if(misses == 0)
                    {
                        missesRating = "FC - ";
        
                        if(ratingsArray[3] < 10 && ratingsArray[4] == 0)
                            missesRating = "SDB - ";
            
                        if(ratingsArray[3] == 0 && ratingsArray[4] == 0)
                            missesRating = "GFC - ";
            
                        if(ratingsArray[2] < 10 && ratingsArray[3] == 0 && ratingsArray[4] == 0)
                            missesRating = "SDG - ";
            
                        if(ratingsArray[2] == 0 && ratingsArray[3] == 0 && ratingsArray[4] == 0)
                            missesRating = "PFC - ";
            
                        if(ratingsArray[1] < 10 && ratingsArray[2] == 0 && ratingsArray[3] == 0 && ratingsArray[4] == 0)
                            missesRating = "SDP - ";
            
                        if(ratingsArray[1] == 0 && ratingsArray[2] == 0 && ratingsArray[3] == 0 && ratingsArray[4] == 0)
                            missesRating = "MFC - ";
                    }
            
                    if(misses > 0 && misses < 10)
                        missesRating = "SDCB - ";
            
                    if(misses >= 10)
                        missesRating = "CLEAR - ";
                }
            case "psych":
                if(misses != null)
                {
                    if(ratingsArray[0] > 0)
                        missesRating = " - " + "MFC";
                    if(ratingsArray[1] > 0)
                        missesRating = " - " + "SFC";
                    if(ratingsArray[2] > 0)
                        missesRating = " - " + "GFC";
                    if(ratingsArray[3] > 0 || ratingsArray[4] > 0)
                        missesRating = " - " + "FC";
                    if(misses > 0 && misses < 10)
                        missesRating = " - " + "SDCB";
                    else if(misses >= 10)
                        missesRating = " - " + "Clear";
                }
            case "grafex":
                if(misses != null)
                {
                    if(ratingsArray[0] > 0)
                        missesRating = " - " + "MFC";
                    if(ratingsArray[1] > 0)
                        missesRating = " - " + "SFC";
                    if(ratingsArray[2] > 0)
                        missesRating = " - " + "GFC";
                    if(ratingsArray[3] > 0 || ratingsArray[4] > 0)
                        missesRating = " - " + "FC";
                    if(misses > 0 && misses < 10)
                        missesRating = " - " + "SDCB";
                    else if(misses >= 10)
                        missesRating = " - " + "Clear";
                }
            default:
                if(misses != null)
                {
                    if(misses == 0)
                        missesRating = "FC - ";
                }
        }

        for(condition in 0...conditions.length)
        {
            var rating_success = conditions[condition];

            if(rating_success)
            {
                switch(utilities.Options.getData("ratingType"))
                {
                    case "complex":
                        switch(condition)
                        {
                            case 0:
                                return missesRating + "SSSS";
                            case 1:
                                return missesRating + "SSS";
                            case 2:
                                return missesRating + "SS";
                            case 3:
                                return missesRating + "S";
                            case 4:
                                return missesRating + "AA";
                            case 5:
                                return missesRating + "A";
                            case 6:
                                return missesRating + "B+";
                            case 7:
                                return missesRating + "B";
                            case 8:
                                return missesRating + "C";
                            case 9:
                                return missesRating + "D";
                            case 10:
                                return missesRating + "E";
                            case 11:
                                return missesRating + "F";
                            case 12:
                                return missesRating + "G";
                        }
                    case "simple +":
                        switch(condition)
                        {
                            case 0:
                                return missesRating + "S+";
                            case 1:
                                return missesRating + "S";
                            case 2:
                                return missesRating + "A";
                            case 3:
                                return missesRating + "B";
                            case 4:
                                return missesRating + "C";
                            case 5:
                                return missesRating + "D";
                            case 6:
                                return missesRating + "F";
                            case 7:
                                return missesRating + "HOW!?!?!";
                        }
                    case "forever":
                        switch(condition)
                        {
                            case 0:
                                return missesRating + "S+";
                            case 1:
                                return missesRating + "S";
                            case 2:
                                return missesRating + "A";
                            case 3:
                                return missesRating + "B";
                            case 4:
                                return missesRating + "C";
                            case 5:
                                return missesRating + "D";
                            case 6:
                                return missesRating + "E";
                            case 7:
                                return missesRating + "F";
                        }
                    case "mania":
                       switch(condition)
                        {
                            case 0:
                                return missesRating + "X";
                            case 1:
                                return missesRating + "S";
                            case 2:
                                return missesRating + "A";
                            case 3:
                                return missesRating + "B";
                             case 4:
                                return missesRating + "C";
                            case 5:
                                return missesRating + "D";
                        }
                    case "mic'd up":
                        switch(condition)
                        {
                            case 0:
                                return "Rating: " + "X";
                            case 1:
                                return "Rating: " + "X-";
                            case 2:
                                return "Rating: " + "SS+";
                            case 3:
                                return "Rating: " + "SS";
                            case 4:
                                return "Rating: " + "SS-";
                            case 5:
                                return "Rating: " + "S+";
                            case 6:
                                return "Rating: " + "S";
                            case 7:
                                return "Rating: " + "S-";
                            case 8:
                                return "Rating: " + "A+";
                            case 9:
                                return "Rating: " + "A";
                            case 10:
                                return "Rating: " + "A-";
                            case 11:
                                return "Rating: " + "B";
                            case 12:
                                return "Rating: " + "C";
                            case 13:
                                return "Rating: " + "D";
                            case 14:
                                return "Rating: " + "E";
                            case 15:
                                return "Rating: " + "F";
                        }
                    case "andromeda": // PLZ HLEP ME TO   FIX THE STAR!!!!
                        switch(condition)
                        {
                            case 0:
                                return missesRating + "☆☆☆☆";
                            case 1:
                                return missesRating + "☆☆☆";
                            case 2:
                                return missesRating + "☆☆";
                            case 3:
                                return missesRating + "☆";
                            case 4:
                                return missesRating + "S+";
                            case 5:
                                return missesRating + "S";
                            case 6:
                                return missesRating + "S-";
                            case 7:
                                return missesRating + "A+";
                            case 8:
                                return missesRating + "A";
                            case 9:
                                return missesRating + "A-";
                            case 10:
                                return missesRating + "B+";
                            case 11:
                                return missesRating + "B";
                            case 12:
                                return missesRating + "B-";
                            case 13:
                                return missesRating + "C+";
                            case 14:
                                return missesRating + "C";
                            case 15:
                                return missesRating + "C-";
                            case 16:
                                return missesRating + "D";
                            case 16:
                                return missesRating + "D";
                        }
                     case "modding plus":
                        switch(condition)
                        {
                            case 0:
                                return missesRating + " AAAAA";
                            case 1:
                                return missesRating + " AAAA:";
                            case 2:
                                return missesRating + " AAAA.";
                            case 3:
                                return missesRating + " AAAA";
                            case 4:
                                return missesRating + " AAA:";
                            case 5:
                                return missesRating + " AAA.";
                            case 6:
                                return missesRating + " AAA";
                            case 7:
                                return missesRating + " AA:";
                            case 8:
                                return missesRating + " AA.";
                            case 9:
                                return missesRating + " AA";
                            case 10:
                                return missesRating + " A:";
                            case 11:
                                return missesRating + " A.";
                            case 12:
                                return missesRating + " A";
                            case 13:
                                return missesRating + " B";
                            case 14:
                                return missesRating + " C";
                            case 15:
                                return missesRating + " D";
                        }
                    case "grafex":
                        switch(condition)
                        {
                            case 0:
                                return "Rating: " + "SS" + missesRating;
                            case 1:
                                return "Rating: " + "S+" + missesRating;
                            case 2:
                                return "Rating: " + "S" + missesRating;
                            case 3:
                                return "Rating: " + "S-" + missesRating;
                            case 4:
                                return "Rating: " + "A" + missesRating;
                            case 5:
                                return "Rating: " + "B" + missesRating;
                            case 6:
                                return "Rating: " + "C" + missesRating;
                            case 7:
                                return "Rating: " + "D" + missesRating;
                            case 8:
                                return "Rating: " + "F" + missesRating;
                        }
                    case "psych":
                        switch(condition)
                        {
                            case 0:
                                return "Rating: " + "Perfect!!" + missesRating;
                            case 1:
                                return "Rating: " + "Sick!" + missesRating;
                            case 2:
                                return "Rating: " + "Great" + missesRating;
                            case 3:
                                return "Rating: " + "Good" + missesRating;
                            case 4:
                                return "Rating: " + "Nice" + missesRating;
                            case 5:
                                return "Rating: " + "Meh" + missesRating;
                            case 6:
                                return "Rating: " + "Bruh" + missesRating;
                            case 7:
                                return "Rating: " + "Bad" + missesRating;
                            case 8:
                                return "Rating: " + "Shit" + missesRating;
                            case 9:
                                return "Rating: " + "You Suck!" + missesRating;
                        }
                    default:
                        switch(condition)
                        {
                            case 0:
                                return missesRating + "Perfect";
                            case 1:
                                return missesRating + "Sick";
                            case 2:
                                return missesRating + "Good";
                            case 3:
                                return missesRating + "Ok";
                            case 4:
                                return missesRating + "Bad";
                            case 5:
                                return missesRating + "Really Bad";
                            case 6:
                                return missesRating + "OOF";
                            case 7:
                                return missesRating + "how tf u this bad";
                        }
                }
            }
        }

        if(utilities.Options.getData("ratingType") != "psych")
            return "N/A";
        else
            return "Rating: ?";

        if(utilities.Options.getData("ratingType") != "forever")
            return "N/A";
        else
            return "Rating: ?";

        if(utilities.Options.getData("ratingType") != "grafex")
            return "N/A";
        else
            return "Rating: ?";

        if(utilities.Options.getData("ratingType") != "complex")
            return "N/A";
        else
            return "N/A";
    }

    public static function getScore(rating:String)
    {
        var score:Int = 0;

        for(x in scores)
        {
            if(rating == x[0])
            {
                score = x[1];
            }
        }

        return score;
    }
}