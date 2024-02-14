package backend;

import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import flixel.util.FlxColor;
#if cpp import Sys.*; #end
//#if html5 import js.html.*; #end
import flixel.FlxSprite;

using StringTools;

function setBg()
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

    var ratioX = FlxG.width / bgPhoto.width;
    var ratioY = FlxG.height / bgPhoto.height;
    var scaleToApply = Math.min(ratioX, ratioY);
    bgPhoto.scale.x = scaleToApply;
    bgPhoto.scale.y = scaleToApply;
    bgPhoto.screenCenter(XY);

    #if sys bgText.text = 'Image from beatmap ${beatmapNameArray[imageChosen]}'; #end
    bgText.font = 'assets/fonts/vcr.ttf';

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