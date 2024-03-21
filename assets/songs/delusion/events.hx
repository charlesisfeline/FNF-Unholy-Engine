var bopOnBeat:Bool = false;
var bopOnOpponentHit:Bool = false;
var bopOnPlayerHit:Bool = false;
var bopMult:Float = 1.0;
function beatHit (beat) {
    switch (beat) {
        case 24:
            bopOnBeat = true;
        case 104:
            bopOnBeat = false;
        case 136:
            bopOnBeat = true;
        case 193:
            bopOnBeat = false;
        case 208:
            bopOnBeat = true;
            bopMult = 0.6;
        case 228:
            bopOnBeat = false;
        case 232:
            bopOnOpponentHit = true;
            bopMult = 0.4;
        case 248:
            bopOnOpponentHit = false;
            bopOnPlayerHit = true;
        case 264:
            bopOnPlayerHit = false;
        case 295:
            PlayState.camHUD.flash(FlxColor.RED, (Conductor.stepCrochet / 1000) * 1.1);
    }
    if (bopOnBeat)  bop();
    
}
function bop () {
    if (getPref('camera-zoom')) {
        PlayState.camGame.zoom += 0.015 * bopMult;
        PlayState.camHUD.zoom += 0.03 * bopMult;
    } 
}

function noteHit (note, isPlayer) {
    if (isPlayer && bopOnPlayerHit) bop();
    if (!isPlayer && bopOnOpponentHit) bop();

}
function goodNoteHit(note) noteHit(note, true);
function opponentNoteHit(note) noteHit(note, false); 
