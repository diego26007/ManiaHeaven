package states;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;
import flixel.ui.*;
import states.MenuState;
import flixel.group.FlxGroup;

class SettingsState extends FlxState
{
	var optionSubstatesArray:Array<String> = [
		'UI Settings',
		'Gameplay Settings',
		'Input and Keybinds',
		'Miscellaneous Settings'
	];
	var optionSelected:<Int> = 0;

	var menuOptions:FlxTypedGroup<FlxText>();

	function iWantToGoBack(){
		FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function() FlxG.switchState(new MenuState());
	}
	
	override public function create()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.5, true);
		
		super.create();

		menuOptions = new FlxTypedGroup<FlxText>();
		add(menuOptions);

		for(i in 0...optionSubstatesArray.length){
			var menuOption = new FlxText(FlxG.width, FlxG.height * 0.15 * (i+1), 0, optionSubstatesArray[i], 40, true);
			menuOption.font = 'assets/fonts/vcr.ttf';
			menuOption.screenCenter(X);
			menuOption.color = FlxColor.WHITE;
			menuOption.borderSize = 4;
			menuOption.borderColor = FlxColor.BLACK;
			menuOption.ID = i;
			menuOptions.add(menuOption);
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESC) iWantToGoBack();
	}
}
