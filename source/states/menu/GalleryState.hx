package states.menu;

import flixel.FlxG;
import flixel.FlxObject;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import backend.game.GameData.MusicBeatState;
import backend.game.GameTransition;
import subStates.options.OptionsSubState;

class GalleryState extends MusicBeatState
{
    var blackBar:FlxSprite;
    var galleryImage:FlxSprite; 
    var galleryGroup:FlxTypedGroup<FlxSprite>;
    var arrowGroup:FlxTypedGroup<FlxSprite>;
    var descricoesTxt:FlxText;

    var camFollow:FlxObject = new FlxObject();
    var inImage:Int;

    var maxImages = 15; // aaa
    var descricoes:Array<String> = [
    ];

    override function create()
    {
        super.create();

        FlxG.camera.bgColor = 0xFFFFFFFF;
        FlxG.camera.follow(camFollow, null, 0.15);

        // inImage = Math.floor((maxImages-1)/2);
        for(i in 0...maxImages)
            descricoes.push(CoolUtil.getDescDescs(i));

        var blackBarF = new FlxSprite().makeGraphic(1280, 40, FlxColor.BLACK);
        blackBarF.scrollFactor.set();
        blackBarF.alpha = 0.69;

        var funny = new FlxText(0,10,0, CoolUtil.getLangText(10));
        funny.setFormat(Main.gFont, 20, 0xFFFFFFFF, CENTER);
		funny.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        funny.scrollFactor.set();
        funny.screenCenter(X);
		
        galleryGroup = new FlxTypedGroup<FlxSprite>();
        for(i in 0...maxImages) {
            galleryImage = new FlxSprite(0,0,Paths.image('gallery/$i'));
            galleryImage.screenCenter();
            galleryImage.x = (i != 0) ? galleryGroup.members[i-1].x + galleryGroup.members[i-1].width - 20 : 0; // nao retorna null
            galleryImage.scale.set(1-(Math.abs(inImage-i)/10)*2, 1-(Math.abs(inImage-i)/10)*2);
            galleryImage.alpha = 1-(Math.abs(inImage-i)/10)*2;
            galleryGroup.add(galleryImage);
        }   

        arrowGroup = new FlxTypedGroup<FlxSprite>();
        for(i in 0...2) { // so para nao repetir argumento
            var arrow = new FlxSprite(5+1120*i);
            arrow.scrollFactor.set();
		    arrow.frames = Paths.getSparrowAtlas('menu/gallery/arrow');
            arrow.animation.addByPrefix('press', '$i', 24, false);
            arrow.animation.play('press', false, 5);
            arrow.screenCenter(Y);
            arrowGroup.add(arrow);
            arrow.scale.set(0.69, 0.69);

            arrow.ID = i;
        }

        blackBar = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        blackBar.scrollFactor.set();
        blackBar.alpha = 0.69;

		descricoesTxt = new FlxText(0,0,0, "hello");
        descricoesTxt.setFormat(Main.gFont, 20, 0xFFFFFFFF, CENTER);
		descricoesTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        descricoesTxt.scrollFactor.set();

        add(galleryGroup);
        add(arrowGroup);
        add(blackBarF);
        add(funny);
        add(blackBar);
        add(descricoesTxt);
    
        changeTheImage(0, true);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(Controls.justPressed(BACK))
            Main.switchState(new MainMenuState());

        if(Controls.justPressed(UI_RIGHT) || Controls.justPressed(UI_LEFT))
            changeTheImage(Controls.justPressed(UI_RIGHT) ? 1 : -1);

        if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(arrowGroup)) {
            arrowGroup.forEach(function(theButton:FlxSprite) {
                if(FlxG.mouse.overlaps(theButton)) changeTheImage(theButton.ID==0?-1:1);
            });
        }

        for(i in 0...maxImages) {
            var valor = 1-(Math.abs(inImage-i)/10)*2;
            galleryGroup.members[i].scale.set(FlxMath.lerp(galleryGroup.members[i].scale.x, valor, 10 * elapsed), FlxMath.lerp(galleryGroup.members[i].scale.y, valor, 10 * elapsed));
            galleryGroup.members[i].alpha = FlxMath.lerp(galleryGroup.members[i].alpha, valor, 10 * elapsed);
        }

        blackBar.scale.set(FlxMath.lerp(blackBar.scale.x, descricoesTxt.width+20, elapsed*8), FlxMath.lerp(blackBar.scale.y, descricoesTxt.height+20, elapsed*8));
        blackBar.setPosition(descricoesTxt.getMidpoint().x, descricoesTxt.getMidpoint().y);
    }

    function changeTheImage(addStuff:Int, ?firstShit:Bool = false)
    {
        inImage += addStuff;
        inImage = FlxMath.wrap(inImage, 0, maxImages-1);

        descricoesTxt.text = '"${descricoes[inImage]}"';
        descricoesTxt.setPosition(640-(descricoesTxt.width/2), 720-(descricoesTxt.height+20));

        camFollow.setPosition(galleryGroup.members[inImage].getMidpoint().x, 360);

        if(!firstShit)arrowGroup.members[addStuff==-1?0:1].animation.play('press');
        else blackBar.scale.set(descricoesTxt.width+20, descricoesTxt.height+20);
    }
}