package states;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.FlxG;
import flixel.ui.*;
import flixel.text.*;
import flixel.input.mouse.*;
import flixel.group.FlxGroup;
import flixel.tweens.*;

import substates.options.*;

import states.InitState;

import backend.Utilities;

class SettingsState extends FlxState
{
	var optionSubstatesArray:Array<String> = [
		'UI Settings',
		'Gameplay Settings',
		'Input and Keybinds',
		'Miscellaneous Settings'
	];
	var optionSelected:Int = 0;
	var openedSubstate:Bool = false;

	var menuOptions:FlxTypedGroup<FlxText>;

	function iWantToGoBack(){
		FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function() FlxG.switchState(new InitState()));
	}

	override public function create()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.5, true);

		super.create();

		add(setBg());
		add(bgDim(0.7));

		subStateClosed.add(SubState->openedSubstate = false);

		menuOptions = new FlxTypedGroup<FlxText>();
		add(menuOptions);

		for (i in 0...optionSubstatesArray.length)
		{
			var menuOption = new FlxText(FlxG.width, FlxG.height * 0.15 * (i + 1), 0, optionSubstatesArray[i], 50, true);
			menuOption.font = 'assets/fonts/vcr.ttf';
			menuOption.screenCenter(X);
			menuOption.color = FlxColor.WHITE;
			menuOption.borderSize = 4;
			menuOption.borderColor = FlxColor.BLACK;
			menuOption.ID = i;
			FlxMouseEvent.add(menuOption,
				function(option:FlxText) {
					!openedSubstate ? {
						openOptionSubstate(optionSelected);
						openedSubstate = true;
					} : null;
				},
				null,
				function(option:FlxText) {optionSelected = option.ID; updateOptions();},
				null,
				false, true, false
			);
			menuOptions.add(menuOption);
		}

		updateOptions();
	}

	function updateOptions(){
		if(!openedSubstate){
			menuOptions.forEach(function(option:FlxText){
				FlxTween.cancelTweensOf(option.scale);

				optionSelected == option.ID ? 
				FlxTween.tween(option.scale, {x: 1.1, y: 1.1}, 0.7, {ease: FlxEase.expoOut}) :
				FlxTween.tween(option.scale, {x: 1, y: 1}, 0.7, {ease: FlxEase.expoOut});
			});
		}
	}

	function openOptionSubstate(id){
		switch(id){
			case 2:
				openSubState(new InputKeybindsSubstate());
			case 3:
				FlxG.switchState(new InitState());
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE) iWantToGoBack();
		if (FlxG.keys.justPressed.UP) {optionSelected == 0 ? optionSelected = 3 : optionSelected--; updateOptions();}
		if (FlxG.keys.justPressed.DOWN) {optionSelected == 3 ? optionSelected = 0 : optionSelected++; updateOptions();}
	}
}
