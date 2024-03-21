var drain:Float = 0.1; // trust
var mult:Float = 4; // The bigger the smaller
function opponentNoteHit (note) {
    if (!PlayState.boyfriend.iconSpr.isDying) {
        PlayState.health -= (drain * (PlayState.health / mult));
    }
}
function opponentSustainPress (note) {
    if (!PlayState.boyfriend.iconSpr.isDying) {
        PlayState.health -= (drain * (PlayState.health / mult)) * FlxG.elapsed;
    }
}
