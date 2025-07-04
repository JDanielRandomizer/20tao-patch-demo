package states;

import crowplexus.iris.Iris;
import backend.game.GameData.MusicBeatState;
import backend.utils.DialogueUtil;
import backend.song.*;
import backend.song.SongData.EventSong;
import backend.song.SongData.SwagSong;
import backend.song.SongData.SwagSection;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import objects.*;
import objects.hud.*;
import objects.note.*;
import objects.dialogue.Dialogue;
import shaders.*;
import states.editors.*;
import states.menu.*;
import subStates.*;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.FlxG;
import lime.app.Application;

#if TOUCH_CONTROLS
import objects.mobile.Hitbox;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	// song stuff
	public static var EVENTS:EventSong;
	public static var SONG:SwagSong;
	public static var songDiff:String = "normal";
	// more song stuff
	public var inst:FlxSound;
	public var vocals:FlxSound;
	public var vocalsOpp:FlxSound;
	public var musicList:Array<FlxSound> = [];

	public static var songLength:Float = 0;

	// to avoid updating discord rpc each frame, it only updates each second
	private var discordUpdateTime:Float = 0;
	
	// story mode stuff
	public static var playList:Array<String> = [];
	public static var curWeek:String = '';
	public static var isStoryMode:Bool = false;
	public static var weekScore:Int = 0;

	// extra stuff
	public static var health:Float = 1;
	public static var blueballed:Int = 0;
	public static var assetModifier:String = "base";
	
	public static var countdownModifier:String = "base";
	// score, misses, accuracy and other stuff
	// are on the Timings.hx class!!

	// hscript!!
	public var loadedScripts:Array<Iris> = [];
	
	// objects
	public var stageBuild:Stage;
	public var cinematic:CinematicGroup;

	public var characters:Array<CharGroup> = [];
	public var dad:CharGroup;
	public var boyfriend:CharGroup;
	public var gf:CharGroup;

	// strumlines
	public static var hasModchart:Bool = false;
	public var strumlines:FlxTypedGroup<Strumline>;
	public var bfStrumline:Strumline;
	public var dadStrumline:Strumline;
	
	var unspawnCount:Int = 0;
	public var unspawnNotes:Array<Note> = [];
	var eventCount:Int = 0;
	public var unspawnEvents:Array<EventNote> = [];
	
	public static var botplay:Bool = false;
	public static var validScore:Bool = true;
	public var ghostTapping:Bool = true;

	public var oldIconEasterEgg:Bool = false;

	// hud
	public var hudBuild:HudClass;
	
	// cameras!!
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camStrum:FlxCamera;
	public var camOther:FlxCamera; // used so substates dont collide with camHUD.alpha or camHUD.visible
	
	public static var cameraSpeed:Float = 1.0;
	public static var defaultCamZoom:Float = 1.0;
	public static var beatCamZoom:Float = 0.0;
	public static var extraCamZoom:Float = 0.0;
	public static var forcedCamPos:Null<FlxPoint>;
	public static var forcedCamSection:String = "none";
	public var camZoomTween:FlxTween;
	public var curSection:SwagSection;

	public static var camFollow:FlxObject = new FlxObject();

	public static var playedCutscene:Bool = false;
	public static var startedCountdown:Bool = false;
	public static var startedSong:Bool = false;
	
	public static var instance:PlayState;
	
	// paused
	public static var paused:Bool = false;

	// these are variables that are used to support old style FNF camera zoom instead of tweens
	// to use simply set isClassicZoom to true and make an event to change zoom with no duration
	var isClassicZoom:Bool = false;
	var classicZoom:Float = 1.0;

	// This map holds which shaders are loaded, to help with disabling and enabling them in the options!
	var tempShaders:Map<String,Array<BitmapFilter>> = [
		"camGame" => [],
		"camHUD" => [],
		"camStrum" => []
	];

	#if TOUCH_CONTROLS
	var hitbox:Hitbox;
	#end

	// Hello my fellas
	public static var cameraZoomTween:FlxTween;
	public var pressedNotesRow:Array<Array<String>> = [[], []]; // jeito bem ruim que achei para fazer isso funcionar (pelo menos nao e tao mal otimizado (acho que nem e mal otimzado e, sei la, depois o guinea olha e me xinga))
	public static var moveCamWithStrum:Bool = true;

	public static function resetStatics()
	{
		health = 1;
		cameraSpeed = 1.0;
		defaultCamZoom = 1.0;
		beatCamZoom = 0.0;
		extraCamZoom = 0.0;
		forcedCamPos = null;
		forcedCamSection = "none";
		paused = false;
		moveCamWithStrum = !(SONG.song == 'papai-calabreso');
		
		hasModchart = false;
		validScore = true;
		
		Timings.init();

		var pixelSongs:Array<String> = [
		];
		
		assetModifier = "base";
		countdownModifier = "base";
		startedCountdown = false;
		startedSong = false;
		
		if(SONG == null) return;
		switch(SONG.song) {
			case 'silly-beta':
				assetModifier = 'quedas';
				countdownModifier = "quedas"; 
		}
	}
	
	public static function resetSongStatics()
	{
		blueballed = 0;
		playedCutscene = false;
	}

	override public function create()
	{
		super.create();
		instance = this;

		while(FlxG.sound.music.playing)
			CoolUtil.playMusic();

		resetStatics();

		// loading scripts
		var scriptPaths:Array<String> = Paths.getScriptArray(SONG.song);

		#if !sys
		// use this to run scripts in HTML5 or other non-sys targets
		//scriptPaths.push("songs/bopeebo/script.hxc");
		#end

		trace(SONG.song);

		for(path in scriptPaths)
		{
			trace('loaded: $path');

			var newScript:Iris = new Iris(Paths.script('$path'), {name: path, autoRun: true, autoPreset: true});
			loadedScripts.push(newScript);
		}
		setScript("this", instance);

		unspawnNotes = ChartLoader.getChart(SONG);
		unspawnEvents = ChartLoader.getEvents(EVENTS);
		
		// adjusting the conductor
		Conductor.setBPM(SONG.bpm);
		Conductor.mapBPMChanges(SONG);
		curSection = SONG.notes[0];
		
		// setting up the cameras
		camGame = new FlxCamera();
		camGame.visible = !(SONG.song == 'papai-calabreso' || SONG.song == 'slk-tralaleiro-tralala-ta-todo-safadeza' || SONG.song == 'silly-beta' || SONG.song == 'paralanches' || SONG.song == 'buraquinho' || SONG.song == 'calvice-prematura' || SONG.song == 'chaves' || SONG.song == 'como-cantar'); // XD ?
		
		camHUD = new FlxCamera();
		camHUD.bgColor.alphaFloat = 0;
		
		camStrum = new FlxCamera();
		camStrum.bgColor.alpha = 0;
		
		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;
		
		// adding the cameras
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camStrum, false);
		FlxG.cameras.add(camOther, false);
		
		// default camera
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		
		//camGame.zoom = 0.6;
		callScript("create");
		
		stageBuild = new Stage();
		stageBuild.reloadStageFromSong(SONG.song, SONG.gfVersion);
		add(stageBuild);

		classicZoom = defaultCamZoom;
		
		camGame.zoom = defaultCamZoom;
		hudBuild = new HudClass();
		hudBuild.setAlpha(0);
		
		/*
		*	if you want to change characters
		*	use changeChar(charVar, "new char");
		*	remember to put false after "new char" for non-singers (like gf)
		*	so it doesnt reload the icons
		*/
		callScript("createPreCharacters");

		gf = new CharGroup(false, stageBuild.gfVersion);
		dad = new CharGroup(false, SONG.player2);
		boyfriend = new CharGroup(true, SONG.player1);

		preloadEvents(unspawnEvents);

		characters.push(gf);
		characters.push(dad);
		characters.push(boyfriend);
		for(char in characters) {
			changeChar(char, char.curChar, (char != gf));
		}

		changeStage(stageBuild.curStage);
		
		// basic layering ig
		var addList:Array<FlxBasic> = [];
		
		for(char in characters)
		{
			if(char.curChar == gf.curChar && char != gf && gf.visible)
			{
				changeChar(char, gf.curChar);
				char.setPos(stageBuild.gfPos.x, stageBuild.gfPos.y);
				gf.visible = false;
			}
			
			addList.push(char);
		}
		addList.push(stageBuild.foreground);
		
		for(item in addList)
			add(item);
		
		cinematic = new CinematicGroup();
		cinematic.cameras = [camHUD];
		add(cinematic);
		
		hudBuild.cameras = [camHUD];
		add(hudBuild);
		
		// strumlines
		strumlines = new FlxTypedGroup();
		strumlines.cameras = [camStrum];
		add(strumlines);

		ghostTapping = SaveData.data.get('Ghost Tapping');
		var downscroll:Bool = SaveData.data.get("Downscroll");
		var doidoEasterEgg:Bool = FlxG.random.bool(0);

		var noteskins:Array<String> = [];

		for(character in [dad.curChar, boyfriend.curChar]) {
			if(doidoEasterEgg) {
				noteskins.push("doido");
				continue;
			}
			
			switch(character) {
				// case 'girlfriend-opponent':
				// 	if(SONG.song == 'como-cantar') noteskins.push("tutorial");
				default:
					noteskins.push(assetModifier);
			}
		}

		dadStrumline = new Strumline(0, dad, downscroll, false, true, noteskins[0]);
		dadStrumline.ID = 0;
		strumlines.add(dadStrumline);
		
		bfStrumline = new Strumline(0, boyfriend, downscroll, true, false, noteskins[1]);
		bfStrumline.ID = 1;
		strumlines.add(bfStrumline);
		
		for(strumline in strumlines.members)
		{
			if(strumline.customData) continue;
			strumline.x = setStrumlineDefaultX()[strumline.ID];
			strumline.scrollSpeed = SONG.speed;
			strumline.updateHitbox();
		}

		hudBuild.updateHitbox(bfStrumline.downscroll);

		var daSong:String = SONG.song.toLowerCase();

		inst = new FlxSound();
		inst.loadEmbedded(Paths.inst(daSong, songDiff), false, false);

		vocals = new FlxSound();
		if(SONG.needsVoices)
			vocals.loadEmbedded(Paths.vocals(daSong, songDiff, "-player"), false, false);

		songLength = inst.length;
		function addMusic(music:FlxSound):Void
		{
			FlxG.sound.list.add(music);

			if(music.length > 0)
			{
				musicList.push(music);

				if(music.length < songLength)
					songLength = music.length;
			}

			music.play();
			music.stop();
		}

		addMusic(inst);
		addMusic(vocals);

		// adding opponent vocals
		if(SONG.needsVoices
		&& Paths.songPath(daSong, 'Voices', songDiff, '-opp').endsWith('-opp'))
		{
			vocalsOpp = new FlxSound();
			vocalsOpp.loadEmbedded(Paths.vocals(daSong, songDiff, '-opp'), false, false);
			addMusic(vocalsOpp);
		}

		Conductor.songPos = -Conductor.crochet * 5;
		
		// setting up the camera following
		followCamSection(SONG.notes[0]);
		FlxG.camera.focusOn(camFollow.getPosition());

		
		
		for(note in unspawnNotes)
		{
			var thisStrumline = dadStrumline;
			for(strumline in strumlines)
				if(note.strumlineID == strumline.ID)
					thisStrumline = strumline;
			
			var noteAssetMod:String = noteskins[1];

			if(thisStrumline == dadStrumline)
				noteAssetMod = noteskins[0];
			
			note.updateData(note.songTime, note.noteData, note.noteType, noteAssetMod);
			note.reloadSprite();
			note.setSongOffset();
			
			thisStrumline.addSplash(note);
		}
		for(event in unspawnEvents) {
			event.setSongOffset();
		}
		
		// Updating Discord Rich Presence and making notes invisible before the countdown
		for(strumline in strumlines.members)
		{
			var strumMult:Int = (strumline.downscroll ? 1 : -1);
			for(strum in strumline.strumGroup)
			{
				strum.y += CoolUtil.noteWidth() * 0.6 * strumMult;
				strum.alpha = 0.0001;
			}
		}

		#if TOUCH_CONTROLS
		hitbox = new Hitbox(noteskins[1]);
		hitbox.cameras = [camOther];
		add(hitbox);
		#end
		
		#if VIDEOS_ALLOWED
		startVideo("test");
		#end

		if(hasCutscene() && !playedCutscene)
		{
			playedCutscene = true;
			switch(SONG.song)
			{
				#if VIDEOS_ALLOWED
				case 'useless':
					startVideo("test");
				#end

				default:
					startCountdown();
					// startDialogue(DialogueUtil.loadDialogue(SONG.song, songDiff));
			}
		}
		else
			startCountdown();

		callScript("createPost");
		callScript("updatedText"); // calabreso

		switch(SONG.song)
		{
			case "silly-beta":
				FlxTween.tween(gf.char, {y: gf.char.y-30, alpha: 0.6}, 2.5, {ease: FlxEase.sineInOut, type: PINGPONG});
		}
	}

	public function startCountdown()
	{
		#if TOUCH_CONTROLS
		createPad("pause", [camOther]);
		hitbox.toggleHbx(true);
		#end

		var daCount:Int = 0;
		
		var countTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			Conductor.songPos = -Conductor.crochet * (4 - daCount);
			
			if(daCount == 0)
			{
				startedCountdown = true;
				for(strumline in strumlines.members)
				{
					for(strum in strumline.strumGroup)
					{	
						// dad's notes spawn backwards
						var strumMult:Int = (strumline.isPlayer ? strum.strumData : 3 - strum.strumData);

						// actual tween
						FlxTween.tween(strum, {y: strum.initialPos.y, alpha: 0.8}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeOut,
							startDelay: Conductor.crochet / 2 / 1000 * strumMult,
						});
					}
				}
			}
			
			callScript("countDownTickle", [daCount, Conductor.crochet * 2 / 1000]);
			// when the girl say "one" the hud appears
			if(daCount == 2)
			{
				hudBuild.setAlpha(1, Conductor.crochet * 2 / 1000);
			}

			if(daCount == 4)
			{
				startSong();
			}

			if(daCount != 4)
			{
				var soundName:String = ["3", "2", "1", "Go"][daCount];
				
				var soundPath:String = countdownModifier;
				if(!Paths.fileExists('sounds/countdown/$soundPath/intro$soundName.ogg'))
					soundPath = 'base';
				
				FlxG.sound.play(Paths.sound('countdown/$soundPath/intro$soundName'));
				
				if(daCount >= 1)
				{
					var countName:String = ["ready", "set", "go"][daCount - 1];
					
					var spritePath:String = countdownModifier;
					if(!Paths.fileExists('images/hud/$spritePath/$countName.png'))
						spritePath = 'base';

					var countSprite = new FlxSprite();
					countSprite.loadGraphic(Paths.image('hud/$spritePath/$countName'));
					switch(spritePath)
					{
						case "pixel":
							countSprite.scale.set(6.5,6.5);
							countSprite.antialiasing = false;
						default:
							countSprite.scale.set(0.65,0.65);
					}
					countSprite.updateHitbox();
					countSprite.screenCenter();
					countSprite.cameras = [camHUD];
					hudBuild.add(countSprite);

					FlxTween.tween(countSprite, {alpha: 0}, Conductor.stepCrochet * 2.8 / 1000, {
						startDelay: Conductor.stepCrochet * 1 / 1000,
						onComplete: function(twn:FlxTween)
						{
							countSprite.destroy();
						}
					});
				}
			}

			daCount++;
		}, 5);
	}
	
	public function startDialogue(dialData:DialogueData)
	{
		if(dialData.pages.length > 0) {
			Logs.print('song ${SONG.song} has found dialogue!');
			
			#if TOUCH_CONTROLS
			createPad("dialogue", [camOther]);
			#end

			new FlxTimer().start(0.45, function(tmr:FlxTimer)
			{
				var dial = new Dialogue();
				dial.finishCallback = function() {
					#if TOUCH_CONTROLS
					createPad("blank");
					#end
					
					CoolUtil.playMusic();
					startCountdown();
					remove(dial);
				};
				dial.cameras = [camHUD];
				dial.load(dialData);
				add(dial);
			});
		}
		else {
			Logs.print('song ${SONG.song} has not found dialogue :(', WARNING);
			startCountdown();
		}
	}

	#if VIDEOS_ALLOWED
	public function startVideo(key:String, onEnd:Bool = false):Void
	{
		openSubState(new VideoPlayerSubState(key, function() {
			if(onEnd)
				endSong();
			else
				startCountdown();
		}));
	}
	#end
	
	public function hasCutscene():Bool
	{
		return switch(SaveData.data.get('Cutscenes'))
		{
			default: true;
			case "FREEPLAY OFF": isStoryMode;
			case "OFF": false;
		}
	}

	public function startSong()
	{
		startedSong = true;
		for(music in musicList)
		{
			music.stop();
			music.play();

			if(paused) {
				music.pause();
			}
		}

		callScript('startedShit');
	}

	override function openSubState(state:FlxSubState)
	{
		super.openSubState(state);
		if(startedSong)
		{
			for(music in musicList)
			{
				music.pause();
			}
		}
	}

	override function closeSubState()
	{
		CoolUtil.activateTimers(true);
		super.closeSubState();
		if(startedSong)
		{
			for(music in musicList)
			{
				music.play();
			}
			syncSong();
		}
	}

	// check if you actually hit it
	public function checkNoteHit(note:Note, strumline:Strumline)
	{
		if(!note.mustMiss)
			onNoteHit(note, strumline);
		else
			onNoteMiss(note, strumline);
	}
		
	// actual note functions

	var miniArray:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	function onNoteHit(note:Note, strumline:Strumline)
	{
		pressedNotesRow[note.strumlineID].push(miniArray[note.noteData]);

		var thisStrum = strumline.strumGroup.members[note.noteData];
		var thisChar = strumline.character.char;
		if(note.noteType == "gf note" && gf.char != null)
			thisChar = gf.char;

		// anything else
		note.gotHeld = true;
		note.gotHit = true;
		note.missed = false;
		if(!note.isHold)
			note.visible = false;
		else
			note.setAlpha();

		if(note.mustMiss) return;

		callScript("onNoteHit", [note, strumline]);

		thisStrum.playAnim("confirm", true);

		// when the player hits notes
		if(strumline.isPlayer)
		{
			vocals.volume = 1;
			popUpRating(note, strumline, false);
			if(!note.isHold)
				CoolUtil.playHitSound();
		}
		else
		{
			if(vocalsOpp == null)
				vocals.volume = 1;
		}
		
		switch(note.noteType)
		{
			case "warn note":
				if(!thisChar.isPlayer)
					CoolUtil.playHitSound("OSU", 1.0);
		}

		if(!note.isHold)
		{
			// splashes for hold notes
			if(note.hasHoldSplash)
				if(note.children.length > 0)
					strumline.playSplash(note.children[note.children.length - 1], true);

			// regular splashes
			var noteDiff:Float = Math.abs(note.noteDiff());
			if(noteDiff <= Timings.getTimings("sick")[1] || strumline.botplay)
				strumline.playSplash(note);
		}

		if(thisChar != null && !note.isHold)
		{
			if(note.noteType != "no animation" && thisChar.specialAnim != 2)
				thisChar.playNote(note);
		}

		
		if(thisChar != null && !note.isHold)
		{
			if(note.noteType != "no animation" && pressedNotesRow[note.strumlineID].length >= 2)
				ghostDoubleNote(thisChar.isPlayer ? 'boyfriend' : 'dad', pressedNotesRow[note.strumlineID][pressedNotesRow[note.strumlineID].length-2]);
		}
	}

	function onNoteMiss(note:Note, strumline:Strumline, ghostTap:Bool = false)
	{
		pressedNotesRow[note.strumlineID] = [];

		var thisStrum = strumline.strumGroup.members[note.noteData];
		var thisChar = strumline.character.char;
		if(note.noteType == "gf note" && gf.char != null)
			thisChar = gf.char;

		note.gotHit = false;
		note.missed = true;
		note.setAlpha();
		
		// put stuff inside if(onlyOnce)
		var onlyOnce:Bool = false;
		if(!note.isHold)
			onlyOnce = true;
		else
			if(note.isHoldEnd && note.holdHitLength > 0)
				onlyOnce = true;

		// onlyOnce is to prevent the game punishing you for missing a bunch of hold notes pieces
		if(onlyOnce)
		{
			if((strumline.isPlayer || vocalsOpp == null) && !ghostTap)
				vocals.volume = 0;

			callScript("onNoteMiss", [note, strumline, ghostTap]);
			
			FlxG.sound.play(Paths.sound('miss/missnote' + FlxG.random.int(1, 3)), 0.55);
			
			if(thisChar != null && note.noteType != "no animation"
			&& thisChar.specialAnim != 2)
				thisChar.playNote(note, true);
			
			// when the player misses notes
			if(strumline.isPlayer)
				popUpRating(note, strumline, true);
		}
	}
	function onNoteHold(note:Note, strumline:Strumline)
	{
		pressedNotesRow[note.strumlineID] = [];

		// runs until you hold it enough
		if(note.holdHitLength > note.holdLength) return;
		
		var thisStrum = strumline.strumGroup.members[note.noteData];
		var thisChar = strumline.character.char;
		if(note.noteType == "gf note" && gf.char != null)
			thisChar = gf.char;
		
		if(strumline.isPlayer || vocalsOpp == null)
			vocals.volume = 1;
		thisStrum.playAnim("confirm", true);

		callScript("onNoteHold", [note, strumline]);
		
		// DIE!!!
		if(note.mustMiss)
			health -= 0.005;
		
		// playing the hold animation
		if(note.gotHit || thisChar == null || note.holdHitLength > note.holdLength - 60) return;
		
		if(note.noteType != "no animation" && thisChar.specialAnim != 2)
		{
			if(thisChar.curAnimFrame == thisChar.holdLoop
			|| SaveData.data.get("Static Hold Anim"))
				thisChar.playNote(note);

			thisChar.holdTimer = 0;
		}
	}

	var prevRating:Rating = null;
	
	public function popUpRating(note:Note, strumline:Strumline, miss:Bool = false)
	{
		// return;
		var thisChar = strumline.character.char;
		var noteDiff:Float = Math.abs(note.noteDiff());
		if(strumline.botplay)
			noteDiff = 0;
		else
			if(note.isHold && !miss)
			{
				noteDiff = Timings.minTiming;
				var holdPercent:Float = (note.holdHitLength / note.holdLength);
				for(timing in Timings.holdTimings)
					if(holdPercent >= timing[0] && noteDiff > timing[1])
						noteDiff = timing[1];
			}

		var rating:String = Timings.diffToRating(noteDiff);
		var judge:Float = Timings.diffToJudge(noteDiff);

		if(miss)
		{
			rating = "miss";
			judge = Timings.getTimings("miss")[2];
			noteDiff = Timings.getTimings("miss")[1];
		}
		
		var healthJudge:Float = 0.02 * judge;
		if(judge < 0)
			healthJudge *= 2;

		if(miss)
		{
			switch(note.noteType)
			{
				case "warn note":
					healthJudge = -0.5;
	
				case "EX Note":
					startGameOver();
					return;
			}
			switch(SONG.song)
			{
				case 'defeat':
					if(Timings.misses > 5) {
						startGameOver();
						return;
					}
			}
		}

		if(healthJudge < 0)
		{
			if(songDiff == "easy")
				healthJudge *= 0.5;
			if(songDiff == "normal")
				healthJudge *= 1.3;
		}

		// handling health and score
		health += healthJudge;

		if(!miss) {
			var absNoteDiff = (Math.abs(noteDiff) <= 5 ? 0 : Math.abs(noteDiff));
			Timings.score += Math.floor((160 - absNoteDiff) / 160 * 350);
		} else {
			Timings.score -= 100;
		}
		Timings.addAccuracy(judge);

		if(miss)
		{
			Timings.misses++;

			if(Timings.combo > 0)
				Timings.combo = 0;
			Timings.combo--;
		}
		else
		{
			if(Timings.combo < 0)
				Timings.combo = 0;
			Timings.combo++;
			
			// regains your health only if you hold it entirely
			if(note.isHold)
				health += 0.05 * (note.holdHitLength / note.holdLength);
			
			if(rating == "shit")
			{
				// forces a miss anyway
				onNoteMiss(note, strumline);
			}
		}
		
		hudBuild.updateText();
		callScript("updatedText");
		
		var daRating = new Rating(rating, Timings.combo, note.assetModifier);

		if(SaveData.data.get("Single Rating"))
		{
			if(prevRating != null)
				prevRating.kill();
			
			prevRating = daRating;
		}
		
		if(SaveData.data.get("Ratings on HUD"))
		{
			hudBuild.ratingGrp.add(daRating);
			
			for(item in daRating.members)
				item.cameras = [camHUD];
			
			var daX:Float = (FlxG.width / 2);
			if(SaveData.data.get("Middlescroll"))
				daX -= FlxG.width / 4;

			daRating.setPos(daX, SaveData.data.get('Downscroll') ? FlxG.height - 100 : 100);
		}
		else
		{
			add(daRating);
			daRating.setPos(
				thisChar.x + thisChar.ratingsOffset.x,
				thisChar.y + thisChar.ratingsOffset.y
			);
		}
	}
	
	public var pressed:Array<Bool> 		= [];
	public var justPressed:Array<Bool> 	= [];
	public var released:Array<Bool> 	= [];
	
	var playerSinging:Bool = false;

	function strToChar(str:String):CharGroup
	{
		return switch(str)
		{
			default: dad;
			case 'bf'|'boyfriend': 	boyfriend;
			case 'gf'|'girlfriend': gf;
		}
	}

	function stringToCam(str:String):FlxCamera {
		return switch(str.toLowerCase())
		{
			default: camGame;
			case 'camhud'|'hud': camHUD;
			case 'camstrum'|'strum': camStrum;
			//case 'camother'|'other': camOther; // meant for transitions only
		}
	}
	
	override function update(elapsed:Float)
	{
		callScript("update", [elapsed]);
		super.update(elapsed);
		var followLerp:Float = cameraSpeed * 5 * elapsed;
		if(followLerp > 1) followLerp = 1;
		
		CoolUtil.camPosLerp(camGame, camFollow, followLerp);
		
		if(Controls.justPressed(PAUSE))
			pauseSong();

		if(Controls.justPressed(RESET))
			startGameOver();
		
		if(SaveData.data.get("Discord RPC") && !paused)
		{
			discordUpdateTime -= elapsed;
			if(discordUpdateTime <= 0.0)
			{
				discordUpdateTime = 10.0;
				var presenceTxt:String = 'Playing: ${CoolUtil.displayName(SONG.song)} [${songDiff.toUpperCase()}]';
				if(startedSong)
					presenceTxt += ' - ${CoolUtil.posToTimer(Conductor.songPos)} / ${CoolUtil.posToTimer(songLength)}';

				DiscordIO.changePresence(presenceTxt, false);
			}
		}
		
		// no turning back you gotta restart now sorry
		if(botplay && startedSong)
			validScore = false;

		#if !mobile
		if(FlxG.keys.justPressed.SEVEN)
		{
			if(ChartingState.SONG.song != SONG.song)
				ChartingState.curSection = 0;
			
			ChartingState.songDiff = songDiff;

			ChartingState.SONG = SONG;
			ChartingState.EVENTS = EVENTS;

			desgraca();
			Main.switchState(new ChartingState());
		}

		if(FlxG.keys.justPressed.EIGHT)
		{
			var char = dad;
			if(FlxG.keys.pressed.SHIFT)
				char = boyfriend;
			if(Controls.pressed(CONTROL))
				char = gf;
			
			desgraca();
			Main.switchState(new CharacterEditorState(char.curChar, true));
		}

		if(oldIconEasterEgg)
		{
			if(FlxG.keys.justPressed.NINE
			&& (FlxG.keys.pressed.SHIFT || Controls.pressed(CONTROL))
			&& boyfriend.curChar == "bf")
			{
				var changeBack:Bool = false;
				var curIcon:String = hudBuild.healthBar.icons[1].curIcon;
				if(FlxG.keys.pressed.SHIFT)
				{
					if(curIcon != 'bf-old')
						curIcon = 'bf-old';
					else
						changeBack = true;
				}
				if(Controls.pressed(CONTROL))
				{
					if(curIcon != 'bf-cool')
						curIcon = 'bf-cool';
					else
						changeBack = true;
				}
				if(changeBack)
					curIcon = boyfriend.char.curChar;
				hudBuild.changeIcon(1, curIcon);
			}
		}
		#end
		
		// syncSong
		if(startedCountdown)
			Conductor.songPos += elapsed * 1000;

		pressed = [
			Controls.pressed(LEFT),
			Controls.pressed(DOWN),
			Controls.pressed(UP),
			Controls.pressed(RIGHT),
		];
		justPressed = [
			Controls.justPressed(LEFT),
			Controls.justPressed(DOWN),
			Controls.justPressed(UP),
			Controls.justPressed(RIGHT),
		];
		released = [
			Controls.released(LEFT),
			Controls.released(DOWN),
			Controls.released(UP),
			Controls.released(RIGHT),
		];

		#if TOUCH_CONTROLS
		for(i in 0...CoolUtil.directions.length) {
			if(hitbox.checkButton(CoolUtil.directions[i], PRESSED))
				pressed[i] = true;

			if(hitbox.checkButton(CoolUtil.directions[i], JUST_PRESSED))
				justPressed[i] = true;

			if(hitbox.checkButton(CoolUtil.directions[i], RELEASED))
				released[i] = true;
		}
		#end

		playerSinging = false;

		// playing events
		if(eventCount < unspawnEvents.length)
		{
			var daEvent = unspawnEvents[eventCount];
			if(daEvent.songTime <= Conductor.songPos)
			{
				#if debug
				Logs.print('${daEvent.eventName} // ${daEvent.value1} // ${daEvent.value2} // ${daEvent.value3}');
				#end
				onEventHit(daEvent);
				eventCount++;
			}
		}
		
		// adding notes to strumlines
		if(unspawnCount < unspawnNotes.length)
		{
			var unsNote = unspawnNotes[unspawnCount];
			
			var thisStrumline = dadStrumline;
			for(strumline in strumlines)
				if(unsNote.strumlineID == strumline.ID)
					thisStrumline = strumline;
			
			var spawnTime:Int = 3200;
			if(thisStrumline.scrollSpeed <= 1.5)
				spawnTime *= 2;
			
			if(unsNote.songTime - Conductor.songPos <= spawnTime)
			{
				unsNote.y = FlxG.height * 4;
				thisStrumline.addNote(unsNote);
				unspawnCount++;
			}
		}
		
		// strumline handler!!
		for(strumline in strumlines.members)
		{
			if(strumline.isPlayer)
				strumline.botplay = botplay;
			
			for(strum in strumline.strumGroup)
			{
				// no botplay animations
				if(strumline.isPlayer && !strumline.botplay)
				{
					if(pressed[strum.strumData])
					{
						if(!["pressed", "confirm"].contains(strum.animation.curAnim.name))
							strum.playAnim("pressed");
					}
					else
						strum.playAnim("static");
					
					if(strum.animation.curAnim.name == "confirm")
						playerSinging = true;
				}
				else // how botplay handles it
				{
					if(strum.animation.curAnim.name == "confirm"
					&& strum.animation.curAnim.finished)
						strum.playAnim("static");
				}
			}

			for(strumline in strumlines)
			{
				if(SONG.song == "exploitation")
				{
					for(strum in strumline.strumGroup)
						strum.angle += elapsed * (curStep % 16 <= 1 ? 128 : 8) * (strum.strumData % 2 == 0 ? 1 : -1);
					for(note in strumline.allNotes)
					{
						note.noteAngle = Math.sin((Conductor.songPos - note.songTime) / 100) * 10 * (strumline.isPlayer ? 1 : -1);
					}
				}
			}

			updateNotes();
			
			if(justPressed.contains(true) && !strumline.botplay && strumline.isPlayer)
			{
				for(i in 0...justPressed.length)
				{
					if(justPressed[i])
					{
						var possibleHitNotes:Array<Note> = []; // gets the possible ones
						var canHitNote:Note = null;
						
						for(note in strumline.noteGroup)
						{
							var noteDiff:Float = note.noteDiff();
							
							var minTiming:Float = Timings.minTiming;
							if(note.mustMiss)
								minTiming = Timings.getTimings("good")[1];
							
							if(noteDiff <= minTiming && !note.missed && !note.gotHit && note.noteData == i)
							{
								if(note.mustMiss
								&& Conductor.songPos >= note.songTime + Timings.getTimings("sick")[1])
								{
									continue;
								}
								
								possibleHitNotes.push(note);
								canHitNote = note;
							}
						}
						
						// if the note actually exists then you got it
						if(canHitNote != null)
						{
							for(note in possibleHitNotes)
							{
								if(note.songTime < canHitNote.songTime)
									canHitNote = note;
							}

							checkNoteHit(canHitNote, strumline);
						}
						else // you ghost tapped lol
						{
							if(!ghostTapping && startedCountdown)
							{
								vocals.volume = 0;

								var note = new Note();
								note.updateData(0, i, "none", assetModifier);
								//note.reloadSprite();
								onNoteMiss(note, strumline, true);
							}
						}
					}
				}
			}
		}
		
		for(i in characters)
		{
			var char = i.char;
			if(char.holdTimer != Math.NEGATIVE_INFINITY)
			{
				if(char.holdTimer < char.holdLength)
					char.holdTimer += elapsed;
				else
				{
					if(char.isPlayer && playerSinging)
						continue;
					
					char.holdTimer = Math.NEGATIVE_INFINITY;
					char.dance();
				}
			}

			switch(char.curChar)
			{
				case "face":
					var altShit:String = "";
					var daHealth = (health / 2);
					if(!char.isPlayer)
						daHealth = 1 - (health / 2);
					if(daHealth <= 0.3)
						altShit = 'miss';
					if(altShit != char.altIdle)
						char.altSing = char.altIdle = 'miss';
			}
		}
		
		if(startedCountdown)
		{
			var lastSteps:Int = 0;
			for(section in SONG.notes)
			{
				if(curStep >= lastSteps) {
					curSection = section;
					pressedNotesRow = [[], []]; // ignora
				}

				lastSteps += section.lengthInSteps;
			}
			if(curSection != null)
			{
				followCamSection(curSection);

				// if(SONG.song == "tutorial")
				// 	extraCamZoom = CoolUtil.camZoomLerp(extraCamZoom, curSection.mustHitSection ? 0 : 0.5, 3);
			}
		}
		// stuff
		if(forcedCamPos != null)
			camFollow.setPosition(forcedCamPos.x, forcedCamPos.y);

		if(health <= 0)
			startGameOver();

		if(isClassicZoom)
			classicZoom = CoolUtil.camZoomLerp(classicZoom, defaultCamZoom);
		
		// camGame.zoom = (isClassicZoom ? classicZoom : defaultCamZoom) + beatCamZoom + extraCamZoom;
		// beatCamZoom = CoolUtil.camZoomLerp(beatCamZoom, 0);
		camHUD.zoom = CoolUtil.camZoomLerp(camHUD.zoom);
		camStrum.zoom = CoolUtil.camZoomLerp(camStrum.zoom);
		
		health = FlxMath.bound(health, 0, 2); // bounds the health
		callScript("updatePost", [elapsed]);
	}

	public function updateNotes()
	{
		for(strumline in strumlines)
		{
			for(hold in strumline.holdGroup)
			{
				if(hold.scrollSpeed != strumline.scrollSpeed)
				{
					hold.scrollSpeed = strumline.scrollSpeed;
					
					hold.holdClipHeight = hold.noteCrochet * (strumline.scrollSpeed * 0.45) + 2;
					if(!hold.isHoldEnd)
					{
						var holdWidth:Float = hold.frameWidth * hold.scale.x;
						
						if(SaveData.data.get("Split Holds"))
							hold.holdClipHeight *= 0.7;
						
						hold.setGraphicSize(
							Math.floor(holdWidth),
							Std.int(hold.holdClipHeight)
						);
					}
					hold.updateHitbox();
				}
			}
			
			for(note in strumline.allNotes)
			{
				if(!paused)
				{
					var despawnTime:Int = 300;
					
					if(Conductor.songPos >= note.songTime + Conductor.inputOffset + note.holdLength + Conductor.crochet + despawnTime)
					{
						if(!note.gotHit && !note.missed && !note.mustMiss && !strumline.botplay)
							onNoteMiss(note, strumline);
						
						note.clipRect = null;
						strumline.removeNote(note);
						note.destroy();
						continue;
					}

					note.setAlpha();
				}
				note.updateHitbox();
				note.offset.x += note.frameWidth * note.scale.x / 2;
				if(note.isHold)
				{
					note.offset.y = 0;
					note.origin.y = 0;
				}
				else
					note.offset.y += note.frameHeight * note.scale.y / 2;
			}
		
			for(note in strumline.noteGroup)
			{
				var thisStrum = strumline.strumGroup.members[note.noteData];
				
				// follows the strum
				var offsetX = note.noteOffset.x;
				var offsetY = (note.songTime - Conductor.songPos) * (strumline.scrollSpeed * 0.45);
				
				var noteAngle:Float = (note.noteAngle + thisStrum.strumAngle);
				if(strumline.downscroll)
					noteAngle += 180;
				
				note.angle = thisStrum.angle;
				if(!strumline.pauseNotes) {
					CoolUtil.setNotePos(note, thisStrum, noteAngle, offsetX, offsetY);
				}
				
				// alings the hold notes
				for(hold in note.children)
				{
					var offsetY = hold.noteCrochet * (strumline.scrollSpeed * 0.45) * hold.ID;
					
					hold.angle = -noteAngle;
					CoolUtil.setNotePos(hold, note, noteAngle, offsetX, offsetY);
				}
				
				if(!paused)
				{
					// hitting / missing notes automatically
					if(strumline.botplay)
					{
						if(note.songTime - Conductor.songPos <= 0 && !note.gotHit && !note.mustMiss)
							checkNoteHit(note, strumline);
					}
					else
					{
						if(Conductor.songPos >= note.songTime + Timings.getTimings("good")[1]
						&& !note.gotHit && !note.missed && !note.mustMiss)
							onNoteMiss(note, strumline);
					}
					
					// doesnt actually do anything
					if (note.scrollSpeed != strumline.scrollSpeed)
						note.scrollSpeed = strumline.scrollSpeed;
				}
			}
			
			if(!paused)
			{
				for(hold in strumline.holdGroup)
				{
					var holdParent = hold.parentNote;
					if(holdParent != null)
					{
						var thisStrum = strumline.strumGroup.members[hold.noteData];
						
						if(holdParent.gotHeld && !hold.missed)
						{
							hold.gotHeld = true;
							hold.holdHitLength = (Conductor.songPos - hold.songTime);
							
							// calculating the clipping by how much you held the note
							if(!strumline.pauseNotes)
							{
								var daRect = new FlxRect(0, 0,
									hold.frameWidth,
									hold.frameHeight
								);
								
								var holdID:Float = hold.ID;
								
								if(SaveData.data.get("Split Holds"))
									holdID -= 0.2;

								var minSize:Float = hold.holdHitLength - (hold.noteCrochet * holdID);
								var maxSize:Float = hold.noteCrochet;
								if(minSize > maxSize)
									minSize = maxSize;
								
								if(minSize > 0)
									daRect.y = (minSize / maxSize) * (hold.holdClipHeight / hold.scale.y);
								
								hold.clipRect = daRect;
							}
							
							var notPressed = (!pressed[hold.noteData] && !strumline.botplay && strumline.isPlayer);
							var holdPercent:Float = (hold.holdHitLength / holdParent.holdLength);
			
							if(hold.isHoldEnd && !notPressed)
								onNoteHold(hold, strumline);
							
							if(notPressed || holdPercent >= 1.0)
							{
								hold.gotReleased = true;
								if(holdPercent > 0.3)
								{
									if(hold.isHoldEnd && !hold.gotHit)
										onNoteHit(hold, strumline);
									hold.missed = false;
									hold.gotHit = true;
								}
								else
									onNoteMiss(hold, strumline);
							}
						}
						
						if(holdParent.missed && !hold.missed)
							onNoteMiss(hold, strumline);
					}
				}
			}
		}
	}
	
	public function followCamSection(sect:SwagSection):Void
	{
		var char:Character = dadStrumline.character.char;
		var offset:FlxPoint = stageBuild.dadCam;

		if(sect != null)
		{
			if(forcedCamSection != "none")
				char = strToChar(forcedCamSection).char;
			else if(sect.mustHitSection)
				char = bfStrumline.character.char;
		}

		if(char == boyfriend.char)
			offset = stageBuild.bfCam;
		else if(char == gf.char)
			offset = stageBuild.gfCam;


		var offset:FlxPoint = stageBuild.dadCam;

		followCamera(char, offset.x, offset.y);
	}

	// o troco  abaixo veio do guinea (ele quis mais credito mesmo que ja e programador "cada mais credito ganho mais dinhero")
	var camNoteOffsets = [0,0]; 
	public static var camNoteAdd = 15;
	public function followCamera(?char:Character, ?offsetX:Float = 0, ?offsetY:Float = 0)
	{
		camFollow.setPosition(0,0);

		if(char != null)
		{
			var playerMult:Int = (char.isPlayer ? -1 : 1);

			camFollow.setPosition(char.getMidpoint().x + (200 * playerMult), char.getMidpoint().y - 20);

			camFollow.x += char.cameraOffset.x * playerMult;
			camFollow.y += char.cameraOffset.y;
		}

		camFollow.x += offsetX;
		camFollow.y += offsetY;

		if(moveCamWithStrum) {
			camNoteOffsets = switch(char.animation.curAnim.name)
			{
				case "singUP"|"singUP-alt"|"singUPmiss"|"singUP-loop": [0, -camNoteAdd];
				case "singDOWN"|"singDOWN-alt"|"singDOWNmiss"|"singDOWN-loop": [0, camNoteAdd];
				case "singLEFT"|"singLEFT-alt"|"singLEFTmiss"|"singLEFT-loop": [-camNoteAdd, 0];
				case "singRIGHT"|"singRIGHT-alt"|"singRIGHTmiss"|"singRIGHT-loop": [camNoteAdd, 0];
				default: [0,0];
			}
			camFollow.x += camNoteOffsets[0];  
			camFollow.y += camNoteOffsets[1];
		}
	}

	override function beatHit()
	{
		super.beatHit();
		for(change in Conductor.bpmChangeMap)
			if(curStep >= change.stepTime && Conductor.bpm != change.bpm)
				Conductor.setBPM(change.bpm);

		hudBuild.beatHit(curBeat);
		
		if(curBeat % 4 == 0)
			zoomCamera(0.05, 0.005);

		for(i in characters)
		{
			var char = i.char;
			if(curBeat % 2 == 0 || char.quickDancer)
			{
				var canIdle = (char.holdTimer == Math.NEGATIVE_INFINITY);
				
				if(char.isPlayer && playerSinging)
					canIdle = false;

				if(canIdle)
					char.dance();
			}
		}

		// hey!!
		switch(SONG.song)
		{
			// case "tutorial":
			// 	if([30, 46].contains(curBeat))
			// 	{
			// 		dad.char.holdTimer = 0;
			// 		dad.char.playAnim('cheer', true);
			// 	}
			// case 'bopeebo':
			// 	if(curBeat % 8 == 7 && curBeat > 0 && !['erect', 'nightmare'].contains(songDiff))
			// 		boyfriend.char.playAnim("hey");
		}

		callScript("beatHit", [curBeat]);
	}

	override function stepHit()
	{
		super.stepHit();
		stageBuild.stepHit(curStep);
		syncSong();
		
		callScript("stepHit", [curStep]);
	}

	public function syncSong():Void
	{
		if(!startedSong) return;
		
		if(!inst.playing && Conductor.songPos > 0 && !paused)
			endSong();
		
		if(inst.playing)
		{
			// syncs the conductor
			if(Math.abs(Conductor.songPos - inst.time) >= 20 && Conductor.songPos - inst.time <= 5000)
			{
				Logs.print('synced song ${Conductor.songPos} to ${inst.time}');
				Conductor.songPos = inst.time;
			}
			
			// syncs the other music to the inst
			for(music in musicList)
			{
				if(music == inst) return;
				
				if(music.playing)
					if(Math.abs(music.time - inst.time) >= 20)
						music.time = inst.time;
			}
		}
		
		// checks if the song is allowed to end
		if(Conductor.songPos >= songLength)
			endSong();
	}
	
	// ends it all
	var playedVideo:Bool = false;
	var endedSong:Bool = false;
	public function endSong()
	{
		#if VIDEOS_ALLOWED
		if(!playedVideo)
		{
			playedVideo = true;
			switch(SONG.song)
			{
				case "useless":
					startVideo("test", true);
					return;
			}
		}
		#end

		if(endedSong) return;
		endedSong = true;
		resetSongStatics();
		
		if(validScore)
		{
			Highscore.addScore(SONG.song.toLowerCase() + '-' + songDiff, {
				score: 		Timings.score,
				accuracy: 	Timings.accuracy,
				misses: 	Timings.misses,
			});
		}
		
		weekScore += Timings.score;

		playList.remove(playList[0]);
		
		if(playList.length <= 0)
		{
			if(isStoryMode && validScore)
			{
				Highscore.addScore('week-$curWeek-$songDiff', {
					score: 		weekScore,
					accuracy: 	0,
					misses: 	0,
				});
			}
			
			sendToMenu();
		}
		else
		{
			loadSong(playList[0]);

			desgraca();
			Main.switchState(new LoadingState());
		}
	}

	override function onFocusLost():Void
	{
		if(SaveData.data.get("Unfocus Pause"))
			pauseSong();
		super.onFocusLost();
	}

	public function pauseSong()
	{
		if(!startedCountdown || endedSong || paused || isDead) return;
		
		if(cameraZoomTween != null)
			cameraZoomTween.active = false;
		paused = true;
		CoolUtil.activateTimers(false);
		discordUpdateTime = 0.0;
		openSubState(new PauseSubState());
		callScript("onPause");
	}
	
	public var isDead:Bool = false;
	
	public function startGameOver()
	{
		if(isDead || !startedCountdown) return;

		if(cameraZoomTween != null)
			cameraZoomTween.active = false;
		health = 0;
		isDead = true;
		blueballed++;
		CoolUtil.activateTimers(false);
		persistentDraw = false;
		openSubState(new GameOverSubState(bfStrumline.character));
	}

	public function zoomCamera(gameZoom:Float = 0, hudZoom:Float = 0)
	{
		//beatCamZoom = gameZoom;
		camHUD.zoom += hudZoom;
		camStrum.zoom += hudZoom;
	}
	
	// funny thingy
	public function changeChar(char:CharGroup, newChar:String = "bf", ?iconToo:Bool = true)
	{
		char.curChar = newChar;
		char.reload();

		if(iconToo)
		{
			// updating icons
			var daID:Int = (char.isPlayer ? 1 : 0);
			hudBuild.changeIcon(daID, char.curChar);
		}
		
		var evilTrail = char._dynamic["evilTrail"];
		if(evilTrail != null)
		{
			remove(evilTrail);
			evilTrail = null;
		}
		switch(newChar)
		{
			case 'spirit':
				evilTrail = new FlxTrail(char.char, null, 4, 24, 0.3, 0.069);
				add(evilTrail);
		}
	}

	// funny thingy
	public function changeStage(newStage:String = "stage")
	{
		if(stageBuild.curStage != newStage)
			stageBuild.reloadStage(newStage);
		
		gf.curChar = stageBuild.gfVersion;
		gf.setPos(stageBuild.gfPos.x, stageBuild.gfPos.y);
		gf.reload();

		dad.setPos(stageBuild.dadPos.x, stageBuild.dadPos.y);

		boyfriend.setPos(stageBuild.bfPos.x, stageBuild.bfPos.y);

		switch(newStage)
		{
			default: // add custom stuff here
		}
	}

	// options substate
	public function updateOption(option:String):Void
	{
		if(['Middlescroll', 'Downscroll'].contains(option))
		{
			for(strumline in strumlines.members)
			{
				if(strumline.customData) continue;
				strumline.x = setStrumlineDefaultX()[strumline.ID];
				strumline.downscroll = SaveData.data.get('Downscroll');
				strumline.updateHitbox();
			}
			for(note in unspawnNotes)
			{
				var thisStrumline = dadStrumline;
				for(strumline in strumlines)
					if(note.strumlineID == strumline.ID)
						thisStrumline = strumline;
				
				if(thisStrumline.customData) continue;
				if(!thisStrumline.isPlayer)
					note.visible = !SaveData.data.get('Middlescroll');
				if(note.gotHit)
					note.visible = false;
			}
			hudBuild.updateHitbox(bfStrumline.downscroll);
			updateNotes();
		}

		switch(option)
		{
			case 'Shaders':
				for(i in ["camGame", "camHUD", "camStrum"])
					stringToCam(i).filters = (SaveData.data.get("Shaders") ? tempShaders.get(i) : []);

			case 'Song Offset':
				for(note in unspawnNotes)
					note.setSongOffset();
				for(event in unspawnEvents)
					event.setSongOffset();

			case 'Antialiasing':
				function loopGroup(group:FlxGroup):Void
				{
					if(group == null) return;
					for(item in group.members)
					{
						if(item == null) continue;
						if(Std.isOfType(item, FlxGroup))
							loopGroup(cast item);
						
						if(Std.isOfType(item, FlxSprite))
						{
							var sprite:FlxSprite = cast item;
							sprite.antialiasing = (sprite.isPixelSprite ? false : FlxSprite.defaultAntialiasing);
						}
					}
				}
				loopGroup(this);
			
			case 'Song Timer':
				hudBuild.timeTxt.visible = SaveData.data.get('Song Timer');
		}
	}

	public function setStrumlineDefaultX():Array<Float>
	{
		for(strumline in strumlines.members)
			if(!strumline.isPlayer)
				for(strum in strumline.strumGroup)
					strum.visible = !SaveData.data.get('Middlescroll');

		var strumPos:Array<Float> = [FlxG.width / 2, FlxG.width / 4];

		if(SaveData.data.get('Middlescroll'))
			return [-strumPos[0], strumPos[0]];
		else
			return [strumPos[0] - strumPos[1], strumPos[0] + strumPos[1]];
	}
	
	// substates also use this
	public static function sendToMenu()
	{
		desgraca();

		CoolUtil.playMusic();
		resetSongStatics();
		instance = null;
		if(isStoryMode)
		{
			isStoryMode = false;
			Main.switchState(new MainMenuState());
		}
		else
			Main.switchState(new FreeplayState());
	}

	public static function loadSong(song:String)
	{
		SONG = SongData.loadFromJson(song, songDiff);
		EVENTS = SongData.loadEventsJson(song, songDiff);
	}

	public function getCamShader(key:String):ShaderFilter
	{
		var shaderArr:Array<String> = [null, null];
		shaderArr[key.endsWith('.frag') ? 0 : 1] = Paths.shader(key);

		var runtime:FlxRuntimeShader = new FlxRuntimeShader(shaderArr[0], shaderArr[1]);
		return new ShaderFilter(runtime);
	}

	public function setCamShader(shaders:Array<BitmapFilter>, cam:String = "camGame") {
		if(SaveData.data.get("Shaders"))
			stringToCam(cam).filters = shaders;

		tempShaders.set(cam, shaders);
	}

	function preloadEvents(unspawnEvents:Array<EventNote>) {
		for (event in unspawnEvents) {
			switch(event.eventName) {
				case 'Change Character':
					strToChar(event.value1).addChar(event.value2);
	
				case 'Change Stage':
					gf.addChar(stageBuild.getGfVersion(event.value1));
			}
		}

	}

	function onEventHit(daEvent:EventNote) {
		switch(daEvent.eventName)
		{
			case 'Play Animation':
				var char = strToChar(daEvent.value1);
				char.char.specialAnim = (CoolUtil.stringToBool(daEvent.value3) ? 2 : 1);
				char.char.playAnim(daEvent.value2, true);

			case 'Show Credits':
				hudBuild.moveToShow();

			case 'Change Character':
				var char = strToChar(daEvent.value1);
				changeChar(char, daEvent.value2, (char != gf));
			
			case 'Change Stage':
				changeStage(daEvent.value1);

			case 'Cinematic Move':
				cinematic.chavesMalandro(CoolUtil.stringToFloat(daEvent.value1, 1280), CoolUtil.stringToFloat(daEvent.value2, -1280));
			
			case 'Freeze Notes':
				var affected:Array<Strumline> = [dadStrumline, bfStrumline];
				switch(daEvent.value2) {
					case "dad": affected.remove(bfStrumline);
					case "bf"|"boyfriend": affected.remove(dadStrumline);
				}
				for(strumline in affected)
					strumline.pauseNotes = CoolUtil.stringToBool(daEvent.value1);

			case 'Change Note Speed':
				for(strumline in strumlines)
				{
					if(strumline.scrollTween != null)
						strumline.scrollTween.cancel();
					var newSpeed:Float = CoolUtil.stringToFloat(daEvent.value1, 2);
					var duration:Float = CoolUtil.stringToFloat(daEvent.value2, 4);
					if(duration <= 0)
						strumline.scrollSpeed = newSpeed;
					else
					{
						strumline.scrollTween = FlxTween.tween(
							strumline, {scrollSpeed: Std.parseFloat(daEvent.value1)},
							Std.parseFloat(daEvent.value2) * Conductor.stepCrochet / 1000,
							{
								ease: CoolUtil.stringToEase(daEvent.value3),
							}
						);
					}
				}

			case 'Change Cam Zoom':
				if(camZoomTween != null) camZoomTween.cancel();
				var newZoom:Float  = CoolUtil.stringToFloat(daEvent.value1, 1);
				var duration:Float = CoolUtil.stringToFloat(daEvent.value2, (isClassicZoom ? 0 : 4));
				if(duration <= 0)
					defaultCamZoom = newZoom;
				else
				{
					camZoomTween = FlxTween.tween(
						PlayState, {defaultCamZoom: newZoom},
						duration * Conductor.stepCrochet / 1000,
						{
							ease: CoolUtil.stringToEase(daEvent.value3),
						}
					);
				}

			case 'Change Cam Pos':
				var x:Float = CoolUtil.stringToFloat(daEvent.value1, 0);
				var y:Float = CoolUtil.stringToFloat(daEvent.value2, 0);
				cameraSpeed = CoolUtil.stringToFloat(daEvent.value3, 1);

				if(daEvent.value1 == ""
				|| daEvent.value2 == "")
					forcedCamPos = null;
				else
					forcedCamPos = new FlxPoint(x,y);
			
			case 'Flash Screen':
				if(daEvent.value3 != 'hud')
				CoolUtil.flash(camGame, Conductor.stepCrochet / 1000 * CoolUtil.stringToFloat(daEvent.value1, 2), CoolUtil.stringToColor(daEvent.value2));
				else
				CoolUtil.flash(camHUD, Conductor.stepCrochet / 1000 * CoolUtil.stringToFloat(daEvent.value1, 2), CoolUtil.stringToColor(daEvent.value2));

			case 'Fade Screen':
				camGame.fade(
					CoolUtil.stringToColor(daEvent.value3),
					CoolUtil.stringToFloat(daEvent.value2, 1) * Conductor.stepCrochet / 1000,
					CoolUtil.stringToBool(daEvent.value1)
				);

			case 'Change Cam Visibility':
				camGame.visible = CoolUtil.stringToBool(daEvent.value1);
				camHUD.visible = daEvent.value2 == 'false' ? false : true;
				camStrum.visible = daEvent.value3 == 'false' ? false : true;

			case '360 screen':
				var sex = CoolUtil.stringToFloat(daEvent.value1, 1);

				camGame.angle = 0;
				FlxTween.tween(camGame, {angle: 360}, sex, {ease: FlxEase.expoOut});
				
			case 'Shake Screen':
				var intensity:Float = CoolUtil.stringToFloat(daEvent.value1, 0.05);
				var duration:Float = CoolUtil.stringToFloat(daEvent.value2, 0.4);
				var cam:FlxCamera = stringToCam(daEvent.value3);
				
				cam.shake(intensity, duration);

			case 'Beat Screen':
				var beatFull:Float = CoolUtil.stringToFloat(daEvent.value1, 1.15);
				var beatReturn:Float = CoolUtil.stringToFloat(daEvent.value2, 1);
				var duration:Float = CoolUtil.stringToFloat(daEvent.value3, 0.1);

				if(cameraZoomTween != null)
					cameraZoomTween.cancel();

				camGame.zoom = beatFull;
				cameraZoomTween = FlxTween.tween(camGame, {zoom: beatReturn}, duration, {ease: FlxEase.expoOut});

			case 'Zoom Screen':
				var beatFull:Float = CoolUtil.stringToFloat(daEvent.value1, 1);
				var duration:Float = CoolUtil.stringToFloat(daEvent.value2, 0.5);

				if(cameraZoomTween != null)
					cameraZoomTween.cancel();

				cameraZoomTween = FlxTween.tween(camGame, {zoom: beatFull}, duration, {ease: FlxEase.expoOut});
			
			case "Change Cam Section":
				forcedCamSection = daEvent.value1;
			
			case "Change Cam Angle":
				var cam:FlxCamera = camGame;
				var newAngle:Float = CoolUtil.stringToFloat(daEvent.value1);
				var duration:Float = CoolUtil.stringToFloat(daEvent.value2);
				
				if(cam._dynamic.get("angleTween") != null)
					cast(cam._dynamic.get("angleTween"), FlxTween).cancel();

				if(duration > 0.0)
					cam._dynamic.set("angleTween", FlxTween.tween(
						cam, {angle: newAngle},
						duration * Conductor.stepCrochet / 1000, {
							ease: CoolUtil.stringToEase(daEvent.value3),
						}
					));
				else
					cam.angle = newAngle;

			case "Flash Image":
				var flashMaPussy = new FlxSprite(0,0, Paths.image('songsAssets/${daEvent.value1}'));
				flashMaPussy.cameras = [camOther];
				flashMaPussy.screenCenter();
				add(flashMaPussy);

				FlxTween.tween(flashMaPussy, {alpha: 0}, CoolUtil.stringToFloat(daEvent.value2), {onComplete: function(a:FlxTween){ flashMaPussy.destroy(); }});
			
			case "Fade BG and Stuff":
				cameraSpeed = 0.3;
				camGame.bgColor = 0xFF000000;
				for(spr in [gf.char, dad.char, boyfriend.char, stageBuild.bg]) FlxTween.tween(spr, {alpha: 0}, 8, {ease: FlxEase.expoInOut});
		}

		callScript("onEventHit", [daEvent.eventName, daEvent.value1, daEvent.value2, daEvent.value3]);
	}

	public function callScript(fun:String, ?args:Array<Dynamic>)
	{
		for(script in loadedScripts) {
			@:privateAccess {
				var ny: Dynamic = script.interp.variables.get(fun);
				try {
					if(ny != null && Reflect.isFunction(ny))
						script.call(fun, args);
				} catch(e) {
					Logs.print('error parsing script: ' + e, ERROR);
				}
			}
		}
	}
	public function setScript(name:String, value:Dynamic, allowOverride:Bool = true)
	{
		for(script in loadedScripts)
			script.set(name, value, allowOverride);
	}

	public static function desgraca()
	{
		if(SONG.song == 'papai-calabreso')
		{
			FlxG.scaleMode = new RatioScaleMode(false);

			final size = [1280, 720];

			FlxG.resizeGame(size[0], size[1]);
			FlxG.resizeWindow(size[0], size[1]);
				
			Application.current.window.resizable = true;
			Application.current.window.y = 60; Application.current.window.x = 25;
			Application.current.window.title = 'FNF: 20tão';
		}
	}

	public static function setupCalabreso()
	{
		FlxG.scaleMode = new StageSizeScaleMode();

		final size = [387, 720];

		FlxG.resizeGame(size[0], size[1]);
		FlxG.resizeWindow(size[0], size[1]);

		Application.current.window.resizable = false;
		Application.current.window.y = 60; Application.current.window.x = 500;
		Application.current.window.title = 'FNF: Tik Tok';
		FlxG.fullscreen = false;
	}

	public function ghostDoubleNote(vemDeQuem:String, animationToPlay:String) // muito baseado no do vs imposter v4 (feio mas funciona)
	{
		var vemDeQuem = (vemDeQuem == 'boyfriend') ? boyfriend : dad;

		var euGhostDaOCU = new FlxSprite();
		euGhostDaOCU.scale.copyFrom(vemDeQuem.char.scale);
		euGhostDaOCU.frames = vemDeQuem.char.frames;
		euGhostDaOCU.animation.copyFrom(vemDeQuem.char.animation);
		euGhostDaOCU.setPosition(vemDeQuem.char.x, vemDeQuem.char.y);
		euGhostDaOCU.animation.play(animationToPlay, true);
		euGhostDaOCU.offset.set(vemDeQuem.char.animOffsets.get(animationToPlay)[0], vemDeQuem.char.animOffsets.get(animationToPlay)[1]);
		euGhostDaOCU.flipX = vemDeQuem.char.flipX;
		euGhostDaOCU.blend = HARDLIGHT;
		euGhostDaOCU.alpha = 0.8;
		add(euGhostDaOCU);

		// muito bom
		var offset:FlxPoint = new FlxPoint(euGhostDaOCU.x,euGhostDaOCU.y);
		if(animationToPlay == 'singRIGHT' || animationToPlay == 'singLEFT') offset.x += animationToPlay=='singLEFT'?-25:25;
		if(animationToPlay == 'singUP' || animationToPlay == 'singDOWN') offset.y += animationToPlay=='singUP'?-25:25;

		euGhostDaOCU.color = vemDeQuem == boyfriend ? hudBuild.healthBar.sideR.color : hudBuild.healthBar.sideL.color;
		FlxTween.tween(euGhostDaOCU, {alpha: 0, x: offset.x, y: offset.y}, 0.75, {ease: FlxEase.expoOut, onComplete: function(a:FlxTween){euGhostDaOCU.destroy();}});
	}
}