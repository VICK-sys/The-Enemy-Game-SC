package;

import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxTimer;

class TitleSequence extends FlxState 
{
    var modLogo:FlxSprite;

    override public function create() 
    {
        FlxG.mouse.visible = false;

        new FlxTimer().start(3, function(timer:FlxTimer) {
            modLogo = new FlxSprite(0, 0, "assets/images/logo.png");
            modLogo.screenCenter();

            FlxG.sound.playMusic("assets/sounds/teamIntro.ogg", 0.3, false);

            new FlxTimer().start(3, function(timer:FlxTimer) {
                FlxTween.tween(modLogo, {alpha: 0}, 1.5, {
                    ease:FlxEase.expoIn, 
                    onComplete: die
                });
            });

            new FlxTimer().start(0.18, function(timer:FlxTimer) {
                add(modLogo);
            });
        });
    }

    function die(tween:FlxTween):Void {
        skip();
    }

    function skip() {
        modLogo.kill();
        FlxG.switchState(new PlayState());
    }
}
