package objects;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxAxes;
import flxanimate.FlxAnimate;
import backend.utils.CharacterUtil;
import backend.utils.CharacterUtil.*;
import objects.note.Note;

using StringTools;

class Character extends FlxAnimate
{
	// dont mess with these unless you know what youre doing!
	// they are used in important stuff
	public var curChar:String = "bf";
	public var isPlayer:Bool = false;
	public var onEditor:Bool = false;
	public var specialAnim:Int = 0;
	public var curAnimFrame(get, never):Int;
	public var curAnimFinished(get, never):Bool;
	public var holdTimer:Float = Math.NEGATIVE_INFINITY;

	// time (in seconds) that takes to the character return to their idle anim
	public var holdLength:Float = 0.7;
	// when (in frames) should the character singing animation reset when pressing long notes
	public var holdLoop:Int = 4;

	// modify these for your liking (idle will cycle through every array value)
	public var idleAnims:Array<String> = ["idle"];
	public var altIdle:String = "";
	public var altSing:String = "";
	
	// true: dances every beat // false: dances every other beat
	public var quickDancer:Bool = false;

	// warning, only uses this
	// if the current character doesnt have game over anims
	public var deathChar:String = "bf-dead";

	// you can modify these manually but i reccomend using the offset editor instead
	public var globalOffset:FlxPoint = new FlxPoint();
	public var cameraOffset:FlxPoint = new FlxPoint();
	public var ratingsOffset:FlxPoint = new FlxPoint();
	private var scaleOffset:FlxPoint = new FlxPoint();

	// you're probably gonna use sparrow by default?
	var spriteType:SpriteType = SPARROW;

	public function new(curChar:String = "bf", isPlayer:Bool = false, onEditor:Bool = false)
	{
		super(0,0,false);
		this.onEditor = onEditor;
		this.isPlayer = isPlayer;
		this.curChar = curChar;
		
		antialiasing = FlxSprite.defaultAntialiasing;
		isPixelSprite = false;
		
		var doidoChar = CharacterUtil.defaultChar();
		switch(curChar)
		{
			case "gf":
				spriteType = ATLAS;
				doidoChar.spritesheet += 'gf/gf-spritemap';
				doidoChar.anims = [
					['sad',			'gf sad',			24, false, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]],
					['danceLeft',	'GF Dancing Beat',	24, false, [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]],
					['danceRight',	'GF Dancing Beat',	24, false, [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]],
					
					['cheer', 		'GF Cheer', 	24, false],
					['singLEFT', 	'GF left note', 24, false],
					['singRIGHT', 	'GF Right Note',24, false],
					['singUP', 		'GF Up Note', 	24, false],
					['singDOWN', 	'GF Down Note', 24, false],
				];

				idleAnims = ["danceLeft", "danceRight"];
				quickDancer = true;
				flipX = isPlayer;
			
			case "no-gf":
				doidoChar.spritesheet += 'gf/no-gf/no-gf';
				doidoChar.anims = [
					['idle', 'idle'],
				];

			case "dad":
				doidoChar.spritesheet += 'dad/DADDY_DEAREST';
				doidoChar.anims = [
					['idle', 		'Dad idle dance', 		24, false],
					['singUP', 		'Dad Sing Note UP', 	24, false],
					['singRIGHT', 	'Dad Sing Note RIGHT', 	24, false],
					['singDOWN', 	'Dad Sing Note DOWN', 	24, false],
					['singLEFT', 	'Dad Sing Note LEFT', 	24, false],

					['idle-loop', 		'Dad idle dance', 		24, true, [11,12,13,14]],
					['singUP-loop', 	'Dad Sing Note UP', 	24, true, [3,4,5,6]],
					['singRIGHT-loop',	'Dad Sing Note RIGHT', 	24, true, [3,4,5,6]],
					['singLEFT-loop', 	'Dad Sing Note LEFT', 	24, true, [3,4,5,6]],
				];

			case "bolho":
				doidoChar.spritesheet += 'bolho/bolho';
				doidoChar.anims = [
					// main
					['idle', 		'idle0', 		24, true],
					['singUP', 		'singing', 	24, false],
					['singRIGHT', 	'singing', 	24, false],
					['singDOWN', 	'singing', 	24, false],
					['singLEFT', 	'singing', 	24, false],

					// miss
					['singUPmiss', 		'hurt', 		24, false],
					['singLEFTmiss', 	'hurt', 	24, false],
					['singRIGHTmiss', 	'hurt', 	24, false],
					['singDOWNmiss', 	'hurt', 	24, false],

					// misc
					['changing',			'change',			24, true],
					['sleep',			'resting',			24, true],
					['sad',			'hurt',			24, false],
					['kill',		  'death',		24, false],

					// alts
					['idle-rata', 		'idle buraco', 		24, true],
					['idle-mine', 		'idle mine', 		24, true],

					// misc alt or something
					['getRat',			'turning rat',			24, false],
				];

			case "playtv":
				doidoChar.spritesheet += 'playtv/playtv2';
				doidoChar.anims = [
					['idle', 		'idle', 		24, false],
					['singUP', 		'up', 	24, false],
					['singRIGHT', 	'right', 	24, false],
					['singDOWN', 	'down', 	24, false],
					['singLEFT', 	'left', 	24, false],
				];
			scale.set(0.8, 0.8);

			case "paraLanchesNormal":
				doidoChar.spritesheet += 'adailton/adailton';
				doidoChar.anims = [
					['idle', 		'idle', 		24, false],
					['singUP', 		'up', 	24, false],
					['singRIGHT', 	'right', 	24, false],
					['singDOWN', 	'down', 	24, false],
					['singLEFT', 	'left', 	24, false],
				];
				scale.set(1.3, 1.3);

			case "para":
				doidoChar.spritesheet += 'adailton/para';
				doidoChar.anims = [
					['idle', 		'idle', 		24, true],
					['singUP', 		'up', 	24, false],
					['singRIGHT', 	'right', 	24, false],
					['singDOWN', 	'down', 	24, false],
					['singLEFT', 	'left', 	24, false],
				];
				scale.set(1.3, 1.3);
				
			case "pontoDaEsfihaNormal":
				doidoChar.spritesheet += 'esfiha/pontoDaEsfiha';
				doidoChar.anims = [
					['idle', 		'idle', 		24, true],
					['singUP', 		'up', 	24, false],
					['singRIGHT', 	'right', 	24, false],
					['singDOWN', 	'down', 	24, false],
					['singLEFT', 	'left', 	24, false],

					['singUPmiss', 		'miss', 		24, false],
					['singLEFTmiss', 	'miss', 	24, false],
					['singRIGHTmiss', 	'miss', 	24, false],
					['singDOWNmiss', 	'miss', 	24, false],
				];
			scale.set(1.3, 1.3);
			flipX = true;
			deathChar = "ponto-da-morte";

			case "esfiha":
				doidoChar.spritesheet += 'esfiha/esfiha';
				doidoChar.anims = [
					['idle', 		'idle', 		24, true],
					['singUP', 		'up', 	24, false],
					['singRIGHT', 	'right', 	24, false],
					['singDOWN', 	'down', 	24, false],
					['singLEFT', 	'left', 	24, false],
				];
			scale.set(1.3, 1.3);
			deathChar = "no-gf";
			flipX = true;

			case "bolhoBucks":
				doidoChar.spritesheet += 'bolho/17bucks';
				doidoChar.anims = [
					['idle', 		'bolho', 		24, true],
				];
				scale.set(1.3, 1.3);

			case "ponto-da-morte":
				doidoChar.spritesheet += 'esfiha/pontoDaEsfiha';
				doidoChar.anims = [
					['firstDeath', 		"dies", 			24, false],
					// ['deathLoop', 		"dieLoop", 	24, true],
					// ['deathConfirm', 	"dieEnd", 	24, false],
				];

				scale.set(1.3, 1.3);
				idleAnims = ['firstDeath'];
				flipX = true;

			case "esfiha-da-morte":
				doidoChar.spritesheet += 'esfiha/esfiha';
				doidoChar.anims = [
					['firstDeath', 		"dies", 			24, false],
					// ['deathLoop', 		"dieLoop", 	24, true],
					// ['deathConfirm', 	"dieEnd", 	24, false],
				];

				scale.set(1.3, 1.3);
				idleAnims = ['firstDeath'];
				flipX = true;

			case "davibrito":
				doidoChar.spritesheet += 'calabreso/davi';
				doidoChar.anims = [
					['idle', 		'idle', 		24, false],
					['singUP', 		'up', 	24, false],
					['singRIGHT', 	'right', 	24, false],
					['singDOWN', 	'down', 	24, false],
					['singLEFT', 	'left', 	24, false],
				];

			case "nhonho":
				doidoChar.spritesheet += 'nhonho/nhonho';
				doidoChar.anims = [
					['idle', 		'idle', 		24, false],
					['singUP', 		'up', 	24, false],
					['singRIGHT', 	'right', 	24, false],
					['singDOWN', 	'down', 	24, false],
					['singLEFT', 	'left', 	24, false],
				];

			case "girafodas":
				doidoChar.spritesheet += 'girafales/linguisa';
				doidoChar.anims = [
					['idle', 		'idle', 		24, false],
					['singUP', 		'up', 	24, false],
					['singRIGHT', 	'right', 	24, false],
					['singDOWN', 	'down', 	24, false],
					['singLEFT', 	'left', 	24, false],
				];

			case "caioX":
				doidoChar.spritesheet += 'caio/seloko';
				doidoChar.anims = [
						['idle', 		'idle', 		24, false],
						['singUP', 		'up', 	24, false],
						['singRIGHT', 	'right', 	24, false],
						['singDOWN', 	'down', 	24, false],
						['singLEFT', 	'left', 	24, false],
				];
				flipX = true;

			case "tralala":
				doidoChar.spritesheet += 'tralala/tralala';
				doidoChar.anims = [
					['idle', 		'idle', 		24, false],
					['singUP', 		'up0', 	24, false],
					['singRIGHT', 	'right0', 	24, false],
					['singDOWN', 	'down0', 	24, false],
					['singLEFT', 	'left0', 	24, false],
				];

			case "buraquinho":
				doidoChar.spritesheet += 'buraco/buraquinho';
				doidoChar.anims = [
					['idle', 		'idle', 		24, false],
					['singUP', 		'up', 	24, false],
					['singRIGHT', 	'right', 	24, false],
					['singDOWN', 	'down', 	24, false],
					['singLEFT', 	'left', 	24, false],
				];

			case "chaves":
				doidoChar.spritesheet += 'chaves/keys';
				doidoChar.anims = [
						['idle', 		'idle', 		24, true],
						['singUP', 		'up0', 	24, false],
						['singRIGHT', 	'right0', 	24, false],
						['singDOWN', 	'down0', 	24, false],
						['singLEFT', 	'left0', 	24, false],

						['singUPmiss', 		'up-miss', 		24, false],
						['singLEFTmiss', 	'left-miss', 	24, false],
						['singRIGHTmiss', 	'right-miss', 	24, false],
						['singDOWNmiss', 	'down-miss', 	24, false],
				];
				deathChar = "keys-morto";
				flipX = true;

			case "rebola":
				doidoChar.spritesheet += 'chaves/rebolando';
				doidoChar.anims = [
						['idle', 		'rebolaaaa', 		48, true],
				];
				deathChar = "keys-morto";
				flipX = true;

			case "keys-morto":
				doidoChar.spritesheet += 'chaves/keys';
				doidoChar.anims = [
					['firstDeath', 		"die0", 			24, false],
					['deathLoop', 		"die-loop", 	24, true],
					['deathConfirm', 	"die-retry", 	24, false],
				];
				idleAnims = ['firstDeath'];
				flipX = true;

			case "bebe":
				doidoChar.spritesheet += 'bebe/careca';
				doidoChar.anims = [
					['idle', 		'idle0', 		24, false],
					['singUP', 		'up0', 	24, false],
					['singRIGHT', 	'right0', 	24, false],
					['singDOWN', 	'down0', 	24, false],
					['singLEFT', 	'left0', 	24, false],

					['idle-alt', 		'idle-violao', 		24, false],
					['singUP-alt', 		'up-violao', 	24, false],
					['singRIGHT-alt', 	'right-violao', 	24, false],
					['singDOWN-alt', 	'down-violao', 	24, false],
					['singLEFT-alt', 	'left-violao', 	24, false],
				];
			scale.set(0.8, 0.8);

			case "silly":
				doidoChar.spritesheet += '17quedas/silly beta';
				doidoChar.anims = [
					['idle', 		'idle', 		24, false],
					['singUP', 		'up', 	24, false],
					['singRIGHT', 	'right', 	24, false],
					['singDOWN', 	'down', 	24, false],
					['singLEFT', 	'left', 	24, false],
				];

			case "olhodo-gf":
				doidoChar.spritesheet += '17quedas/olhodoSilly';
				doidoChar.anims = [
					['idle', 'idle', 24, true],
				];

			case "beta":
				doidoChar.spritesheet += '17quedas/beta';
				doidoChar.anims = [
					['idle', 			'IDLE', 		24, false],
					['singUP', 			'UP0', 			24, false],
					['singRIGHT', 		'RIGHT0', 		24, false],
					['singLEFT', 		'LEFT0', 		24, false],
					['singDOWN', 		'DOWN0', 		24, false],

					['singUPmiss', 		'upmiss', 		24, false],
					['singLEFTmiss', 	'leftmiss', 	24, false],
					['singRIGHTmiss', 	'rightmiss', 	24, false],
					['singDOWNmiss', 	'downmiss', 	24, false],
					['hey', 			'upalt', 				24, false]
				];
				flipX = true;
				deathChar = "beta-dead";

			case "beta-dead":
				doidoChar.spritesheet += '17quedas/beta';
				doidoChar.anims = [
					['firstDeath', 		"dieStart", 			24, false],
					['deathLoop', 		"dieLoop", 	24, true],
					['deathConfirm', 	"dieEnd", 	24, false],
				];

				idleAnims = ['firstDeath'];
				
				flipX = true;

			case "girlfriend-opponent":
				doidoChar.spritesheet += 'gf/girlfriend';
				doidoChar.anims = [
					['idle', 		'idle', 		24, false],
					['singUP', 		'up0', 	24, false],
					['singRIGHT', 	'right0', 	24, false],
					['singDOWN', 	'down0', 	24, false],
					['singLEFT', 	'left0', 	24, false],
				];
			
			case "girlfriend":
				doidoChar.spritesheet += 'gf/girlfriend';
				doidoChar.anims = [
					['idle', 		'idle', 		24, false],
					['singUP', 		'up0', 	24, false],
					['singRIGHT', 	'left0', 	24, false],
					['singDOWN', 	'down0', 	24, false],
					['singLEFT', 	'right0', 	24, false],
					['singUPmiss', 		'up miss', 		24, false],
					['singLEFTmiss', 	'right miss', 	24, false],
					['singRIGHTmiss', 	'left miss', 	24, false],
					['singDOWNmiss', 	'down miss', 	24, false],
				];
				deathChar = "gf-dead";

			case "bf mine":
				doidoChar.spritesheet += 'bf/minecraft';
				doidoChar.anims = [
					['idle', 		'idle0', 		24, false],
					['singUP', 		'up0', 	24, false],
					['singLEFT', 	'left0', 	24, false],
					['singDOWN', 	'down0', 	24, false],
					['singRIGHT', 	'right0', 	24, false],

					['idle-alt', 		'idle-V', 		24, false],
					['singUP-alt', 		'viola o tocao', 		24, false],
					['singRIGHT-alt', 		'viola o tocao', 		24, false],
					['singLEFT-alt', 		'viola o tocao', 		24, false],
					['singDOWN-alt', 		'viola o tocao', 		24, false],
				];
				flipX = true;

			default: // case "bf"
				if(!["bf", "face"].contains(curChar))
					curChar = (isPlayer ? "bf" : "face");

				if(curChar == "bf")
				{
					doidoChar.spritesheet += 'bf/BOYFRIEND';
					doidoChar.anims = [
						['idle', 			'idle0', 		24, false],
						['singUP', 			'up0', 			24, false],
						['singLEFT', 		'left0', 		24, false],
						['singRIGHT', 		'right0', 		24, false],
						['singDOWN', 		'down0', 		24, false],
						['idlemiss', 			'idle miss', 		24, false],
						['singUPmiss', 		'up miss', 		24, false],
						['singLEFTmiss', 	'left miss', 	24, false],
						['singRIGHTmiss', 	'right miss', 	24, false],
						['singDOWNmiss', 	'down miss', 	24, false],
						['hey', 			'hey', 				24, false],
						['PLEASE', 			'please', 		24, false]
					];
					flipX = true;
				}
				else if(curChar == "face")
				{
					spriteType = ATLAS;
					doidoChar.spritesheet += 'face';
					doidoChar.anims = [
						['idle', 			'idle-alive', 		24, false],
						['idlemiss', 		'idle-dead', 		24, false],

						['singLEFT', 		'left-alive', 		24, false],
						['singDOWN', 		'down-alive', 		24, false],
						['singUP', 			'up-alive', 		24, false],
						['singRIGHT', 		'right-alive', 		24, false],
						['singLEFTmiss', 	'left-dead', 		24, false],
						['singDOWNmiss', 	'down-dead', 		24, false],
						['singUPmiss', 		'up-dead', 			24, false],
						['singRIGHTmiss', 	'right-dead', 		24, false],
					];
				}
				this.curChar = curChar;
			
			case "bf-dead":
				doidoChar.spritesheet += 'bf/BOYFRIEND_GETTING_BRUTALLY_MURDERED';
				doidoChar.anims = [
					['firstDeath', 		"firstDeath", 			24, false],
					['deathLoop', 		"deathLoop", 	24, true],
					['deathConfirm', 	"acceptDeath", 	24, false],
				];

				idleAnims = ['firstDeath'];
				flipX = true;

			case "gf-dead":
				doidoChar.spritesheet += 'gf/GIRLFRIEND_GETTING_BRUTALLY_MURDERED';
				doidoChar.anims = [
					['firstDeath', 		"dieStart", 			24, false],
					['deathLoop', 		"dieBumpin", 	24, true],
					['deathConfirm', 	"dieConfirm", 	24, false],
				];

				idleAnims = ['firstDeath'];
				flipX = true;
		}

		if(isPixelSprite) antialiasing = false;

		if(spriteType != ATLAS)
		{
			if(Paths.fileExists('images/${doidoChar.spritesheet}.txt')) {
				frames = Paths.getPackerAtlas(doidoChar.spritesheet);
				spriteType = PACKER;
			}
			else if(Paths.fileExists('images/${doidoChar.spritesheet}.json')) {
				frames = Paths.getAsepriteAtlas(doidoChar.spritesheet);
				spriteType = ASEPRITE;
			}
			else if(doidoChar.extrasheets != null) {
				frames = Paths.getMultiSparrowAtlas(doidoChar.spritesheet, doidoChar.extrasheets);
				spriteType = MULTISPARROW;
			}
			else
				frames = Paths.getSparrowAtlas(doidoChar.spritesheet);

			for(i in 0...doidoChar.anims.length)
			{
				var anim:Array<Dynamic> = doidoChar.anims[i];
				if(anim.length > 4)
					animation.addByIndices(anim[0],  anim[1], anim[4], "", anim[2], anim[3]);
				else
					animation.addByPrefix(anim[0], anim[1], anim[2], anim[3]);
			}
		}
		else
		{
			// :shushing_face:
			isAnimateAtlas = true;

			loadAtlas(Paths.getPath('images/${doidoChar.spritesheet}'));
			showPivot = false;
			for(i in 0...doidoChar.anims.length)
			{
				var dAnim:Array<Dynamic> = doidoChar.anims[i];
				if(dAnim.length > 4)
					anim.addBySymbolIndices(dAnim[0], dAnim[1], dAnim[4], dAnim[2], dAnim[3]);
				else
					anim.addBySymbol(dAnim[0], dAnim[1], dAnim[2], dAnim[3]);
			}
		}

		// adding animations to array
		for(i in 0...doidoChar.anims.length) {
			var daAnim = doidoChar.anims[i][0];
			if(animExists(daAnim) && !animList.contains(daAnim))
				animList.push(daAnim);
		}

		// prevents crashing
		for(i in 0...idleAnims.length)
		{
			if(!animList.contains(idleAnims[i]))
				idleAnims[i] = animList[0];
		}
		
		// offset gettin'
		switch(curChar)
		{
			default:
				try {
					var charData:DoidoOffsets = cast Paths.json('images/characters/_offsets/${curChar}');
					
					for(i in 0...charData.animOffsets.length)
					{
						var animData:Array<Dynamic> = charData.animOffsets[i];
						addOffset(animData[0], animData[1], animData[2]);
					}
					globalOffset.set(charData.globalOffset[0], charData.globalOffset[1]);
					cameraOffset.set(charData.cameraOffset[0], charData.cameraOffset[1]);
					ratingsOffset.set(charData.ratingsOffset[0], charData.ratingsOffset[1]);
				} catch(e) {
					Logs.print('$curChar offsets not found', WARNING);
				}
		}
		
		playAnim(idleAnims[0]);

		updateHitbox();
		scaleOffset.set(offset.x, offset.y);

		if(isPlayer)
			flipX = !flipX;

		dance();
	}

	private var curDance:Int = 0;

	public function dance(forced:Bool = false)
	{
		if(specialAnim > 0) return;

		switch(curChar)
		{
			default:
				var daIdle = idleAnims[curDance];
				if(animExists(daIdle + altIdle))
					daIdle += altIdle;
				playAnim(daIdle);
				curDance++;

				if (curDance >= idleAnims.length)
					curDance = 0;
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if(!onEditor)
		{
			if(animExists(curAnimName + '-loop') && curAnimFinished)
				playAnim(curAnimName + '-loop');
	
			if(specialAnim > 0 && specialAnim != 3 && curAnimFinished)
			{
				specialAnim = 0;
				dance();
			}
		}
	}

	public var singAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	public function playNote(note:Note, miss:Bool = false)
	{
		var daAnim:String = singAnims[note.noteData];
		if(animExists(daAnim + 'miss') && miss)
			daAnim += 'miss';

		if(animExists(daAnim + altSing))
			daAnim += altSing;

		holdTimer = 0;
		specialAnim = 0;
		playAnim(daAnim, true);
	}

	// animation handler
	public var curAnimName:String = '';
	public var animList:Array<String> = [];
	public var animOffsets:Map<String, Array<Float>> = [];

	public function addOffset(animName:String, offX:Float = 0, offY:Float = 0):Void
		return animOffsets.set(animName, [offX, offY]);

	public function playAnim(animName:String, ?forced:Bool = false, ?reversed:Bool = false, ?frame:Int = 0)
	{
		if(!animExists(animName)) return;
		
		curAnimName = animName;
		if(spriteType != ATLAS)
			animation.play(animName, forced, reversed, frame);
		else
			anim.play(animName, forced, reversed, frame);
		
		try
		{
			var daOffset = animOffsets.get(animName);
			offset.set(daOffset[0] * scale.x, daOffset[1] * scale.y);
		}
		catch(e)
			offset.set(0,0);

		// useful for pixel notes since their offsets are not 0, 0 by default
		offset.x += scaleOffset.x;
		offset.y += scaleOffset.y;
	}

	public function invertDirections(axes:FlxAxes = NONE)
	{
		switch(axes) {
			case X:
				singAnims = ['singRIGHT', 'singDOWN', 'singUP', 'singLEFT'];
			case Y:
				singAnims = ['singLEFT', 'singUP', 'singDOWN', 'singRIGHT'];
			case XY:
				singAnims = ['singRIGHT', 'singUP', 'singDOWN', 'singLEFT'];
			default:
				singAnims = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
		}
	}

	public function pauseAnim()
	{
		if(spriteType != ATLAS)
			animation.pause();
		else
			anim.pause();
	}

	public function animExists(animName:String):Bool
	{
		if(spriteType != ATLAS)
			return animation.getByName(animName) != null;
		else
			return anim.getByName(animName) != null;
	}

	public function get_curAnimFrame():Int
	{
		if(spriteType != ATLAS)
			return animation.curAnim.curFrame;
		else
			return anim.curSymbol.curFrame;
	}

	public function get_curAnimFinished():Bool
	{
		if(spriteType != ATLAS)
			return animation.curAnim.finished;
		else
			return anim.finished;
	}
}