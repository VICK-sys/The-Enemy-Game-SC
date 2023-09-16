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

	private var _follower:Follower;

	private var _background:FlxSprite;
	private var _shadowPlayer:FlxSprite;
	private var _shadowPlayer2:FlxSprite;
	private var weapon:FlxSprite;
	private var weaponAttackAnim:FlxSprite;
	private var barBackground:FlxSprite;
	private var playerIcon:FlxSprite;
	private var redObject:FlxSprite;

	private var enemyDamaged:Bool;
	private var attackSound:Bool = false;
	var isAttacking:Bool = false;
	
	private var dead:Bool;


	static inline var TILE_WIDTH:Int = 16;
	static inline var TILE_HEIGHT:Int = 16;
	private var startAttackAngle:Float;
	public var health:Float = 2;
	var attackSpeed:Float = 760;
	var attackAngle:Float = 180;  // This is the angle by which you want to rotate the weapon when attacking

	private var attackingSound:FlxSound;

	var _collisionMap:FlxTilemap;

	public var bar:FlxBar;

	public var camUI:FlxCamera;

	private var customCursor:FlxSprite;

	override public function create()
	{
		// Create a new instance of the player at the point
		// (50, 50) on the screen.
		FlxG.camera.bgColor = 0xFFFFFFFF;

		FlxG.debugger.drawDebug = true;

		camUI = new FlxCamera();
		FlxG.cameras.add(camUI, false);
		camUI.bgColor.alpha = 0;

		_collisionMap = new FlxTilemap();

		_background = new FlxSprite(0, 0, "assets/images/stages/theEnemy.png");
		add(_background); // Make sure to add this first, so it's rendered behind everything else

		_collisionMap.loadMapFromCSV("assets/default_auto.txt", "assets/auto_tiles.png", TILE_WIDTH, TILE_HEIGHT, AUTO);
		_collisionMap.scale.set(4, 4);
		add(_collisionMap);

		_player = new Player(350, 350);
		// Add the player to the scene.

		_shadowPlayer = new FlxSprite(_player.x + 10, _player.y + 48, "assets/images/effects/shadow.png");
		_shadowPlayer.scale.set(4, 4);

		_follower = new Follower(100, 100);  // Starting position of follower
		_follower.target = _player;          // Set the player as the target to follow

		_shadowPlayer2 = new FlxSprite(_follower.x + 10, _follower.y + 48, "assets/images/effects/shadow.png");
		_shadowPlayer2.scale.set(4, 4);

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

		add(_shadowPlayer2);
		add(_shadowPlayer);
		add(_follower);
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

		super.create();
	}

	override public function update(elapsed:Float):Void 
	{	
		super.update(elapsed);

		// Check for collision between _player and _follower
		//FlxG.overlap(_player, _follower, onPlayerFollowerOverlap);

		FlxG.mouse.visible = false;

		customCursor.setPosition(FlxG.mouse.screenX - 5, FlxG.mouse.screenY);

		updateWeaponPositionXY(_player, weapon);

		weaponAttackAnim.updateHitbox();
		redObject.updateHitbox();
		_player.updateHitbox();
		_follower.updateHitbox();

		_shadowPlayer.x = _player.x + 57;
		_shadowPlayer.y = _player.y + 122;

		//weaponAttackAnim.origin.x = weapon.origin.x + 20;
		//weaponAttackAnim.origin.y = weapon.origin.y - 30;

		if(_follower.flipX == true)
		{
			_shadowPlayer2.x = _follower.x + 52;
		}
		else
		{
			_shadowPlayer2.x = _follower.x + 62;
		}
		_shadowPlayer2.y = _follower.y + 122;

		orderEntitiesByY();

		//Not working properly, gonna leave it commented out
		/*if (FlxG.overlap(weaponAttackAnim, _follower)) {
			enemyDamaged = true;
		}	
		
		if(enemyDamaged == true)
		{
			//_follower.animation.play("hurt", false);

			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{	
				enemyDamaged = false;
			});
		}*/

		if (FlxG.overlap(redObject, _player)) {
			health -= 0.025;
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

		if(health <= 0)
			{
				health = 0;
				_player.animation.play("death");//The Animation is not playing in full for whatever reason
				remove(_shadowPlayer);
				remove(weapon);
				dead = true;
			}
	}	

	function orderEntitiesByY():Void {
		remove(_player);
		remove(_follower);
		remove(weapon);
	
		if (_player.y < _follower.y) {
			add(_player);
			add(weapon);
			add(_follower);
		} else {
			add(_follower);
			add(_player);
			add(weapon);
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
		weapon.x = _player.x + distanceFromPlayer * Math.cos(theta) - weapon.origin.x + 67;
		weapon.y = _player.y + distanceFromPlayer * Math.sin(theta) - weapon.origin.y + 105;
	}

	function updateWeaponPositionXY(_player:Player, weapon:FlxSprite):Void 
	{ 
		var distanceFromPlayer:Float = 0;  // Adjust this value based on your game's needs
		weapon.x = _player.x + distanceFromPlayer /** Math.cos(theta)*/ - weapon.origin.x + 67;
		weapon.y = _player.y + distanceFromPlayer /** Math.cos(theta)*/ - weapon.origin.y + 105;
	}

	function onPlayerFollowerOverlap(_player:Player, _follower:Follower):Void 
	{
		// Handle the collision here. For example, you can stop the follower or make the player take damage.
		// This is just an example, you can customize the behavior as needed.
		trace("Overlap detected!");
		_follower.velocity.x = 0;
		_follower.velocity.y = 0;
		_player.velocity.x = 0;
		_player.velocity.y = 0;
	
		// If you want the player to take damage or any other action, add that logic here.
	}
		
		
}
