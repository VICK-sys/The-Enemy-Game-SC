package;

import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import flixel.util.FlxTimer;

class TitleSequence extends FlxState 
{
    var modLogo:FlxSprite;
    var modLogoAnimated:FlxSprite;

    override public function create() 
    {
        FlxG.mouse.visible = false;

        new FlxTimer().start(3, function(timer:FlxTimer) {
            modLogo = new FlxSprite(0, 0, "assets/images/logo.png");
            modLogo.screenCenter();
            modLogo.scale.set(0.8, 0.8);

            modLogoAnimated = new FlxSprite(0, 0, "assets/images/Im_only_an_artist_after_all.png");
            modLogoAnimated.frames = FlxAtlasFrames.fromSparrow("assets/images/Im_only_an_artist_after_all.png", "assets/images/Im_only_an_artist_after_all.xml");
            modLogoAnimated.animation.addByPrefix("idle", "TEEM", 24, false);
            modLogoAnimated.antialiasing = false;
            modLogoAnimated.visible = false;
            modLogoAnimated.screenCenter();
            add(modLogoAnimated);     

            FlxG.sound.playMusic("assets/sounds/teamIntro.ogg", 0.3, false);

            new FlxTimer().start(2, function(timer:FlxTimer) {
               // modLogo.visible = false;
                //modLogoAnimated.visible = true;
                //modLogoAnimated.animation.play("idle", false);
            });

            new FlxTimer().start(0.18, function(timer:FlxTimer) {
                //add(modLogo);
                modLogoAnimated.visible = true;
                modLogoAnimated.animation.play("idle", false);
            });

            new FlxTimer().start(3, function(timer:FlxTimer) {
                FlxTween.tween(modLogoAnimated, {alpha: 0}, 4.5, {
                    ease:FlxEase.expoIn, 
                    onComplete: die
                });
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
