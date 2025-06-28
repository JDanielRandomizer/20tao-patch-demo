package states.menu;

import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import backend.game.GameData.MusicBeatState;
import backend.song.Highscore;
import backend.song.Highscore.ScoreData;
import backend.song.SongData;
import objects.menu.AlphabetMenu;
import objects.hud.HealthIcon;
import states.*;
import states.editors.ChartingState;
import subStates.menu.DeleteScoreSubState;

using StringTools;

typedef CreditData = {
	var name:String;
    var icon:String;
    var color:FlxColor;
    var info:String;
	var link:Null<String>;
	var readable:Bool;
}
class CreditsState extends MusicBeatState
{
	var creditList:Array<CreditData> = [];
    
	function addCredit(name:String, icon:String, color:FlxColor, info:String, ?link:Null<String>, ?readable:Bool = true)
	{
		creditList.push({
            name: name,
            icon: icon,
            color: color,
            info: info,
			link: link,
			readable: readable,
        });
	}

	static var curSelected:Int = 1;

	var bg:FlxSprite;
	var bgTween:FlxTween;
	var grpItems:FlxGroup;
	var infoTxtFocus:AlphabetMenu;
	var infoTxt:FlxText;

	override function create()
	{
		super.create();
		CoolUtil.playMusic("freakyMenu");

		DiscordIO.changePresence("Credits - Thanks!!");

		bg = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/menuDesat'));
		bg.scale.set(1.2,1.2); bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		grpItems = new FlxGroup();
		add(grpItems);

		infoTxt = new FlxText(0, 0, FlxG.width * 0.6, 'balls');
		infoTxt.setFormat(Main.gFont, 24, 0xFFFFFFFF, CENTER);
        infoTxt.setBorderStyle(OUTLINE, 0xFF000000, 1.5);
        add(infoTxt);

	
		// yes, this implies coders aren't people
		// :D
		
		// btw you dont need to credit everyone here on your mod, just credit doido engine as a whole and we're goodz
		addCredit('20TAO TEAM', 			'none', 	 0xFFFDFDFD, "none", 				'https://x.com/Thurzyz_',  false);

			addCredit('Thurz', 			'thurz', 	 0xFFFDFDFD, "Main Coder, Charter and Founder", 				'https://x.com/Thurzyz_');
			addCredit('JDaniel', 				'witheydobearalpha', 	 0xFF16C010, "Main Coder, Animator, Artist, Charter and Owner\n(17quedas forever)",	'https://www.youtube.com/@JDanielAleatorio');
			addCredit('NineFds', 		'nine', 	 0xffffffff, "Composer, Charter, Animator\n(pediu para o carlosplay fazer a musica do roblox, sim, isso vale muito)",			'https://www.youtube.com/channel/UCb1gAeO6_0uu47afIQWEAQQ');
			addCredit('Maxxerbruh_', 		'maxxer', 	 0xff008dff, "Animator,  Artist and Charter",			'https://www.youtube.com/channel/UCagMo_SBEJEo_H0sWfHNrbA');
			addCredit('Siwiki',			'siwiki', 	 0xFFFFFFFF, "Composer, Artist and Animator",   		'https://x.com/siwiki25');
			addCredit('GuineaPigUuhh', 		'none', 	 0xff00e512, "Coder",			'https://github.com/GuineaPigUuhh');
			addCredit('CarlosPlay231', 		'none', 	 0xFFFFFFFF, "Composer",			'https://www.youtube.com/@carlosplay231');
			addCredit('Guisende', 		'guisende', 	 0xff8c7363, "Composer",			'https://www.youtube.com/@guisendeg');
			addCredit('Twitter', 		'x', 	 0xff555555, "Our Twitter",			'https://x.com/20taonopix');
			// addCredit('Krystal', 		'none', 	 0xff8c7363, 'Charter',			'https://www.youtube.com/channel/UCYjAAOzNBSyvG2fEc9EDV6g');
			addCredit('', 			'none', 	 0xFFFDFDFD, "none", 				'https://x.com/Thurzyz_',  false);

		addCredit('silly beta (17QUEDAS)', 			'none', 	 0xFFFDFDFD, "none", 				'https://x.com/Thurzyz_',  false);

			addCredit('Over647', 		'over', 	 0xff202020, 'Composer of "Silly Beta"',			'https://www.youtube.com/@OverREALREAL');
			addCredit('', 			'none', 	 0xFFFDFDFD, "none", 				'https://x.com/Thurzyz_',  false);

		addCredit('Engine', 			'none', 	 0xFFFDFDFD, "none", 				'https://x.com/Thurzyz_',  false);

			addCredit('Doido Engine', 		'doido', 	 0xffff5e46, "The engine used in the mod\n(don't kill me DiogoTV :((()",			'https://github.com/DoidoTeam/FNF-Doido-Engine');
		
		for(i in 0...creditList.length)
		{
			var credit = creditList[i];

			var item = new AlphabetMenu(0, 0, credit.name, !credit.readable);
			item.align = CENTER;
			item.updateHitbox();
			grpItems.add(item);

			var icon = new FlxSprite();
			icon.loadGraphic(Paths.image('credits/${credit.icon}'));
			grpItems.add(icon);
			icon.visible = credit.icon != 'none'; // util

		
			item.icon = icon;
			item.ID = i;
			icon.ID = i;

			item.spaceX = 150;
			item.spaceY = 150;
			item.xTo = (FlxG.width / 2) - (icon.width / 2);
			item.focusY = i - curSelected;
			item.updatePos();			
		}
		changeSelection();

		#if TOUCH_CONTROLS
		createPad("back");
		#end
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, creditList.length - 1);

		for(rawItem in grpItems.members)
		{
			if(Std.isOfType(rawItem, AlphabetMenu))
			{
				var item = cast(rawItem, AlphabetMenu);
				item.focusY = item.ID - curSelected;

				if(creditList[curSelected].readable) item.alpha = 0.4; else changeSelection(change);
				if(item.ID == curSelected) {
					infoTxtFocus = item;
					item.alpha = 1;
				}

				if(!creditList[item.ID].readable) item.alpha = 1; // odeio minha vida
			}
		}

		infoTxt.text = creditList[curSelected].info;
		infoTxt.screenCenter();
		
		if(bgTween != null) bgTween.cancel();
		bgTween = FlxTween.color(bg, 0.4, bg.color, creditList[curSelected].color);

		if(change != 0)
			FlxG.sound.play(Paths.sound("menu/scrollMenu"));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(Controls.justPressed(UI_UP))
			changeSelection(-1);
		if(Controls.justPressed(UI_DOWN))
			changeSelection(1);

		if(Controls.justPressed(BACK))
			Main.switchState(new MainMenuState());

		if(Controls.justPressed(ACCEPT))
		{
			var daCredit = creditList[curSelected].link;
			if(daCredit != null)
				CoolUtil.openURL(daCredit);
		}
		
		infoTxt.y = infoTxtFocus.y + infoTxtFocus.height + 48;
		for(rawItem in grpItems.members)
		{
			if(Std.isOfType(rawItem, AlphabetMenu))
			{
				var item = cast(rawItem, AlphabetMenu);
				item.icon.x = item.x + (item.width / 2);
				item.icon.y = item.y - item.icon.height / 6;
				item.icon.alpha = item.alpha;
			}
		}
	}
}