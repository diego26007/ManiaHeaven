package substates.options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.input.keyboard.*;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

import states.SettingsState;

import backend.ClientSettings;
import backend.Utilities;

class InputKeybindsSubstate extends FlxSubState
{
	var optionNames:FlxTypedGroup<FlxText>;
	var optionButtons:FlxTypedGroup<FlxButton>;
	var options:Array<Dynamic> = [
		["Gameplay"],
		["Left (1st receptor)", 'note_left'],
		["Down (2nd receptor)", 'note_down'],
		["Up (3rd receptor)", 'note_up'],
		["Right (4th receptor)", 'note_right'],
		["Navigation"],
		["Accept", 'accept'],
		["Cancel/Pause", 'cancel'],
		["Quick Restart", 'restart']
	];

	var optionSelected:Int = 0;
	var lastOptionRelY = 0;

	function rebindKeybind(key:String, bind:Int)
	{
		var keyPressed = FlxG.keys.firstPressed();
		if (keyPressed != -1)
		{
			ClientSettings.keybinds.set(key,
			    bind == 0 ? [keyPressed, ClientSettings.keybinds.get(key)[1]] : [ClientSettings.keybinds.get(key)[0], keyPressed]
            );
		}
    }

	override public function create()
	{
		add(bgDim(0.7));

		optionNames = new FlxTypedGroup<FlxText>();
		optionButtons = new FlxTypedGroup<FlxButton>();
		add(optionNames);
		add(optionButtons);

		for (i in options)
		{
			var option = new FlxText(0, 0, FlxG.width - 100, i[0]);
			option.screenCenter(X);
			option.font = 'assets/fonts/vcr.ttf';
			option.borderColor = FlxColor.BLACK;
			if (i.length == 1)
			{
				option.size = 60;
				option.y = lastOptionRelY /*+ 60*/;
				lastOptionRelY += 90;
				option.alignment = CENTER;
			}
			else
			{
                var optionButton1:FlxButton;
				optionButton1 = new FlxButton(FlxG.width - 50 - 120 * 2 - 10, lastOptionRelY + 10,
					FlxG.save != null ? ClientSettings.keybinds.get(i[1])[0].toString() : '', function(){
                        rebindKeybind(i[1], 0);
					    optionButton1.text = ClientSettings.keybinds.get(i[1])[0].toString();
                    }
                );
                var optionButton2:FlxButton;
				optionButton2 = new FlxButton(FlxG.width - 50 - 120, lastOptionRelY + 10,
					FlxG.save != null ? ClientSettings.keybinds.get(i[1])[1].toString() : '', function(){
                        rebindKeybind(i[1], 1);
                        optionButton2.text = ClientSettings.keybinds.get(i[1])[1].toString();
                    }
                );
				option.size = 40;
				option.y = lastOptionRelY /*+ 40*/;
				optionButton1.scale.y = 2;
				optionButton1.scale.x = 1.5;
				optionButton2.scale.y = 2;
				optionButton2.scale.x = 1.5;
				lastOptionRelY += 55;
				option.alignment = LEFT;
				optionButtons.add(optionButton1);
				optionButtons.add(optionButton2);
			}
			option.borderSize = option.size / 10;
			optionNames.add(option);
		}
		super.create();
	}

	override public function update(elapsed)
	{
		if (FlxG.keys.pressed.ESCAPE)
		{
			close();
		}
		super.update(elapsed);
	}
}
