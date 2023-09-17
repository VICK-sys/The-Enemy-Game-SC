import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import openfl.utils.Assets;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;
//import motion.Actuate;

/**
 * Class to represent the player character.
 */
class Player extends FlxSprite
{
	// A constant to represent how fast the player can move.
	static inline var MOVEMENT_SPEED:Float = 450;
	var intialSpeed:Float = 50;
	var velocityTween:VarTween;
	private var walkingSound:FlxSound;
	var walkSound:Bool = false;

	public static var blockMovement:Bool = false;

	/**
	 * Player class' constructor. Used to set the player's initial position
	 * along with a few other things we need to initialize when creating the 
	 * player.
	 * @param x The X position of the player. 
	 * @param y The Y position of the player.
	 */
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		this.loadGraphic("assets/images/characters/mufu.png", true, 20, 23);
		this.frames = FlxAtlasFrames.fromSparrow("assets/images/characters/mufu.png", "assets/images/characters/mufu.xml");
		this.animation.addByPrefix("idle", "Idle", 12, true);
		this.animation.addByPrefix("walk", "Run", 12, true);
		this.animation.addByPrefix("hurt", "Hurt", 12, false);
		this.animation.addByPrefix("death", "Death", 12, false);
		this.antialiasing = false;
		this.width = 75;
		this.height = 95;
		this.offset.set(-19, -17);
		this.scale.set(4, 4);

		drag.x = drag.y = 700;
	}

	override function update(elapsed:Float)
	{
		if (!blockMovement) movement();

		super.update(elapsed);
	}

	private function movement()
	{
		// Initial variable setup to represent the direction in which the
		// player character is moving.
		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;

		// Check for user input.
		up = FlxG.keys.anyPressed([W]);
		down = FlxG.keys.anyPressed([S]);
		left = FlxG.keys.anyPressed([A]);
		right = FlxG.keys.anyPressed([D]);

		// Check to make sure that the user isn't pressing opposite keys
		// at the same time.
		if (up && down)
		{
			up = down = false;
		}

		if (right && left)
		{
			right = left = false;
		}

		if (up || down || left || right)
		{
			var newAngle:Float = 0;

			if(!walkSound)
			{
				var soundOptions:Array<String> = [
					"assets/sounds/walk/wave.ogg"
				];
				
				var randomSound:String = soundOptions[Std.random(soundOptions.length)];
				
				walkingSound = FlxG.sound.load(randomSound);
				walkingSound.looped = true;  // Make the sound loop continuously
				walkingSound.play();
				walkSound = true;
			}

			if(intialSpeed < MOVEMENT_SPEED)
			{
				intialSpeed += 15;
			}
	
			if(intialSpeed >= MOVEMENT_SPEED)
			{
				intialSpeed = MOVEMENT_SPEED;
			}

			// If moving, play the walk animation.
			this.animation.play("walk");
	
			if (up)
			{
				newAngle = -90;
	
				if (left)
				{
					newAngle -= 45;	
				}
				else if (right)
				{
					newAngle += 45;
				}
			}
			else if (down)
			{
				newAngle = 90;
	
				if (left)
				{
					newAngle += 45;
				}
				else if (right)
				{
					newAngle -= 45;
				}
			}
			else if (left)
			{
				newAngle = 180;
				this.flipX = true;  // Flip the sprite when moving left
			}
			else if (right)
			{
				newAngle = 0;
				this.flipX = false; // Do not flip (or unflip) when moving right
			}
	
			velocity.set(intialSpeed, 0);
			velocity.rotate(FlxPoint.weak(0, 0), newAngle);
		}
		else
		{
			// If not moving, revert back to the idle animation.
			this.animation.play("idle");
			//Actuate.tween(this, 2, {MOVEMENT_SPEED: 0}).ease(Quad.easeOut);

			if(walkSound)
			{
				walkingSound.stop();  // Stop the walking sound
				walkSound = false;   // Reset the flag
			}

			intialSpeed = 100;
		}
	}
}
