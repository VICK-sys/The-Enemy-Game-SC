package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import flixel.FlxG;

//Enumerator that handles Behavior states
enum State {
	Wandering;
	Following;
	Attacking;
}

class Enemies extends FlxSprite
{
    static inline var SPEED:Float = 300;
    static inline var AGGRO_RANGE:Float = 200;
    static inline var STOP_THRESHOLD:Float = 170;
    static inline var ATTACK_RANGE:Float = 150;
	static inline var IDLE_DURATION:Float = 3.0;  // 3 seconds for idle duration
	static inline var WANDER_DURATION:Float = 2.0;  // 2 seconds for now, adjust as needed

	public static var enemyMovement:Bool = true;

	private var animations:Array<String> = ["sstart", "sloop", "send"];
	private var currentAnimationIndex:Int = 0;

	private var stopAttacking:Bool;
	private var idleTimer:FlxTimer = new FlxTimer();
	private var wanderSpeed:Float = 100 + FlxG.random.float() * 20;  // Define a random speed for wandering between 100 and 120.
	private var wanderDirection:FlxPoint = new FlxPoint(FlxG.random.float() * 2 - 1, FlxG.random.float() * 2 - 1);
	private var wanderTimer:FlxTimer = new FlxTimer();
	private var currentState:State = Wandering;

	public var target:Player;

    public function new(x:Float=0, y:Float=0)
    {
        super(x, y);

		this.antialiasing = false;
		this.width = 75;
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

	/*private function attack():Void
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
	}*/	

	private function attack():Void {
		playNextAnimation();
	}

	private function playNextAnimation():Void {
		if (currentAnimationIndex >= animations.length) {
			if (!stopAttacking) {
				currentAnimationIndex = 0; // Reset index to loop the sequence
			} else {
				return; // Stop if we're told to stop attacking
			}
		}
		
		var animationName:String = animations[currentAnimationIndex];
		this.animation.play(animationName);
		
		// You can use the duration if needed. For now, we'll just move on to the next animation after a fixed delay.
		// var duration:Float = this.animation.getByName(animationName).frames.length;
	
		currentAnimationIndex++;
		
		new FlxTimer().start(0.2, function(tmr:FlxTimer) {
			playNextAnimation();
		});
	}
}
