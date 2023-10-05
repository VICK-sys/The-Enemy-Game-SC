import haxe.Http;

class MessageFetcher
{
	public static var isOnline:Bool;

    public static function isServerOnline(callback:Bool->Void):Void
    {
        var url = "http://127.0.0.1:5000/heartbeat";
        var request = new Http(url);
        
        request.onData = function(data:String) {
            var response = haxe.Json.parse(data);
            if (response.status == "online") {
                callback(true);
            } else {
                callback(false);
            }
        };
        
        request.onError = function(error:String) {
            trace("Error checking server status: " + error);
            callback(false);
        };
        
        request.request(true);
    }
        
        
    public static function fetchMessageFromServer():Void
    {
        var url = "http://127.0.0.1:5000/";
        var request = new Http(url);
        
        request.onData = function(data:String) {
            var messageObj = haxe.Json.parse(data);
            trace(messageObj.message);
        };
        
        request.onError = function(error:String) {
            trace("Error fetching message: " + error);
        };
        
        request.request();
    }
}
