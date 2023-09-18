package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseButton;
import flixel.util.FlxTimer;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;	
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxBar;
import flixel.FlxCamera;


class PlayState extends FlxState
{
	// A class variable to represent the character in this
	// scene.
	private var _player:Player;

	private var enemy:Enemy;

	private var woodster:Woodster;

	private var likWid:LikWid;

	private var _background:FlxSprite;
	private var _shadowPlayer:FlxSprite;
	private var _shadowPlayer2:FlxSprite;
	private var _shadowPlayer3:FlxSprite;
	private var _shadowPlayer4:FlxSprite;
	private var weapon:FlxSprite;
	private var weaponAttackAnim:FlxSprite;
	private var barBackground:FlxSprite;
	private var playerIcon:FlxSprite;
	private var redObject:FlxSprite;

	private var gotHit:Bool = false;

	private var enemyDamaged:Bool;
	private var attackSound:Bool = false;
	var isAttacking:Bool = false;

	private var sixNotPressed = true;
	
	public static var dead:Bool = false;

	private var iframes:Bool = false;

	var isCurrentlyOverlapping:Bool = false;

    var enemyTimer:Float = 0;
    var woodsterTimer:Float = 0;
    var likWidTimer:Float = 0;

	static inline var TILE_WIDTH:Int = 16;
	static inline var TILE_HEIGHT:Int = 16;
	private var startAttackAngle:Float;
	public var health:Float = 2;
	var attackSpeed:Float = 760;
	var attackAngle:Float = 180;  // This is the angle by which you want to rotate the weapon when attacking

	    // Constants for the max time an entity will move in one direction
    static inline var MAX_TIME:Float = 2.0; // 2 seconds, for example

	private var attackingSound:FlxSound;

	public var gotHitSound:FlxSound;

	var _collisionMap:FlxTilemap;

	public var bar:FlxBar;

	public var camUI:FlxCamera;

	private var customCursor:FlxSprite;

	override public function create()
	{
		// Create a new instance of the player at the point
		// (50, 50) on the screen.
		FlxG.camera.bgColor = 0xFFFFFFFF;

		Player.blockMovement = false;

		camUI = new FlxCamera();
		FlxG.cameras.add(camUI, false);
		camUI.bgColor.alpha = 0;

		_collisionMap = new FlxTilemap();

		_background = new FlxSprite(0, 0, "assets/images/stages/theEnemy.png");
		add(_background); // Make sure to add this first, so it's rendered behind everything else

		_collisionMap.loadMapFromCSV("assets/default_auto.txt", "assets/auto_tiles.png", TILE_WIDTH, TILE_HEIGHT, AUTO);
		_collisionMap.scale.set(4, 4);
		//add(_collisionMap);

		_player = new Player(350, 350);
		// Add the player to the scene.

		_shadowPlayer = new FlxSprite(_player.x + 10, _player.y + 48, "assets/images/effects/shadow.png");
		_shadowPlayer.scale.set(4, 4);

		enemy = new Enemy(100, 100);  // Starting position of follower

		woodster = new Woodster(100, 100);

		likWid = new LikWid(100, 100);

		_shadowPlayer2 = new FlxSprite(enemy.x + 10, enemy.y + 48, "assets/images/effects/shadow.png");
		_shadowPlayer2.scale.set(4, 4);

		_shadowPlayer3 = new FlxSprite(woodster.x, woodster.y, "assets/images/effects/shadow.png");
		_shadowPlayer3.scale.set(6, 4);

		_shadowPlayer4 = new FlxSprite(likWid.x, likWid.y, "assets/images/effects/shadow.png");
		_shadowPlayer4.scale.set(7, 4);

		weapon = new FlxSprite(_player.x, _player.y - 50, "assets/images/items/mufu_scythe.png");  // Initializing weapon above the player for this example
		weapon.scale.set(4, 4);

		weaponAttackAnim = new FlxSprite(0, 0, "assets/images/effects/attacks_gfx.png");
		weaponAttackAnim.frames = FlxAtlasFrames.fromSparrow("assets/images/effects/attacks_gfx.png", "assets/images/effects/attacks_gfx.xml");
		weaponAttackAnim.animation.addByPrefix("swordAttack", "Sword", 12, false);
		weaponAttackAnim.animation.addByPrefix("spearAttack", "Spear", 12, false);
		weaponAttackAnim.animation.addByPrefix("daggerAttack", "Dagger", 12, false);
		weaponAttackAnim.antialiasing = false;
		weaponAttackAnim.visible = false;
		weaponAttackAnim.scale.set(4, 4);

		redObject = new FlxSprite(300, 300, "assets/images/characters/red.png");
		redObject.scale.set(4, 4);

		add(_shadowPlayer4);
		add(_shadowPlayer3);
		add(_shadowPlayer2);
		add(_shadowPlayer);
		add(enemy);
		add(woodster);
		add(likWid);
		add(_player);
		add(weapon);


		add(redObject);

		weapon.origin.set(weapon.width * 0.5, weapon.height);

		//weaponAttackAnim.origin.set(weapon.width / 2, weapon.height / 2);

		barBackground = new FlxSprite(160, 670, "assets/images/ui/bar_red.png");
		barBackground.antialiasing = false;
		barBackground.scale.set(4, 4);
		barBackground.cameras = [camUI];

		bar = new FlxBar(barBackground.x, barBackground.y, LEFT_TO_RIGHT, Std.int(barBackground.width), Std.int(barBackground.height), this, 'health', 0, 2);
		bar.createImageBar("assets/images/ui/bar_main_empty.png", "assets/images/ui/bar_red.png", FlxColor.TRANSPARENT, FlxColor.TRANSPARENT);
		bar.updateBar();
		bar.antialiasing = false;
		bar.scale.set(4, 4);
		bar.cameras = [camUI];

		playerIcon = new FlxSprite(barBackground.x - 120, barBackground.y, "assets/images/ui/mufu_icon.png");
		playerIcon.scale.set(4, 4);
		playerIcon.cameras = [camUI];

		add(barBackground);
		add(bar);

		add(playerIcon);

		// Load the custom cursor graphic
		customCursor = new FlxSprite(0, 0, "assets/images/ui/mouse.png");
		customCursor.cameras = [camUI];

		// Scale the cursor to make it larger (e.g., 2 times its original size)
		customCursor.scale.set(4, 4);

		// Add the custom cursor to the state
		add(customCursor);

		FlxG.sound.playMusic("assets/music/stage/gloomDoomWoods.ogg", 0.3, true);

		gotHitSound = FlxG.sound.load("assets/sounds/damaged/hit.ogg");

		super.create();
	}

	override public function update(elapsed:Float):Void 
	{	
		if (FlxG.overlap(redObject, _player) && !dead) 
		{
			// Play the hit sound and take damage only if iframes are not active
			if (!iframes)
			{
				// Play the hit sound
				var hitSoundInstance = FlxG.sound.load("assets/sounds/damaged/hit.ogg");
				hitSoundInstance.play();
				
				// Destroy the sound instance once it's done playing
				hitSoundInstance.onComplete = function() 
				{
					hitSoundInstance.destroy();
				};

				// Implementing knockback
				var knockbackMagnitude = 500; // Adjust this to your needs
				var knockbackDirection = _player.x > redObject.x ? 1 : -1;
				_player.velocity.x = knockbackMagnitude * knockbackDirection;

				// Implementing knockback for y-axis
				var knockbackMagnitudeY = 500; // Adjust this to your needs
				var knockbackDirectionY = _player.y > redObject.y ? 1 : -1;
				_player.velocity.y = knockbackMagnitudeY * knockbackDirectionY;
				
				// You might also want to introduce a slight vertical knockback for better feel
				//_player.velocity.y = -20; // This will give a small vertical "jump" feel
		
				// Handle health reduction and animations
				health -= 0.25;
				_player.animation.play("hurt", false);
				Player.blockMovement = true;
		
				iframes = true; // Set invulnerability
		
				// Reset iframes after a short duration (e.g., 0.4 seconds)
				new FlxTimer().start(0.4, function(tmr:FlxTimer)
				{
					iframes = false;
				});
		
				// Allow movement after a short duration (e.g., 0.1 seconds)
				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					if(!dead)
					{
						Player.blockMovement = false;
					}
				});
			}
		}			
			
		super.update(elapsed);

        enemyTimer -= elapsed;
        woodsterTimer -= elapsed;
        likWidTimer -= elapsed;

		if(!dead)
		{
			enemy.target = _player;          // Set the player as the target to follow
			woodster.target = _player;
			likWid.target = _player;
		}
		else
		{
			if (enemyTimer <= 0) {
				setRandomVelocity(enemy);
				enemyTimer = Math.random() * MAX_TIME;
			}
	
			if (woodsterTimer <= 0) {
				setRandomVelocity(woodster);
				woodsterTimer = Math.random() * MAX_TIME;
			}
	
			if (likWidTimer <= 0) {
				setRandomVelocity(likWid);
				likWidTimer = Math.random() * MAX_TIME;
			}
		}

		// Check for collision between _player and enemy
		//FlxG.overlap(_player, enemy, onPlayerFollowerOverlap);

		if (FlxG.keys.justPressed.ONE)
		{
			decreaseVolume();
		}

		if (FlxG.keys.justPressed.TWO)
		{
			increaseVolume();
		}

		if (FlxG.keys.justPressed.THREE)
		{
			createFollower();
		}

		if (FlxG.keys.justPressed.FIVE)
		{
			health = 0;
		}

		if (FlxG.keys.justPressed.SIX)
		{
			if (sixNotPressed)
			{
				FlxG.debugger.drawDebug = !FlxG.debugger.drawDebug;  // Toggle the drawDebug state
				sixNotPressed = false;
			}
			else
			{
				sixNotPressed = true;
			}
		}
		
		if (FlxG.keys.justPressed.FOUR)
		{
			health = 2;
			dead = false;
			Player.blockMovement = false;
			_shadowPlayer.visible = true;
		}

		FlxG.mouse.visible = false;

		customCursor.setPosition(FlxG.mouse.screenX - 5, FlxG.mouse.screenY);

		updateWeaponPositionXY(_player, weapon);

		redObject.updateHitbox();


		_shadowPlayer.x = _player.x + 30;
		_shadowPlayer.y = _player.y + 90;

		_shadowPlayer3.x = woodster.x + 33;
		_shadowPlayer3.y = woodster.y + 105;

		_shadowPlayer4.x = likWid.x + 33;
		_shadowPlayer4.y = likWid.y + 73;

		if(enemy.flipX == true)
		{
			_shadowPlayer2.x = enemy.x + 22;
		}
		else
		{
			_shadowPlayer2.x = enemy.x + 32;
		}
		_shadowPlayer2.y = enemy.y + 90;

		orderEntitiesByY();

		//Not working properly, gonna leave it commented out
		if (FlxG.overlap(weaponAttackAnim, enemy)) {
			//enemyDamaged = true;
		}	
		
		if(enemyDamaged == true)
		{
			//enemy.animation.play("hurt", false);

			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{	
				//enemyDamaged = false;
			});
		}

		// Update weapon position based on mouse and player
		if(!isAttacking)
		{
			updateWeaponPosition(FlxG.mouse.screenX, FlxG.mouse.screenY, _player, weapon);
			weaponAttackAnim.x = _player.x - 75;
			weaponAttackAnim.y = _player.y - 50;
		}
	
		// Check for a single mouse click to start the attack
		if (FlxG.mouse.justPressed && !isAttacking && !dead)
		{
			isAttacking = true;

			// Parameters: Intensity of the shake (0 to 1), Duration of the shake in seconds
			//FlxG.camera.shake(0.005, 0.5);

			add(weaponAttackAnim);

			weaponAttackAnim.visible = true;
			FlxTween.tween(weaponAttackAnim, {x: FlxG.mouse.screenX, y: FlxG.mouse.screenY}, 0.3, {ease: FlxEase.quintOut}); //TODO: Fix the range of this cuz rn is just going to mouse position
			weaponAttackAnim.animation.play("swordAttack", false);
			weaponAttackAnim.angle = weapon.angle;

			if(!attackSound)
			{
				var soundOptions:Array<String> = [
					"assets/sounds/swing/swing1.ogg",
					"assets/sounds/swing/swing2.ogg",
					"assets/sounds/swing/swing3.ogg",
					"assets/sounds/swing/swing4.ogg",
					"assets/sounds/swing/swing5.ogg",
					"assets/sounds/swing/swing6.ogg",
					"assets/sounds/swing/swing7.ogg",
					"assets/sounds/swing/swing8.ogg"
				];
				
				var randomSound:String = soundOptions[Std.random(soundOptions.length)];
				
				attackingSound = FlxG.sound.load(randomSound);
				attackingSound.looped = true;  // Make the sound loop continuously
				attackingSound.play();
				attackSound = true;
			}
			
			// Store the current angle as the starting angle for the attack
			//var startAttackAngle:Float = weapon.angle;
			
			weapon.angle += 120;

			if(weapon.flipX == true)
			{
				weapon.flipX = false;
			}
			else
			{
				weapon.flipX = true;
			}

			new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				weaponAttackAnim.visible = false;
				remove(weaponAttackAnim);
				isAttacking = false;
			});
		}
		else
		{
			if(attackSound)
			{
				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					attackingSound.stop();  // Stop the attacking sound
					attackSound = false;   // Reset the flag
				});
			}
		}

		if(health <= 0 && !dead)
		{
			_player.animation.play("death", false);//The Animation is not playing in full for whatever reason
			dead = true;
		}

		if(health <= 0)
		{
			health = 0;
			_shadowPlayer.visible = false;
			remove(weapon);
			Player.blockMovement = true;
		}
	}	

	//I'll have to tweak this function since its not working 100%
	function orderEntitiesByY():Void {
		remove(_player);
		remove(enemy);
		remove(weapon);
		remove(woodster);
		remove(likWid);
	
		var entities:Array<Dynamic> = [_player, enemy, woodster, likWid];
		entities.sort(function(a, b) return a.y - b.y);
	
		for(entity in entities) {
			if(entity == _player) {
				add(weapon);
			}
			add(entity);
		}
	}
	
	function updateWeaponPosition(mouseX:Float, mouseY:Float, _player:Player, weapon:FlxSprite):Void 
	{
		// Calculate the angle   
		var dy:Float = mouseY - _player.y;
		var dx:Float = mouseX - _player.x;
		var theta:Float = Math.atan2(dy, dx);
	
		// Set the weapon's rotation angle
		weapon.angle = theta * (180 / Math.PI);  // Convert the angle from radians to degrees

		weaponAttackAnim.angle = weapon.angle;
	
		// Position the weapon
		var distanceFromPlayer:Float = 0;  // Adjust this value based on your game's needs
		weapon.x = _player.x + distanceFromPlayer * Math.cos(theta) - weapon.origin.x + 30;
		weapon.y = _player.y + distanceFromPlayer * Math.sin(theta) - weapon.origin.y + 65;
	}

	function updateWeaponPositionXY(_player:Player, weapon:FlxSprite):Void 
	{ 
		var distanceFromPlayer:Float = 0;  // Adjust this value based on your game's needs
		weapon.x = _player.x + distanceFromPlayer /** Math.cos(theta)*/ - weapon.origin.x + 30;
		weapon.y = _player.y + distanceFromPlayer /** Math.cos(theta)*/ - weapon.origin.y + 65;
	}

	function onPlayerFollowerOverlap(_player:Player, enemy:Enemy):Void 
	{
		// Handle the collision here. For example, you can stop the follower or make the player take damage.
		// This is just an example, you can customize the behavior as needed.
		trace("Overlap detected!");
		enemy.velocity.x = 0;
		enemy.velocity.y = 0;
		_player.velocity.x = 0;
		_player.velocity.y = 0;
	
		// If you want the player to take damage or any other action, add that logic here.
	}

    function increaseVolume():Void {
        FlxG.sound.changeVolume(0.1);
    }

    function decreaseVolume():Void {
        FlxG.sound.changeVolume(-0.1);
    }	

    function setRandomVelocity(entity:FlxSprite):Void {
        entity.velocity.x = Math.random() * 200 - 100;
        entity.velocity.y = Math.random() * 200 - 100;
    }

	private function createFollower():Void
	{
		// Instantiate the new follower object
		var enemy:Enemy = new Enemy(100, 100);
		enemy.target = _player;
		add(enemy);
	};
}
