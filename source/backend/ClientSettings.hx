package backend;

import flixel.input.keyboard.*;

class ClientSettings {
    public static var keybinds:Map<String, Array<FlxKey>> = [
        'note_left'     => [D, LEFT],
        'note_down'     => [F, DOWN],
        'note_up'       => [J, UP],
        'note_right'    => [K, RIGHT],

        'accept'        => [ENTER, SPACE],
        'cancel'        => [ESCAPE, null],
        'restart'       => [SHIFT, null]
    ];

    public var downscroll:Bool = false;

    public var scoreSettings:Array<Dynamic> = [
        true, //Whether to show score or not
        "Up", //Where should score be displayed? (Horz)
        "Left", //Where should score be displayed? (Vert)
        true //Whether to tween the score display instead of instantly displaying the new score
    ];
    public var accuracySettings:Array<Dynamic> = [
        true, //Whether to display accuracy or not
        "Up", //Where should accuracy be displayed? (Horz)
        "Left", //Where should accuracy be displayed? (Vert)
        2 //Number of decimal places of the accuracy (0 to 4)
    ];
    public var missSettings:Array<Dynamic> = [
        true, //Whether to display misses or not
        "Up", //Where should misses be displayed? (Horz)
        "Left", //Where should misses be displayed? (Vert)
        true //Replace misses with FC grade when misses == 0
    ];
    public var healthSettings:Array<Dynamic> = [
        true //Whether to display health or not
    ];
}