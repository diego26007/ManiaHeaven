package states;

//import flixel.util.FlxSpriteUtil;
import openfl.media.Sound;
import flixel.sound.FlxSound;
#if sys import sys.FileSystem; #end
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
import Sys;

class EditorState extends FlxState
{
	var editorSections:Array<String> = ["Song", "Beatmap Data", "Notes/Events"];

	var sections = [[]];
	var sectionNotes:Array<Array<Any>> = [];
	var renderedNotes:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var renderedSustains:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var stepCrochet:Int = 16;
	var steps:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	var currentSection:Int = 0;

	var time:Float = 0.0;

	var selectedBeatmap:String = '';
	var selectedBeatmapInput:FlxTextInput = new FlxTextInput(800, 40, 300, '', 14);
	var thisSong:FlxSound = new FlxSound();
	var selectedDifficulty:String = '';
	var selectedDifficultyInput:FlxTextInput = new FlxTextInput(1000, 70, 100, '', 10);
	var songBPM:Float = 60;
	var songBPMInput:FlxUINumericStepper = new FlxUINumericStepper(800, 70, 1, 60, 1, 1200, 2, STACK_HORIZONTAL);
	var loadFile:FlxButton = new FlxButton(1000, 100, 'Load Beatmap');

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
		renderedSustains.forEach(function(note:FlxSprite) renderedSustains.remove(note));

		time = toSection * (60 / songBPM) * 4000;
		thisSong.time = time;

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

				updateSustains(sectionNotes[i][0], sectionNotes[i][1]);
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
			renderedSustains.remove(renderedSustains.getFirst(function(sustain) return (sustain.ID == lane * 10000 + Std.int(step * 100))));
		};
		else
		{
			sectionNotes.push([lane, step, 0]);
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

	function copySection(fromSection:Int, toSection:Int){
		if (sections.length <= toSection) for (i in 0...(toSection - sections.length + 1)) sections.push([]);
		sections[toSection] = sections[fromSection];
	}

	function updateSteps(newStepCrochet:Int){
		steps.forEach(function(thisStep:FlxSprite) steps.remove(thisStep));
		for (lane in 0...4)
		{
			for (step in 0...newStepCrochet)
			{
				var stepSize:Float = (1 / newStepCrochet) * 16;
				var editorStep:FlxSprite = new FlxSprite(180 + lane * 40, 30 + step * stepSize * 40);
				editorStep.makeGraphic(40, Std.int(stepSize * 40), (lane + step) % 2 == 0 ? FlxColor.fromRGB(95, 95, 95) : FlxColor.fromRGB(175, 175, 175));
				editorStep.ID = lane * 100 + Std.int(step * stepSize);
				FlxMouseEvent.add(editorStep, function(thisStep:FlxSprite) updateNotes(lane, step * stepSize, thisStep), null, null, null);
				steps.add(editorStep);
				//trace(editorStep);
			}
		}
		stepCrochet = newStepCrochet;
		steps.forEach(function(thisStep) trace(thisStep));
	}

	var propertiesBG:FlxSprite = new FlxSprite(20, 20, null);

	var currentSectionText:FlxText = new FlxText(180, 10, 160, 'Current Section:', 9);

	var beatmapInput = false;

	#if sys
	function load(loadFile:Bool = false){
		trace('searching for \'$selectedBeatmap\'');
		if(FileSystem.exists('assets/beatmaps/$selectedBeatmap')){
			trace('found $selectedBeatmap');
			for(file in FileSystem.readDirectory('assets/beatmaps/$selectedBeatmap/')){
				if(!FileSystem.isDirectory('assets/beatmaps/$selectedBeatmap/$file') && (StringTools.endsWith(file, '.mp3') || StringTools.endsWith(file, '.ogg'))){
					trace('found an mp3 file, called $file');
					thisSong.loadEmbedded('assets/beatmaps/$selectedBeatmap/$file');
					//thisSong.loadEmbedded(file);
					trace(thisSong);
				}
				if (loadFile && 'assets/beatmaps/$selectedBeatmap/$file' == 'assets/beatmaps/$selectedBeatmap/beatmapData'){}
			}
		}
	}
	#end

	var timeText = new FlxText(350, 80, 0, '', 12);

	var line:FlxSprite = new FlxSprite(180, 40);

	override public function create()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.5, true);

		add(steps);
		updateSteps(stepCrochet);

		var timeLabel = new FlxText(350, 60, 0, 'Time:', 12);
		add(timeLabel);
		add(timeText);

		super.create();

		propertiesBG.makeGraphic(600, 300, 0x5F5F5F, true);
		//FlxSpriteUtil.drawRoundRect(propertiesBG, 580, 20, 600, 300, 30, 30, 0x5F5F5F);
		propertiesBG.updateHitbox();
		add(propertiesBG);
		

		var labelBPM:FlxText = new FlxText(songBPMInput.x - 90, songBPMInput.y, 90, 'BPM', 10);
		add(songBPMInput);
		add(labelBPM);

		selectedBeatmapInput.textField.textColor = 0x000000;
		selectedBeatmapInput.textField.background = true;
		selectedBeatmapInput.textField.backgroundColor = 0xFFFFFF;
		selectedBeatmapInput.textField.border = true;
		selectedBeatmapInput.textField.borderColor = 0x2A2A2A;

		selectedBeatmapInput.onChange.add(function() selectedBeatmap = selectedBeatmapInput.text);
		selectedBeatmapInput.onFocusGained.add(function() beatmapInput = true);
		selectedBeatmapInput.onFocusLost.add(function() beatmapInput = false);
		var labelBeatmap:FlxText = new FlxText(selectedBeatmapInput.x - 90, selectedBeatmapInput.y, 120, 'Beatmap', 10);
		add(selectedBeatmapInput);
		add(labelBeatmap);

		currentSectionText.text = 'Current Section: $currentSection';
		currentSectionText.alignment = CENTER;
		add(currentSectionText);


		add(renderedSustains);
		add(renderedNotes);

		function clearSections(){
			sectionNotes = [];
			sections = [[]];
			swapSection(0, 0);
		}
		var clearAllSectionsButton:FlxButton = new FlxButton(800, 100, 'Clear all Sections', function() clearSections());
		clearAllSectionsButton.scale.x = 90 / clearAllSectionsButton.width;
		clearAllSectionsButton.scale.y = 40 / clearAllSectionsButton.height;
		clearAllSectionsButton.updateHitbox();
		clearAllSectionsButton.label.offset.add(-3, -5);
		clearAllSectionsButton.color = 0xAA0000;
		clearAllSectionsButton.label.color = 0xFFFFFF;
		add(clearAllSectionsButton);

		var loadSong:FlxButton = new FlxButton(900, 100, 'Load Song', function() #if sys load(false) #else trace('kys') #end);
		add(loadSong);

		line.makeGraphic(160, 4, FlxColor.GREEN);
		add(line);
	}

	function updateSustains(lane:Int, step:Float){
		var correspondingSustain = renderedSustains.getFirst(function(sustain) return (sustain.ID == lane * 10000 + Std.int(step * 100)));
		var correspondingNote:Array<Any> = [];
		for(i in sectionNotes) if(i[0] == lane && i[1] == step){
			correspondingNote = i;
		}
		if(correspondingSustain == null){
			var sustain:FlxSprite = new FlxSprite(196 + lane * 40, 50 + step * 40, 'assets/images/receptors/BlueTrail.png');
			sustain.scale.y = Std.parseFloat(correspondingNote[2]) * 40;
			sustain.scale.x = 2;
			sustain.updateHitbox();
			sustain.ID = lane * 10000 + Std.int(step * 100);
			renderedSustains.add(sustain);
		} else {
			if(Std.parseFloat(correspondingNote[2]) == 0) renderedSustains.remove(correspondingSustain);
			else {
				correspondingSustain.scale.y = Std.parseFloat(correspondingNote[2]) * 40;
				correspondingSustain.updateHitbox();
			}
		}
	}

	override public function update(elapsed:Float)
	{
		if(songBPMInput.value != songBPM){
			songBPM = songBPMInput.value;
			time = currentSection * (60 / songBPM) * 4000;
		}

		if(thisSong.playing){
			time += elapsed * 1000;
			timeText.text = '${Math.round(time) / 1000} / ${thisSong.length / 1000}';
		}

		line.y = 30 + (40 * 16 * ((time - (currentSection * 60 / songBPM * 4000)) / (60 / songBPM * 4000)));

		if (time >= ((currentSection + 1) * (60 / songBPM) * 4000)){
			swapSection(currentSection, currentSection + 1);
		}

		super.update(elapsed);

		timeText.text = '${Math.round(time) / 1000} / ${thisSong.length / 1000}';


		if (FlxG.keys.justPressed.RIGHT){
			if(FlxG.keys.pressed.CONTROL && stepCrochet < 128) updateSteps(stepCrochet * 2);
			else swapSection(currentSection, currentSection + 1);
		}
		if (FlxG.keys.justPressed.LEFT){
			if(FlxG.keys.pressed.CONTROL && stepCrochet > 1) updateSteps(Std.int(stepCrochet / 2));
			else if(currentSection > 0) swapSection(currentSection, currentSection - 1);
		}
		if (FlxG.keys.justPressed.SPACE){
			/*if(beatmapInput){
				selectedBeatmapInput.text += ' ';
				selectedBeatmapInput.setSelection(selectedBeatmapInput.text.length, selectedBeatmapInput.text.length);
			} else */if (thisSong != null) {
				if (!thisSong.playing) thisSong.play(false, time);
				else {
					trace('stopped song');
					thisSong.stop();
				}
			}
		}
		if (FlxG.keys.justPressed.E && !beatmapInput){
			sectionNotes[sectionNotes.length - 1][2] = Std.parseFloat(sectionNotes[sectionNotes.length - 1][2]) + (1/stepCrochet * 16);
			updateSustains(sectionNotes[sectionNotes.length - 1][0], sectionNotes[sectionNotes.length - 1][1]);
		}
		if (FlxG.keys.justPressed.Q && !beatmapInput){
			if(Std.int(sectionNotes[sectionNotes.length - 1][2]) >= (1/stepCrochet * 16)){
				sectionNotes[sectionNotes.length - 1][2] = Std.parseFloat(sectionNotes[sectionNotes.length - 1][2]) - (1 / stepCrochet * 16);
				updateSustains(sectionNotes[sectionNotes.length - 1][0], sectionNotes[sectionNotes.length - 1][1]);
			}
		}
	}
}
