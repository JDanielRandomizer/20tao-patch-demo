package states;

import backend.game.GameData.MusicBeatState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import subStates.options.OptionsSubState;

var selectingWhat = true;

var options:FlxText;
var proceed:FlxText;

class WarningState extends MusicBeatState
{
	override public function create():Void 
	{
		super.create();
		var tex:String = "AVISO / WARNING 
		\n\nO mod contem FLASHS piscantes / This mod contains flashing lights
		\nVocê pode tirar ou reduzir / You can turn it off or reduce
		\neles em \"PREFERENCES\" / it in \"PREFERENCES\"
		\nVocê tambem pode troca a linguagem lá! / You can also change your game language there!";
		var popUpTxt = new FlxText(0,10,0,tex);
		popUpTxt.setFormat(Main.gFont, 24, 0xFFFFFFFF, CENTER);
		popUpTxt.screenCenter(X);
		add(popUpTxt);

		options = new FlxText(0,400,0,'> OPTIONS <', 50);
		options.setFormat(Main.gFont, 50, 0xFFFFFFFF, CENTER);
		options.screenCenter(X);
		add(options);
		proceed = new FlxText(0,500,0,'PROCEED', 50);
		proceed.setFormat(Main.gFont, 50, 0xFFFFFFFF, CENTER);
		proceed.screenCenter(X);
		add(proceed);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if(Controls.justPressed(UI_UP) || Controls.justPressed(UI_DOWN))
		{
			selectingWhat = !selectingWhat;

			options.text = selectingWhat ? '> OPTIONS <' : 'OPTIONS';
			options.screenCenter(X);
			proceed.text = !selectingWhat ? '> PROCEED <' : 'PROCEED';
			proceed.screenCenter(X);

			FlxG.sound.play(Paths.sound('menu/scrollMenu'));
		}
		
		if(Controls.justPressed(ACCEPT))
		{
			if(selectingWhat)
				openSubState(new OptionsSubState(true));
			else {
				Main.switchState(new states.TitleState());

				FlxG.save.data.beenWarned = true;
				FlxG.save.flush();
			}
        }
	}
}