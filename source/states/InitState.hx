package states;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.*;
import flixel.tweens.*;
import flixel.input.mouse.*;
import flixel.FlxState;
import flixel.group.FlxGroup;

import states.MenuState;
import states.SettingsState;
import states.EditorState;

import backend.Utilities;


class InitState extends FlxState
{
	var logoTween:FlxTween;
	var logoClicked:Bool = false;
	var logoTween2:FlxTween;
	var logoTween3:FlxTween;
	var logo = new FlxSprite();
	var logoScale:Float = 1;

	var menuOptionsArray:Array<String> = [
		'Play',
		'Settings',
		'Editor'
	];

	var optionSelected:Int = 0;

	var menuOptions:FlxTypedGroup<FlxSprite>;
	var menuOptionsTxt:FlxTypedGroup<FlxText>;

	function coolTransition(ID:Int):Void{
		logoTween3 = FlxTween.tween(logo, {x: FlxG.width * -2}, 1, {ease: FlxEase.expoIn, type: FlxTween.FlxTweenType.ONESHOT});
		menuOptions.forEach(function(option:FlxSprite){FlxTween.tween(option, {x: FlxG.width * 2}, 1, {ease: FlxEase.expoIn});});
		menuOptionsTxt.forEach(function(option:FlxSprite){FlxTween.tween(option, {x: FlxG.width * 2 + 120}, 1, {ease: FlxEase.expoIn});});

		FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function(){
			FlxG.switchState(ID == 0 ? /*new MenuState()*/ new SoonTM() : ID == 1 ? new SettingsState() : ID == 2 ? new EditorState() : new InitState());
		});
	}

	function clickStart():Void{
		logoScale = 0.66;
		logoClicked = true;

		logoTween2 = FlxTween.tween(logo.scale, {x: logoScale, y: logoScale}, 0.5, {ease: FlxEase.expoOut, type: FlxTween.FlxTweenType.ONESHOT});
		logoTween3 = FlxTween.tween(logo, {x: FlxG.width * -0.05}, 0.5, {ease: FlxEase.expoIn, type: FlxTween.FlxTweenType.ONESHOT});

		menuOptions.forEach(function(option:FlxSprite){
			FlxTween.tween(option, {
				x: FlxG.width * 0.55
			}, 0.7, {
				ease: FlxEase.sineOut, type: FlxTween.FlxTweenType.ONESHOT
				});
			FlxMouseEvent.add(
				option,
				function(item:FlxSprite) coolTransition(item.ID),
				null,
				function(item:FlxSprite){optionSelected = item.ID; updateOptions();},
				null,
				false, true, false
			);
		});

		menuOptionsTxt.forEach(function(option:FlxText)
		{
			FlxTween.tween(option, {
				x: FlxG.width * 0.55 + 120
			}, 0.7, {
				ease: FlxEase.sineOut,
				type: FlxTween.FlxTweenType.ONESHOT
			});
			FlxMouseEvent.add(
				option,
				function(item:FlxSprite) coolTransition(item.ID), 
				null,
				function(item:FlxSprite) {optionSelected = item.ID; updateOptions();}, 
				null,
				false, true, false
			);
		});

		updateOptions();

	}

	override public function create()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.5, true);

		super.create();

		add(setBg());
		add(bgDim(0.6));

		menuOptions = new FlxTypedGroup<FlxSprite>();
		add(menuOptions);
		menuOptionsTxt = new FlxTypedGroup<FlxText>();
		add(menuOptionsTxt);

		for(i in 0...menuOptionsArray.length){
			var menuOption = new FlxSprite(FlxG.width * 2, FlxG.height * 0.2 * (i + 1), 'assets/images/mainMenu/${menuOptionsArray[i]}Icon.png');
			menuOption.ID = i;
			menuOption.scale.x = 0.9;
			menuOption.scale.y = 0.9;
			menuOptions.add(menuOption);
			var menuOptionTxt:FlxText = new FlxText(menuOption.x + 120, menuOption.y + 25, 0, menuOptionsArray[i], 40, true);
			menuOptionTxt.font = 'assets/fonts/vcr.ttf';
			menuOptionTxt.color = FlxColor.WHITE;
			menuOptionTxt.borderSize = 4;
			menuOptionTxt.borderColor = FlxColor.BLACK;
			menuOptionTxt.ID = i;
			menuOptionsTxt.add(menuOptionTxt);
		}

		logo.loadGraphic('assets/images/logo.png');
		logo.screenCenter();
		add(logo);
		FlxMouseEvent.add(
			logo, 
			function(logo:FlxSprite) clickStart(), 
			null, 
			function(logo:FlxSprite) logoClicked == false ? logoTween2 = FlxTween.tween(logo.scale, {x: logoScale + 0.07, y: logoScale + 0.07}, 0.5, {ease: FlxEase.expoOut, type: FlxTween.FlxTweenType.ONESHOT}) : null, 
			function(logo:FlxSprite) logoClicked == false ? logoTween2 = FlxTween.tween(logo.scale, {x: logoScale, y: logoScale}, 0.5, {ease: FlxEase.expoOut, type: FlxTween.FlxTweenType.ONESHOT}) : null,
			false, true, false
		);

		logoTween = FlxTween.angle(logo, -5, 5, 4.0, {
			ease: FlxEase.sineInOut,
			type: FlxTween.FlxTweenType.PINGPONG
		});


	}

	function updateOptions(){
		menuOptionsTxt.forEach(function(option:FlxText) {
			FlxTween.cancelTweensOf(option.scale);

			optionSelected == option.ID ? 
			FlxTween.tween(option.scale, {x: 1.1, y: 1.1}, 0.7, {ease: FlxEase.expoOut}) :
			FlxTween.tween(option.scale, {x: 1, y: 1}, 0.7, {ease: FlxEase.expoOut});
		});

		menuOptions.forEach(function(option:FlxSprite) {
			FlxTween.cancelTweensOf(option.scale);

			optionSelected == option.ID ?
			FlxTween.tween(option.scale, {x: 1.1, y: 1.1}, 0.7, {ease: FlxEase.expoOut}) :
			FlxTween.tween(option.scale, {x: 0.9, y: 0.9}, 0.7, {ease: FlxEase.expoOut});
		});
	}


	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if(FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER) logoClicked ? coolTransition(optionSelected) : clickStart();
		if(FlxG.keys.justPressed.DOWN && logoClicked == true){
			optionSelected == 2 ? optionSelected = 0 : optionSelected++;
			updateOptions();
		}
		if (FlxG.keys.justPressed.UP && logoClicked == true)
		{
			optionSelected == 0 ? optionSelected = 2 : optionSelected--;
			updateOptions();
		}
	}
}
