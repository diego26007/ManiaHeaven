package;

import flixel.FlxGame;
import openfl.display.Sprite;
import states.InitState;
import flixel.FlxG;

class Main extends Sprite
{

	var game = {
		width: 1280,
		height: 720,
		initialState: InitState,
		framerate: 60,
		skipSplash: true,
		startFullscreen: false
	};

	public function new()
	{
		FlxG.resizeWindow(1280, 720);

		super();

		addChild(new FlxGame(game.width, game.height, game.initialState, game.framerate, game.skipSplash, game.startFullscreen));
	}

	private function setupGame():Void
	{
		FlxG.save.bind('userdata', 'assets/user/');
	}
}
