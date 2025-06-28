package states;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import backend.game.GameData.MusicBeatState;
import backend.song.Conductor;
import backend.song.SongData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import objects.menu.Alphabet;
import states.menu.MainMenuState;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;

using StringTools;

class TitleState extends MusicBeatState
{
	var textGroup:FlxTypedGroup<Alphabet>;
	var someShit:FlxTypedGroup<FlxSprite>;
	var curWacky:Array<String> = ['',''];
	var ngSpr:FlxSprite;
	
	var blackScreen:FlxSprite;
	var logoBump:FlxSprite;
	var corner1:FlxSprite;
	var corner2:FlxSprite;
	var bg:FlxSprite;
	
	var enterTxt:FlxSprite;
	
	static var introEnded:Bool = false;

	override function create()
	{
		FlxG.camera.bgColor = FlxColor.BLACK;
		SaveData.updateLang();

		super.create();
		if(!introEnded)
		{
			new FlxTimer().start(1, function(tmr:FlxTimer) {
				CoolUtil.playMusic("freakyMenu");
			});
			
			doTextParseHeck();
		}
		
		DiscordIO.changePresence("In Title Screen");
		FlxG.mouse.visible = false;
		
		persistentUpdate = true;
		Conductor.setBPM(65);
		
		someShit = new FlxTypedGroup<FlxSprite>();
		add(someShit);

		corner1 = new FlxSprite(1280,-720);
		corner1.frames = Paths.getSparrowAtlas('menu/title/corner');
		corner1.animation.addByPrefix('play', 'a', 24, true);
		corner1.animation.play('play');
		corner1.flipY = true;
		corner1.flipX = true;

		corner2 = new FlxSprite(-1280,720);
		corner2.frames = Paths.getSparrowAtlas('menu/title/corner');
		corner2.animation.addByPrefix('play', 'a', 24, true);
		corner2.animation.play('play');

		bg = new FlxSprite(0,0).loadGraphic(Paths.image('menu/title/bg'));
		bg.screenCenter(); 
		
		logoBump = new FlxSprite(-1000, 175);
		logoBump.frames = Paths.getSparrowAtlas('menu/title/logoBumpin');
		logoBump.animation.addByPrefix('bump', 'bumpintitle', 24, false);
		logoBump.animation.play('bump');
		logoBump.screenCenter();
		logoBump.angle = -100;
		logoBump.alpha = 0;
		
		enterTxt = new FlxSprite(0, 600);
		enterTxt.frames = Paths.getSparrowAtlas('menu/title/titleEnter');
		enterTxt.animation.addByPrefix('idle', 'ENTER FREEZE', 24, false);
		enterTxt.animation.addByPrefix('pressed', 'ENTER PRESSED', 24, false, false, false);
		enterTxt.animation.play('idle');
		enterTxt.scale.set(0.6, 0.6);
		enterTxt.screenCenter(X);
		enterTxt.alpha = 0.8;
		FlxTween.tween(enterTxt, {alpha: 0.6}, 2, {type: PINGPONG, ease: FlxEase.sineInOut});

		someShit.add(bg);
		someShit.add(logoBump);
		someShit.add(corner1);
		someShit.add(corner2);
		someShit.add(enterTxt);
		
		blackScreen = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		blackScreen.screenCenter();
		add(blackScreen);
		
		textGroup = new FlxTypedGroup<Alphabet>();
		add(textGroup);
		
		ngSpr = new FlxSprite().loadGraphic(Paths.image('menu/title/newgrounds_logo'));
		ngSpr.screenCenter();
		ngSpr.y = FlxG.height - ngSpr.height - 40;
		ngSpr.visible = false;
		add(ngSpr);

		addText([]);
		
		if(introEnded)
			skipIntro(true);
	}
	
	var pressedEnter:Bool = false;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(FlxG.sound.music != null)
			if(FlxG.sound.music.playing)
				Conductor.songPos = FlxG.sound.music.time;
		
		if(Controls.justPressed(ACCEPT))
		{
			if(introEnded)
			{
				if(!pressedEnter)
				{
					pressedEnter = true;
					enterTxt.animation.play('pressed');
					enterTxt.setPosition(enterTxt.x-72, enterTxt.y-55);
					enterTxt.scale.set(0.65, 0.65);
					FlxG.sound.play(Paths.sound('menu/confirmMenu'));
					CoolUtil.flash(FlxG.camera, 1, 0xFFFFFFFF);
					new FlxTimer().start(2.0, function(tmr:FlxTimer)
					{
						Main.switchState(new MainMenuState());
					});

					for(i in 0...5)
						FlxTween.cancelTweensOf(someShit.members[i]);

					FlxTween.tween(logoBump, {angle: 360, alpha: 0}, 1.8, { ease: FlxEase.expoInOut, });
					FlxTween.tween(enterTxt, {alpha: 0}, 2, { ease: FlxEase.expoIn, });
					FlxTween.tween(corner1, {x: 1280, y: -720},  2.2, {ease: FlxEase.expoIn});
					FlxTween.tween(corner2, {x: -1280, y: 720}, 2.2, {ease: FlxEase.expoIn});
					FlxTween.tween(bg, {alpha: 0}, 2.4, {ease: FlxEase.expoIn});

					enterTxt.alpha = 1;
				}
			}
			else
				skipIntro();
		}

		enterTxt.scale.set(FlxMath.lerp(enterTxt.scale.x, 0.6, elapsed*5), FlxMath.lerp(enterTxt.scale.y, 0.6, elapsed*5));
	}
	
	override function stepHit()
	{
		super.stepHit();
		if(!introEnded)
		{
			switch(curStep) // AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
			{	
				case 5 | 9 | 26 | 33 | 44: // blank spot
					addText(['']);

				case 1: addText(['20tao'], true);
				case 2: addText(['MOD TEAM'], false);
				case 6: addText(['Thurz']);
				case 7: addText(['JDaniel'], false);
				case 8: addText(['E o resto do time'], false);
				case 10: addText(['GO']);
				case 11: addText(['GODE']);
				case 12: addText(['GODENOT']);
				case 13: addText(['MAN'], false);
				case 14: addText(['GODENOT']);
					addText(['MANDA'], false);
				case 15: addText(['GODENOT']);
					addText(['MANDA SALVE'], false);
					ngSpr.visible = true;
				case 17: addText([]);
					ngSpr.visible = false;	
				case 18 | 20: addText([curWacky[0]]);
				case 19 | 21: addText([curWacky[1]], false);
					doTextParseHeck(); // mais wacky for me!
				case 23: addText([CoolUtil.getLangText(0)]);
				case 24: addText([CoolUtil.getLangText(1)], false);
				case 25: addText([CoolUtil.getLangText(2)], false);
				case 27: addText([CoolUtil.getLangText(3)]);
				case 28: addText([CoolUtil.getLangText(4)]);
				case 29: addText([CoolUtil.getLangText(5)]);
				case 30: addText([CoolUtil.getLangText(5)]);
					addText([CoolUtil.getLangText(6)], false);
				case 31: addText([CoolUtil.getLangText(5)]);
					addText([CoolUtil.getLangText(6)], false);
					addText([CoolUtil.getLangText(7)], false);
				case 32: addText([CoolUtil.getLangText(5)]);
					addText([CoolUtil.getLangText(6)], false);
					addText([CoolUtil.getLangText(8)], false);
				case 35: CoolUtil.flash(FlxG.camera, 1, 0xFFFFFFFF);
					addText(['PLAY TV!']); // que se foda, canse de tentar sincronizar
				case 37: addText(['BLUE BOYFRIEND'], false);
				case 39: addText(['BOLHO'], false);
				case 41: addText(['GIRLFRIEND'], false);
					addText(['BETA BOYFRIEND'], false);
				case 42: addText(['MINUS GIRLFRIEND MORTA'], false);
					addText(['PARA LANCHES'], false);
					addText(['PONTO DA ESFIHA'], false);
				case 43: addText(['TRALALERO TRALALA'], false);
					addText(['CAIOX'], false);
					addText(['CALMA CALABRESO'], false);
					addText(['CHAVES'], false);
				case 53: addText([CoolUtil.getLangText(9)]);
				case 64: FlxTween.tween(textGroup.members[0], {alpha: 0}, 0.5);
				case 69: // uau
					skipIntro();
			}
		}
		
		logoBump.animation.play('bump', false);	
	}
	
	
	public function skipIntro(force:Bool = false)
	{
		if(introEnded && !force) return;
		introEnded = true;
		
		// if(FlxG.sound.music != null)
		// 	FlxG.sound.music.time = (Conductor.crochet * 16);
		
		addText([]);
		ngSpr.visible = false;
		CoolUtil.flash(FlxG.camera, Conductor.crochet * 4 / 1000, 0xFFFFFFFF);
		remove(blackScreen);

		FlxTween.tween(logoBump, {alpha: 1, angle: 0}, Conductor.crochet * 4 / 1000, { ease: FlxEase.expoOut, });
		FlxTween.tween(corner1, {x: FlxG.width - corner1.width + 15, y: -37},  Conductor.crochet * 5 / 1000, {ease: FlxEase.expoOut});
		FlxTween.tween(corner2, {x: -15, y: 500 - 10}, Conductor.crochet * 4.5 / 1000, {ease: FlxEase.expoOut});
	}
	
	public function addText(newText:Array<String>, clearTxt:Bool = true, mainY:Int = 130)
	{
		if(clearTxt) textGroup.clear();
		
		for(i in newText)
		{
			var item = new Alphabet(0, 0, i.toUpperCase(), true);
			item.align = CENTER;
			item.x = FlxG.width / 2;
			item.y = mainY + item.boxHeight * textGroup.members.length;
			item.updateHitbox();
			textGroup.add(item);
		}
	}

	function doTextParseHeck()
	{
		var allTexts:Array<String> = CoolUtil.parseTxt('introText');
		curWacky = allTexts[FlxG.random.int(0, allTexts.length - 1)].split('--');
	}
}
