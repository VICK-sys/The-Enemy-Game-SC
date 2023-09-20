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

	//Player and Opponent Variables
	private var _player:Player;
	private var enemy:Enemy;
	private var woodster:Woodster;
	private var likWid:LikWid;

	private var _background:FlxSprite;

	//Shadows for players
	private var _shadowPlayer:FlxSprite;
	private var _shadowPlayer2:FlxSprite;
	private var _shadowPlayer3:FlxSprite;
	private var _shadowPlayer4:FlxSprite;
	
	//scythe Variables
	private var scythe:FlxSprite;
	private var bow:FlxSprite;
	private var hammer:FlxSprite;
	private var hook:FlxSprite;
	private var weaponAttackAnim:FlxSprite;
	private var attacked:Bool = false;
	var recoilProcessed:Bool;

	//UI Variables
	private var barBackground:FlxSprite;
	private var playerIcon:FlxSprite;
	private var customCursor:FlxSprite;
	public var passiveRed:FlxSprite;
	public var passiveBlue:FlxSprite;
	public var activeBlue:FlxSprite;
	public var activeRed:FlxSprite;
	public var bar:FlxBar;
	public var barCardBlue:FlxBar;
	public var barCardRed:FlxBar;
	public var camUI:FlxCamera;

	//Damage Object For Testing
	private var redObject:FlxSprite;

	//Collision Variables
	private var enemyDamaged:Bool;
	private var attackSound:Bool = false;
	private var isAttacking:Bool = false;
	private var iframes:Bool = false;
	private var attackingSound:FlxSound;
	public var health:Float = 2;
	public var itemBar:Float = 2;
	public static var dead:Bool = false;

	//Variable For Hitbox Debugging
	private var sixNotPressed = true;

	//Tile Variables
	static inline var TILE_WIDTH:Int = 16;
	static inline var TILE_HEIGHT:Int = 16;
	private var _collisionMap:FlxTilemap;

	//Opponent Variables For Checking AI
	private var enemyTimer:Float = 0;
    private var woodsterTimer:Float = 0;
    private var likWidTimer:Float = 0;
    static inline var MAX_TIME:Float = 2.0; //Constants for the max time an entity will move in one direction. 2 seconds, for example.

	override public function create()
	{
		// Create a new instance of the player at the point
		// (50, 50) on the screen.

		//Making sure the camera color is clear
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

		scythe = new FlxSprite(_player.x, _player.y - 50, "assets/images/items/mufu_scythe.png");  // Initializing scythe above the player for this example
		scythe.scale.set(4, 4);

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

		//Setting Up Layering For Shadows
		add(_shadowPlayer4);
		add(_shadowPlayer2);
		add(_shadowPlayer3);
		add(_shadowPlayer);

		//Setting Up Layering For Player and Opponent
		add(enemy);
		add(woodster);
		add(likWid);
		add(_player);

		add(scythe);

		add(redObject);

		scythe.origin.set(scythe.width * 0.5, scythe.height);

		//Un-Manipulated HealthBar Texture
		barBackground = new FlxSprite(160, 670, "assets/images/ui/bar_red.png");
		barBackground.antialiasing = false;
		barBackground.scale.set(4, 4);
		barBackground.cameras = [camUI];

		activeBlue = new FlxSprite(160, 670, "assets/images/ui/active_blue.png");
		activeBlue.antialiasing = false;
		activeBlue.scale.set(4, 4);
		activeBlue.cameras = [camUI];

		activeRed = new FlxSprite(1060, 670, "assets/images/ui/active_red.png");
		activeRed.antialiasing = false;
		activeRed.scale.set(4, 4);
		activeRed.cameras = [camUI];

		passiveBlue = new FlxSprite(160, 670, "assets/images/ui/pasive_blue.png");
		passiveBlue.antialiasing = false;
		passiveBlue.scale.set(4, 4);
		passiveBlue.cameras = [camUI];

		passiveRed = new FlxSprite(1150, 670, "assets/images/ui/pasive_red.png");
		passiveRed.antialiasing = false;
		passiveRed.scale.set(4, 4);
		passiveRed.cameras = [camUI];

		//Manipulated HealthBar Texture
		bar = new FlxBar(barBackground.x, barBackground.y, LEFT_TO_RIGHT, Std.int(barBackground.width), Std.int(barBackground.height), this, 'health', 0, 2);
		bar.createImageBar("assets/images/ui/bar_main_empty.png", "assets/images/ui/bar_red.png", FlxColor.TRANSPARENT, FlxColor.TRANSPARENT);
		bar.updateBar();
		bar.antialiasing = false;
		bar.scale.set(4, 4);
		bar.cameras = [camUI];

		barCardBlue = new FlxBar(activeBlue.x, activeBlue.y, LEFT_TO_RIGHT, Std.int(activeBlue.width), Std.int(activeBlue.height), this, 'itemBar', 0, 2);
		barCardBlue.createImageBar("assets/images/ui/active_empty.png", "assets/images/ui/active_blue.png", FlxColor.TRANSPARENT, FlxColor.TRANSPARENT);
		barCardBlue.updateBar();
		barCardBlue.antialiasing = false;
		barCardBlue.scale.set(4, 4);
		barCardBlue.cameras = [camUI];

		barCardRed = new FlxBar(activeRed.x, activeRed.y, LEFT_TO_RIGHT, Std.int(activeRed.width), Std.int(activeRed.height), this, 'itemBar', 0, 2);
		barCardRed.createImageBar("assets/images/ui/active_empty.png", "assets/images/ui/active_red.png", FlxColor.TRANSPARENT, FlxColor.TRANSPARENT);
		barCardRed.updateBar();
		barCardRed.antialiasing = false;
		barCardRed.scale.set(4, 4);
		barCardRed.cameras = [camUI];

		playerIcon = new FlxSprite(barBackground.x - 120, barBackground.y, "assets/images/ui/mufu_icon.png");
		playerIcon.scale.set(4, 4);
		playerIcon.cameras = [camUI];



		add(barBackground);
		add(bar);

		add(activeRed);
		add(passiveRed);
		add(passiveRed);


		add(playerIcon);

		// Load the custom cursor graphic
		customCursor = new FlxSprite(0, 0, "assets/images/ui/mouse.png");
		customCursor.cameras = [camUI];

		// Scale the cursor to make it larger (e.g., 2 times its original size)
		customCursor.scale.set(4, 4);

		// Add the custom cursor to the state
		add(customCursor);

		FlxG.sound.playMusic("assets/music/stage/gloomDoomWoods.ogg", 0.3, true);

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
				var knockbackMagnitude = 300; // Adjust this to your needs
				var knockbackDirection = _player.x > redObject.x ? 1 : -1;
				_player.velocity.x = knockbackMagnitude * knockbackDirection;

				// Implementing knockback for y-axis
				var knockbackMagnitudeY = 300; // Adjust this to your needs
				var knockbackDirectionY = _player.y > redObject.y ? 1 : -1;
				_player.velocity.y = knockbackMagnitudeY * knockbackDirectionY;
		
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

		if (FlxG.keys.justPressed.ONE)//Rofel wanted these binds cuz his volume keys don't work
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

		if (FlxG.keys.justPressed.FIVE)//Kills Player
		{
			health = 0;
			itemBar = 0;
		}

		if (FlxG.keys.justPressed.SIX)//Shows Sprite Hitboxes
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
		
		if (FlxG.keys.justPressed.FOUR)//Revives player and gives full health
		{
			health = 2;
			itemBar = 2;
			dead = false;
			Player.blockMovement = false;
			_shadowPlayer.visible = true;
		}

		FlxG.mouse.visible = false;

		customCursor.setPosition(FlxG.mouse.screenX - 5, FlxG.mouse.screenY);

		updateWeaponPositionXY(_player, scythe);

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
		//Most likely going to refactor this similarly to how the player is damaged
		/*if (FlxG.overlap(weaponAttackAnim, enemy)) {
			//enemyDamaged = true;
		}	
		
		if(enemyDamaged == true)
		{
			//enemy.animation.play("hurt", false);

			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{	
				//enemyDamaged = false;
			});
		}*/

		// Update scythe position based on mouse and player
		if(!isAttacking)
		{
			updateWeaponPosition(FlxG.mouse.screenX, FlxG.mouse.screenY, _player, scythe);
			weaponAttackAnim.x = _player.x - 75;
			weaponAttackAnim.y = _player.y - 50;
		}
	
		// Check for a single mouse click to start the attack
		if (FlxG.mouse.justPressed && !isAttacking && !dead)//Big old player attacking if statement. I might refactor this into a function.
		{
			isAttacking = true;

			attacked = true;

			add(weaponAttackAnim);

			weaponAttackAnim.visible = true;
			FlxTween.tween(weaponAttackAnim, {x: FlxG.mouse.screenX, y: FlxG.mouse.screenY}, 0.3, {ease: FlxEase.quintOut}); //TODO: Fix the range of this cuz rn is just going to mouse position
			weaponAttackAnim.animation.play("swordAttack", false);
			weaponAttackAnim.angle = scythe.angle;

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
			
			scythe.angle += 120;

			if(_player.flipX == false && scythe.flipX == false)
				{
					scythe.flipX = true;
					if(recoilProcessed == true)
					{
						recoilProcessed = false;
					}
					else
					{
						recoilProcessed = true;
					}
				}
				else if(_player.flipX == false && scythe.flipX == true)
				{
					scythe.flipX = false;
					if(recoilProcessed == true)
					{
						recoilProcessed = false;
					}
					else
					{
						recoilProcessed = true;
					}
				}
			
			if(_player.flipX == true && scythe.flipX == false)
			{
				scythe.flipX = true;
				if(recoilProcessed == true)
				{
					recoilProcessed = false;
				}
				else
				{
					recoilProcessed = true;
				}
			}
			else if(_player.flipX == true && scythe.flipX == true)
			{
				scythe.flipX = false;
				if(recoilProcessed == true)
				{
					recoilProcessed = false;
				}
				else
				{
					recoilProcessed = true;
				}
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

		if(health <= 0 && !dead)//Plays death animation when player dies
		{
			_player.animation.play("death", false);
			dead = true;
		}

		if(health <= 0)//Makes sure you can't attack when you die
		{
			health = 0;
			_shadowPlayer.visible = false;
			remove(scythe);
			Player.blockMovement = true;
		}
	}	

	//Function to sort out entity layering based on hitbox y axis
	function orderEntitiesByY():Void {
		remove(_player);
		remove(enemy);
		remove(scythe);
		remove(woodster);
		remove(likWid);
	
		var entities:Array<Dynamic> = [_player, enemy, woodster, likWid];
		entities.sort(function(a, b) return a.y - b.y);
	
		for(entity in entities) {
			add(entity);
			if(entity == _player) {
				add(scythe);
			}
		}
	}
	
	//This function is weird. It works as intended, but when the player attacks, the angle of the scythe is supposed to change
	//to a relative down position. Instead, it tracks the current angle, and the scythe returns to its previous position after initiating.
	/*function updateWeaponPosition(mouseX:Float, mouseY:Float, _player:Player, scythe:FlxSprite):Void 
	{
		// Calculate the angle   
		var dy:Float = mouseY - _player.y;
		var dx:Float = mouseX - _player.x;
		var theta:Float = Math.atan2(dy, dx);
	
		// Set the scythe's rotation angle
		scythe.angle = theta * (180 / Math.PI);  // Convert the angle from radians to degrees

		weaponAttackAnim.angle = scythe.angle;
	
		// Position the scythe
		var distanceFromPlayer:Float = 0;  // Adjust this value based on your game's needs
		scythe.x = _player.x + distanceFromPlayer * Math.cos(theta) - scythe.origin.x + 30;
		scythe.y = _player.y + distanceFromPlayer * Math.sin(theta) - scythe.origin.y + 65;
	}*/

	var recoilAngle:Float = 0; // This variable is probably better as a member variable of the class

	function updateWeaponPosition(mouseX:Float, mouseY:Float, _player:Player, scythe:FlxSprite):Void 
	{
		// Calculate the angle   
		var dy:Float = mouseY - _player.y;
		var dx:Float = mouseX - _player.x;
		var theta:Float = Math.atan2(dy, dx);
		
		// Handle recoil
		// This rotation thing still needs some work
		// RecoilAngle should adjust when the player flips direction
		if (recoilProcessed && _player.flipX == true) 
		{ 
			recoilAngle = 180;
		}

		if (recoilProcessed && _player.flipX == false) 
		{ 
			recoilAngle = 130;
		}

		if (!recoilProcessed && _player.flipX == false) 
		{ 
			recoilAngle = 0;
		}

		if (!recoilProcessed && _player.flipX == true) 
		{ 
			recoilAngle = 0;
		}
			
		
		recoilAngle = MathHelper.Lerp(recoilAngle, 0, 0.1); // Gradually return the scythe back to its normal position. The value 0.1 determines the speed.

		// Set the scythe's rotation angle
		scythe.angle = (theta * (180 / Math.PI)) + recoilAngle;  // Convert the angle from radians to degrees and apply the recoil

		weaponAttackAnim.angle = scythe.angle;
		
		// Position the scythe
		var distanceFromPlayer:Float = 0;  // Adjust this value based on your game's needs
		scythe.x = _player.x + distanceFromPlayer * Math.cos(theta) - scythe.origin.x + 30;
		scythe.y = _player.y + distanceFromPlayer * Math.sin(theta) - scythe.origin.y + 65;
	}


	//Makes sure the scythe's X and Y position is still being tracked when the player is moving
	function updateWeaponPositionXY(_player:Player, scythe:FlxSprite):Void 
	{ 
		var distanceFromPlayer:Float = 0;  // Adjust this value based on your game's needs
		scythe.x = _player.x + distanceFromPlayer - scythe.origin.x + 30;
		scythe.y = _player.y + distanceFromPlayer - scythe.origin.y + 65;
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

	private function createFollower():Void //Creates Enemy Shadow Clones
	{
		var shadow = new FlxSprite(enemy.x + 10, enemy.y + 48, "assets/images/effects/shadow.png");
		shadow.scale.set(4, 4);
		add(shadow);

		// Instantiate the new follower object
		var enemy:Enemy = new Enemy(100, 100);
		enemy.target = _player;
		add(enemy);
	};
}
