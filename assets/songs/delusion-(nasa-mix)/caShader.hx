var gameChrom:Float = 0;
var hudChrom:Float = 0;
var mult:Float = 1.2;
function createPost() {
    initShader("aberration", "chromAbbre", true);
    initShader("aberration", "chromAbb", true);
    setCameraShader(PlayState.camGame, "chromAbbre");
    setCameraShader(PlayState.camHUD, "chromAbb");
}
function updatePost (e) {
    gameChrom = FlxMath.lerp(gameChrom, 0, (e * 5));
    hudChrom = FlxMath.lerp(hudChrom, 0, (e * 5));
    setShaderFloat("chromAbbre", "aberrationAmount", gameChrom);
    setShaderFloat("chromAbb", "aberrationAmount", hudChrom);
}
function opponentNoteHit (note) {
    gameChrom += 0.0015 * mult;
    hudChrom += 0.00075 * mult;
}
function opponentSustainPress (note) {
    gameChrom += (0.0015 * mult * (FlxG.elapsed * 15));
    hudChrom += (0.00075 * mult * (FlxG.elapsed * 5));

}
function goodNoteHit (note) {
    gameChrom /= 1.125;
    hudChrom /= 1.00075;

}
function beatHit () {
    gameChrom += 0.003;
    hudChrom += 0.001;
}