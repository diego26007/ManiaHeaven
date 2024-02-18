package backend;

import openfl.Assets;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import flixel.util.FlxColor;
#if cpp import Sys.*; #end
import flixel.FlxSprite;
import flixel.FlxState;

import states.InitState;

using StringTools;

typedef Note = {
    var lane:Int;
    var step:Float;
    var sustainLength:Float;
}

typedef Section = Array<Note>;

typedef Song = {
    var sectionData:Array<Section>;
    var initialBPM:Float;
}

function setBg(?filePath:String)
{
    var bg:FlxTypedGroup<Dynamic> = new FlxTypedGroup<Dynamic>();
    var bgPhoto:FlxSprite = new FlxSprite(0, 0, null);
    var bgText:FlxText = new FlxText(0, 0, FlxG.width, '', 18);

    var imageArray:Array<Dynamic> = [];
    var beatmapNameArray:Array<String> = [];

    #if sys
    for (dir in sys.FileSystem.readDirectory('assets/beatmaps/')){
        trace('found $dir');
        if(sys.FileSystem.isDirectory('assets/beatmaps/$dir')){
            trace('found dir $dir');
            for(file in sys.FileSystem.readDirectory('assets/beatmaps/$dir/')){
                trace('found $file');
                if(!sys.FileSystem.isDirectory('assets/beatmaps/$dir/$file')){
                    trace('found file $file');
                    if(StringTools.endsWith(file, ".png") || StringTools.endsWith(file, ".jpg") || StringTools.endsWith(file, ".jpeg")) {
                        trace('found valid file $file in $dir');
                        beatmapNameArray.push(dir);
                        imageArray.push('assets/beatmaps/$dir/$file');
                    }
                }
            }
        }
    }

    #end

    #if html5
    trace("kys");
    #end
	var imageChosen:Int = Std.int(Math.random() * imageArray.length);
    trace('Image chosen: ${imageChosen + 1} out of ${imageArray.length}');
    bgPhoto.loadGraphic(imageArray[imageChosen]);

    var ratioX = FlxG.width / (bgPhoto.width == 0 ? FlxG.width : bgPhoto.width);
    var ratioY = FlxG.height / (bgPhoto.height == 0 ? FlxG.width : bgPhoto.height);
    var scaleToApply = Math.min(ratioX, ratioY);
    bgPhoto.scale.x = scaleToApply;
    bgPhoto.scale.y = scaleToApply;
    bgPhoto.updateHitbox();
    bgPhoto.screenCenter(XY);

    #if sys bgText.text = 'Image from beatmap ${beatmapNameArray[imageChosen]}'; #end
    bgText.font = 'assets/fonts/vcr.ttf';

    trace(bgPhoto);
    trace(imageArray[imageChosen]);
    bg.add(bgPhoto);
    bg.add(bgText);

    return bg;
}

function bgDim(opacity:Float, color:FlxColor = FlxColor.BLACK){
    var dim:FlxSprite = new FlxSprite(0, 0, null);
    dim.makeGraphic(FlxG.width, FlxG.height, color);
    FlxSpriteUtil.drawRect(dim, 0, 0, FlxG.width, FlxG.height, color);
    dim.alpha = opacity;

    return dim;
}

class SoonTM extends FlxState {
	override public function create()
	{
		super.create();

        var soon:FlxText = new FlxText(0, 0, 0, 'SOON', 300);
        soon.font = 'assets/fonts/vcr.ttf';
        soon.screenCenter(XY);
        add(soon);

        var tm:FlxText = new FlxText(soon.y - 30, soon.x + soon.width, 0, 'TM', 70);
        tm.font = 'assets/fonts/vcr.ttf';
        tm.y = soon.y;
        tm.x = soon.x + soon.width;
        add(tm);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
        if(FlxG.keys.pressed.ESCAPE) FlxG.switchState(new InitState());
	}
}