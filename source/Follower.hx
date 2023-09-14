package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;

class Follower extends FlxSprite
{
    static inline var SPEED:Float = 200;
    public var target:Player;
	static inline var STOP_THRESHOLD:Float = 70;
	

    public function new(x:Float=0, y:Float=0)
    {
        super(x, y);
        // Load a graphic for the Follower (change this to your AI's image)
		this.loadGraphic("assets/images/enemy.png", true, 20, 23);
		this.frames = FlxAtlasFrames.fromSparrow("assets/images/enemy.png", "assets/images/mufu.xml");
		this.animation.addByPrefix("idle", "Idle", 12, true);
		this.animation.addByPrefix("walk", "Run", 12, true);
		this.animation.addByPrefix("hurt", "Hurt", 12, true);
		this.animation.addByPrefix("death", "Death", 12, true);
		this.antialiasing = false;
		this.scale.set(3, 3);
    }

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	
		if (target == null) return;  // Ensure we have a target to follow
	
		var targetMid:FlxPoint = target.getMidpoint();
		var followerMid:FlxPoint = this.getMidpoint();
		var dir:FlxPoint = new FlxPoint(targetMid.x - followerMid.x, targetMid.y - followerMid.y);
	
		// Check the direction and set flipX accordingly
		if (dir.x > 0)
		{
			this.flipX = false;  // Player is to the right of the follower
		}
		else if (dir.x < 0)
		{
			this.flipX = true;   // Player is to the left of the follower
		}
	
		// Calculate the distance between Follower and Player
		var distance:Float = Math.sqrt(dir.x * dir.x + dir.y * dir.y);
	
		// Check if the distance is less than the threshold
		if (distance <= STOP_THRESHOLD)
		{
			// Stop the Follower
			velocity.set(0, 0);
			this.animation.play("idle");
		}
		else
		{
			// Normalize the direction to get a unit vector
			var length:Float = Math.sqrt(dir.x * dir.x + dir.y * dir.y);
			// Only normalize if the length is not zero (to avoid dividing by zero)
			if (length != 0)
			{
				dir.x /= length;
				dir.y /= length;
			}
	
			// Set the velocity based on direction and speed
			velocity.set(dir.x * SPEED, dir.y * SPEED);
	
			// Play walk animation
			this.animation.play("walk");
		}
	}	
}
