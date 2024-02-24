package states;

//import flixel.util.FlxSpriteUtil;
import haxe.display.JsonModuleTypes.JsonDoc;
import haxe.Json;
import sys.io.FileOutput;
import sys.io.File;
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

import backend.Utilities;

class EditorState extends FlxState
{
	var editorSections:Array<String> = ["Song", "Beatmap Data", "Notes/Events"];

	var sections:Array<Section> = [{sectionBeats: 4, sectionBPM: 60, sectionNotes: []}];
	var sectionNotes:Section = {sectionBeats: 4, sectionBPM: 60, sectionNotes: []};
	var renderedNotes:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var renderedSustains:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var stepCrochet:Int = 16;
	var steps:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	var currentSection:Int = 0;

	var time:Float = 0.0;

	var difficultyRating:Float = 0.0;

	var selectedBeatmap:String = '';
	var selectedBeatmapInput:FlxTextInput = new FlxTextInput(800, 40, 300, '', 14);
	var thisSong:FlxSound = new FlxSound();
	var selectedDifficulty:String = '';
	var selectedDifficultyInput:FlxTextInput = new FlxTextInput(1000, 70, 100, '', 10);
	var songBPM:Float = 60;
	var songBPMInput:FlxUINumericStepper = new FlxUINumericStepper(800, 70, 1, 60, 1, 1200, 2, STACK_HORIZONTAL);

	function swapSection(fromSection:Int, toSection:Int)
	{
		trace('swapping section from $fromSection (currentSection set to $currentSection) to $toSection');
		if (sections.length <= toSection)
			for (i in 0...(toSection - sections.length + 1))
				sections.push({sectionNotes: [], sectionBPM: songBPM, sectionBeats: 4});
		sections[fromSection] = sectionNotes;
		trace(sections);

		sectionNotes = sections[toSection];
		trace('section $toSection has the notes $sectionNotes');
		renderedNotes.forEach(function(note:FlxSprite) renderedNotes.remove(note));
		renderedSustains.forEach(function(note:FlxSprite) renderedSustains.remove(note));

		time = toSection * (60 / songBPM) * 4000;
		thisSong.time = time;

		noteHitPlayBack = sectionNotes.sectionNotes.copy();

		if (sectionNotes.sectionNotes.length != 0)
		{
			for (i in 0...sectionNotes.sectionNotes.length)
			{
				var note = new FlxSprite(0, 0, 'assets/images/receptors/BlueArrow.png');
				note.ID = sectionNotes.sectionNotes[i].lane * 10000 + Std.int(sectionNotes.sectionNotes[i].step * 100);
				note.scale.x = 2.33;
				note.scale.y = 2.33 * (Std.int(sectionNotes.sectionNotes[i].lane) % 2 == 0 ? -1 : 1);
				note.updateHitbox();
				note.x = 180 + sectionNotes.sectionNotes[i].lane * 40;
				note.y = 30 + sectionNotes.sectionNotes[i].step * 40;
				switch (sectionNotes.sectionNotes[i].lane)
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

				updateSustains(sectionNotes.sectionNotes[i].lane, sectionNotes.sectionNotes[i].step);
			}
		}

		currentSection = toSection;
		currentSectionText.text = 'Current Section: $currentSection';
		trace('current section is now $currentSection');
	}

	function updateNotes(lane:Int, step:Float, square:FlxSprite)
	{
		var found:Bool = false;
		var songLoaded:Bool = (thisSong.length != 0);
		var ubication:Int = 0;
		for (i in 0...sectionNotes.sectionNotes.length)
		{
			if (sectionNotes.sectionNotes[i].lane == lane && sectionNotes.sectionNotes[i].step == step)
			{
				found = true;
				ubication = i;
			}
			trace('checking if ${[lane, step]} is ${sectionNotes.sectionNotes[i]}... returned $found');
		}
		if (found)
		{
			sectionNotes.sectionNotes.remove(sectionNotes.sectionNotes[ubication]);
			renderedNotes.remove(renderedNotes.getFirst(function(note:FlxSprite) return (note.ID == lane * 10000 + Std.int(step * 100))));
			renderedSustains.remove(renderedSustains.getFirst(function(sustain) return (sustain.ID == lane * 10000 + Std.int(step * 100))));
		};
		else
		{
			var newSectionNote:Note = {lane: lane, step: step, sustainLength: 0};
			sectionNotes.sectionNotes.push(newSectionNote);
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
		if(songLoaded){
			var notes:Int = 0;
			for(section in sections) for(note in section.sectionNotes) notes++;
			difficultyRating = notes != 0 ? (notes / (thisSong.length / 1000) / 1.5) : 0;
		}
		trace(sectionNotes);
	}

	function copySection(fromSection:Int, toSection:Int){
		if (sections.length <= toSection) for (i in 0...(toSection - sections.length + 1)) sections.push({sectionNotes: [], sectionBPM: songBPM, sectionBeats: 4});
		sections[toSection] = sections[fromSection];
		swapSection(fromSection, toSection);
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
				if (loadFile && 'assets/beatmaps/$selectedBeatmap/$file' == 'assets/beatmaps/$selectedBeatmap/beatmapData'){
					if(FileSystem.exists('assets/beatmaps/$selectedBeatmap/beatmapData/$selectedDifficulty.json')){
						trace('loading file');
						var beatmapFileData = File.read('assets/beatmaps/$selectedBeatmap/beatmapData/$selectedDifficulty.json');
						//var jsonData:Song = Json.parse(beatmapFileData.readString(beatmapFileData.readAll().length));
						//sections = jsonData.sectionData;
						//trace(beatmapFileData.readString(beatmapFileData.readAll().length - 1));
						var beatmapJsonData:Song = Json.parse(beatmapFileData.readAll().toString());
						sections = beatmapJsonData.sectionData;
						if(sections.length <= currentSection + 1) for(i in sections.length...(currentSection + 2)) sections[i] = {sectionNotes: [], sectionBPM: songBPM, sectionBeats: 4};
						else sectionNotes = beatmapJsonData.sectionData[currentSection];
						swapSection(currentSection, 0);
						songBPMInput.value = beatmapJsonData.initialBPM;
						var notes:Int = 0;
						for (section in sections)
							for (note in section.sectionNotes)
								notes++;
						difficultyRating = notes / (thisSong.length / 1000) / 1.5;
					} else {
						//File.write('assets/beatmaps/$selectedBeatmap/beatmapData/$selectedDifficulty.json');
						trace('creating new file');
						File.saveContent('assets/beatmaps/$selectedBeatmap/beatmapData/$selectedDifficulty.json', '{"sectionData": [{"sectionNotes": [], "sectionBPM": 60, "sectionBeats": 4}], "initialBPM": 60}');
					}
				}
			}
		}
	}

	function save(){
		var contentToSave:Song = {sectionData: sections, initialBPM: songBPM};
		File.saveContent('assets/beatmaps/$selectedBeatmap/beatmapData/$selectedDifficulty.json', Json.stringify(contentToSave, null, "\t"));
		trace('file saved. contents: ' + Json.stringify(contentToSave, null, "\t"));
	}
	#end

	var timeText = new FlxText(350, 80, 0, '', 12);

	var difficultyText = new FlxText(350, 600, 0, '', 12);

	var line:FlxSprite = new FlxSprite(180, 40);
	var bg:FlxTypedGroup<Dynamic>;

	override public function create()
	{

		FlxG.camera.fade(FlxColor.BLACK, 0.5, true);

		add(steps);
		updateSteps(stepCrochet);

		var timeLabel = new FlxText(350, 60, 0, 'Time:', 12);
		add(timeLabel);
		add(timeText);

		var difficultyLabel = new FlxText(350, 580, 0, 'Difficulty:', 12);
		add(difficultyLabel);
		add(difficultyText);

		super.create();

		propertiesBG.makeGraphic(600, 300, 0x5F5F5F, true);
		//FlxSpriteUtil.drawRoundRect(propertiesBG, 580, 20, 600, 300, 30, 30, 0x5F5F5F);
		propertiesBG.updateHitbox();
		add(propertiesBG);
		

		var labelBPM:FlxText = new FlxText(songBPMInput.x - 90, songBPMInput.y, 90, 'BPM', 10);
		add(songBPMInput);
		add(labelBPM);

		selectedDifficultyInput.textField.textColor = 0x000000;
		selectedDifficultyInput.textField.background = true;
		selectedDifficultyInput.textField.backgroundColor = 0xFFFFFF;
		selectedDifficultyInput.textField.border = true;
		selectedDifficultyInput.textField.borderColor = 0x2A2A2A;

		selectedDifficultyInput.onChange.add(function() selectedDifficulty = selectedDifficultyInput.text);
		selectedDifficultyInput.onFocusGained.add(function() beatmapInput = true);
		selectedDifficultyInput.onFocusLost.add(function() beatmapInput = false);

		add(selectedDifficultyInput);

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
			sectionNotes = {sectionNotes: [], sectionBPM: songBPM, sectionBeats: 4};
			sections = [{sectionNotes: [], sectionBPM: songBPM, sectionBeats: 4}];
			swapSection(0, 0);
			difficultyRating = 0;
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
		loadSong.scale.x = 90 / loadSong.width;
		add(loadSong);

		var loadFile:FlxButton = new FlxButton(1000, 100, 'Load Beatmap', function() #if sys load(true) #else trace('kys') #end);
		loadFile.scale.x = 90 / loadFile.width;
		add(loadFile);

		var saveFile:FlxButton = new FlxButton(1000, 130, 'Save Beatmap', function() #if sys save() #else trace('kys') #end);
		saveFile.scale.x = 90 / loadFile.width;
		add(saveFile);

		line.makeGraphic(160, 4, FlxColor.GREEN);
		add(line);
	}

	function updateSustains(lane:Int, step:Float){
		var correspondingSustain = renderedSustains.getFirst(function(sustain) return (sustain.ID == lane * 10000 + Std.int(step * 100)));
		var correspondingNote:Note = {lane: -1, step: -1, sustainLength: 0};
		for(i in sectionNotes.sectionNotes) if(i.lane == lane && i.step == step){
			correspondingNote = i;
		}
		if(correspondingSustain == null){
			var sustain:FlxSprite = new FlxSprite(196 + lane * 40, 50 + step * 40, 'assets/images/receptors/BlueTrail.png');
			sustain.scale.y = correspondingNote.sustainLength * 40;
			sustain.scale.x = 2;
			sustain.updateHitbox();
			sustain.ID = lane * 10000 + Std.int(step * 100);
			renderedSustains.add(sustain);
		} else {
			if(correspondingNote.sustainLength == 0) renderedSustains.remove(correspondingSustain);
			else {
				correspondingSustain.scale.y = correspondingNote.sustainLength * 40;
				correspondingSustain.updateHitbox();
			}
		}
	}

	var noteHitPlayBack:Array<Note> = [];

	override public function update(elapsed:Float)
	{
		if(songBPMInput.value != songBPM){
			songBPM = songBPMInput.value;
			time = currentSection * (60 / songBPM) * 4000;
		}

		if(thisSong.playing){
			time += elapsed * 1000;
			timeText.text = '${Math.round(time) / 1000} / ${thisSong.length / 1000}';
			for (i in noteHitPlayBack)
			{
				if ((i.step * ((60 / songBPM) * 4000 / 16)) <= (time - (currentSection * 60 / songBPM * 4000)))
				{
					noteHitPlayBack.remove(i);
					FlxG.sound.play('assets/sounds/hitsound.ogg');
				}
			}
		}

		line.y = 30 + (40 * 16 * ((time - (currentSection * 60 / songBPM * 4000)) / (60 / songBPM * 4000)));

		if (time >= ((currentSection + 1) * (60 / songBPM) * 4000)){
			swapSection(currentSection, currentSection + 1);
		}

		super.update(elapsed);

		timeText.text = '${Math.round(time) / 1000} / ${thisSong.length / 1000}';

		difficultyText.text = '${Math.floor(difficultyRating * 100) / 100} stars';


		if (FlxG.keys.justPressed.RIGHT){
			if(FlxG.keys.pressed.CONTROL && stepCrochet < 128) updateSteps(stepCrochet * 2);
			else swapSection(currentSection, currentSection + 1);
		}
		if (FlxG.keys.justPressed.LEFT){
			if(FlxG.keys.pressed.CONTROL && stepCrochet > 1) updateSteps(Std.int(stepCrochet / 2));
			else if(currentSection > 0) swapSection(currentSection, currentSection - 1);
		}
		if (FlxG.keys.justPressed.SPACE){
			#if html5 if(beatmapInput){
				selectedBeatmapInput.text += ' ';
				selectedBeatmapInput.setSelection(selectedBeatmapInput.text.length, selectedBeatmapInput.text.length);
			} else #end if (thisSong != null) {
				if (!thisSong.playing){
					thisSong.play(false, time);
					noteHitPlayBack = sectionNotes.sectionNotes.copy();
					for(i in noteHitPlayBack){
						if ((i.step * ((60 / songBPM) * 4000 / 16)) < (time - (currentSection * 60 / songBPM * 4000))){
							noteHitPlayBack.remove(i);
						}
					}
				} else {
					trace('stopped song');
					thisSong.stop();
				}
			}
		}
		if (FlxG.keys.justPressed.E && !beatmapInput){
			sectionNotes.sectionNotes[sectionNotes.sectionNotes.length - 1].sustainLength += (1/stepCrochet * 16);
			updateSustains(sectionNotes.sectionNotes[sectionNotes.sectionNotes.length - 1].lane, sectionNotes.sectionNotes[sectionNotes.sectionNotes.length - 1].step);
		}
		if (FlxG.keys.justPressed.Q && !beatmapInput){
			if(Std.int(sectionNotes.sectionNotes[sectionNotes.sectionNotes.length - 1].sustainLength) >= (1/stepCrochet * 16)){
				sectionNotes.sectionNotes[sectionNotes.sectionNotes.length - 1].sustainLength -= (1 / stepCrochet * 16);
				updateSustains(sectionNotes.sectionNotes[sectionNotes.sectionNotes.length - 1].lane, sectionNotes.sectionNotes[sectionNotes.sectionNotes.length - 1].step);
			}
		}
		if (FlxG.keys.pressed.ESCAPE)
			FlxG.switchState(new InitState());
	}
}
