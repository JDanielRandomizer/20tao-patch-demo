package backend.game;

import flixel.FlxSprite;
import flixel.util.FlxSave;
import openfl.system.Capabilities;
import backend.song.Conductor;
import backend.song.Highscore;

/*
	Save data such as options and other things.
*/

enum SettingType
{
	CHECKMARK;
	SELECTOR;
}
class SaveData
{
	public static var data:Map<String, Dynamic> = [];
	public static var displaySettings:Map<String, Dynamic> = [
		/*
		*
		* PREFERENCES
		* 
		*/
		'Language' => [
			"PORTUGUESE",
			SELECTOR,
			11,
			["PORTUGUESE", "ENGLISH"]
		],
		"Window Size" => [
			"1280x720",
			SELECTOR,
			"Change the game's resolution if it doesn't fit your monitor",
			["640x360","854x480","960x540","1024x576","1152x648","1280x720","1366x768","1600x900","1920x1080", "2560x1440", "3840x2160"],
		],
		'Flashing Lights' => [
			"ON",
			SELECTOR,
			12,
			["ON", "REDUCED", "OFF"]
		],
		"Cutscenes" => [
			"ON",
			SELECTOR,
			"Decides if the song cutscenes should play",
			["ON", "FREEPLAY OFF", "OFF"],
		],
		"FPS Counter" => [
			false,
			CHECKMARK,
			13,
		],
		'Unfocus Pause' => [
			true,
			CHECKMARK,
			14,
		],
		"Countdown on Unpause" => [
			true,
			CHECKMARK,
			15,
		],
		'Discord RPC' => [
			#if DISCORD_RPC
			true,
			#else
			false,
			#end
			CHECKMARK,
			"Whether to use Discord's game activity.",
		],
		"Shaders" => [
			true,
			CHECKMARK,
			"Fancy graphical effects. Disable this if you get GPU related crashes."
		],
		"Low Quality" => [
			false,
			CHECKMARK,
			16,
		],
		/*
		*
		* GAMEPLAY
		* 
		*/
		"Ghost Tapping" => [
			true,
			CHECKMARK,
			17,
		],
		"Downscroll" => [
			false,
			CHECKMARK,
			18,
		],
		"Middlescroll" => [
			false,
			CHECKMARK,
			19,
		],
		"Framerate Cap"	=> [
			60, // 120
			SELECTOR,
			20,
			[30, 360]
		],
		'Hitsounds' => [
			"OFF",
			SELECTOR,
			21,
			["OFF", "OSU", "NSWITCH", "CD"]
		],
		'Hitsound Volume' => [
			100,
			SELECTOR,
			22,
			[0, 100]
		],
		/*
		*
		* APPEARANCE
		* 
		*/
		"Note Splashes" => [
			"ON",
			SELECTOR,
			23,
			["ON", "PLAYER ONLY", "OFF"],
		],
		"Hold Splashes" => [
			true,
			CHECKMARK,
			24
		],
		"Antialiasing" => [
			true,
			CHECKMARK,
			25
		],
		"Split Holds" => [
			false,
			CHECKMARK,
			26
		],
		"Static Hold Anim" => [
			true,
			CHECKMARK,
			27
		],
		"Single Rating" => [
			false,
			CHECKMARK,
			28,
		],
		"Ratings on HUD" => [
			true,
			CHECKMARK,
			29
		],
		"Song Timer" => [
			true,
			CHECKMARK,
			30
		],
		/*
		*
		* MOBILE
		* 
		*/
		"Invert Swipes" => [
			"OFF",
			SELECTOR,
			"Inverts the direction of the swipes.",
			["HORIZONTAL", "VERTICAL", "BOTH", "OFF"],
		],
		"Button Opacity" => [
			5,
			SELECTOR,
			"Decides the transparency of the virtual buttons.",
			[0, 10]
		],
		"Hitbox Opacity" => [
			7,
			SELECTOR,
			"Decides the transparency of the playing Hitboxes.",
			[0, 10]
		],
		/*
		*
		* EXTRA STUFF
		* 
		*/
		"Song Offset" => [
			0,
			SELECTOR,
			"no one is going to see this anyway whatever",
			[-100, 100],
		],
		"Input Offset" => [
			0,
			SELECTOR,
			"same xd",
			[-100, 100],
		],
	];
	
	public static var saveSettings:FlxSave = new FlxSave();
	public static var saveControls:FlxSave = new FlxSave();
	public static function init()
	{
		saveSettings.bind("settings"); // use these for settings
		saveControls.bind("controls"); // controls :D
		FlxG.save.bind("save-data"); // these are for other stuff, not recquiring to access the SaveData class
		
		load();
		Controls.load();
		Highscore.load();
		subStates.editors.ChartAutoSaveSubState.load(); // uhhh
		updateWindowSize();
	}
	
	public static function load()
	{
		if(saveSettings.data.volume != null)
			FlxG.sound.volume = saveSettings.data.volume;
		if(saveSettings.data.muted != null)
			FlxG.sound.muted  = saveSettings.data.muted;

		if(saveSettings.data.settings == null)
		{
			for(key => values in displaySettings)
				data[key] = values[0];
			
			saveSettings.data.settings = data;
		}
		else
		{
			var freeze:Null<Bool> = saveSettings.data.settings.get("Unfocus Freeze");
			if(freeze != null) {
				saveSettings.data.settings.set("Unfocus Pause", freeze);
				saveSettings.data.settings.remove("Unfocus Freeze");
			}
		}
		
		if(Lambda.count(displaySettings) != Lambda.count(saveSettings.data.settings)) {
			data = saveSettings.data.settings;
			
			for(key => values in displaySettings) {
				if(data[key] == null)
					data[key] = values[0];
			}

			for(key => values in data) {
				if(displaySettings[key] == null)
					data.remove(key);
			}

			saveSettings.data.settings = data;
		}
		
		for(hitsound in Paths.readDir('sounds/hitsounds', [".ogg"], true))
			if(!displaySettings.get("Hitsounds")[3].contains(hitsound))
				displaySettings.get("Hitsounds")[3].insert(1, hitsound);
		
		data = saveSettings.data.settings;
		save();
	}
	
	public static function save()
	{
		saveSettings.data.settings = data;
		saveSettings.flush();
		update();
	}

	public static function update()
	{
		Main.changeFramerate(data.get("Framerate Cap"));
		
		if(Main.fpsCounter != null)
			Main.fpsCounter.visible = data.get("FPS Counter");

		FlxSprite.defaultAntialiasing = data.get("Antialiasing");

		FlxG.autoPause = data.get('Unfocus Pause');

		Conductor.musicOffset = data.get('Song Offset');
		Conductor.inputOffset = data.get('Input Offset');

		DiscordIO.check();
	}

	public static function updateWindowSize()
	{
		#if desktop
		if(FlxG.fullscreen) return;
		var ws:Array<String> = data.get("Window Size").split("x");
        	var windowSize:Array<Int> = [Std.parseInt(ws[0]),Std.parseInt(ws[1])];
        	FlxG.stage.window.width = windowSize[0];
        	FlxG.stage.window.height= windowSize[1];
		
		// centering the window
		FlxG.stage.window.x = Math.floor(Capabilities.screenResolutionX / 2 - windowSize[0] / 2);
		FlxG.stage.window.y = Math.floor(Capabilities.screenResolutionY / 2 - (windowSize[1] + 16) / 2);
		#end
	}

	public static function updateLang() { Main.lang = data.get("Language") == "PORTUGUESE" ? 0 : 1; trace(Main.lang); }
}
