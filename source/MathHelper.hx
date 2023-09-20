package;

class MathHelper {
    public static function Lerp(a:Float, b:Float, t:Float):Float {
        return a + t * (b - a);
    }
}
