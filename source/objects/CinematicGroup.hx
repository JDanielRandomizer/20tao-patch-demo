package objects;

import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.math.FlxMath;

class CinematicGroup extends FlxTypedGroup<FlxSprite>
{
    public static var bar1:FlxSprite;
    public static var bar2:FlxSprite;

    public static var meMata:Array<Float> = 
    []; // bar1, bar2

    public function new()
    {
        super();

        bar1 = new FlxSprite(FlxG.width, -260).makeGraphic(FlxG.width, 360, FlxColor.BLACK);
        add(bar1);

        bar2 = new FlxSprite(-FlxG.width, FlxG.height-100).makeGraphic(FlxG.width, 360, FlxColor.BLACK);
        add(bar2);

        chavesMalandro(FlxG.width,-FlxG.width);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        bar1.x = FlxMath.lerp(bar1.x, meMata[0], 10 * elapsed);
        bar2.x = FlxMath.lerp(bar2.x, meMata[1], 10 * elapsed);
    }

    public function chavesMalandro(event1, event2)
    {
        meMata = [event1, event2];
    }
}