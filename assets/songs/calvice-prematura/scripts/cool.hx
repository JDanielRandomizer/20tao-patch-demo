import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import backend.utils.CoolUtil;
import Paths;
var grad:FlxSprite;
function createPost()
{
    grad = new FlxSprite(0,0, Paths.image('songsAssets/grad'));
    grad.cameras = [this.camHUD];
    grad.alpha = 0;
    this.insert(0, grad);
}
function onEventHit(name, v1, v2, v3) {
    if(name == 'Song Script Event' && v1 == 'gradAlpha')
        FlxTween.tween(grad,{alpha: CoolUtil.stringToFloat(v2)},1);
}
function stepHit(s)
    if(s == 1071) {this.boyfriend.char.altIdle = '-alt'; this.boyfriend.char.altSing = '-alt'; this.dad.char.altIdle = '-alt'; this.dad.char.altSing = '-alt';}