package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseButton;


class PlayState extends FlxState
{
	// A class variable to represent the character in this
	// scene.
	private var _player:Player;
	private var _follower:Follower;
	private var _background:FlxSprite;
	private var weapon:FlxSprite;
	var startAttackAngle:Float;

	var isAttacking:Bool = false;
	var attackSpeed:Float = 760;
	var attackAngle:Float = 180;  // This is the angle by which you want to rotate the weapon when attacking


	override public function create()
	{
		// Create a new instance of the player at the point
		// (50, 50) on the screen.
		FlxG.camera.bgColor = 0xFFFFFFFF;

		_background = new FlxSprite(0, 0, "assets/images/image.png");
		add(_background); // Make sure to add this first, so it's rendered behind everything else

		_player = new Player(50, 50);
		// Add the player to the scene.

		_follower = new Follower(100, 100);  // Starting position of follower
		_follower.target = _player;          // Set the player as the target to follow
		weapon = new FlxSprite(_player.x, _player.y - 50, "assets/images/mufu_scythe.png");  // Initializing weapon above the player for this example
		weapon.scale.set(3, 3);

		add(_follower);
		add(_player);
		add(weapon);

		weapon.origin.set(weapon.width, weapon.height);


		super.create();
	}

	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	
		// Check for a single mouse click to start the attack
		if (FlxG.mouse.justPressed && !isAttacking)
		{
			isAttacking = true;
			
			// Store the current angle as the starting angle for the attack
			var startAttackAngle:Float = weapon.angle;
		}
	
		if (isAttacking)
		{
			// Rotate the weapon smoothly for the attack in the clockwise direction
			weapon.angle += attackSpeed * elapsed;
			
			// Stop the attack after reaching the desired angle (90-degree swing)
			if (Math.abs(weapon.angle + startAttackAngle) >= attackAngle)
			{
				isAttacking = false;
			}
		}
		else
		{
			// Update weapon position based on mouse and player
			updateWeaponPosition(FlxG.mouse.screenX, FlxG.mouse.screenY, _player, weapon);
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
		var distanceFromPlayer:Float = 50;  // Adjust this value based on your game's needs
		weapon.x = _player.x + distanceFromPlayer * Math.cos(theta) - weapon.origin.x + 18;
		weapon.y = _player.y + distanceFromPlayer * Math.sin(theta) - weapon.origin.y + 45;
	}	
}
