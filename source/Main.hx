package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import openfl.display.FPS;
import flixel.text.FlxText;
import sys.net.Host;
import flixel.util.FlxColor;
import haxe.Http;
import sys.FileSystem;
import sys.io.File;

class Main extends Sprite
{
	public static var counter:FPS;

	public static var usersName:FlxText;
	public static var ipText:FlxText;

	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, TitleSequence));
		counter = new FPS(10, 3, 0xFFFFFF);
		addChild(counter);

		//( ͡° ͜ʖ ͡°)
		/*var http = new Http("http://ipinfo.io/ip");
		http.onData = function(ip: String) {
			ipText = new FlxText(10, 10, 0, ip + " ;)", 16);
			ipText.color = FlxColor.CYAN; // set the color to cyan
			ipText.size = 32; // set the text's size to 32px
			ipText.alignment = FlxTextAlign.CENTER; // center the text
			ipText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.RED, 4); // give the text a 4-pixel deep, blue shadow
		};
		http.onError = function(error: String) {
			trace('Error: ' + error);
		};
		http.request();

		var userName = Sys.getEnv("USERNAME");
		if (userName != null) {
			usersName = new FlxText(10, 40, 0, userName, 16);
			usersName.color = FlxColor.CYAN; // set the color to cyan
			usersName.size = 32; // set the text's size to 32px
			usersName.alignment = FlxTextAlign.CENTER; // center the text
			usersName.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.RED, 4); // give the text a 4-pixel deep, blue shadow
		} else {
			trace("Couldn't fetch user name");
		}*/
	}
}
