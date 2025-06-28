package objects.hud;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import backend.utils.CharacterUtil;

class HealthIcon extends FlxSprite
{
	public function new()
	{
		super();
	}

	public var isPlayer:Bool = false;
	public var curIcon:String = "";
	public var maxFrames:Int = 0;

	public function setIcon(curIcon:String = "face", isPlayer:Bool = false):HealthIcon
	{
		this.curIcon = curIcon;
		if(!Paths.fileExists('images/icons/icon-${curIcon}.png'))
		{
			if(curIcon.contains('-'))
				return setIcon(CharacterUtil.formatChar(curIcon), isPlayer);
			else
				return setIcon("face", isPlayer);
		}

		var iconGraphic = Paths.image("icons/icon-" + curIcon);

		maxFrames = Math.floor(iconGraphic.width / 150);

		loadGraphic(iconGraphic, true, Math.floor(iconGraphic.width / maxFrames), iconGraphic.height);

		antialiasing = FlxSprite.defaultAntialiasing;
		isPixelSprite = false;
		if(curIcon.contains('pixel'))
		{
			antialiasing = false;
			isPixelSprite = true;
		}

		animation.add("icon", [for(i in 0...maxFrames) i], 0, false);
		animation.play("icon");

		this.isPlayer = isPlayer;
		flipX = isPlayer;

		return this;
	}

	public function setAnim(health:Float = 1)
	{
		health /= 2;
		var daFrame:Int = 0;

		if(health < 0.3)
			daFrame = 1;

		if(health > 0.7)
			daFrame = 2;

		if(daFrame >= maxFrames)
			daFrame = 0;

		animation.curAnim.curFrame = daFrame;
	}

	public static function getColor(char:String = ""):FlxColor
	{
		var colorMap:Map<String, FlxColor> = [
			"face" => 0xFFA1A1A1,
			"bf"  => 0xff6699cc,
			"girlfriend" => 0xFFA8146C,
			"girlfriend-opponent" => 0xFFA8146C,
			"gf" => 0xFFA5004D,
			"dad" => 0xFFAF66CE,
			"silly"	=> 0xff97C91A,
			"beta"	=> 0xffe9ff48,
			"para" => 0xff9a1e1d,
			"esfiha" => 0xff9a1e1d,
			"paraLanchesNormal" => 0xFFFFCC00,
			"pontoDaEsfihaNormal" => 0xFFCC0033,
			"davibrito" => 0xFF66CC66,
			"playtv" => 0xFFDE2929,
			"caioX" => 0xFF3333FF,
			"buraquinho" => 0xFF666699,
			"tralaleiro" => 0xFF0099FF,
			"tralala" => 0xFF0099FF,
			"nhonho" => 0xFF669966,
			"chaves" => 0xFF669933,
			"rebola" => 0xFF669933,
			"bebe" =>  0xFF9DC9E6,
			"bf mine"  => 0xff6699cc,
			"girafodas" => 0xFFFFCC33,
		];

		function loopMap()
		{
			if(!colorMap.exists(char))
			{
				if(char.contains('-'))
				{
					char = CharacterUtil.formatChar(char);
					loopMap();
				}
				else
					char = "face";
			}
		}
		loopMap();

		return colorMap.get(char);
	}
}