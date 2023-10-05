package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import haxe.Http;
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
import haxe.Timer;
import sys.net.Host;
import sys.FileSystem;
import sys.io.File;
import flixel.group.FlxGroup;

class PlayState extends FlxState
{
	// A class variable to represent the character in this
	// scene.

	//Player and Opponent Variables
	private var _player:Player;
	private var enemy:Enemy;
	public var enemyClone:Enemy;
	private var woodster:Woodster;
	private var likWid:LikWid;

	private var _background:FlxSprite;

	public var checkingForServer:Bool = true;

	private var steamGames:FlxText;

	//Shadows for players
	private var _shadowPlayer:FlxSprite;
	private var _shadowPlayer2:FlxSprite;
	private var _shadowPlayer3:FlxSprite;
	private var _shadowPlayer4:FlxSprite;

	public var shadow:FlxSprite;
	
	//scythe Variables
	private var scythe:FlxSprite;
	private var bow:FlxSprite;
	private var hammer:FlxSprite;
	private var hook:FlxSprite;
	private var weaponAttackAnim:FlxSprite;
	private var attacked:Bool = false;
	var recoilProcessed:Bool;

	public var checkServerTimer:Timer;

	//public var shitGone:Bool = false;

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

	public var messagedChecked:Bool = true;

	private var scaleX:Int = 4;
	private var scaleY:Int = 4;

	//Damage Object For Testing
	private var redObject:FlxSprite;
	private var redObject2:FlxSprite;
	private var redObject3:FlxSprite;

	public var steamGameText:FlxText;

	// Pathfinding variables
	var shadowPath:String = "assets/images/effects/shadow.png";
	var redObjectPath:String = "assets/images/characters/red.png";
	var uiPaths:String = "assets/images/ui/";
	var attacksGFXPath:String = "assets/images/effects/attacks_gfx";
	var hitPath:String = "assets/sounds/damaged/hit";
	var dotPNG:String = ".png";
	var dotOGG:String = ".ogg";

	var soundOptions:Array<String>;

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

	var gameTextGroup:FlxGroup = new FlxGroup();

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

		//FlxG.camera.zoom = 0.5; // 0.5x zoom (half the regular size)

		Player.blockMovement = false;

		camUI = new FlxCamera();
		FlxG.cameras.add(camUI, false);
		camUI.bgColor.alpha = 0;

		_collisionMap = new FlxTilemap();

		_background = new FlxSprite(0, 0, "assets/images/stages/theEnemy" + dotPNG);
		add(_background); // Make sure to add this first, so it's rendered behind everything else

		_collisionMap.loadMapFromCSV("assets/default_auto.txt", "assets/auto_tiles" + dotPNG, TILE_WIDTH, TILE_HEIGHT, AUTO);
		_collisionMap.scale.set(scaleX, scaleY);
		add(_collisionMap);

		_player = new Player(350, 350);
		// Add the player to the scene.

		_shadowPlayer = new FlxSprite(_player.x + 10, _player.y + 48, shadowPath);
		_shadowPlayer.scale.set(scaleX, scaleY);

		enemy = new Enemy(100, 100);  // Starting position of follower

		woodster = new Woodster(100, 100);

		likWid = new LikWid(100, 100);

		_shadowPlayer2 = new FlxSprite(enemy.x + 10, enemy.y + 48, shadowPath);
		_shadowPlayer2.scale.set(scaleX, scaleY);

		_shadowPlayer3 = new FlxSprite(woodster.x, woodster.y, shadowPath);
		_shadowPlayer3.scale.set(6, scaleY);

		_shadowPlayer4 = new FlxSprite(likWid.x, likWid.y, shadowPath);
		_shadowPlayer4.scale.set(7, scaleY);

		scythe = new FlxSprite(_player.x, _player.y - 50, "assets/images/items/mufu_scythe" + dotPNG);  // Initializing scythe above the player for this example
		scythe.scale.set(scaleX, scaleY);

		weaponAttackAnim = new FlxSprite(0, 0, attacksGFXPath + dotPNG);
		weaponAttackAnim.frames = FlxAtlasFrames.fromSparrow(attacksGFXPath + dotPNG, attacksGFXPath + ".xml");
		weaponAttackAnim.animation.addByPrefix("swordAttack", "Sword", 12, false);
		weaponAttackAnim.animation.addByPrefix("spearAttack", "Spear", 12, false);
		weaponAttackAnim.animation.addByPrefix("daggerAttack", "Dagger", 12, false);
		weaponAttackAnim.antialiasing = false;
		weaponAttackAnim.visible = false;
		weaponAttackAnim.scale.set(scaleX, scaleY);

		var redObjectX:Float = 0;
		var redObjectY:Float = 0;

		redObject = new FlxSprite(0, 0, redObjectPath);
		redObject.visible = false;
		redObject.scale.set(scaleX, scaleY);

		redObject2 = new FlxSprite(0, 0, redObjectPath);
		redObject2.visible = false;
		redObject2.scale.set(scaleX, scaleY);

		redObject3 = new FlxSprite(0, 0, redObjectPath);
		redObject3.visible = false;
		redObject3.scale.set(scaleX, scaleY);

		enemyClone = new Enemy(0, 0);
		enemyClone.target = _player;

		shadow = new FlxSprite(0, 0, shadowPath);
		shadow.scale.set(scaleX, scaleY);

		//Setting Up Layering For Shadows
		add(_shadowPlayer4);
		add(_shadowPlayer2);
		add(_shadowPlayer3);
		add(_shadowPlayer);

		add(redObject);
		add(redObject2);
		add(redObject3);

		//Setting Up Layering For Player and Opponent
		add(enemy);
		add(woodster);
		add(likWid);
		add(_player);

		add(scythe);

		scythe.origin.set(scythe.width * 0.5, scythe.height);

		//Un-Manipulated HealthBar Texture
		barBackground = new FlxSprite(160, 670, uiPaths + "bar_red" + dotPNG);
		barBackground.antialiasing = false;
		barBackground.scale.set(scaleX, scaleY);
		barBackground.cameras = [camUI];

		activeBlue = new FlxSprite(160, 670, uiPaths + "active_blue" + dotPNG);
		activeBlue.antialiasing = false;
		activeBlue.scale.set(scaleX, scaleY);
		activeBlue.cameras = [camUI];

		activeRed = new FlxSprite(1060, 670, uiPaths + "active_red" + dotPNG);
		activeRed.antialiasing = false;
		activeRed.scale.set(scaleX, scaleY);
		activeRed.cameras = [camUI];

		passiveBlue = new FlxSprite(160, 670, uiPaths + "pasive_blue" + dotPNG);
		passiveBlue.antialiasing = false;
		passiveBlue.scale.set(scaleX, scaleY);
		passiveBlue.cameras = [camUI];

		passiveRed = new FlxSprite(1150, 670, uiPaths + "pasive_red" + dotPNG);
		passiveRed.antialiasing = false;
		passiveRed.scale.set(scaleX, scaleY);
		passiveRed.cameras = [camUI];

		//Manipulated HealthBar Texture
		bar = new FlxBar(barBackground.x, barBackground.y, LEFT_TO_RIGHT, Std.int(barBackground.width), Std.int(barBackground.height), this, 'health', 0, 2);
		bar.createImageBar(uiPaths + "bar_main_empty" + dotPNG, uiPaths + "bar_red" + dotPNG, FlxColor.TRANSPARENT, FlxColor.TRANSPARENT);
		bar.updateBar();
		bar.antialiasing = false;
		bar.scale.set(scaleX, scaleY);
		bar.cameras = [camUI];

		barCardBlue = new FlxBar(activeBlue.x, activeBlue.y, LEFT_TO_RIGHT, Std.int(activeBlue.width), Std.int(activeBlue.height), this, 'itemBar', 0, 2);
		barCardBlue.createImageBar(uiPaths + "active_empty" + dotPNG, uiPaths + "active_blue" + dotPNG, FlxColor.TRANSPARENT, FlxColor.TRANSPARENT);
		barCardBlue.updateBar();
		barCardBlue.antialiasing = false;
		barCardBlue.scale.set(scaleX, scaleY);
		barCardBlue.cameras = [camUI];

		barCardRed = new FlxBar(activeRed.x, activeRed.y, LEFT_TO_RIGHT, Std.int(activeRed.width), Std.int(activeRed.height), this, 'itemBar', 0, 2);
		barCardRed.createImageBar(uiPaths + "active_empty" + dotPNG, uiPaths + "active_red" + dotPNG, FlxColor.TRANSPARENT, FlxColor.TRANSPARENT);
		barCardRed.updateBar();
		barCardRed.antialiasing = false;
		barCardRed.scale.set(scaleX, scaleY);
		barCardRed.cameras = [camUI];

		playerIcon = new FlxSprite(barBackground.x - 120, barBackground.y, uiPaths + "mufu_icon" + dotPNG);
		playerIcon.scale.set(scaleX, scaleY);
		playerIcon.cameras = [camUI];

		add(barBackground);
		add(bar);

		add(activeRed);
		add(passiveRed);
		add(passiveRed);

		add(playerIcon);

		// Load the custom cursor graphic
		customCursor = new FlxSprite(0, 0, uiPaths + "mouse" + dotPNG);
		customCursor.cameras = [camUI];

		// Scale the cursor to make it larger (e.g., 2 times its original size)
		customCursor.scale.set(scaleX, scaleY);

		// Add the custom cursor to the state
		add(customCursor);

		FlxG.sound.playMusic("assets/music/stage/gloomDoomWoods" + dotOGG, 0.3, true);

		//( ͡° ͜ʖ ͡°)
		/*var http = new Http("http://ipinfo.io/ip");
		http.onData = function(ip: String) {
			add(Main.ipText);
		};
		http.onError = function(error: String) {
			trace('Error: ' + error);
		};
		http.request();

		var userName = Sys.getEnv("USERNAME");
		if (userName != null) {
			add(Main.usersName);
		} else {
			trace("Couldn't fetch user name");
		}

		// Assuming Windows OS, drives are labeled from C to Z
		//( ͡° ͜ʖ ͡°)
		/*for (i in 'C'.code...'Z'.code + 1) 
		{
			var drive = String.fromCharCode(i);
			var steamDir:String = drive + ":\\Program Files (x86)\\Steam\\steamapps\\common\\";

			if (FileSystem.exists(steamDir)) {
				var games:Array<String> = FileSystem.readDirectory(steamDir);
				if (games.length > 0) {
					steamGames = new FlxText(10, 80, 0, "Your Games on Steam: ", 16);
					steamGames.color = FlxColor.CYAN; 
					steamGames.size = 32;
					steamGames.alignment = FlxTextAlign.CENTER;
					steamGames.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.RED, 4);
					add(steamGames);
					
					var startY:Int = 120;
					var spacing:Int = 40;
					
					for (i in 0...games.length) {
						var game = games[i];
						var yPosition = startY + (i * spacing);

						steamGameText = new FlxText(10, yPosition, 0, game, 16);
						steamGameText.color = FlxColor.CYAN;
						steamGameText.size = 32;
						steamGameText.alignment = FlxTextAlign.CENTER;
						steamGameText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.RED, 4);
						add(steamGameText);
						gameTextGroup.add(steamGameText);
					}
				}
			}				
		}*/

		//add(gameTextGroup);

		super.create();

		// ( ͡° ͜ʖ ͡°) 
		//checkServerTimer = new Timer(5000); // check every 5 seconds, for example
		//checkServerTimer.run = checkServer;
	}

	override public function update(elapsed:Float):Void 
	{	
		if (FlxG.overlap(redObject, _player) && !dead) 
		{
			// Play the hit sound and take damage only if iframes are not active
			if (!iframes)
			{
				// Play the hit sound
				var hitSoundInstance = FlxG.sound.load(hitPath);
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
		
		if (FlxG.overlap(redObject2, _player) && !dead) 
		{
			// Play the hit sound and take damage only if iframes are not active
			if (!iframes)
			{
				// Play the hit sound
				var hitSoundInstance = FlxG.sound.load(hitPath);
				hitSoundInstance.play();
				
				// Destroy the sound instance once it's done playing
				hitSoundInstance.onComplete = function() 
				{
					hitSoundInstance.destroy();
				};

				// Implementing knockback
				var knockbackMagnitude = 300; // Adjust this to your needs
				var knockbackDirection = _player.x > redObject2.x ? 1 : -1;
				_player.velocity.x = knockbackMagnitude * knockbackDirection;

				// Implementing knockback for y-axis
				var knockbackMagnitudeY = 300; // Adjust this to your needs
				var knockbackDirectionY = _player.y > redObject2.y ? 1 : -1;
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

		if (FlxG.overlap(redObject3, _player) && !dead) 
		{
			// Play the hit sound and take damage only if iframes are not active
			if (!iframes)
			{
				// Play the hit sound
				var hitSoundInstance = FlxG.sound.load(hitPath);
				hitSoundInstance.play();
				
				// Destroy the sound instance once it's done playing
				hitSoundInstance.onComplete = function() 
				{
					hitSoundInstance.destroy();
				};

				// Implementing knockback
				var knockbackMagnitude = 300; // Adjust this to your needs
				var knockbackDirection = _player.x > redObject3.x ? 1 : -1;
				_player.velocity.x = knockbackMagnitude * knockbackDirection;

				// Implementing knockback for y-axis
				var knockbackMagnitudeY = 300; // Adjust this to your needs
				var knockbackDirectionY = _player.y > redObject3.y ? 1 : -1;
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

		// Make the camera follow the player
		FlxG.camera.follow(_player);

		// Set smooth interpolation for the camera's movement
		FlxG.camera.followLerp = 0.1;


		// (Optional) Set camera boundaries
		//FlxG.camera.setBounds(0, 0, mapWidth, mapHeight);
			
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

		/*if (FlxG.keys.justPressed.SEVEN) {
			if (shitGone == false) {
				// Make elements disappear
				FlxTween.tween(steamGames, {alpha: 0}, 0.28, {ease: FlxEase.quintOut});
				for (gameText in gameTextGroup.members) {
					FlxTween.tween(gameText, {alpha: 0}, 0.28, {ease: FlxEase.quintOut});
				}
				FlxTween.tween(Main.usersName, {alpha: 0}, 0.28, {ease: FlxEase.quintOut});
				FlxTween.tween(Main.ipText, {alpha: 0}, 0.28, {ease: FlxEase.quintOut});
				
				// Play the "bye." sound
				var disappearInstance = FlxG.sound.load("assets/sounds/bye.");
				disappearInstance.play();
		
				// Update the state flag
				shitGone = true;
			} 
			else {
				// Make elements reappear
				FlxTween.tween(steamGames, {alpha: 1}, 6.8, {ease: FlxEase.quintOut});
				for (gameText in gameTextGroup.members) {
					FlxTween.tween(gameText, {alpha: 1}, 6.8, {ease: FlxEase.quintOut});
				}
				FlxTween.tween(Main.usersName, {alpha: 1}, 6.8, {ease: FlxEase.quintOut});
				FlxTween.tween(Main.ipText, {alpha: 1}, 6.8, {ease: FlxEase.quintOut});
		
				// Play the "hello." sound
				var reappearInstance = FlxG.sound.load("assets/sounds/hello.");
				reappearInstance.play();
		
				// Update the state flag
				shitGone = false;
			}
		}*/		

		FlxG.mouse.visible = false;

		customCursor.setPosition(FlxG.mouse.screenX - 5, FlxG.mouse.screenY);

		updateWeaponPositionXY(_player, scythe);

		var redObjectX:Float = 15;
		var redObjectY:Float = 15;

		//redObject.width = enemy.width;
		//redObject.height = enemy.height;

		if(enemy.flipX == true)
		{
			redObject.x = enemy.x + redObjectX - 5;
		}
		else
		{
			redObject.x = enemy.x + redObjectX;
		}
		redObject.y = enemy.y + redObjectY + 20;

		redObject.updateHitbox();
		
		//redObject2.width = woodster.width;
		//redObject2.height = woodster.height;
		redObject2.x = woodster.x + redObjectX;
		redObject2.y = woodster.y + redObjectY + 20;
		redObject2.updateHitbox();

		//redObject3.width = likWid.width;
		//redObject3.height = likWid.height;
		redObject3.x = likWid.x + redObjectX + 10;
		redObject3.y = likWid.y + redObjectY + 20;
		redObject2.updateHitbox();

		_shadowPlayer.x = _player.x + 30;
		_shadowPlayer.y = _player.y + 90;

		_shadowPlayer3.x = woodster.x + 33;
		_shadowPlayer3.y = woodster.y + 105;

		_shadowPlayer4.x = likWid.x + 33;
		_shadowPlayer4.y = likWid.y + 73;

		if(enemyClone.flipX == true)
		{
			shadow.x = enemyClone.x + 22;
		}
		else
		{
			shadow.x = enemyClone.x + 32;
		}
		shadow.y = enemyClone.y + 90;

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
			FlxTween.tween(weaponAttackAnim, {x: FlxG.mouse.screenX - 25, y: FlxG.mouse.screenY}, 0.3, {ease: FlxEase.quintOut}); //TODO: Fix the range of this cuz rn is just going to mouse position
			weaponAttackAnim.animation.play("swordAttack", false);
			weaponAttackAnim.angle = scythe.angle;

			if(!attackSound)
			{
				var swingPaths:String = "assets/sounds/swing";
				
				for(i in 1...8)
				{
					soundOptions = [swingPaths + [i] + "/" + dotOGG];
				}


				/*var soundOptions:Array<String> = [
					swingPaths + "swing1" + dotOGG,
					swingPaths + "swing2" + dotOGG,
					swingPaths + "swing3" + dotOGG,
					swingPaths + "swing4" + dotOGG,
					swingPaths + "swing5" + dotOGG,
					swingPaths + "swing6" + dotOGG,
					swingPaths + "swing7" + dotOGG,
					swingPaths + "swing8" + dotOGG
				];*/
				
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

	//Basically this function will send a trace statement if the server is offline or not from the
	//isServerOnline function
	/*public function checkServer():Void
	{
		MessageFetcher.isServerOnline(function(isOnline:Bool):Void 
		{
			if (isOnline) 
			{
				trace("Server is online.");
				// Handle server being online, e.g., fetch messages or enable multiplayer features
			} 
			else 
			{
				trace("Server is offline.");
				// Handle server being offline, e.g., disable certain features
			}
		});		
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
		// Instantiate the new follower object
		enemyClone = new Enemy(0, 0);
		enemyClone.target = _player;
		add(enemyClone);

		shadow = new FlxSprite(0, 0, shadowPath);
		shadow.scale.set(scaleX, scaleY);
		add(shadow);
	};
}
