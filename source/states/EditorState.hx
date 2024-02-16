package states;

import flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.text.FlxTextInput;
import flixel.addons.text.ui.FlxUINumericStepper;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.FlxInput;
import flixel.input.actions.FlxActionInput.FlxInputDeviceObject;
import flixel.input.mouse.FlxMouseEvent;
import flixel.system.debug.interaction.tools.Mover;
import flixel.text.FlxText;
import flixel.ui.*;
import flixel.util.FlxColor;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

class EditorState extends FlxState
{
	var editorSections:Array<String> = ["Song", "Beatmap Data", "Notes/Events"];

	var sections = [[]];
	var sectionNotes:Array<Array<Any>> = [];
	var renderedNotes:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	var currentSection:Int = 0;

	var selectedBeatmap:String = '';
	var selectedBeatmapInput:FlxTextInput = new FlxTextInput(800, 40, 300, '', 14);
	var songBPM:Float = 60;
	var songBPMInput:FlxUINumericStepper = new FlxUINumericStepper(800, 70, 1, 60, 1, 1200, 2, STACK_HORIZONTAL);

	function swapSection(fromSection:Int, toSection:Int)
	{
		trace('swapping section from $fromSection (currentSection set to $currentSection) to $toSection');
		if (sections.length <= toSection)
			for (i in 0...(toSection - sections.length + 1))
				sections.push([]);
		sections[fromSection] = sectionNotes;
		trace(sections);

		sectionNotes = sections[toSection];
		trace('section $toSection has the notes $sectionNotes');
		renderedNotes.forEach(function(note:FlxSprite) renderedNotes.remove(note));

		if (sectionNotes.length != 0)
		{
			for (i in 0...sectionNotes.length)
			{
				var note = new FlxSprite(0, 0, 'assets/images/receptors/BlueArrow.png');
				note.ID = Std.int(sectionNotes[i][0]) * 10000 + Std.int(Std.parseFloat(sectionNotes[i][1]) * 100);
				note.scale.x = 2.33;
				note.scale.y = 2.33 * (Std.int(sectionNotes[i][0]) % 2 == 0 ? -1 : 1);
				note.updateHitbox();
				note.x = 180 + Std.int(sectionNotes[i][0]) * 40;
				note.y = 30 + Std.parseFloat(sectionNotes[i][1]) * 40;
				switch (Std.int(sectionNotes[i][0]))
				{
					case 0:
						note.angle = 180;
					case 1:
						note.angle = 90;
					case 2:
						note.angle = 270;
					case 3:
						note.angle = 0;
				}
				renderedNotes.add(note);
			}
		}

		currentSection = toSection;
		currentSectionText.text = 'Current Section: $currentSection';
		trace('current section is now $currentSection');
	}

	function updateNotes(lane:Int, step:Float, square:FlxSprite)
	{
		var found:Bool = false;
		var ubication:Int = 0;
		for (i in 0...sectionNotes.length)
		{
			if (sectionNotes[i][0] == lane && sectionNotes[i][1] == step)
			{
				found = true;
				ubication = i;
			}
			trace('checking if ${[lane, step]} is ${sectionNotes[i]}... returned $found');
		}
		if (found)
		{
			sectionNotes.remove(sectionNotes[ubication]);
			renderedNotes.remove(renderedNotes.getFirst(function(note:FlxSprite) return (note.ID == lane * 10000 + Std.int(step * 100))));
		}
		else
		{
			sectionNotes.push([lane, step]);
			var note = new FlxSprite(square.x, square.y, 'assets/images/receptors/BlueArrow.png');
			note.ID = lane * 10000 + Std.int(step * 100);
			note.scale.x = 2.33;
			note.scale.y = 2.33 * (lane % 2 == 0 ? -1 : 1);
			note.updateHitbox();
			note.x = 180 + lane * 40;
			note.y = 30 + step * 40;
			switch (lane)
			{
				case 0:
					note.angle = 180;
				case 1:
					note.angle = 90;
				case 2:
					note.angle = 270;
				case 3:
					note.angle = 0;
			}
			renderedNotes.add(note);
		}
		trace(sectionNotes);
	}

	var currentSectionText:FlxText = new FlxText(180, 10, 160, 'Current Section:', 9);

	override public function create()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.5, true);

		super.create();

		var propertiesBG:FlxSprite = new FlxSprite(580, 20);
		propertiesBG.makeGraphic(600, 300, 0x5F5F5F);
		FlxSpriteUtil.drawRoundRect(propertiesBG, 580, 20, 600, 300, 30, 30, 0x5F5F5F);
		add(propertiesBG);

		var labelBPM:FlxText = new FlxText(songBPMInput.x - 90, songBPMInput.y, 90, 'BPM', 10);
		add(songBPMInput);
		add(labelBPM);

		selectedBeatmapInput.textField.textColor = 0x000000;
		selectedBeatmapInput.textField.background = true;
		selectedBeatmapInput.textField.backgroundColor = 0xFFFFFF;
		selectedBeatmapInput.textField.border = true;
		selectedBeatmapInput.textField.borderColor = 0x2A2A2A;
		var labelBeatmap:FlxText = new FlxText(selectedBeatmapInput.x - 90, selectedBeatmapInput.y, 120, 'Beatmap', 10);
		add(selectedBeatmapInput);
		add(labelBeatmap);

		currentSectionText.text = 'Current Section: $currentSection';
		currentSectionText.alignment = CENTER;
		add(currentSectionText);

		for (lane in 0...4)
		{
			for (step in 0...16)
			{
				var editorStep:FlxSprite = new FlxSprite(180 + lane * 40, 30 + step * 40);
				editorStep.makeGraphic(40, 40, (lane + step) % 2 == 0 ? FlxColor.fromRGB(95, 95, 95) : FlxColor.fromRGB(175, 175, 175));
				editorStep.ID = lane * 100 + step;
				FlxMouseEvent.add(editorStep, function(thisStep:FlxSprite) updateNotes(lane, step, thisStep), null, null, null);
				add(editorStep);
			}
		}

		add(renderedNotes);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.RIGHT)
			swapSection(currentSection, currentSection + 1);
		if (FlxG.keys.justPressed.LEFT && currentSection > 0)
			swapSection(currentSection, currentSection - 1);
	}
}
