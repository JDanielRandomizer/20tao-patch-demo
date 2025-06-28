package objects.hud;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import backend.song.Conductor;
import backend.song.Timings;
import states.PlayState;

class HudClass extends FlxGroup
{
	public var ratingGrp:FlxGroup;
	public var infoTxt:FlxText;
	public var timeTxt:FlxText;
	
	var botplaySin:Float = 0;
	var botplayTxt:FlxText;
	var badScoreTxt:FlxText;

	var arrayFDP = [CoolUtil.getLangText(31), CoolUtil.getLangText(32), CoolUtil.getLangText(33)];

	// health bar
	public var healthBar:HealthBar;
	public var health:Float = 1;

	// credits
	public static var box:FlxSprite;
	public static var cred:FlxText;
	public static var theSongCredits:Map<String,Array<String>> = [ // nome || musico || charter || sprites
		"play-tv" => ['PLAY TV', 'Siwiki', 'AINDA INCOMPLETO', 'Maxxer & JDaniel'],
		"paralanches" => ['#ParáLanches', 'CarlosPlay231', 'NineFds', 'JDaniel'],
		"papai-calabreso" => ['PAPAI CALABRESO', 'NineFds', 'JDaniel', 'JDaniel'],
		"slk-tralaleiro-tralala-ta-todo-safadeza" => ['SLK TRALALEIRO TRALALA TA TODO SAFADEZA', 'NineFds', 'Maxxer', 'Maxxer & JDaniel'],
		"chaves" => ['MEUZOVO', 'NineFds', 'Maxxer', 'Siwiki, Maxxer & JDaniel'],
		"buraquinho" => ['ME DA SEU RATINHO', 'NineFds', 'Maxxer', 'Maxxer & JDaniel'],
		"calvice-prematura" => ['CALVICE PREMATURA', 'NineFds', 'Maxxer', 'Maxxer & JDaniel'],
		"como-cantar" => ['COMO CANTAR (atualizado 2025 desgraca)', 'NineFds', 'Maxxer', 'JDaniel'],
		"silly-beta" => ['SILLY BETA', 'Over647', 'Maxxer', 'JDaniel'],
	];

	public function new()
	{
		super();
		ratingGrp = new FlxGroup();
		add(ratingGrp);
		
		healthBar = new HealthBar();
		changeIcon(0, healthBar.icons[0].curIcon);
		add(healthBar);
		
		infoTxt = new FlxText(0, 0, 0, "hi there! i am using whatsapp");
		infoTxt.setFormat(Main.gFont, 20, 0xFFFFFFFF, CENTER);
		infoTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		add(infoTxt);
		
		timeTxt = new FlxText(0, 0, 0, "nuts / balls even");
		timeTxt.setFormat(Main.gFont, 32, 0xFFFFFFFF, CENTER);
		timeTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		timeTxt.visible = SaveData.data.get('Song Timer');
		add(timeTxt);
		
		badScoreTxt = new FlxText(0,0,0,"SCORE WILL NOT BE SAVED");
		badScoreTxt.setFormat(Main.gFont, 26, 0xFFFF0000, CENTER);
		badScoreTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		badScoreTxt.screenCenter(X);
		badScoreTxt.visible = false;
		add(badScoreTxt);
		
		botplayTxt = new FlxText(0,0,0,"[BOTPLAY]");
		botplayTxt.setFormat(Main.gFont, 40, 0xFFFFFFFF, CENTER);
		botplayTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		botplayTxt.screenCenter();
		botplayTxt.visible = false;
		add(botplayTxt);

		box = new FlxSprite();
		add(box);

		trace(PlayState.SONG.song);
		var informacoesLegais:Array<String> = theSongCredits.get(PlayState.SONG.song);
		cred = new FlxText(0, 0, 0, '${informacoesLegais[0]}\n${CoolUtil.getLangText(38)}: ${informacoesLegais[1]}\ncharter: ${informacoesLegais[2]}\nsprites: ${informacoesLegais[3]}');
		cred.setFormat(Main.gFont, 20, FlxColor.BLACK, LEFT);
		cred.setBorderStyle(OUTLINE, FlxColor.WHITE, 1.5);
		add(cred);

		setupCredbox();
		updateHitbox();
		health = PlayState.health;
	}

	public final separator:String = " - ";

	public function updateText()
	{
		infoTxt.text = "";
		
		infoTxt.text += 			arrayFDP[0]	+	': '		+ Timings.score;
		infoTxt.text += separator +	arrayFDP[1] +': '	+ Timings.accuracy + "%" + ' [${Timings.getRank()}]';
		infoTxt.text += separator +	arrayFDP[2] + ': '		+ Timings.misses;

		infoTxt.screenCenter(X);
	}
	
	public function updateTimeTxt()
	{
		var displayedTime:Float = Conductor.songPos;
		if(Conductor.songPos > PlayState.songLength)
			displayedTime = PlayState.songLength;
		
		timeTxt.text
		= CoolUtil.posToTimer(displayedTime)
		+ ' / '
		+ CoolUtil.posToTimer(PlayState.songLength);
		timeTxt.screenCenter(X);
	}

	public function updateHitbox(downscroll:Bool = false)
	{
		healthBar.bg.x = (FlxG.width / 2) - (healthBar.bg.width / 2);
		healthBar.bg.y = (downscroll ? 70 : FlxG.height - healthBar.bg.height - 50);
		healthBar.updatePos();
		
		updateText();
		infoTxt.screenCenter(X);
		infoTxt.y = healthBar.bg.y + healthBar.bg.height + 4;
		
		badScoreTxt.y = healthBar.bg.y - badScoreTxt.height - 4;
		
		updateTimeTxt();
		timeTxt.y = downscroll ? (FlxG.height - timeTxt.height - 8) : (8);
	}
	
	public function setAlpha(hudAlpha:Float = 1, ?tweenTime:Float = 0, ?ease:String = "cubeout")
	{
		// put the items you want to set invisible when the song starts here
		var allItems:Array<FlxSprite> = [
			infoTxt,
			timeTxt,
			healthBar.bg,
			healthBar.sideL,
			healthBar.sideR,
		];
		for(icon in healthBar.icons)
			allItems.push(icon);
		
		for(item in allItems)
		{
			if(tweenTime <= 0)
				item.alpha = hudAlpha;
			else
				FlxTween.tween(item, {alpha: hudAlpha}, tweenTime, {ease: CoolUtil.stringToEase(ease)});
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		health = FlxMath.lerp(health, PlayState.health, elapsed * 8);
		if(Math.abs(health - PlayState.health) <= 0.00001)
			health = PlayState.health;
		
		healthBar.percent = (health * 50);
		
		botplayTxt.visible = PlayState.botplay;
		badScoreTxt.visible = !PlayState.validScore;
		
		if(botplayTxt.visible)
		{
			botplaySin += elapsed * Math.PI;
			botplayTxt.alpha = 0.5 + Math.sin(botplaySin) * 0.8;
		}

		healthBar.updateIconPos();
		updateTimeTxt();
	}

	public function changeIcon(iconID:Int = 0, newIcon:String = "face")
	{
		healthBar.changeIcon(iconID, newIcon);
	}

	public function beatHit(curBeat:Int = 0)
	{
		if(curBeat % 2 == 0)
		{
			for(icon in healthBar.icons)
			{
				icon.scale.set(1.3,1.3);
				icon.updateHitbox();
				healthBar.updateIconPos();
			}
		}
	}

	function setupCredbox()
	{
		box.makeGraphic(Math.floor(cred.width+20), Math.floor(cred.height+20), FlxColor.BLACK);
		box.alpha = 0.69;
		cred.x = -(cred.width+10);
		box.x = -(cred.width+20);

		box.screenCenter(Y);
		cred.screenCenter(Y);
	}

	public function moveToShow() // meio merda
	{
		FlxTween.tween(box, {x:0}, 0.5, {ease: FlxEase.expoOut});
		FlxTween.tween(cred, {x:10}, 0.5, {ease: FlxEase.expoOut});

		FlxTween.tween(box, {x:-(cred.width+20)}, 0.5, {ease: FlxEase.expoIn, startDelay: 3, onComplete: function(a:FlxTween){box.destroy();}});
		FlxTween.tween(cred, {x:-(cred.width+10)}, 0.5, {ease: FlxEase.expoIn, startDelay: 3, onComplete: function(a:FlxTween){cred.destroy();}});
	}
}