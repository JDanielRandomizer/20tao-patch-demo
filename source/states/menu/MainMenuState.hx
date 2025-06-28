package states.menu;

import backend.game.GameData.MusicBeatState;
import backend.song.SongData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var optionShit:Array<String> = ["playTvT", "freeplay", "gallery", "options", "credits"];
	static var curSelected:Int = 0;
	
	var grpOptions:FlxTypedGroup<FlxSprite>;
	
	var bg:FlxSprite;
	var bolho:FlxSprite;

	var canClickInBolho:Bool = false;
	
	override function create()
	{
		super.create();
		CoolUtil.playMusic("freakyMenu");
		DiscordIO.changePresence("In the Main Menu");
		FlxG.camera.bgColor = 0xFFFFFFFF;

		// bg = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/menuBG'));
		// add(bg);
		
		var logo = new FlxSprite(422.5, -300);
		logo.frames = Paths.getSparrowAtlas('menu/menu/20tao');
		logo.animation.addByPrefix('idle', '20', 24, true);
		logo.animation.play('idle');
		logo.angle = -5;
		FlxTween.tween(logo, {y:10}, 1, {ease: FlxEase.expoOut});
		FlxTween.tween(logo, {angle: 5}, 3.5, {ease: FlxEase.sineInOut, type: PINGPONG});
		add(logo);

		grpOptions = new FlxTypedGroup<FlxSprite>();
		add(grpOptions);
		
		for(i in 0...optionShit.length)
		{
			var item = new FlxSprite(0, 0, Paths.image('menu/menu/options/${optionShit[i]}'));
			grpOptions.add(item);

			item.ID = i;
			switch(i) {
				case 0 | 1: item.setPosition(20, 10+275*i);
				case 2: item.setPosition(20, -50+(275*i));
				case 3 | 4: item.setPosition(FlxG.width-(item.width+20), 20+(350*(i-3)));
			}
		}

		bolho = new FlxSprite(493.5, 1231);
		bolho.frames = Paths.getSparrowAtlas('menu/menu/bolho');
		bolho.animation.addByPrefix('idle', 'bolho', 24, true);
		bolho.animation.addByPrefix('punch', 'punching her is just mean bro :(', 24, false);
		bolho.animation.play('idle');
		FlxTween.tween(bolho, {y:259}, 2, {ease: FlxEase.expoOut, onComplete: function(t:FlxTween)canClickInBolho=true});
		add(bolho);

		changeSelection();

		#if TOUCH_CONTROLS
		createPad("back");
		#end
	}
	
	var selectedSum:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if debug
		// Crash the game. For CrashHandler test purposes
		if(FlxG.keys.justPressed.R)
			null.draw();
		#end

		if(FlxG.keys.justPressed.V)
		{
			persistentUpdate = false;
			openSubState(new subStates.VideoPlayerSubState("test"));
		}

		if(FlxG.keys.justPressed.EIGHT)
		{
			FlxG.sound.play(Paths.sound("menu/cancelMenu"));
			Main.switchState(new states.editors.CharacterEditorState("bf", false));
		}

		for(item in grpOptions.members) {
			var theLerp = (curSelected == item.ID)?1.1:1;
			item.scale.set(FlxMath.lerp(item.scale.x, theLerp, 9*elapsed), FlxMath.lerp(item.scale.y, theLerp, 9*elapsed));
		}
		
		if(!selectedSum)
		{
			if(Controls.justPressed(UI_UP) || Controls.justPressed(UI_DOWN))
				changeSelection(Controls.justPressed(UI_DOWN) ? 1 : -1);
			if(Controls.justPressed(UI_RIGHT) || Controls.justPressed(UI_LEFT))
				changeSelection(Controls.justPressed(UI_RIGHT)?1:-1, false, true);

			if(FlxG.mouse.overlaps(grpOptions)) { // mouse
				grpOptions.forEach(function(menuItemFunc:FlxSprite) {
						if(menuItemFunc.ID != curSelected && FlxG.mouse.overlaps(menuItemFunc))
							changeSelection(menuItemFunc.ID, true);
					});

				if(FlxG.mouse.justPressed)
					acceptMenu();
			}

			// if(FlxG.mouse.wheel != 0) // estranha
			// 	changeSelection(FlxG.mouse.wheel);
			
			if(Controls.justPressed(BACK))
				Main.switchState(new TitleState());
			
			if(Controls.justPressed(ACCEPT))
				acceptMenu();

			if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(bolho))
				punchingBolho();
		}
	}

	public function changeSelection(change:Int = 0, ?setValue:Bool = false, ?leftAndRight:Bool = false)
	{
		if(change != 0 || setValue) FlxG.sound.play(Paths.sound('menu/scrollMenu'));

		if(!leftAndRight) { // meio chato mas quem liga
			if(!setValue) {
				curSelected += change;
				curSelected = FlxMath.wrap(curSelected, 0, optionShit.length - 1);
			} else curSelected = change;
		} else { // isso e meio feio, mas e
			if(change == 1 && curSelected < 3) curSelected = curSelected > 1 ? 4 : 3;
			else if(curSelected > 2 && change == -1) curSelected = curSelected == 4 ? 2 : 0; 
		}
	}

	public function punchingBolho()
	{
		FlxG.sound.play(Paths.sound('menu/punch'));
		FlxTween.cancelTweensOf(bolho);

		bolho.animation.play('punch');
		bolho.animation.finishCallback = function(name:String) bolho.animation.play('idle'); // antigo?????

		bolho.y = 234; bolho.scale.set(0.95, 0.95);
		FlxTween.tween(bolho, {y: 249, "scale.x": 1, "scale.y": 1}, 0.25, {ease: FlxEase.expoOut});

		for(i in 0...FlxG.random.int(1, 3))
		{
			var star = new FlxSprite(FlxG.random.float(bolho.x, bolho.x+bolho.width-50), FlxG.random.float(bolho.y, bolho.y+bolho.height-50), Paths.image('menu/menu/star'));
			star.scale.set(0.5, 0.5);
			star.velocity.set(0, -100);
			star.angularAcceleration = FlxG.random.float(-45, 45);
			star.acceleration.set(FlxG.random.float(-50, 50), FlxG.random.float(100, 250));
			add(star);

			FlxTween.tween(star, {alpha: 0}, FlxG.random.float(0.7, 1.5), {ease: FlxEase.expoIn, onComplete: function(t:FlxTween){star.destroy();}});
		}
	}

	public function acceptMenu()
	{
		switch(optionShit[curSelected])
		{
			case "playTv":
				PlayState.isStoryMode = true;
				PlayState.playList = [];
				PlayState.songDiff = 'normal';
				PlayState.loadSong('play-tv');
				Main.switchState(new LoadingState());
			case "playTvT": FlxG.sound.play(Paths.sound('locked')); return;
			case "freeplay": Main.switchState(new FreeplayState());
			case "credits": Main.switchState(new CreditsState());
			case "options": Main.switchState(new OptionsState());
			case "gallery": Main.switchState(new GalleryState());
			default: // avoids freezing
				Main.resetState();
		}

		selectedSum = true;
		FlxG.sound.play(Paths.sound('menu/confirmMenu'));

		for(item in grpOptions.members)
		{
			if(item.ID != curSelected)
				FlxTween.tween(item, {alpha: 0}, 0.4, {ease: FlxEase.cubeOut});
		}
	}
}
