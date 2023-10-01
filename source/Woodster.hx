package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import flixel.FlxG;

enum StateWoodster {
	Wandering;
	Following;
	Attacking;
}

class Woodster extends FlxSprite
{
    static inline var SPEED:Float = 300;
    public var target:Player;
    static inline var AGGRO_RANGE:Float = 200;
    static inline var STOP_THRESHOLD:Float = 170;
    static inline var ATTACK_RANGE:Float = 150;

	var idleTimer:FlxTimer = new FlxTimer();
	static inline var IDLE_DURATION:Float = 3.0;  // 3 seconds for idle duration

	var wanderSpeed:Float = 100 + FlxG.random.float() * 20;  // Define a random speed for wandering between 100 and 120.

	var wanderDirection:FlxPoint = new FlxPoint(FlxG.random.float() * 2 - 1, FlxG.random.float() * 2 - 1);
	var wanderTimer:FlxTimer = new FlxTimer();
	static inline var WANDER_DURATION:Float = 2.0;  // 2 seconds for now, adjust as needed

	private var stopAttacking:Bool;

	var currentState:StateWoodster = Wandering;

    public function new(x:Float=0, y:Float=0)
    {
        super(x, y);
        // Load a graphic for the Enemies (change this to your AI's image)
		this.loadGraphic("assets/images/enemies/woodster.png", true, 20, 23);
		this.frames = FlxAtlasFrames.fromSparrow("assets/images/enemies/woodster.png", "assets/images/enemies/woodster.xml");
		this.animation.addByPrefix("idle", "Idle", 12, true);
		this.animation.addByPrefix("walk", "Walk", 12, true);
		this.animation.addByPrefix("sstart", "Shoot start", 12, false);
		this.animation.addByPrefix("sloop", "Shoot loop", 12, false);
		this.animation.addByPrefix("send", "Shoot end", 12, false);
		this.animation.addByPrefix("hurt", "Hurt", 12, false);
		this.animation.addByPrefix("death", "Death.", 12, false);
		this.antialiasing = false;
		this.width = 75;
		this.height = 105;
		this.offset.set(-23, 9);
		this.scale.set(4, 4);
    }

    override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (target == null) return;

		var targetMid:FlxPoint = target.getMidpoint();
		var enemyMid:FlxPoint = this.getMidpoint();
		var dir:FlxPoint = new FlxPoint(targetMid.x - enemyMid.x, targetMid.y - enemyMid.y);
		var distance:Float = Math.sqrt(dir.x * dir.x + dir.y * dir.y);

		// FSM Logic
		switch (currentState)
		{
			case Wandering:
				if (!wanderTimer.active && !idleTimer.active)
				{
					// Start wandering
					velocity.set(wanderDirection.x * wanderSpeed, wanderDirection.y * wanderSpeed);

					if (wanderDirection.x > 0) { this.flipX = false; }
					else if (wanderDirection.x < 0) { this.flipX = true; }

					this.animation.play("walk");
					wanderTimer.start(WANDER_DURATION, function(timer) {
						// Stop and go to idle state when wandering completes
						velocity.set(0, 0);
						this.animation.play("idle");
						idleTimer.start(IDLE_DURATION, function(idleTime) {
							// Choose a new wander direction after idle completes
							wanderDirection.set(FlxG.random.float() * 2 - 1, FlxG.random.float() * 2 - 1);
							var length:Float = Math.sqrt(wanderDirection.x * wanderDirection.x + wanderDirection.y * wanderDirection.y);
							if (length != 0)
							{
								wanderDirection.x /= length;
								wanderDirection.y /= length;
							}
	
							// Set the enemy's velocity based on the adjusted wanderDirection.
							velocity.set(wanderDirection.x * wanderSpeed, wanderDirection.y * wanderSpeed);
							this.animation.play("walk");
						});
					});
				}

				if (distance <= AGGRO_RANGE)
				{
					currentState = Following;
					idleTimer.cancel();
					wanderTimer.cancel(); // Stop the wandering timer when transitioning to another state
				}
			case Following:
				if (distance <= ATTACK_RANGE)
				{
					currentState = Attacking;
				}
				else if (distance > AGGRO_RANGE)
				{
					currentState = Wandering;
				}
				else
				{
					// Following logic as before
					if (dir.x > 0) { this.flipX = false; }
					else if (dir.x < 0) { this.flipX = true; }

					if (distance <= STOP_THRESHOLD)
					{
						velocity.set(0, 0);
						this.animation.play("idle");
					}
					else
					{
						var length:Float = Math.sqrt(dir.x * dir.x + dir.y * dir.y);
						if (length != 0)
						{
							dir.x /= length;
							dir.y /= length;
						}
						velocity.set(dir.x * SPEED, dir.y * SPEED);
						this.animation.play("walk");
					}
				}
			case Attacking:
				// Logic for attacking
				// ... (e.g., play attack animation, deal damage)
				velocity.set(0, 0);
				if(!stopAttacking)
				{
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						attack();
					});
				}
				stopAttacking = false;
				if (distance > ATTACK_RANGE)
				{
					currentState = Following;
					stopAttacking = true;
				}
		}
	}	

	private function attack():Void
	{
		this.animation.play("sstart");
		var sstartDuration:Float = this.animation.getByName("sstart").frames.length;
		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			this.animation.play("sloop");
			var sloopDuration:Float = this.animation.getByName("sloop").frames.length;
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				this.animation.play("send");
				var sendDuration:Float = this.animation.getByName("send").frames.length;
				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
					if(!stopAttacking)
					{
						this.attack();  // Call attack again to loop the sequence
					}
				});
			});
		});
	}	
}
