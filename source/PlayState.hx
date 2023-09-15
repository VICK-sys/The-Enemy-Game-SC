package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseButton;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;


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
	var startAttackAngle:Float;
	private var attackingSound:FlxSound;
	var attackSound:Bool = false;

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

		_shadowPlayer = new FlxSprite(_player.x + 10, _player.y + 48, "assets/images/shadow.png");
		_shadowPlayer.scale.set(4, 4);

		_follower = new Follower(100, 100);  // Starting position of follower
		_follower.target = _player;          // Set the player as the target to follow

		_shadowPlayer2 = new FlxSprite(_follower.x + 10, _follower.y + 48, "assets/images/shadow.png");
		_shadowPlayer2.scale.set(4, 4);

		weapon = new FlxSprite(_player.x, _player.y - 50, "assets/images/mufu_scythe.png");  // Initializing weapon above the player for this example
		weapon.scale.set(4, 4);

		add(_shadowPlayer2);
		add(_follower);
		add(_shadowPlayer);
		add(_player);
		add(weapon);

		weapon.origin.set(weapon.width * 0.5, weapon.height);

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

		// Update weapon position based on mouse and player
		if(!isAttacking)
		{
			updateWeaponPosition(FlxG.mouse.screenX, FlxG.mouse.screenY, _player, weapon);
		}
	
		// Check for a single mouse click to start the attack
		if (FlxG.mouse.justPressed && !isAttacking)
		{
			isAttacking = true;

			if(!attackSound)
			{
				var soundOptions:Array<String> = [
					"assets/sounds/swing1.ogg",
					"assets/sounds/swing2.ogg",
					"assets/sounds/swing3.ogg",
					"assets/sounds/swing4.ogg",
					"assets/sounds/swing5.ogg",
					"assets/sounds/swing6.ogg",
					"assets/sounds/swing7.ogg",
					"assets/sounds/swing8.ogg"
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

			new FlxTimer().start(0.15, function(tmr:FlxTimer)
			{
				isAttacking = false;
			});
		}
		else
		{
			if(attackSound)
			{
				attackingSound.stop();  // Stop the walking sound
				attackSound = false;   // Reset the flag
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
