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
import flixel.tile.FlxTilemap;


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

	static inline var TILE_WIDTH:Int = 16;
	static inline var TILE_HEIGHT:Int = 16;

	private var startAttackAngle:Float;
	private var attackingSound:FlxSound;
	private var attackSound:Bool = false;

	var isAttacking:Bool = false;
	var attackSpeed:Float = 760;
	var attackAngle:Float = 180;  // This is the angle by which you want to rotate the weapon when attacking

	var _collisionMap:FlxTilemap;

	override public function create()
	{
		// Create a new instance of the player at the point
		// (50, 50) on the screen.
		FlxG.camera.bgColor = 0xFFFFFFFF;

		_collisionMap = new FlxTilemap();

		_background = new FlxSprite(0, 0, "assets/images/stages/theEnemy.png");
		add(_background); // Make sure to add this first, so it's rendered behind everything else

		_collisionMap.loadMapFromCSV("assets/default_auto.txt", "assets/auto_tiles.png", TILE_WIDTH, TILE_HEIGHT, AUTO);
		_collisionMap.scale.set(4, 4);
		add(_collisionMap);

		_player = new Player(50, 50);
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
		weaponAttackAnim.animation.addByPrefix("speakAttack", "Spear", 12, false);
		weaponAttackAnim.antialiasing = false;
		weaponAttackAnim.visible = false;
		weaponAttackAnim.scale.set(4, 4);

		add(_shadowPlayer2);
		add(_shadowPlayer);
		add(_follower);
		add(_player);
		add(weapon);
		add(weaponAttackAnim);

		weapon.origin.set(weapon.width * 0.5, weapon.height);

		FlxG.sound.playMusic("assets/music/stage/gloomDoomWoods.ogg", 0.3, true);

		super.create();
	}

	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);

		updateWeaponPositionXY(_player, weapon);

		_shadowPlayer.x = _player.x + 10;
		_shadowPlayer.y = _player.y + 72;

		_shadowPlayer2.x = _follower.x + 10;
		_shadowPlayer2.y = _follower.y + 72;

		weaponAttackAnim.x = weapon.x + 25;
		weaponAttackAnim.y = weapon.y + 25;

		// Update weapon position based on mouse and player
		if(!isAttacking)
		{
			updateWeaponPosition(FlxG.mouse.screenX, FlxG.mouse.screenY, _player, weapon);
		}
	
		// Check for a single mouse click to start the attack
		if (FlxG.mouse.justPressed && !isAttacking)
		{
			isAttacking = true;

			weaponAttackAnim.visible = true;
			weaponAttackAnim.animation.play("swordAttack", false);

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

			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				weaponAttackAnim.visible = false;
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
	}	
	
	function updateWeaponPosition(mouseX:Float, mouseY:Float, _player:Player, weapon:FlxSprite):Void 
	{
		// Calculate the angle   
		var dy:Float = mouseY - _player.y;
		var dx:Float = mouseX - _player.x;
		var theta:Float = Math.atan2(dy, dx);
	
		// Set the weapon's rotation angle
		weapon.angle = theta * (180 / Math.PI);  // Convert the angle from radians to degrees
	
		// Position the weapon
		var distanceFromPlayer:Float = 0;  // Adjust this value based on your game's needs
		weapon.x = _player.x + distanceFromPlayer * Math.cos(theta) - weapon.origin.x + 17;
		weapon.y = _player.y + distanceFromPlayer * Math.sin(theta) - weapon.origin.y + 45;
	}

	function updateWeaponPositionXY(_player:Player, weapon:FlxSprite):Void 
	{ 
		var distanceFromPlayer:Float = 0;  // Adjust this value based on your game's needs
		weapon.x = _player.x + distanceFromPlayer /** Math.cos(theta)*/ - weapon.origin.x + 17;
		weapon.y = _player.y + distanceFromPlayer /** Math.cos(theta)*/ - weapon.origin.y + 45;
	}
		
}
